import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions/v2';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { ReviewAnalysisService } from '../services/reviewAnalysis';

// Cloud Firestore のインスタンス
const db = admin.firestore();

// レビュー分析サービスのインスタンス
const reviewAnalysisService = new ReviewAnalysisService();

/**
 * レビュー感情分析関数
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
 * ユーザーのレビュー統計を取得する関数
 */
export const getUserReviewStats = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;

    logger.info('Getting user review stats', { userId });

    // ユーザーのレビュー統計を取得
    const reviewsSnapshot = await db
      .collection('reviews')
      .where('userId', '==', userId)
      .get();

    const reviews = reviewsSnapshot.docs.map(doc => doc.data());
    
    // 統計計算
    const totalReviews = reviews.length;
    const averageRating = totalReviews > 0 
      ? reviews.reduce((sum, review) => sum + (review.rating || 0), 0) / totalReviews 
      : 0;
    
    // ジャンル別統計
    const genreStats = new Map<string, { count: number; totalRating: number }>();
    
    reviews.forEach(review => {
      if (review.movieGenres && Array.isArray(review.movieGenres)) {
        review.movieGenres.forEach((genre: string) => {
          const current = genreStats.get(genre) || { count: 0, totalRating: 0 };
          genreStats.set(genre, {
            count: current.count + 1,
            totalRating: current.totalRating + (review.rating || 0)
          });
        });
      }
    });

    const genrePreferences = Array.from(genreStats.entries()).map(([genre, stats]) => ({
      genre,
      count: stats.count,
      averageRating: stats.totalRating / stats.count
    }));

    // 月別レビュー数
    const monthlyStats = new Map<string, number>();
    reviews.forEach(review => {
      if (review.createdAt) {
        const date = review.createdAt.toDate ? review.createdAt.toDate() : new Date(review.createdAt);
        const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
        monthlyStats.set(monthKey, (monthlyStats.get(monthKey) || 0) + 1);
      }
    });

    const monthlyReviews = Array.from(monthlyStats.entries()).map(([month, count]) => ({
      month,
      count
    }));

    return {
      success: true,
      stats: {
        totalReviews,
        averageRating: Number(averageRating.toFixed(2)),
        genrePreferences: genrePreferences.sort((a, b) => b.count - a.count).slice(0, 10),
        monthlyReviews: monthlyReviews.sort((a, b) => a.month.localeCompare(b.month)),
        lastReviewDate: reviews.length > 0 ? reviews[reviews.length - 1].createdAt : null,
      }
    };

  } catch (error: any) {
    logger.error('Failed to get user review stats', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    throw new functions.https.HttpsError('internal', `レビュー統計取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * レビューにコメントを追加する関数
 */
export const addReviewComment = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { reviewId, comment } = data;
    const userId = context.auth.uid;

    if (!reviewId || !comment) {
      throw new functions.https.HttpsError('invalid-argument', 'レビューIDとコメントが必要です。');
    }

    logger.info('Adding review comment', { reviewId, userId });

    // コメントデータを作成
    const commentData = {
      reviewId,
      userId,
      comment: comment.trim(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // コメントを保存
    const commentRef = await db.collection('reviewComments').add(commentData);

    return {
      success: true,
      commentId: commentRef.id,
      message: 'コメントが追加されました。'
    };

  } catch (error: any) {
    logger.error('Failed to add review comment', { 
      reviewId: data?.reviewId,
      error: error?.message,
      userId: context.auth?.uid,
    });
    
    throw new functions.https.HttpsError('internal', `コメント追加中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * レビューのコメントを取得する関数
 */
export const getReviewComments = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { reviewId, limit = 20 } = data;

    if (!reviewId) {
      throw new functions.https.HttpsError('invalid-argument', 'レビューIDが必要です。');
    }

    logger.info('Getting review comments', { reviewId, limit });

    // コメントを取得
    const commentsSnapshot = await db
      .collection('reviewComments')
      .where('reviewId', '==', reviewId)
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .get();

    const comments = commentsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    return {
      success: true,
      comments,
      count: comments.length,
    };

  } catch (error: any) {
    logger.error('Failed to get review comments', { 
      reviewId: data?.reviewId,
      error: error?.message,
      userId: context.auth?.uid,
    });
    
    throw new functions.https.HttpsError('internal', `コメント取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
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
 * レビューの感情分析結果をバッチで更新する関数（管理者用）
 */
export const batchUpdateReviewAnalysis = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 管理者権限チェック
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();
    
    if (!userData?.isAdmin) {
      throw new functions.https.HttpsError('permission-denied', '管理者権限が必要です。');
    }

    const { limit = 100 } = data;

    logger.info('Starting batch review analysis update', { limit, userId });

    // 分析されていないレビューを取得
    const reviewsSnapshot = await db
      .collection('reviews')
      .limit(limit)
      .get();

    const analysisPromises: Promise<any>[] = [];

    for (const reviewDoc of reviewsSnapshot.docs) {
      const reviewData = reviewDoc.data();
      const reviewId = reviewDoc.id;

      // 既に分析済みかチェック
      const existingAnalysis = await db
        .collection('reviewAnalysis')
        .where('reviewId', '==', reviewId)
        .get();

      if (existingAnalysis.empty && reviewData.reviewText && reviewData.movieTitle) {
        analysisPromises.push(
          reviewAnalysisService.analyzeReview(
            reviewId,
            reviewData.userId,
            reviewData.movieId,
            reviewData.reviewText,
            reviewData.movieTitle
          ).then(result => reviewAnalysisService.saveAnalysisResult(result))
        );
      }
    }

    const results = await Promise.allSettled(analysisPromises);
    const successCount = results.filter(r => r.status === 'fulfilled').length;
    const errorCount = results.filter(r => r.status === 'rejected').length;

    logger.info('Batch review analysis completed', { 
      total: analysisPromises.length,
      success: successCount,
      errors: errorCount,
      userId,
    });

    return {
      success: true,
      processed: analysisPromises.length,
      successful: successCount,
      errors: errorCount,
    };

  } catch (error: any) {
    logger.error('Failed to batch update review analysis', { 
      error: error?.message,
      userId: context.auth?.uid,
    });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `バッチ分析更新中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});