import { MovieData, UserProfile, RecommendationResult } from '../recommendationEngine';

/**
 * 推薦戦略の基底インターフェース
 * 戦略パターンを使用して異なる推薦アルゴリズムを統一的に扱う
 */
export interface RecommendationStrategy {
  /**
   * 推薦を実行
   * @param userProfile ユーザープロファイル
   * @param availableMovies 候補映画リスト
   * @param maxResults 最大推薦数
   * @returns 推薦結果リスト
   */
  recommend(
    userProfile: UserProfile,
    availableMovies: MovieData[],
    maxResults: number
  ): Promise<RecommendationResult[]>;

  /**
   * 戦略の重み（ハイブリッド推薦で使用）
   */
  getWeight(): number;

  /**
   * 戦略名
   */
  getName(): string;
}

/**
 * 推薦戦略のベース抽象クラス
 * 共通機能を提供
 */
export abstract class BaseRecommendationStrategy implements RecommendationStrategy {
  protected readonly weight: number;
  protected readonly name: string;

  constructor(weight: number, name: string) {
    this.weight = weight;
    this.name = name;
  }

  abstract recommend(
    userProfile: UserProfile,
    availableMovies: MovieData[],
    maxResults: number
  ): Promise<RecommendationResult[]>;

  getWeight(): number {
    return this.weight;
  }

  getName(): string {
    return this.name;
  }

  /**
   * 類似度計算のためのユーティリティメソッド
   */
  protected calculateSimilarity(vector1: number[], vector2: number[]): number {
    if (vector1.length !== vector2.length) return 0;

    const dotProduct = vector1.reduce((sum, a, i) => sum + a * vector2[i], 0);
    const magnitude1 = Math.sqrt(vector1.reduce((sum, a) => sum + a * a, 0));
    const magnitude2 = Math.sqrt(vector2.reduce((sum, a) => sum + a * a, 0));

    if (magnitude1 === 0 || magnitude2 === 0) return 0;
    return dotProduct / (magnitude1 * magnitude2);
  }

  /**
   * 正規化のためのユーティリティメソッド
   */
  protected normalizeScores(scores: number[]): number[] {
    const max = Math.max(...scores);
    const min = Math.min(...scores);
    const range = max - min;

    if (range === 0) return scores.map(() => 0.5);
    return scores.map(score => (score - min) / range);
  }

  /**
   * 推薦理由を生成
   */
  protected generateReasons(movie: MovieData, userProfile: UserProfile): string[] {
    const reasons: string[] = [];

    // ジャンル一致
    const matchingGenres = movie.genres.filter(genre =>
      userProfile.preferences.genres[genre] > 0.5
    );
    if (matchingGenres.length > 0) {
      reasons.push(`好きなジャンル: ${matchingGenres.join(', ')}`);
    }

    // 監督一致
    if (userProfile.preferences.directors[movie.director] > 0.5) {
      reasons.push(`お気に入りの監督: ${movie.director}`);
    }

    // 俳優一致
    const matchingActors = movie.actors.filter(actor =>
      userProfile.preferences.actors[actor] > 0.5
    );
    if (matchingActors.length > 0) {
      reasons.push(`好きな俳優: ${matchingActors.slice(0, 2).join(', ')}`);
    }

    // 高評価
    if (movie.rating >= 8.0) {
      reasons.push(`高評価作品 (${movie.rating}/10)`);
    }

    return reasons.length > 0 ? reasons : ['あなたの嗜好にマッチ'];
  }

  /**
   * 信頼度を計算
   */
  protected calculateConfidence(score: number, reasons: string[]): number {
    const baseConfidence = Math.min(score, 1.0);
    const reasonBonus = Math.min(reasons.length * 0.1, 0.3);
    return Math.min(baseConfidence + reasonBonus, 1.0);
  }
}
