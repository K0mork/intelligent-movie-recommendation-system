import { logger } from 'firebase-functions/v2';
import { RecommendationStrategy } from './RecommendationStrategy';
import { ContentBasedStrategy } from './ContentBasedStrategy';
import { CollaborativeStrategy } from './CollaborativeStrategy';
import { SentimentBasedStrategy } from './SentimentBasedStrategy';
import { MovieData, UserProfile, RecommendationResult, RecommendationConfig } from '../recommendationEngine';

/**
 * ハイブリッド推薦エンジン
 * 複数の推薦戦略を組み合わせて最適な推薦を提供
 */
export class HybridRecommendationEngine {
  private readonly strategies: RecommendationStrategy[] = [];

  constructor() {
    this.initializeStrategies();
  }

  /**
   * 推薦戦略を初期化
   */
  private initializeStrategies(): void {
    this.strategies.push(
      new ContentBasedStrategy(0.5),     // 基本的なコンテンツマッチング
      new CollaborativeStrategy(0.3),    // 協調フィルタリング
      new SentimentBasedStrategy(0.2)    // 感情分析ベース
    );

    logger.info('Hybrid recommendation engine initialized', {
      strategiesCount: this.strategies.length,
      strategies: this.strategies.map(s => s.getName())
    });
  }

  /**
   * 推薦を生成
   */
  async generateRecommendations(
    userProfile: UserProfile,
    availableMovies: MovieData[],
    config: RecommendationConfig
  ): Promise<RecommendationResult[]> {
    logger.info('Starting hybrid recommendation generation', {
      userId: userProfile.userId,
      moviesCount: availableMovies.length,
      config
    });

    try {
      // 各戦略から推薦を取得
      const strategyResults = await this.executeStrategies(
        userProfile,
        availableMovies,
        config.maxRecommendations * 2 // 候補を多めに取得
      );

      // 結果を統合
      const hybridResults = this.combineResults(strategyResults, config);

      // 多様性の向上
      const diversifiedResults = config.diversityBoost
        ? this.enhanceDiversity(hybridResults, config.maxRecommendations)
        : hybridResults.slice(0, config.maxRecommendations);

      // 信頼度フィルタリング
      const filteredResults = diversifiedResults.filter(
        result => result.confidence >= config.minConfidence
      );

      logger.info('Hybrid recommendation generation completed', {
        strategiesExecuted: strategyResults.length,
        hybridResultsCount: hybridResults.length,
        finalResultsCount: filteredResults.length
      });

      return filteredResults;

    } catch (error) {
      logger.error('Error in hybrid recommendation generation', { error });
      return [];
    }
  }

  /**
   * 各戦略を実行
   */
  private async executeStrategies(
    userProfile: UserProfile,
    availableMovies: MovieData[],
    maxResults: number
  ): Promise<StrategyResult[]> {
    const strategyResults: StrategyResult[] = [];

    for (const strategy of this.strategies) {
      try {
        logger.info(`Executing strategy: ${strategy.getName()}`);

        const startTime = Date.now();
        const results = await strategy.recommend(userProfile, availableMovies, maxResults);
        const executionTime = Date.now() - startTime;

        strategyResults.push({
          strategy: strategy.getName(),
          weight: strategy.getWeight(),
          results,
          executionTime
        });

        logger.info(`Strategy ${strategy.getName()} completed`, {
          resultsCount: results.length,
          executionTime: `${executionTime}ms`
        });

      } catch (error) {
        logger.error(`Error executing strategy ${strategy.getName()}`, { error });

        // エラーが発生した戦略は空の結果で継続
        strategyResults.push({
          strategy: strategy.getName(),
          weight: strategy.getWeight(),
          results: [],
          executionTime: 0
        });
      }
    }

    return strategyResults;
  }

  /**
   * 戦略結果を統合
   */
  private combineResults(
    strategyResults: StrategyResult[],
    config: RecommendationConfig
  ): RecommendationResult[] {
    const movieScores = new Map<string, CombinedScore>();

    // 各戦略の結果を重み付きで統合
    for (const strategyResult of strategyResults) {
      const strategyWeight = this.calculateDynamicWeight(strategyResult, config);

      for (const result of strategyResult.results) {
        const movieId = result.movieId;

        if (!movieScores.has(movieId)) {
          movieScores.set(movieId, {
            movie: result.movie,
            totalScore: 0,
            weightSum: 0,
            reasonsSet: new Set<string>(),
            strategiesUsed: [],
            confidenceSum: 0,
            recommendationTypes: new Set<string>()
          });
        }

        const combined = movieScores.get(movieId)!;
        combined.totalScore += result.score * strategyWeight;
        combined.weightSum += strategyWeight;
        combined.confidenceSum += result.confidence;
        combined.strategiesUsed.push(strategyResult.strategy);
        combined.recommendationTypes.add(result.recommendationType);

        // 理由を統合
        result.reasons.forEach(reason => combined.reasonsSet.add(reason));
      }
    }

    // 最終的な推薦結果を生成
    const finalResults: RecommendationResult[] = [];

    for (const [movieId, combined] of movieScores.entries()) {
      const normalizedScore = combined.weightSum > 0 ? combined.totalScore / combined.weightSum : 0;
      const averageConfidence = combined.confidenceSum / combined.strategiesUsed.length;

      // ハイブリッドボーナス（複数戦略で推薦された場合）
      const hybridBonus = combined.strategiesUsed.length > 1 ? 0.1 : 0;
      const finalScore = Math.min(1.0, normalizedScore + hybridBonus);

      finalResults.push({
        movieId,
        movie: combined.movie,
        score: finalScore,
        reasons: Array.from(combined.reasonsSet),
        recommendationType: 'hybrid',
        confidence: Math.min(1.0, averageConfidence + hybridBonus)
      });
    }

    return finalResults.sort((a, b) => b.score - a.score);
  }

  /**
   * 戦略の動的重み計算
   */
  private calculateDynamicWeight(
    strategyResult: StrategyResult,
    config: RecommendationConfig
  ): number {
    let dynamicWeight = strategyResult.weight;

    // 結果の質に基づく重み調整
    if (strategyResult.results.length === 0) {
      dynamicWeight *= 0.1; // 結果なしの場合は重みを大幅減
    } else {
      const avgConfidence = strategyResult.results.reduce(
        (sum, r) => sum + r.confidence, 0
      ) / strategyResult.results.length;

      dynamicWeight *= (0.5 + avgConfidence); // 信頼度で重み調整
    }

    // パフォーマンスに基づく重み調整
    if (strategyResult.executionTime > 5000) { // 5秒以上
      dynamicWeight *= 0.8; // 遅い戦略の重みを減少
    }

    // 設定による重み調整
    if (strategyResult.strategy === 'content_based') {
      dynamicWeight *= config.contentWeight || 1.0;
    } else if (strategyResult.strategy === 'collaborative') {
      dynamicWeight *= config.collaborativeWeight || 1.0;
    }

    return dynamicWeight;
  }

  /**
   * 推薦結果の多様性を向上
   */
  private enhanceDiversity(
    results: RecommendationResult[],
    maxResults: number
  ): RecommendationResult[] {
    if (results.length <= maxResults) {
      return results;
    }

    const diversified: RecommendationResult[] = [];
    const usedGenres = new Set<string>();
    const usedDirectors = new Set<string>();

    // 上位の推薦を優先しつつ、多様性を確保
    for (const result of results) {
      if (diversified.length >= maxResults) break;

      const movie = result.movie;


      // 多様性スコアを計算
      const diversityScore = this.calculateDiversityScore(
        movie, usedGenres, usedDirectors, diversified.length
      );

      // 高スコアまたは多様性がある場合に採用
      if (result.score >= 0.7 || diversityScore > 0.5 || diversified.length < maxResults * 0.6) {
        diversified.push(result);

        // 使用済みとしてマーク
        movie.genres.forEach(genre => usedGenres.add(genre));
        usedDirectors.add(movie.director);
      }
    }

    // 不足分を上位から補填
    while (diversified.length < maxResults && diversified.length < results.length) {
      const remaining = results.filter(r =>
        !diversified.find(d => d.movieId === r.movieId)
      );

      if (remaining.length === 0) break;
      diversified.push(remaining[0]);
    }

    return diversified;
  }

  /**
   * 多様性スコアを計算
   */
  private calculateDiversityScore(
    movie: MovieData,
    usedGenres: Set<string>,
    usedDirectors: Set<string>,
    currentCount: number
  ): number {
    let diversityScore = 0;

    // ジャンルの新規性
    const newGenres = movie.genres.filter(genre => !usedGenres.has(genre));
    diversityScore += (newGenres.length / Math.max(movie.genres.length, 1)) * 0.5;

    // 監督の新規性
    if (!usedDirectors.has(movie.director)) {
      diversityScore += 0.3;
    }

    // 位置による調整（後半ほど多様性を重視）
    const positionMultiplier = 1 + (currentCount * 0.1);

    return diversityScore * positionMultiplier;
  }
}

/**
 * 戦略実行結果
 */
interface StrategyResult {
  strategy: string;
  weight: number;
  results: RecommendationResult[];
  executionTime: number;
}

/**
 * 統合スコア情報
 */
interface CombinedScore {
  movie: MovieData;
  totalScore: number;
  weightSum: number;
  reasonsSet: Set<string>;
  strategiesUsed: string[];
  confidenceSum: number;
  recommendationTypes: Set<string>;
}
