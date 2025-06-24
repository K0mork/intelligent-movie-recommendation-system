import { logger } from 'firebase-functions/v2';
import { getFirestore } from 'firebase-admin/firestore';
import { BaseRecommendationStrategy } from './RecommendationStrategy';
import { MovieData, UserProfile, RecommendationResult } from '../recommendationEngine';

/**
 * 協調フィルタリング戦略
 * 類似ユーザーの評価データを基に推薦を行う
 */
export class CollaborativeStrategy extends BaseRecommendationStrategy {
  private readonly db = getFirestore();

  constructor(weight: number = 0.3) {
    super(weight, 'collaborative');
  }

  async recommend(
    userProfile: UserProfile,
    availableMovies: MovieData[],
    maxResults: number
  ): Promise<RecommendationResult[]> {
    logger.info('Starting collaborative filtering', {
      userId: userProfile.userId,
      moviesCount: availableMovies.length,
      maxResults
    });

    try {
      // 類似ユーザーを発見
      const similarUsers = await this.findSimilarUsers(userProfile);

      if (similarUsers.length === 0) {
        logger.warn('No similar users found for collaborative filtering');
        return [];
      }

      // 類似ユーザーの評価を基に推薦スコアを計算
      const recommendations = await this.generateCollaborativeRecommendations(
        userProfile,
        similarUsers,
        availableMovies,
        maxResults
      );

      logger.info('Collaborative filtering completed', {
        similarUsersCount: similarUsers.length,
        generatedCount: recommendations.length
      });

      return recommendations;

    } catch (error) {
      logger.error('Error in collaborative filtering', { error });
      return [];
    }
  }

  /**
   * 類似ユーザーを発見
   */
  private async findSimilarUsers(targetUser: UserProfile): Promise<SimilarUser[]> {
    const usersRef = this.db.collection('userProfiles');
    const usersSnapshot = await usersRef.limit(100).get(); // パフォーマンス考慮で制限

    const similarUsers: SimilarUser[] = [];

    for (const doc of usersSnapshot.docs) {
      const userData = doc.data() as UserProfile;

      if (userData.userId === targetUser.userId) continue;

      const similarity = this.calculateUserSimilarity(targetUser, userData);

      if (similarity > 0.3) { // 類似度閾値
        similarUsers.push({
          profile: userData,
          similarity
        });
      }
    }

    // 類似度順でソート
    return similarUsers
      .sort((a, b) => b.similarity - a.similarity)
      .slice(0, 20); // 上位20ユーザーのみ使用
  }

  /**
   * ユーザー間の類似度を計算
   */
  private calculateUserSimilarity(user1: UserProfile, user2: UserProfile): number {
    let totalSimilarity = 0;
    let weights = 0;

    // ジャンル嗜好の類似度
    const genreSimilarity = this.calculatePreferenceSimilarity(
      user1.preferences.genres,
      user2.preferences.genres
    );
    totalSimilarity += genreSimilarity * 0.4;
    weights += 0.4;

    // 感情分析パターンの類似度
    const sentimentSimilarity = this.calculateSentimentSimilarity(
      user1.sentimentHistory,
      user2.sentimentHistory
    );
    totalSimilarity += sentimentSimilarity * 0.3;
    weights += 0.3;

    // 監督嗜好の類似度
    const directorSimilarity = this.calculatePreferenceSimilarity(
      user1.preferences.directors,
      user2.preferences.directors
    );
    totalSimilarity += directorSimilarity * 0.2;
    weights += 0.2;

    // 評価傾向の類似度
    const ratingDiff = Math.abs((user1.averageRating || 0) - (user2.averageRating || 0));
    const ratingSimilarity = Math.max(0, 1 - ratingDiff / 5); // 5点差で完全非類似
    totalSimilarity += ratingSimilarity * 0.1;
    weights += 0.1;

    return weights > 0 ? totalSimilarity / weights : 0;
  }

  /**
   * 嗜好辞書の類似度を計算
   */
  private calculatePreferenceSimilarity(
    prefs1: Record<string, number>,
    prefs2: Record<string, number>
  ): number {
    const allKeys = new Set([...Object.keys(prefs1), ...Object.keys(prefs2)]);

    if (allKeys.size === 0) return 0;

    const vector1: number[] = [];
    const vector2: number[] = [];

    for (const key of allKeys) {
      vector1.push(prefs1[key] || 0);
      vector2.push(prefs2[key] || 0);
    }

    return this.calculateSimilarity(vector1, vector2);
  }

  /**
   * 感情分析の類似度を計算
   */
  private calculateSentimentSimilarity(
    sentiment1: { positive: number; neutral: number; negative: number },
    sentiment2: { positive: number; neutral: number; negative: number }
  ): number {
    const vector1 = [
      sentiment1.positive || 0,
      sentiment1.neutral || 0,
      sentiment1.negative || 0
    ];
    const vector2 = [
      sentiment2.positive || 0,
      sentiment2.neutral || 0,
      sentiment2.negative || 0
    ];

    return this.calculateSimilarity(vector1, vector2);
  }

  /**
   * 協調フィルタリングベースの推薦を生成
   */
  private async generateCollaborativeRecommendations(
    targetUser: UserProfile,
    similarUsers: SimilarUser[],
    availableMovies: MovieData[],
    maxResults: number
  ): Promise<RecommendationResult[]> {
    const movieScores = new Map<string, number>();
    const movieReasonCounts = new Map<string, number>();

    // 類似ユーザーの評価データを取得
    for (const similarUser of similarUsers) {
      const userReviews = await this.getUserReviews(similarUser.profile.userId);

      for (const review of userReviews) {
        const movieId = review.movieId;
        const rating = review.rating;

        // 類似ユーザーの評価を重み付きで加算
        const weightedScore = (rating / 5) * similarUser.similarity;
        movieScores.set(movieId, (movieScores.get(movieId) || 0) + weightedScore);
        movieReasonCounts.set(movieId, (movieReasonCounts.get(movieId) || 0) + 1);
      }
    }

    // 推薦結果を生成
    const recommendations: RecommendationResult[] = [];

    for (const movie of availableMovies) {
      const score = movieScores.get(movie.id) || 0;
      const reasonCount = movieReasonCounts.get(movie.id) || 0;

      if (score > 0.3 && reasonCount >= 2) { // 最小スコアと最小推薦者数
        const reasons = this.generateCollaborativeReasons(reasonCount, score);
        const confidence = this.calculateConfidence(score, reasons);

        recommendations.push({
          movieId: movie.id,
          movie,
          score,
          reasons,
          recommendationType: 'collaborative',
          confidence
        });
      }
    }

    return recommendations
      .sort((a, b) => b.score - a.score)
      .slice(0, maxResults);
  }

  /**
   * ユーザーのレビューデータを取得
   */
  private async getUserReviews(userId: string): Promise<UserReview[]> {
    const reviewsRef = this.db.collection('reviews');
    const reviewsSnapshot = await reviewsRef
      .where('userId', '==', userId)
      .where('rating', '>=', 3) // 評価3以上のみ（推薦対象として）
      .limit(50)
      .get();

    return reviewsSnapshot.docs.map(doc => {
      const data = doc.data();
      return {
        movieId: data.movieId,
        rating: data.rating,
        reviewText: data.reviewText || ''
      };
    });
  }

  /**
   * 協調フィルタリング用の推薦理由を生成
   */
  private generateCollaborativeReasons(reasonCount: number, score: number): string[] {
    const reasons: string[] = [];

    if (reasonCount >= 5) {
      reasons.push(`${reasonCount}人の類似ユーザーが高評価`);
    } else if (reasonCount >= 3) {
      reasons.push(`複数の類似ユーザーが推薦`);
    } else {
      reasons.push('類似ユーザーが評価');
    }

    if (score >= 0.8) {
      reasons.push('非常に高い評価');
    } else if (score >= 0.6) {
      reasons.push('高い評価');
    }

    return reasons;
  }
}

/**
 * 類似ユーザー情報
 */
interface SimilarUser {
  profile: UserProfile;
  similarity: number;
}

/**
 * ユーザーレビュー情報
 */
interface UserReview {
  movieId: string;
  rating: number;
  reviewText: string;
}
