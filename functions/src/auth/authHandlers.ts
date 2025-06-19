import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions/v2';

// Cloud Firestore のインスタンス
const db = admin.firestore();

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
    
    // ユーザードキュメントを取得
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      // ユーザードキュメントが存在しない場合は作成
      const newUserData = {
        uid: userId,
        email: context.auth.token.email || null,
        displayName: context.auth.token.name || null,
        photoURL: context.auth.token.picture || null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        lastSignIn: admin.firestore.FieldValue.serverTimestamp(),
        isAdmin: false, // デフォルトは管理者ではない
      };

      await db.collection('users').doc(userId).set(newUserData);
      
      return {
        success: true,
        profile: newUserData,
        isNewUser: true,
      };
    }

    const userData = userDoc.data();
    
    // 最終サインイン時刻を更新
    await db.collection('users').doc(userId).update({
      lastSignIn: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      profile: userData,
      isNewUser: false,
    };

  } catch (error: any) {
    logger.error('Failed to get user profile', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `ユーザープロファイル取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * ユーザープロファイルを更新する機能
 */
export const updateUserProfile = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;
    const { displayName, photoURL, preferences } = data;

    // 更新データの準備
    const updateData: any = {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (displayName !== undefined) {
      updateData.displayName = displayName;
    }

    if (photoURL !== undefined) {
      updateData.photoURL = photoURL;
    }

    if (preferences !== undefined) {
      updateData.preferences = preferences;
    }

    // プロファイル更新
    await db.collection('users').doc(userId).update(updateData);

    logger.info('User profile updated successfully', { userId });

    return {
      success: true,
      message: 'プロファイルが更新されました。',
    };

  } catch (error: any) {
    logger.error('Failed to update user profile', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `プロファイル更新中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * ユーザーデータをエクスポートする機能
 */
export const exportUserData = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;

    logger.info('Starting user data export', { userId });

    // ユーザーのレビューデータを取得
    const reviewsSnapshot = await db
      .collection('reviews')
      .where('userId', '==', userId)
      .get();

    const reviews = reviewsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    // ユーザーの推薦履歴を取得
    const recommendationsSnapshot = await db
      .collection('userRecommendations')
      .where('userId', '==', userId)
      .get();

    const recommendations = recommendationsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    // ユーザープロファイルを取得
    const userDoc = await db.collection('users').doc(userId).get();
    const userProfile = userDoc.data();

    // エクスポートデータを構築
    const exportData = {
      profile: userProfile,
      reviews: reviews,
      recommendations: recommendations,
      exportedAt: new Date().toISOString(),
      version: '1.0.0',
    };

    logger.info('User data export completed successfully', { 
      userId, 
      reviewCount: reviews.length,
      recommendationCount: recommendations.length,
    });

    return {
      success: true,
      data: exportData,
      summary: {
        reviewCount: reviews.length,
        recommendationCount: recommendations.length,
      },
    };

  } catch (error: any) {
    logger.error('Failed to export user data', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    throw new functions.https.HttpsError('internal', `データエクスポート中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * ユーザーアカウントを削除する機能
 */
export const deleteUserAccount = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;

    logger.info('Starting user account deletion', { userId });

    // バッチ処理でユーザーデータを削除
    const batch = db.batch();

    // ユーザーのレビューを削除
    const reviewsSnapshot = await db
      .collection('reviews')
      .where('userId', '==', userId)
      .get();

    reviewsSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    // ユーザーの推薦データを削除
    const recommendationsSnapshot = await db
      .collection('userRecommendations')
      .where('userId', '==', userId)
      .get();

    recommendationsSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    // ユーザーの分析データを削除
    const analysisSnapshot = await db
      .collection('reviewAnalysis')
      .where('userId', '==', userId)
      .get();

    analysisSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    // ユーザープロファイルを削除
    const userRef = db.collection('users').doc(userId);
    batch.delete(userRef);

    // バッチ実行
    await batch.commit();

    // Firebase Authからユーザーを削除
    await admin.auth().deleteUser(userId);

    logger.info('User account deleted successfully', { userId });

    return {
      success: true,
      message: 'アカウントが正常に削除されました。',
    };

  } catch (error: any) {
    logger.error('Failed to delete user account', { 
      userId: context.auth?.uid, 
      error: error?.message 
    });
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', `アカウント削除中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 管理者権限をチェックする共通関数
 */
export async function checkAdminPermission(userId: string): Promise<boolean> {
  try {
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();
    return userData?.isAdmin === true;
  } catch (error) {
    logger.error('Failed to check admin permission', { userId, error });
    return false;
  }
}

/**
 * 管理者権限が必要な操作の前に呼び出すヘルパー関数
 */
export async function requireAdminPermission(context: any): Promise<void> {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
  }

  const isAdmin = await checkAdminPermission(context.auth.uid);
  if (!isAdmin) {
    throw new functions.https.HttpsError('permission-denied', '管理者権限が必要です。');
  }
}