import { GoogleGenerativeAI } from '@google/generative-ai';
import * as functions from 'firebase-functions';
import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { ReviewAnalysisResult } from './reviewAnalysis';

// 映画の基本情報型定義
export interface MovieData {
  id: string;
  title: string;
  genres: string[];
  director: string;
  actors: string[];
  year: number;
  rating: number;
  plot: string;
  keywords: string[];
  tmdbId?: string;
}

// 推薦結果の型定義
export interface RecommendationResult {
  movieId: string;
  movie: MovieData;
  score: number;
  reasons: string[];
  recommendationType: 'content_based' | 'collaborative' | 'hybrid' | 'trending';
  confidence: number;
}

// 推薦設定の型定義
export interface RecommendationConfig {
  maxRecommendations: number;
  contentWeight: number; // コンテンツベースフィルタリングの重み
  collaborativeWeight: number; // 協調フィルタリングの重み
  diversityBoost: boolean; // 多様性ブースト
  minConfidence: number; // 最小信頼度
}

// ユーザープロファイルの型定義
export interface UserProfile {
  userId: string;
  preferences: {
    genres: Record<string, number>;
    themes: Record<string, number>;
    actors: Record<string, number>;
    directors: Record<string, number>;
    keywords: Record<string, number>;
  };
  sentimentHistory: {
    positive: number;
    negative: number;
    neutral: number;
  };
  reviewCount: number;
  lastUpdated: Date;
}

export class RecommendationEngine {
  private genAI?: GoogleGenerativeAI;
  private defaultConfig: RecommendationConfig = {
    maxRecommendations: 10,
    contentWeight: 0.7,
    collaborativeWeight: 0.3,
    diversityBoost: true,
    minConfidence: 0.3
  };

  private getDb() {
    return getFirestore();
  }

  constructor() {
    const apiKey = functions.config().gemini?.api_key || '';
    if (apiKey) {
      this.genAI = new GoogleGenerativeAI(apiKey);
    } else {
      // API keyが設定されていない場合は警告のみ
      logger.warn('GEMINI_API_KEY environment variable is not set. AI recommendation features will be limited.');
    }
  }

  /**
   * ユーザー向けの個人化映画推薦を生成
   */
  async generateRecommendations(
    userId: string,
    config: Partial<RecommendationConfig> = {}
  ): Promise<RecommendationResult[]> {
    try {
      logger.info('Starting recommendation generation', { userId });

      const finalConfig = { ...this.defaultConfig, ...config };

      // ユーザープロファイルを取得
      const userProfile = await this.getUserProfile(userId);
      if (!userProfile) {
        throw new Error('User profile not found');
      }

      // 映画データベースから候補映画を取得
      const candidateMovies = await this.getCandidateMovies(userProfile);

      // コンテンツベース推薦を実行
      const contentBasedRecommendations = await this.generateContentBasedRecommendations(
        userProfile,
        candidateMovies,
        finalConfig
      );

      // 協調フィルタリング推薦を実行
      const collaborativeRecommendations = await this.generateCollaborativeRecommendations(
        userId,
        candidateMovies,
        finalConfig
      );

      // ハイブリッド推薦結果を生成
      const hybridRecommendations = this.combineRecommendations(
        contentBasedRecommendations,
        collaborativeRecommendations,
        finalConfig
      );

      // AI推薦理由を生成
      const finalRecommendations = await this.generateRecommendationReasons(
        userProfile,
        hybridRecommendations
      );

      // 多様性とフィルタリングを適用
      const filteredRecommendations = this.applyDiversityAndFiltering(
        finalRecommendations,
        finalConfig
      );

      // 推薦結果を保存
      await this.saveRecommendationResults(userId, filteredRecommendations);

      logger.info('Recommendation generation completed', {
        userId,
        recommendationCount: filteredRecommendations.length
      });

      return filteredRecommendations;
    } catch (error: any) {
      logger.error('Recommendation generation failed', {
        userId,
        error: error?.message
      });
      throw new Error(`Recommendation generation failed: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * ユーザープロファイルを取得・構築
   */
  async getUserProfile(userId: string): Promise<UserProfile | null> {
    try {
      // ユーザーの好み履歴を取得
      const userPrefsRef = this.getDb().collection('userPreferences').doc(userId);
      const userPrefsDoc = await userPrefsRef.get();

      if (!userPrefsDoc.exists) {
        return null;
      }

      const prefsData = userPrefsDoc.data() as any;

      // ユーザーのレビュー履歴から感情統計を計算
      const reviewAnalysisQuery = this.getDb().collection('reviewAnalysis')
        .where('userId', '==', userId)
        .orderBy('analyzedAt', 'desc')
        .limit(100);

      const reviewAnalysisSnapshot = await reviewAnalysisQuery.get();
      const sentimentHistory = { positive: 0, negative: 0, neutral: 0 };

      reviewAnalysisSnapshot.docs.forEach(doc => {
        const analysis = doc.data() as ReviewAnalysisResult;
        sentimentHistory[analysis.sentiment.sentiment]++;
      });

      const userProfile: UserProfile = {
        userId,
        preferences: {
          genres: prefsData.genres || {},
          themes: prefsData.themes || {},
          actors: prefsData.actors || {},
          directors: prefsData.directors || {},
          keywords: prefsData.keywords || {}
        },
        sentimentHistory,
        reviewCount: reviewAnalysisSnapshot.size,
        lastUpdated: new Date(prefsData.lastUpdated || Date.now())
      };

      return userProfile;
    } catch (error: any) {
      logger.error('Failed to get user profile', { userId, error: error?.message });
      throw new Error(`Failed to get user profile: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * 推薦候補となる映画を取得
   */
  async getCandidateMovies(userProfile: UserProfile): Promise<MovieData[]> {
    try {
      // ユーザーが好むジャンルの映画を優先的に取得
      const topGenres = this.getTopPreferences(userProfile.preferences.genres, 5);

      const candidateMovies: MovieData[] = [];

      // 各ジャンルから映画を取得
      for (const genre of topGenres) {
        const moviesQuery = this.getDb().collection('movies')
          .where('genres', 'array-contains', genre)
          .where('rating', '>=', 6.0) // 評価6.0以上
          .orderBy('rating', 'desc')
          .limit(20);

        const moviesSnapshot = await moviesQuery.get();
        moviesSnapshot.docs.forEach(doc => {
          const movieData = { id: doc.id, ...doc.data() } as MovieData;
          candidateMovies.push(movieData);
        });
      }

      // 人気映画も追加
      const popularMoviesQuery = this.getDb().collection('movies')
        .where('rating', '>=', 7.0)
        .orderBy('rating', 'desc')
        .limit(50);

      const popularMoviesSnapshot = await popularMoviesQuery.get();
      popularMoviesSnapshot.docs.forEach(doc => {
        const movieData = { id: doc.id, ...doc.data() } as MovieData;
        if (!candidateMovies.find(m => m.id === movieData.id)) {
          candidateMovies.push(movieData);
        }
      });

      // ユーザーが既に評価した映画を除外
      const userReviewsQuery = this.getDb().collection('reviews')
        .where('userId', '==', userProfile.userId);

      const userReviewsSnapshot = await userReviewsQuery.get();
      const reviewedMovieIds = new Set(userReviewsSnapshot.docs.map(doc => doc.data().movieId));

      const filteredCandidates = candidateMovies.filter(movie =>
        !reviewedMovieIds.has(movie.id)
      );

      logger.info('Candidate movies retrieved', {
        userId: userProfile.userId,
        totalCandidates: filteredCandidates.length
      });

      return filteredCandidates;
    } catch (error: any) {
      logger.error('Failed to get candidate movies', {
        userId: userProfile.userId,
        error: error?.message
      });
      throw new Error(`Failed to get candidate movies: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * コンテンツベース推薦を生成
   */
  async generateContentBasedRecommendations(
    userProfile: UserProfile,
    candidateMovies: MovieData[],
    config: RecommendationConfig
  ): Promise<RecommendationResult[]> {
    try {
      const recommendations: RecommendationResult[] = [];

      for (const movie of candidateMovies) {
        const score = this.calculateContentBasedScore(userProfile, movie);

        if (score >= config.minConfidence) {
          recommendations.push({
            movieId: movie.id,
            movie,
            score,
            reasons: [], // 後で詳細な理由を追加
            recommendationType: 'content_based',
            confidence: score
          });
        }
      }

      // スコア順でソート
      recommendations.sort((a, b) => b.score - a.score);

      return recommendations.slice(0, config.maxRecommendations * 2); // 後でハイブリッド化するため多めに取得
    } catch (error: any) {
      logger.error('Content-based recommendation failed', { error: error?.message });
      throw new Error(`Content-based recommendation failed: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * 協調フィルタリング推薦を生成
   */
  async generateCollaborativeRecommendations(
    userId: string,
    candidateMovies: MovieData[],
    config: RecommendationConfig
  ): Promise<RecommendationResult[]> {
    try {
      // 類似ユーザーを見つける
      const similarUsers = await this.findSimilarUsers(userId);

      // 類似ユーザーが高評価した映画を取得
      const collaborativeScores = new Map<string, number>();

      for (const similarUser of similarUsers) {
        const userReviewsQuery = this.getDb().collection('reviews')
          .where('userId', '==', similarUser.userId)
          .where('rating', '>=', 4); // 高評価のみ

        const reviewsSnapshot = await userReviewsQuery.get();

        reviewsSnapshot.docs.forEach(doc => {
          const review = doc.data();
          const movieId = review.movieId;
          const currentScore = collaborativeScores.get(movieId) || 0;
          const weightedScore = review.rating * similarUser.similarity;
          collaborativeScores.set(movieId, currentScore + weightedScore);
        });
      }

      const recommendations: RecommendationResult[] = [];

      for (const movie of candidateMovies) {
        const score = collaborativeScores.get(movie.id) || 0;

        if (score >= config.minConfidence) {
          recommendations.push({
            movieId: movie.id,
            movie,
            score: Math.min(score / 5.0, 1.0), // 0-1に正規化
            reasons: [],
            recommendationType: 'collaborative',
            confidence: Math.min(score / 5.0, 1.0)
          });
        }
      }

      recommendations.sort((a, b) => b.score - a.score);

      return recommendations.slice(0, config.maxRecommendations * 2);
    } catch (error: any) {
      logger.error('Collaborative filtering failed', { error: error?.message });
      // 協調フィルタリングが失敗した場合は空の配列を返す
      return [];
    }
  }

  /**
   * コンテンツベーススコアを計算
   */
  private calculateContentBasedScore(userProfile: UserProfile, movie: MovieData): number {
    let score = 0;
    let maxScore = 0;

    // ジャンル一致度
    const genreScore = this.calculateMatchScore(
      userProfile.preferences.genres,
      movie.genres
    );
    score += genreScore * 0.3;
    maxScore += 0.3;

    // 監督一致度
    if (userProfile.preferences.directors[movie.director]) {
      const directorScore = userProfile.preferences.directors[movie.director] / 10;
      score += Math.min(directorScore, 0.2);
    }
    maxScore += 0.2;

    // 俳優一致度
    const actorScore = this.calculateMatchScore(
      userProfile.preferences.actors,
      movie.actors
    );
    score += actorScore * 0.25;
    maxScore += 0.25;

    // キーワード一致度
    const keywordScore = this.calculateMatchScore(
      userProfile.preferences.keywords,
      movie.keywords
    );
    score += keywordScore * 0.15;
    maxScore += 0.15;

    // 映画評価による調整
    const ratingBonus = (movie.rating - 5.0) / 5.0 * 0.1;
    score += Math.max(ratingBonus, 0);
    maxScore += 0.1;

    return maxScore > 0 ? score / maxScore : 0;
  }

  /**
   * 好み要素とのマッチスコアを計算
   */
  private calculateMatchScore(preferences: Record<string, number>, items: string[]): number {
    if (items.length === 0) return 0;

    let totalScore = 0;
    let matchCount = 0;

    items.forEach(item => {
      if (preferences[item]) {
        totalScore += Math.min(preferences[item] / 10, 1.0);
        matchCount++;
      }
    });

    return matchCount > 0 ? totalScore / items.length : 0;
  }

  /**
   * 類似ユーザーを検索
   */
  private async findSimilarUsers(userId: string, limit: number = 20): Promise<Array<{userId: string, similarity: number}>> {
    try {
      // 現在のユーザーの好みを取得
      const currentUserProfile = await this.getUserProfile(userId);
      if (!currentUserProfile) return [];

      // 他のユーザーの好みと比較
      const userPrefsQuery = this.getDb().collection('userPreferences').limit(100);
      const userPrefsSnapshot = await userPrefsQuery.get();

      const similarities: Array<{userId: string, similarity: number}> = [];

      userPrefsSnapshot.docs.forEach(doc => {
        const otherUserId = doc.id;
        if (otherUserId === userId) return;

        const otherPrefs = doc.data();
        const similarity = this.calculateUserSimilarity(
          currentUserProfile.preferences,
          {
            genres: otherPrefs.genres || {},
            themes: otherPrefs.themes || {},
            actors: otherPrefs.actors || {},
            directors: otherPrefs.directors || {},
            keywords: otherPrefs.keywords || {}
          }
        );

        if (similarity > 0.3) { // 閾値以上の類似度
          similarities.push({ userId: otherUserId, similarity });
        }
      });

      similarities.sort((a, b) => b.similarity - a.similarity);
      return similarities.slice(0, limit);
    } catch (error: any) {
      logger.error('Failed to find similar users', { userId, error: error?.message });
      return [];
    }
  }

  /**
   * ユーザー間の類似度を計算
   */
  private calculateUserSimilarity(prefs1: UserProfile['preferences'], prefs2: UserProfile['preferences']): number {
    const categories = ['genres', 'themes', 'actors', 'directors', 'keywords'];
    let totalSimilarity = 0;

    categories.forEach(category => {
      const sim = this.calculateCosineSimilarity(
        prefs1[category as keyof UserProfile['preferences']],
        prefs2[category as keyof UserProfile['preferences']]
      );
      totalSimilarity += sim;
    });

    return totalSimilarity / categories.length;
  }

  /**
   * コサイン類似度を計算
   */
  private calculateCosineSimilarity(vec1: Record<string, number>, vec2: Record<string, number>): number {
    const keys1 = Object.keys(vec1);
    const keys2 = Object.keys(vec2);
    const allKeys = new Set([...keys1, ...keys2]);

    if (allKeys.size === 0) return 0;

    let dotProduct = 0;
    let norm1 = 0;
    let norm2 = 0;

    allKeys.forEach(key => {
      const val1 = vec1[key] || 0;
      const val2 = vec2[key] || 0;

      dotProduct += val1 * val2;
      norm1 += val1 * val1;
      norm2 += val2 * val2;
    });

    if (norm1 === 0 || norm2 === 0) return 0;

    return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
  }

  /**
   * ハイブリッド推薦結果を組み合わせ
   */
  private combineRecommendations(
    contentBased: RecommendationResult[],
    collaborative: RecommendationResult[],
    config: RecommendationConfig
  ): RecommendationResult[] {
    const combinedMap = new Map<string, RecommendationResult>();

    // コンテンツベース推薦を追加
    contentBased.forEach(rec => {
      const hybridScore = rec.score * config.contentWeight;
      combinedMap.set(rec.movieId, {
        ...rec,
        score: hybridScore,
        recommendationType: 'hybrid'
      });
    });

    // 協調フィルタリング推薦を組み合わせ
    collaborative.forEach(rec => {
      const existing = combinedMap.get(rec.movieId);
      if (existing) {
        // 既存の推薦と組み合わせ
        existing.score += rec.score * config.collaborativeWeight;
        existing.confidence = Math.max(existing.confidence, rec.confidence);
      } else {
        // 新しい推薦として追加
        const hybridScore = rec.score * config.collaborativeWeight;
        combinedMap.set(rec.movieId, {
          ...rec,
          score: hybridScore,
          recommendationType: 'hybrid'
        });
      }
    });

    const combinedResults = Array.from(combinedMap.values());
    combinedResults.sort((a, b) => b.score - a.score);

    return combinedResults;
  }

  /**
   * AI生成による推薦理由を追加
   */
  async generateRecommendationReasons(
    userProfile: UserProfile,
    recommendations: RecommendationResult[]
  ): Promise<RecommendationResult[]> {
    try {
      if (!this.genAI) {
        throw new Error('AI service is not available. Please configure gemini.api_key in Firebase Functions config.');
      }
      const model = this.genAI.getGenerativeModel({ model: 'gemini-pro' });

      // ユーザーの好みを要約
      const topGenres = this.getTopPreferences(userProfile.preferences.genres, 3);
      const topActors = this.getTopPreferences(userProfile.preferences.actors, 3);
      const topDirectors = this.getTopPreferences(userProfile.preferences.directors, 2);

      for (const rec of recommendations.slice(0, 10)) { // 上位10件のみ理由生成
        const prompt = `
          映画推薦システムの推薦理由を日本語で生成してください。

          ユーザーの好み:
          - 好きなジャンル: ${topGenres.join(', ')}
          - 好きな俳優: ${topActors.join(', ')}
          - 好きな監督: ${topDirectors.join(', ')}
          - レビュー傾向: ポジティブ${userProfile.sentimentHistory.positive}件、ネガティブ${userProfile.sentimentHistory.negative}件

          推薦映画:
          - タイトル: ${rec.movie.title}
          - ジャンル: ${rec.movie.genres.join(', ')}
          - 監督: ${rec.movie.director}
          - 主演: ${rec.movie.actors.slice(0, 3).join(', ')}
          - 評価: ${rec.movie.rating}/10
          - あらすじ: ${rec.movie.plot}

          推薦理由を3つの短い文で説明してください。ユーザーの好みとの具体的な関連性を明確に示してください。

          出力形式: ["理由1", "理由2", "理由3"]
        `;

        try {
          const result = await model.generateContent(prompt);
          const response = await result.response;
          const reasonsText = response.text().trim();

          // JSON形式の理由を解析
          const reasons = JSON.parse(reasonsText);
          if (Array.isArray(reasons)) {
            rec.reasons = reasons;
          } else {
            rec.reasons = [reasonsText]; // フォールバック
          }
        } catch (reasonError) {
          // 理由生成に失敗した場合のフォールバック
          rec.reasons = [
            `${rec.movie.genres.join('、')}ジャンルがお好みに合致`,
            `評価${rec.movie.rating}/10の高品質作品`,
            `あなたの視聴履歴に基づく推薦`
          ];
        }
      }

      // 残りの推薦には簡単な理由を設定
      recommendations.slice(10).forEach(rec => {
        rec.reasons = [
          `${rec.movie.genres.join('、')}ジャンルがお好みに合致`,
          `評価${rec.movie.rating}/10の高品質作品`
        ];
      });

      return recommendations;
    } catch (error: any) {
      logger.error('Failed to generate recommendation reasons', { error: error?.message });

      // エラー時のフォールバック理由
      recommendations.forEach(rec => {
        rec.reasons = [
          `${rec.movie.genres.join('、')}ジャンルがお好みに合致`,
          `評価${rec.movie.rating}/10の高品質作品`,
          `AI分析による個人化推薦`
        ];
      });

      return recommendations;
    }
  }

  /**
   * 多様性とフィルタリングを適用
   */
  private applyDiversityAndFiltering(
    recommendations: RecommendationResult[],
    config: RecommendationConfig
  ): RecommendationResult[] {
    if (!config.diversityBoost) {
      return recommendations
        .filter(rec => rec.confidence >= config.minConfidence)
        .slice(0, config.maxRecommendations);
    }

    const filtered = recommendations.filter(rec => rec.confidence >= config.minConfidence);
    const diverse: RecommendationResult[] = [];
    const usedGenres = new Set<string>();
    const usedDirectors = new Set<string>();

    // 多様性を考慮した選択
    for (const rec of filtered) {
      if (diverse.length >= config.maxRecommendations) break;

      const hasNewGenre = rec.movie.genres.some(genre => !usedGenres.has(genre));
      const hasNewDirector = !usedDirectors.has(rec.movie.director);

      if (hasNewGenre || hasNewDirector || diverse.length < 3) {
        diverse.push(rec);
        rec.movie.genres.forEach(genre => usedGenres.add(genre));
        usedDirectors.add(rec.movie.director);
      }
    }

    // 残りの枠は単純にスコア順で埋める
    for (const rec of filtered) {
      if (diverse.length >= config.maxRecommendations) break;
      if (!diverse.find(d => d.movieId === rec.movieId)) {
        diverse.push(rec);
      }
    }

    return diverse.slice(0, config.maxRecommendations);
  }

  /**
   * 推薦結果を保存
   */
  async saveRecommendationResults(
    userId: string,
    recommendations: RecommendationResult[]
  ): Promise<void> {
    try {
      const recommendationRef = this.getDb().collection('userRecommendations').doc(userId);

      await recommendationRef.set({
        userId,
        recommendations: recommendations.map(rec => ({
          ...rec,
          movie: {
            ...rec.movie,
            // 保存サイズを削減するため一部フィールドのみ保存
            id: rec.movie.id,
            title: rec.movie.title,
            genres: rec.movie.genres,
            director: rec.movie.director,
            actors: rec.movie.actors.slice(0, 3),
            year: rec.movie.year,
            rating: rec.movie.rating
          }
        })),
        generatedAt: new Date().toISOString(),
        algorithm: 'hybrid_v1'
      });

      logger.info('Recommendation results saved', {
        userId,
        count: recommendations.length
      });
    } catch (error: any) {
      logger.error('Failed to save recommendation results', {
        userId,
        error: error?.message
      });
      // 保存失敗は致命的ではないので、エラーログのみ
    }
  }

  /**
   * 保存された推薦結果を取得
   */
  async getSavedRecommendations(userId: string): Promise<RecommendationResult[]> {
    try {
      const recommendationRef = this.getDb().collection('userRecommendations').doc(userId);
      const doc = await recommendationRef.get();

      if (!doc.exists) {
        return [];
      }

      const data = doc.data() as any;
      return data.recommendations || [];
    } catch (error: any) {
      logger.error('Failed to get saved recommendations', {
        userId,
        error: error?.message
      });
      return [];
    }
  }

  /**
   * トップ好み要素を取得
   */
  private getTopPreferences(preferences: Record<string, number>, limit: number): string[] {
    return Object.entries(preferences)
      .sort(([, a], [, b]) => b - a)
      .slice(0, limit)
      .map(([key]) => key);
  }

  /**
   * 推薦結果の評価とフィードバック処理
   */
  async recordRecommendationFeedback(
    userId: string,
    movieId: string,
    feedback: 'like' | 'dislike' | 'not_interested' | 'watched' | 'bookmark',
    options?: { recommendationId?: string; reason?: string }
  ): Promise<void> {
    try {
      const feedbackRef = this.getDb().collection('recommendationFeedback').doc();

      await feedbackRef.set({
        userId,
        movieId,
        feedback,
        recommendationId: options?.recommendationId,
        reason: options?.reason,
        timestamp: new Date().toISOString()
      });

      logger.info('Recommendation feedback recorded', {
        userId,
        movieId,
        feedback
      });
    } catch (error: any) {
      logger.error('Failed to record recommendation feedback', {
        userId,
        movieId,
        feedback,
        error: error?.message
      });
    }
  }

  /**
   * ユーザーの推薦設定を更新
   */
  async updateUserSettings(
    userId: string,
    settings: {
      preferredGenres?: string[];
      excludedGenres?: string[];
      preferredYearRange?: { min: number; max: number };
      diversityPreference?: number;
      noveltyPreference?: number;
      notificationSettings?: {
        newRecommendations: boolean;
        weeklyDigest: boolean;
        monthlyReport: boolean;
      };
      updatedAt: Date;
    }
  ): Promise<void> {
    try {
      const userSettingsRef = this.getDb().collection('userPreferences').doc(userId);
      await userSettingsRef.set(settings, { merge: true });
      logger.info('User recommendation settings updated', { userId });
    } catch (error: any) {
      logger.error('Failed to update user settings', { userId, error: error?.message });
      throw new Error(`Failed to update user settings: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * 推薦の説明を取得
   */
  async getRecommendationExplanation(
    userId: string,
    movieId: string,
    recommendationId?: string
  ): Promise<string> {
    try {
      // ここでは簡易的な説明を返す。実際にはAIで生成する
      const movie = await this.getDb().collection('movies').doc(movieId).get();
      if (!movie.exists) {
        return '映画情報が見つかりません。';
      }
      const movieData = movie.data() as MovieData;

      return `この映画「${movieData.title}」は、あなたの好みに基づいて推薦されました。特に${movieData.genres.join('、')}ジャンルや、${movieData.director}監督の作品に興味があるようです。`;
    } catch (error: any) {
      logger.error('Failed to get recommendation explanation', { userId, movieId, error: error?.message });
      throw new Error(`Failed to get recommendation explanation: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * 類似ユーザーの推薦を取得
   */
  async getSimilarUserRecommendations(
    userId: string,
    options?: { limit?: number; minSimilarity?: number }
  ): Promise<RecommendationResult[]> {
    try {
      const { limit = 20, minSimilarity = 0.3 } = options || {};
      const similarUsers = await this.findSimilarUsers(userId, limit * 2); // 多めに取得

      const recommendations: RecommendationResult[] = [];
      for (const similarUser of similarUsers) {
        if (similarUser.similarity < minSimilarity) continue;
        const userRecs = await this.getSavedRecommendations(similarUser.userId);
        recommendations.push(...userRecs);
      }

      // 重複を排除し、スコアでソート
      const uniqueRecommendations = Array.from(new Map(recommendations.map(rec => [rec.movieId, rec])).values());
      uniqueRecommendations.sort((a, b) => b.score - a.score);

      return uniqueRecommendations.slice(0, limit);
    } catch (error: any) {
      logger.error('Failed to get similar user recommendations', { userId, error: error?.message });
      throw new Error(`Failed to get similar user recommendations: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * トレンド推薦を取得
   */
  async getTrendingRecommendations(
    userId: string,
    options?: { timeWindow?: 'day' | 'week'; limit?: number; personalizeWeight?: number }
  ): Promise<RecommendationResult[]> {
    try {
      const { limit = 20 } = options || {};
      // ここでは簡易的に、最近評価の高い映画をトレンドとして返す
      const trendingMoviesSnapshot = await this.getDb().collection('movies')
        .orderBy('rating', 'desc')
        .limit(limit)
        .get();

      const trendingMovies = trendingMoviesSnapshot.docs.map(doc => ({
        movieId: doc.id,
        movie: doc.data() as MovieData,
        score: (doc.data() as MovieData).rating / 10, // 0-1に正規化
        reasons: ['現在トレンドの映画です'],
        recommendationType: 'trending' as const,
        confidence: 0.8,
      }));

      return trendingMovies;
    } catch (error: any) {
      logger.error('Failed to get trending recommendations', { userId, error: error?.message });
      throw new Error(`Failed to get trending recommendations: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * システム統計情報を取得
   */
  async getSystemStats(): Promise<any> {
    try {
      const movieStats = await this.getDb().collection('movies').count().get();
      const userStats = await this.getDb().collection('users').count().get();
      const reviewStats = await this.getDb().collection('reviews').count().get();

      return {
        totalMovies: movieStats.data().count,
        totalUsers: userStats.data().count,
        totalReviews: reviewStats.data().count,
        lastRetrain: null, // 実際にはモデルの訓練履歴から取得
      };
    } catch (error: any) {
      logger.error('Failed to get system stats', { error: error?.message });
      throw new Error(`Failed to get system stats: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * 推薦モデルを再訓練
   */
  async retrainModel(options?: { forceRetrain?: boolean }): Promise<any> {
    try {
      // ここではダミーの再訓練ロジック
      logger.info('Recommendation model retraining initiated', { forceRetrain: options?.forceRetrain });
      await new Promise(resolve => setTimeout(resolve, 2000)); // 2秒の遅延をシミュレート
      logger.info('Recommendation model retraining completed');
      return { status: 'completed', timestamp: new Date().toISOString(), message: 'Model retrained successfully' };
    } catch (error: any) {
      logger.error('Failed to retrain model', { error: error?.message });
      throw new Error(`Failed to retrain model: ${error?.message || 'Unknown error'}`);
    }
  }
}
