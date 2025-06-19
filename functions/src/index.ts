import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GoogleGenerativeAI } from '@google/generative-ai';

// ハンドラーのインポート
import * as authHandlers from './auth/authHandlers';
import * as movieHandlers from './movies/movieHandlers';
import * as reviewHandlers from './reviews/reviewHandlers';
import * as recommendationHandlers from './recommendations/recommendationHandlers';

// Firebase Admin SDK を初期化
admin.initializeApp();

// Gemini API の初期化
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_AI_API_KEY || '');

// ===============================
// 認証関連の関数エクスポート
// ===============================
export const getUserProfile = authHandlers.getUserProfile;
export const updateUserProfile = authHandlers.updateUserProfile;
export const exportUserData = authHandlers.exportUserData;
export const deleteUserAccount = authHandlers.deleteUserAccount;

// ===============================
// 映画関連の関数エクスポート
// ===============================
export const searchMovies = movieHandlers.searchMovies;
export const getPopularMovies = movieHandlers.getPopularMovies;
export const getMoviesByGenre = movieHandlers.getMoviesByGenre;
export const getMovieDetails = movieHandlers.getMovieDetails;
export const getSimilarMovies = movieHandlers.getSimilarMovies;
export const getMovieStats = movieHandlers.getMovieStats;
export const initializeSampleMovies = movieHandlers.initializeSampleMovies;
export const getMovieTrends = movieHandlers.getMovieTrends;
export const getNewReleases = movieHandlers.getNewReleases;

// ===============================
// レビュー関連の関数エクスポート
// ===============================
export const analyzeReviewWithService = reviewHandlers.analyzeReviewWithService;
export const getReviewAnalysis = reviewHandlers.getReviewAnalysis;
export const getUserPreferences = reviewHandlers.getUserPreferences;
export const getUserReviewStats = reviewHandlers.getUserReviewStats;
export const addReviewComment = reviewHandlers.addReviewComment;
export const getReviewComments = reviewHandlers.getReviewComments;
export const onReviewCreated = reviewHandlers.onReviewCreated;
export const batchUpdateReviewAnalysis = reviewHandlers.batchUpdateReviewAnalysis;

// ===============================
// 推薦関連の関数エクスポート
// ===============================
export const generatePersonalizedRecommendations = recommendationHandlers.generatePersonalizedRecommendations;
export const getSavedRecommendations = recommendationHandlers.getSavedRecommendations;
export const recordRecommendationFeedback = recommendationHandlers.recordRecommendationFeedback;
export const updateRecommendationSettings = recommendationHandlers.updateRecommendationSettings;
export const getRecommendationExplanation = recommendationHandlers.getRecommendationExplanation;
export const getSimilarUserRecommendations = recommendationHandlers.getSimilarUserRecommendations;
export const getTrendingRecommendations = recommendationHandlers.getTrendingRecommendations;
export const getRecommendationStats = recommendationHandlers.getRecommendationStats;
export const retrainRecommendationModel = recommendationHandlers.retrainRecommendationModel;

// ===============================
// レガシーサポート関数
// ===============================

/**
 * レガシー: 旧analyzeReview関数のサポート（Gemini API直接使用）
 * 新しいコードでは analyzeReviewWithService を使用することを推奨
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

    return {
      analysis,
      success: true,
      message: 'この関数は非推奨です。analyzeReviewWithService を使用してください。'
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
 * レガシー: 旧getRecommendations関数のサポート
 * 新しいコードでは generatePersonalizedRecommendations を使用することを推奨
 */
export const getRecommendations = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const userId = context.auth.uid;

    // 新しい推薦システムを使用
    return await generatePersonalizedRecommendations({ maxRecommendations: 10 }, context);

  } catch (error) {
    console.error('推薦生成エラー:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', '推薦生成の処理中にエラーが発生しました。');
  }
});

// ===============================
// システム関数
// ===============================

/**
 * 健康チェック用のHTTPS関数
 */
export const healthCheck = functions.https.onRequest((req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    message: 'FilmFlow Cloud Functions are running (Refactored)',
    version: '2.0.0',
    architecture: 'Modular',
    services: {
      auth: 'Available',
      movies: 'Available', 
      reviews: 'Available',
      recommendations: 'Available',
      reviewAnalysis: 'Available',
      recommendationEngine: 'Available',
      movieDataUtils: 'Available',
      geminiAPI: process.env.GOOGLE_AI_API_KEY ? 'Configured' : 'Not configured'
    },
    endpoints: {
      auth: [
        'getUserProfile',
        'updateUserProfile', 
        'exportUserData',
        'deleteUserAccount'
      ],
      movies: [
        'searchMovies',
        'getPopularMovies',
        'getMoviesByGenre', 
        'getMovieDetails',
        'getSimilarMovies',
        'getMovieStats',
        'initializeSampleMovies',
        'getMovieTrends',
        'getNewReleases'
      ],
      reviews: [
        'analyzeReviewWithService',
        'getReviewAnalysis',
        'getUserPreferences',
        'getUserReviewStats',
        'addReviewComment',
        'getReviewComments',
        'batchUpdateReviewAnalysis'
      ],
      recommendations: [
        'generatePersonalizedRecommendations',
        'getSavedRecommendations',
        'recordRecommendationFeedback',
        'updateRecommendationSettings',
        'getRecommendationExplanation',
        'getSimilarUserRecommendations',
        'getTrendingRecommendations',
        'getRecommendationStats',
        'retrainRecommendationModel'
      ],
      legacy: [
        'analyzeReview (deprecated)',
        'getRecommendations (deprecated)'
      ],
      triggers: [
        'onReviewCreated (Firestore trigger)'
      ]
    }
  });
});