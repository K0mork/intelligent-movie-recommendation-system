import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { ReviewAnalysisService } from './services/reviewAnalysis';
import { RecommendationEngine } from './services/recommendationEngine';
import { MovieDataUtils } from './services/movieDataUtils';
import { logger } from 'firebase-functions/v2';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

// Firebase Admin SDK を初期化
admin.initializeApp();

// Cloud Firestore のインスタンス
const db = admin.firestore();

// Gemini API の初期化
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_AI_API_KEY || '');

// レビュー分析サービスのインスタンス
const reviewAnalysisService = new ReviewAnalysisService();

// 推薦エンジンのインスタンス
const recommendationEngine = new RecommendationEngine();

// 映画データユーティリティのインスタンス
const movieDataUtils = new MovieDataUtils();

/**
 * レビュー分析用のHTTPS関数
 * レビューのセンチメント分析と映画推薦を行う
 */
export const analyzeReview = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { reviewText, movieTitle, rating } = data;

    if (!reviewText || !movieTitle || rating === undefined) {
      throw new functions.https.HttpsError('invalid-argument', '必要なパラメータが不足しています。');
    }

    // Gemini APIを使用してレビューを分析
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
    
    const prompt = `
映画レビューを分析してください：

映画タイトル: ${movieTitle}
評価: ${rating}/5
レビュー内容: ${reviewText}

以下の項目について分析し、JSON形式で回答してください：
1. sentiment: ポジティブ(positive)、ネガティブ(negative)、ニュートラル(neutral)のいずれか
2. genres: このレビューから推測される好みのジャンル（配列）
3. themes: 映画のテーマや要素への言及（配列）
4. recommendations: 類似した映画のおすすめ（最大5作品、理由付き）

JSON形式のみで回答してください。
`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const analysisText = response.text();

    let analysis;
    try {
      analysis = JSON.parse(analysisText);
    } catch (error) {
      console.error('JSON解析エラー:', error);
      throw new functions.https.HttpsError('internal', 'レビュー分析の処理中にエラーが発生しました。');
    }

    // 分析結果をFirestoreに保存
    const reviewAnalysis = {
      userId: context.auth.uid,
      movieTitle,
      rating,
      reviewText,
      analysis,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = await db.collection('reviewAnalyses').add(reviewAnalysis);

    return {
      analysisId: docRef.id,
      analysis,
      success: true,
    };

  } catch (error) {
    console.error('レビュー分析エラー:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', 'レビュー分析の処理中にエラーが発生しました。');
  }
});

/**
 * ユーザーの推薦映画を取得するHTTPS関数
 */
export const getRecommendations = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;

    // ユーザーの過去の分析データを取得
    const analysesSnapshot = await db
      .collection('reviewAnalyses')
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(10)
      .get();

    if (analysesSnapshot.empty) {
      return {
        recommendations: [],
        message: 'まだレビューがありません。映画をレビューして推薦を受け取りましょう！',
      };
    }

    // 分析データから傾向を抽出
    const analyses = analysesSnapshot.docs.map(doc => doc.data());
    const genresPreference = new Map();
    const themesPreference = new Map();

    analyses.forEach(analysis => {
      const { genres, themes } = analysis.analysis;
      
      genres?.forEach((genre: string) => {
        genresPreference.set(genre, (genresPreference.get(genre) || 0) + 1);
      });
      
      themes?.forEach((theme: string) => {
        themesPreference.set(theme, (themesPreference.get(theme) || 0) + 1);
      });
    });

    // 上位の好みを抽出
    const topGenres = Array.from(genresPreference.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([genre]) => genre);

    const topThemes = Array.from(themesPreference.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([theme]) => theme);

    // Gemini APIを使用して個人化された推薦を生成
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
    
    const prompt = `
以下のユーザーの映画の好みに基づいて、個人化された映画推薦を作成してください：

好みのジャンル: ${topGenres.join(', ')}
好きなテーマ: ${topThemes.join(', ')}

過去のレビューした映画:
${analyses.map(a => `- ${a.movieTitle} (評価: ${a.rating}/5)`).join('\n')}

以下の形式のJSON配列で10作品の映画を推薦してください：
[
  {
    "title": "映画タイトル",
    "year": "公開年",
    "genre": "主要ジャンル",
    "reason": "なぜこの映画をおすすめするかの理由",
    "matchScore": 推薦度（1-10の数値）
  }
]

JSON配列のみで回答してください。
`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const recommendationsText = response.text();

    let recommendations;
    try {
      recommendations = JSON.parse(recommendationsText);
    } catch (error) {
      console.error('JSON解析エラー:', error);
      throw new functions.https.HttpsError('internal', '推薦生成の処理中にエラーが発生しました。');
    }

    // 推薦結果をFirestoreに保存
    await db.collection('userRecommendations').doc(userId).set({
      recommendations,
      preferences: {
        topGenres,
        topThemes,
      },
      generatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      recommendations,
      preferences: {
        topGenres,
        topThemes,
      },
      success: true,
    };

  } catch (error) {
    console.error('推薦生成エラー:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', '推薦生成の処理中にエラーが発生しました。');
  }
});

/**
 * 新しいレビュー感情分析関数
 * ReviewAnalysisServiceを使用した高度な分析
 */
export const analyzeReviewWithService = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { reviewId, reviewText, movieId, movieTitle } = data;
    const userId = context.auth.uid;

    if (!reviewId || !reviewText || !movieId || !movieTitle) {
      throw new functions.https.HttpsError('invalid-argument', '必要なパラメータが不足しています。');
    }

    logger.info('Starting review analysis with service', { reviewId, userId, movieId });

    // レビュー分析サービスを使用して総合分析を実行
    const analysisResult = await reviewAnalysisService.analyzeReview(
      reviewId,
      userId,
      movieId,
      reviewText,
      movieTitle
    );

    // 結果をFirestoreに保存
    await reviewAnalysisService.saveAnalysisResult(analysisResult);

    logger.info('Review analysis completed successfully', { reviewId });

    return {
      success: true,
      analysisResult: {
        reviewId: analysisResult.reviewId,
        sentiment: analysisResult.sentiment,
        preferences: analysisResult.preferences,
        confidence: analysisResult.confidence,
        analyzedAt: analysisResult.analyzedAt.toISOString()
      }
    };

  } catch (error: any) {
    logger.error('Review analysis with service failed', { error: error?.message });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `レビュー分析中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * レビュー分析結果を取得する関数
 */
export const getReviewAnalysis = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { reviewId } = data;

    if (!reviewId) {
      throw new functions.https.HttpsError('invalid-argument', 'レビューIDが必要です。');
    }

    const analysisResult = await reviewAnalysisService.getAnalysisResult(reviewId);

    if (!analysisResult) {
      throw new functions.https.HttpsError('not-found', '指定されたレビューの分析結果が見つかりません。');
    }

    return {
      success: true,
      analysisResult: {
        ...analysisResult,
        analyzedAt: analysisResult.analyzedAt.toISOString()
      }
    };

  } catch (error: any) {
    logger.error('Failed to get review analysis', { error: error?.message });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `分析結果の取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * ユーザーの好み履歴を取得する関数
 */
export const getUserPreferences = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;
    const preferences = await reviewAnalysisService.getUserPreferences(userId);

    return {
      success: true,
      preferences: preferences || null
    };

  } catch (error: any) {
    logger.error('Failed to get user preferences', { error: error?.message });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `ユーザー好み履歴の取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * Firestoreトリガー: レビューが作成されたときに自動分析を実行
 */
export const onReviewCreated = onDocumentCreated('reviews/{reviewId}', async (event) => {
  try {
    const reviewId = event.params.reviewId;
    const reviewData = event.data?.data();

    if (!reviewData) {
      logger.warn('Review data not found', { reviewId });
      return;
    }

    logger.info('Review created, starting automatic analysis', { reviewId });

    // レビューデータの検証
    if (!reviewData.userId || !reviewData.movieId || !reviewData.reviewText || !reviewData.movieTitle) {
      logger.warn('Review data incomplete, skipping analysis', { reviewId });
      return;
    }

    // 自動分析を実行
    const analysisResult = await reviewAnalysisService.analyzeReview(
      reviewId,
      reviewData.userId,
      reviewData.movieId,
      reviewData.reviewText,
      reviewData.movieTitle
    );

    // 結果を保存
    await reviewAnalysisService.saveAnalysisResult(analysisResult);

    logger.info('Automatic review analysis completed', { reviewId });

  } catch (error: any) {
    logger.error('Automatic review analysis failed', { 
      reviewId: event.params.reviewId, 
      error: error?.message 
    });
    // 自動分析の失敗は致命的ではないため、エラーを投げない
  }
});

/**
 * 推薦エンジンを使用した高度な映画推薦機能
 */
export const generatePersonalizedRecommendations = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;
    const { maxRecommendations = 10, contentWeight = 0.7, collaborativeWeight = 0.3, diversityBoost = true } = data;

    logger.info('Starting personalized recommendation generation', { userId });

    // 推薦設定
    const config = {
      maxRecommendations,
      contentWeight,
      collaborativeWeight,
      diversityBoost,
      minConfidence: 0.3
    };

    // 推薦エンジンを使用して推薦を生成
    const recommendations = await recommendationEngine.generateRecommendations(userId, config);

    logger.info('Personalized recommendations generated successfully', { 
      userId, 
      recommendationCount: recommendations.length 
    });

    return {
      success: true,
      recommendations: recommendations.map(rec => ({
        movieId: rec.movieId,
        movie: rec.movie,
        score: rec.score,
        reasons: rec.reasons,
        recommendationType: rec.recommendationType,
        confidence: rec.confidence
      })),
      config,
      generatedAt: new Date().toISOString()
    };

  } catch (error: any) {
    logger.error('Personalized recommendation generation failed', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `推薦生成中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 保存された推薦結果を取得する機能
 */
export const getSavedRecommendations = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;
    const savedRecommendations = await recommendationEngine.getSavedRecommendations(userId);

    return {
      success: true,
      recommendations: savedRecommendations,
      count: savedRecommendations.length
    };

  } catch (error: any) {
    logger.error('Failed to get saved recommendations', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    throw new functions.https.HttpsError('internal', `保存された推薦の取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 推薦結果に対するフィードバックを記録する機能
 */
export const recordRecommendationFeedback = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;
    const { movieId, feedback } = data;

    if (!movieId || !feedback) {
      throw new functions.https.HttpsError('invalid-argument', 'movieIdとfeedbackが必要です。');
    }

    if (!['like', 'dislike', 'not_interested'].includes(feedback)) {
      throw new functions.https.HttpsError('invalid-argument', 'feedbackは like, dislike, not_interested のいずれかである必要があります。');
    }

    await recommendationEngine.recordRecommendationFeedback(userId, movieId, feedback);

    return {
      success: true,
      message: 'フィードバックが記録されました。'
    };

  } catch (error: any) {
    logger.error('Failed to record recommendation feedback', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `フィードバック記録中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * ユーザープロファイルを取得する機能
 */
export const getUserProfile = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;
    const userProfile = await recommendationEngine.getUserProfile(userId);

    if (!userProfile) {
      return {
        success: true,
        profile: null,
        message: 'ユーザープロファイルが見つかりません。映画をレビューしてプロファイルを作成してください。'
      };
    }

    return {
      success: true,
      profile: {
        userId: userProfile.userId,
        preferences: userProfile.preferences,
        sentimentHistory: userProfile.sentimentHistory,
        reviewCount: userProfile.reviewCount,
        lastUpdated: userProfile.lastUpdated.toISOString()
      }
    };

  } catch (error: any) {
    logger.error('Failed to get user profile', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    throw new functions.https.HttpsError('internal', `ユーザープロファイル取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 推薦システムの統計情報を取得する機能（管理者用）
 */
export const getRecommendationStats = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    // 管理者権限チェック（実装に応じて調整）
    const userId = context.auth.uid;
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();
    
    if (!userData?.isAdmin) {
      throw new functions.https.HttpsError('permission-denied', '管理者権限が必要です。');
    }

    // 統計情報を収集
    const reviewAnalysisCount = await db.collection('reviewAnalysis').count().get();
    const userPreferencesCount = await db.collection('userPreferences').count().get();
    const recommendationFeedbackCount = await db.collection('recommendationFeedback').count().get();
    const userRecommendationsCount = await db.collection('userRecommendations').count().get();

    return {
      success: true,
      stats: {
        totalReviewAnalyses: reviewAnalysisCount.data().count,
        totalUserProfiles: userPreferencesCount.data().count,
        totalRecommendationFeedbacks: recommendationFeedbackCount.data().count,
        totalUserRecommendations: userRecommendationsCount.data().count,
        timestamp: new Date().toISOString()
      }
    };

  } catch (error: any) {
    logger.error('Failed to get recommendation stats', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `統計情報取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * サンプル映画データを初期化する機能（管理者用）
 */
export const initializeSampleMovies = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    // 管理者権限チェック（実装に応じて調整）
    const userId = context.auth.uid;
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();
    
    if (!userData?.isAdmin) {
      throw new functions.https.HttpsError('permission-denied', '管理者権限が必要です。');
    }

    await movieDataUtils.initializeSampleMovies();

    return {
      success: true,
      message: 'サンプル映画データが初期化されました。'
    };

  } catch (error: any) {
    logger.error('Failed to initialize sample movies', { error: error?.message });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `サンプルデータ初期化中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 映画を検索する機能
 */
export const searchMovies = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { query, limit = 20 } = data;

    if (!query) {
      throw new functions.https.HttpsError('invalid-argument', '検索クエリが必要です。');
    }

    const movies = await movieDataUtils.searchMovies(query, limit);

    return {
      success: true,
      movies,
      count: movies.length
    };

  } catch (error: any) {
    logger.error('Failed to search movies', { error: error?.message });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `映画検索中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 人気映画を取得する機能
 */
export const getPopularMovies = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { limit = 20 } = data;
    const movies = await movieDataUtils.getPopularMovies(limit);

    return {
      success: true,
      movies,
      count: movies.length
    };

  } catch (error: any) {
    logger.error('Failed to get popular movies', { error: error?.message });
    
    throw new functions.https.HttpsError('internal', `人気映画取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * ジャンル別映画を取得する機能
 */
export const getMoviesByGenre = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { genre, limit = 20 } = data;

    if (!genre) {
      throw new functions.https.HttpsError('invalid-argument', 'ジャンルが必要です。');
    }

    const movies = await movieDataUtils.getMoviesByGenre(genre, limit);

    return {
      success: true,
      movies,
      genre,
      count: movies.length
    };

  } catch (error: any) {
    logger.error('Failed to get movies by genre', { error: error?.message });
    
    throw new functions.https.HttpsError('internal', `ジャンル別映画取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 映画の詳細情報を取得する機能
 */
export const getMovieDetails = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { movieId } = data;

    if (!movieId) {
      throw new functions.https.HttpsError('invalid-argument', '映画IDが必要です。');
    }

    const movie = await movieDataUtils.getMovie(movieId);

    if (!movie) {
      throw new functions.https.HttpsError('not-found', '指定された映画が見つかりません。');
    }

    return {
      success: true,
      movie
    };

  } catch (error: any) {
    logger.error('Failed to get movie details', { error: error?.message });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `映画詳細取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 映画データの統計情報を取得する機能
 */
export const getMovieStats = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const stats = await movieDataUtils.getMovieStats();

    return {
      success: true,
      stats
    };

  } catch (error: any) {
    logger.error('Failed to get movie stats', { error: error?.message });
    
    throw new functions.https.HttpsError('internal', `映画統計取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 健康チェック用のHTTPS関数
 */
export const healthCheck = functions.https.onRequest((req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    message: 'Movie Recommendation Functions are running',
    services: {
      reviewAnalysis: 'Available',
      recommendationEngine: 'Available',
      movieDataUtils: 'Available',
      geminiAPI: process.env.GEMINI_API_KEY ? 'Configured' : 'Not configured'
    }
  });
});