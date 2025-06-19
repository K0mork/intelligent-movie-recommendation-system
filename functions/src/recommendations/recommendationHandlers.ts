import * as functions from 'firebase-functions';
import { logger } from 'firebase-functions/v2';
import { RecommendationEngine } from '../services/recommendationEngine';

// 推薦エンジンのインスタンス
const recommendationEngine = new RecommendationEngine();

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
    const { 
      maxRecommendations = 10, 
      contentWeight = 0.7, 
      collaborativeWeight = 0.3, 
      diversityBoost = true,
      minConfidence = 0.3,
      excludeWatched = true,
    } = data;

    logger.info('Starting personalized recommendation generation', { userId });

    // 推薦設定
    const config = {
      maxRecommendations,
      contentWeight,
      collaborativeWeight,
      diversityBoost,
      minConfidence,
      excludeWatched,
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
    const { includeExpired = false, limit = 50 } = data;

    logger.info('Getting saved recommendations', { userId, includeExpired, limit });

    const savedRecommendations = await recommendationEngine.getSavedRecommendations(
      userId, 
      { includeExpired, limit }
    );

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
    const { movieId, feedback, recommendationId, reason } = data;

    if (!movieId || !feedback) {
      throw new functions.https.HttpsError('invalid-argument', 'movieIdとfeedbackが必要です。');
    }

    if (!['like', 'dislike', 'not_interested', 'watched', 'bookmark'].includes(feedback)) {
      throw new functions.https.HttpsError('invalid-argument', 'feedbackは有効な値である必要があります。');
    }

    logger.info('Recording recommendation feedback', { userId, movieId, feedback });

    await recommendationEngine.recordRecommendationFeedback(
      userId, 
      movieId, 
      feedback, 
      { recommendationId, reason }
    );

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
 * ユーザー向けの推薦設定を更新する機能
 */
export const updateRecommendationSettings = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;
    const { 
      preferredGenres, 
      excludedGenres, 
      preferredYearRange, 
      diversityPreference,
      noveltyPreference,
      notificationSettings,
    } = data;

    logger.info('Updating recommendation settings', { userId });

    const settings = {
      preferredGenres: preferredGenres || [],
      excludedGenres: excludedGenres || [],
      preferredYearRange: preferredYearRange || { min: 1900, max: new Date().getFullYear() },
      diversityPreference: diversityPreference || 0.5,
      noveltyPreference: noveltyPreference || 0.5,
      notificationSettings: notificationSettings || {
        newRecommendations: true,
        weeklyDigest: false,
        monthlyReport: false,
      },
      updatedAt: new Date(),
    };

    await recommendationEngine.updateUserSettings(userId, settings);

    return {
      success: true,
      settings,
      message: '推薦設定が更新されました。'
    };

  } catch (error: any) {
    logger.error('Failed to update recommendation settings', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    throw new functions.https.HttpsError('internal', `推薦設定更新中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 推薦の説明を取得する機能
 */
export const getRecommendationExplanation = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;
    const { movieId, recommendationId } = data;

    if (!movieId) {
      throw new functions.https.HttpsError('invalid-argument', 'movieIdが必要です。');
    }

    logger.info('Getting recommendation explanation', { userId, movieId });

    const explanation = await recommendationEngine.getRecommendationExplanation(
      userId, 
      movieId, 
      recommendationId
    );

    return {
      success: true,
      explanation,
    };

  } catch (error: any) {
    logger.error('Failed to get recommendation explanation', { 
      userId: context.auth?.uid,
      movieId: data?.movieId,
      error: error?.message 
    });
    
    throw new functions.https.HttpsError('internal', `推薦説明取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 類似ユーザーの推薦を取得する機能
 */
export const getSimilarUserRecommendations = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;
    const { limit = 20, minSimilarity = 0.3 } = data;

    logger.info('Getting similar user recommendations', { userId, limit, minSimilarity });

    const recommendations = await recommendationEngine.getSimilarUserRecommendations(
      userId, 
      { limit, minSimilarity }
    );

    return {
      success: true,
      recommendations,
      count: recommendations.length,
    };

  } catch (error: any) {
    logger.error('Failed to get similar user recommendations', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    throw new functions.https.HttpsError('internal', `類似ユーザー推薦取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * トレンド映画の推薦を取得する機能
 */
export const getTrendingRecommendations = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;
    const { timeWindow = 'week', limit = 20, personalizeWeight = 0.3 } = data;

    logger.info('Getting trending recommendations', { userId, timeWindow, limit });

    const recommendations = await recommendationEngine.getTrendingRecommendations(
      userId,
      { timeWindow, limit, personalizeWeight }
    );

    return {
      success: true,
      recommendations,
      count: recommendations.length,
      timeWindow,
    };

  } catch (error: any) {
    logger.error('Failed to get trending recommendations', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    throw new functions.https.HttpsError('internal', `トレンド推薦取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
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

    // 管理者権限チェック
    const userId = context.auth.uid;
    const userDoc = await recommendationEngine.db.collection('users').doc(userId).get();
    const userData = userDoc.data();
    
    if (!userData?.isAdmin) {
      throw new functions.https.HttpsError('permission-denied', '管理者権限が必要です。');
    }

    logger.info('Getting recommendation system stats', { userId });

    const stats = await recommendationEngine.getSystemStats();

    return {
      success: true,
      stats,
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
 * 推薦モデルを再訓練する機能（管理者用）
 */
export const retrainRecommendationModel = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    // 管理者権限チェック
    const userId = context.auth.uid;
    const userDoc = await recommendationEngine.db.collection('users').doc(userId).get();
    const userData = userDoc.data();
    
    if (!userData?.isAdmin) {
      throw new functions.https.HttpsError('permission-denied', '管理者権限が必要です。');
    }

    const { forceRetrain = false } = data;

    logger.info('Starting recommendation model retrain', { userId, forceRetrain });

    const result = await recommendationEngine.retrainModel({ forceRetrain });

    logger.info('Recommendation model retrain completed', { userId, result });

    return {
      success: true,
      result,
      message: 'モデルの再訓練が完了しました。'
    };

  } catch (error: any) {
    logger.error('Failed to retrain recommendation model', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `モデル再訓練中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});