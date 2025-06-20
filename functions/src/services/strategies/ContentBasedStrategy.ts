import { logger } from 'firebase-functions/v2';
import { BaseRecommendationStrategy } from './RecommendationStrategy';
import { MovieData, UserProfile, RecommendationResult } from '../recommendationEngine';

/**
 * コンテンツベースフィルタリング戦略
 * ユーザーの過去の評価から映画の特徴量を分析し、
 * 類似した特徴を持つ映画を推薦する
 */
export class ContentBasedStrategy extends BaseRecommendationStrategy {
  constructor(weight: number = 0.7) {
    super(weight, 'content_based');
  }

  async recommend(
    userProfile: UserProfile,
    availableMovies: MovieData[],
    maxResults: number
  ): Promise<RecommendationResult[]> {
    logger.info('Starting content-based filtering', {
      moviesCount: availableMovies.length,
      maxResults
    });

    const recommendations: RecommendationResult[] = [];

    for (const movie of availableMovies) {
      const score = this.calculateContentScore(movie, userProfile);
      
      if (score > 0.1) { // 最小スコア閾値
        const reasons = this.generateReasons(movie, userProfile);
        const confidence = this.calculateConfidence(score, reasons);
        
        recommendations.push({
          movieId: movie.id,
          movie,
          score,
          reasons,
          recommendationType: 'content_based',
          confidence
        });
      }
    }

    // スコア順にソートして上位を返す
    const sortedRecommendations = recommendations
      .sort((a, b) => b.score - a.score)
      .slice(0, maxResults);

    logger.info('Content-based filtering completed', {
      generatedCount: sortedRecommendations.length
    });

    return sortedRecommendations;
  }

  /**
   * コンテンツベースのスコアを計算
   */
  private calculateContentScore(movie: MovieData, userProfile: UserProfile): number {
    let totalScore = 0;
    let weights = 0;

    // ジャンルスコア（重み: 40%）
    const genreScore = this.calculateGenreScore(movie, userProfile);
    totalScore += genreScore * 0.4;
    weights += 0.4;

    // 監督スコア（重み: 20%）
    const directorScore = this.calculateDirectorScore(movie, userProfile);
    totalScore += directorScore * 0.2;
    weights += 0.2;

    // 俳優スコア（重み: 20%）
    const actorScore = this.calculateActorScore(movie, userProfile);
    totalScore += actorScore * 0.2;
    weights += 0.2;

    // キーワードスコア（重み: 15%）
    const keywordScore = this.calculateKeywordScore(movie, userProfile);
    totalScore += keywordScore * 0.15;
    weights += 0.15;

    // 評価スコア（重み: 5%）
    const ratingScore = this.calculateRatingScore(movie);
    totalScore += ratingScore * 0.05;
    weights += 0.05;

    return weights > 0 ? totalScore / weights : 0;
  }

  /**
   * ジャンル一致度を計算
   */
  private calculateGenreScore(movie: MovieData, userProfile: UserProfile): number {
    if (movie.genres.length === 0) return 0;

    const genreScores = movie.genres.map(genre => 
      userProfile.preferences.genres[genre] || 0
    );

    return genreScores.reduce((sum, score) => sum + score, 0) / movie.genres.length;
  }

  /**
   * 監督一致度を計算
   */
  private calculateDirectorScore(movie: MovieData, userProfile: UserProfile): number {
    return userProfile.preferences.directors[movie.director] || 0;
  }

  /**
   * 俳優一致度を計算
   */
  private calculateActorScore(movie: MovieData, userProfile: UserProfile): number {
    if (movie.actors.length === 0) return 0;

    const actorScores = movie.actors.map(actor => 
      userProfile.preferences.actors[actor] || 0
    );

    return Math.max(...actorScores); // 最も好きな俳優のスコアを使用
  }

  /**
   * キーワード一致度を計算
   */
  private calculateKeywordScore(movie: MovieData, userProfile: UserProfile): number {
    if (movie.keywords.length === 0) return 0;

    const keywordScores = movie.keywords.map(keyword => 
      userProfile.preferences.keywords[keyword] || 0
    );

    return keywordScores.reduce((sum, score) => sum + score, 0) / movie.keywords.length;
  }

  /**
   * 評価スコアを正規化
   */
  private calculateRatingScore(movie: MovieData): number {
    // 評価を0-1の範囲に正規化 (10点満点として)
    return Math.min(movie.rating / 10, 1.0);
  }

  /**
   * ユーザーの特徴ベクトルを生成
   */
  private generateUserFeatureVector(userProfile: UserProfile): number[] {
    const features: number[] = [];
    
    // 上位ジャンルの好み度
    const topGenres = this.getTopPreferences(userProfile.preferences.genres, 5);
    features.push(...topGenres);
    
    // 感情分析結果
    features.push(
      userProfile.sentimentHistory.positive || 0,
      userProfile.sentimentHistory.neutral || 0,
      userProfile.sentimentHistory.negative || 0
    );
    
    // 評価傾向
    features.push(userProfile.averageRating || 0);
    
    return features;
  }

  /**
   * 映画の特徴ベクトルを生成
   */
  private generateMovieFeatureVector(movie: MovieData, allGenres: string[]): number[] {
    const features: number[] = [];
    
    // ジャンルワンホットエンコーディング
    for (const genre of allGenres.slice(0, 5)) {
      features.push(movie.genres.includes(genre) ? 1 : 0);
    }
    
    // 評価
    features.push(movie.rating / 10);
    
    // 年代 (正規化)
    features.push((movie.year - 1900) / 124); // 1900-2024の範囲で正規化
    
    return features;
  }

  /**
   * 上位の嗜好を取得
   */
  private getTopPreferences(preferences: Record<string, number>, count: number): number[] {
    const sorted = Object.entries(preferences)
      .sort(([, a], [, b]) => b - a)
      .slice(0, count);
    
    const values = sorted.map(([, value]) => value);
    
    // 不足分を0で埋める
    while (values.length < count) {
      values.push(0);
    }
    
    return values;
  }
}