import { GoogleGenerativeAI } from '@google/generative-ai';
import * as functions from 'firebase-functions';
import { logger } from 'firebase-functions/v2';
import { BaseRecommendationStrategy } from './RecommendationStrategy';
import { MovieData, UserProfile, RecommendationResult } from '../recommendationEngine';

/**
 * 感情分析ベース推薦戦略
 * ユーザーのレビューテキストの感情分析結果を基に、
 * 感情的に合致する映画を推薦する
 */
export class SentimentBasedStrategy extends BaseRecommendationStrategy {
  private readonly genAI: GoogleGenerativeAI;

  constructor(weight: number = 0.2) {
    super(weight, 'sentiment_based');
    const apiKey = functions.config().gemini?.api_key || '';
    this.genAI = new GoogleGenerativeAI(apiKey);
  }

  async recommend(
    userProfile: UserProfile,
    availableMovies: MovieData[],
    maxResults: number
  ): Promise<RecommendationResult[]> {
    logger.info('Starting sentiment-based filtering', {
      userId: userProfile.userId,
      moviesCount: availableMovies.length,
      maxResults
    });

    try {
      // ユーザーの感情プロファイルを分析
      const emotionalProfile = this.analyzeEmotionalProfile(userProfile);

      // 映画の感情的特徴を分析して推薦を生成
      const recommendations = await this.generateSentimentRecommendations(
        emotionalProfile,
        availableMovies,
        maxResults
      );

      logger.info('Sentiment-based filtering completed', {
        generatedCount: recommendations.length
      });

      return recommendations;

    } catch (error) {
      logger.error('Error in sentiment-based filtering', { error });
      return [];
    }
  }

  /**
   * ユーザーの感情プロファイルを分析
   */
  private analyzeEmotionalProfile(userProfile: UserProfile): EmotionalProfile {
    const sentimentHistory = userProfile.sentimentHistory;

    // 感情傾向の正規化
    const total = sentimentHistory.positive + sentimentHistory.neutral + sentimentHistory.negative;

    if (total === 0) {
      // デフォルトプロファイル
      return {
        dominantEmotion: 'balanced',
        emotionalIntensity: 0.5,
        preferredTones: ['uplifting', 'engaging'],
        avoidedTones: []
      };
    }

    const normalizedPositive = sentimentHistory.positive / total;
    const normalizedNegative = sentimentHistory.negative / total;
    const normalizedNeutral = sentimentHistory.neutral / total;

    // 支配的感情を決定
    let dominantEmotion: EmotionalType;
    if (normalizedPositive > 0.5) {
      dominantEmotion = 'positive';
    } else if (normalizedNegative > 0.4) {
      dominantEmotion = 'negative';
    } else {
      dominantEmotion = 'balanced';
    }

    // 感情の強度を計算
    const emotionalIntensity = Math.max(normalizedPositive, normalizedNegative, normalizedNeutral);

    // 好まれるトーンを決定
    const preferredTones = this.determinePreferredTones(dominantEmotion, emotionalIntensity);
    const avoidedTones = this.determineAvoidedTones(dominantEmotion);

    return {
      dominantEmotion,
      emotionalIntensity,
      preferredTones,
      avoidedTones
    };
  }

  /**
   * 好まれるトーンを決定
   */
  private determinePreferredTones(emotion: EmotionalType, intensity: number): string[] {
    const tones: string[] = [];

    switch (emotion) {
      case 'positive':
        tones.push('uplifting', 'inspiring', 'heartwarming');
        if (intensity > 0.7) {
          tones.push('exhilarating', 'joyful');
        }
        break;

      case 'negative':
        tones.push('dramatic', 'intense', 'thought-provoking');
        if (intensity > 0.6) {
          tones.push('dark', 'melancholic');
        }
        break;

      case 'balanced':
        tones.push('engaging', 'well-rounded', 'nuanced');
        break;
    }

    return tones;
  }

  /**
   * 避けられるトーンを決定
   */
  private determineAvoidedTones(emotion: EmotionalType): string[] {
    switch (emotion) {
      case 'positive':
        return ['depressing', 'bleak', 'nihilistic'];

      case 'negative':
        return ['overly-cheerful', 'simplistic'];

      case 'balanced':
        return ['extreme'];
    }
  }

  /**
   * 感情ベース推薦を生成
   */
  private async generateSentimentRecommendations(
    emotionalProfile: EmotionalProfile,
    availableMovies: MovieData[],
    maxResults: number
  ): Promise<RecommendationResult[]> {
    const recommendations: RecommendationResult[] = [];

    for (const movie of availableMovies) {
      const sentimentScore = await this.calculateSentimentScore(movie, emotionalProfile);

      if (sentimentScore > 0.3) {
        const reasons = this.generateSentimentReasons(movie, emotionalProfile);
        const confidence = this.calculateConfidence(sentimentScore, reasons);

        recommendations.push({
          movieId: movie.id,
          movie,
          score: sentimentScore,
          reasons,
          recommendationType: 'content_based', // sentiment_basedは暫定的にcontent_basedとして扱う
          confidence
        });
      }
    }

    return recommendations
      .sort((a, b) => b.score - a.score)
      .slice(0, maxResults);
  }

  /**
   * 映画の感情スコアを計算
   */
  private async calculateSentimentScore(movie: MovieData, profile: EmotionalProfile): Promise<number> {
    try {
      // 映画の感情的特徴を分析
      const movieSentiment = await this.analyzeMovieSentiment(movie);

      // プロファイルとの適合度を計算
      let score = 0;

      // 好まれるトーンとの一致度
      const toneMatches = profile.preferredTones.filter(tone =>
        movieSentiment.tones.includes(tone)
      ).length;
      score += (toneMatches / profile.preferredTones.length) * 0.6;

      // 避けられるトーンの確認
      const avoidedMatches = profile.avoidedTones.filter(tone =>
        movieSentiment.tones.includes(tone)
      ).length;
      score -= (avoidedMatches / Math.max(profile.avoidedTones.length, 1)) * 0.4;

      // 感情強度の一致度
      const intensityDiff = Math.abs(profile.emotionalIntensity - movieSentiment.intensity);
      score += (1 - intensityDiff) * 0.3;

      // 感情の方向性の一致度
      if (profile.dominantEmotion === movieSentiment.dominantEmotion) {
        score += 0.2;
      }

      return Math.max(0, Math.min(1, score));

    } catch (error) {
      logger.warn('Failed to analyze movie sentiment', { movieId: movie.id, error });
      return 0;
    }
  }

  /**
   * 映画の感情的特徴を分析
   */
  private async analyzeMovieSentiment(movie: MovieData): Promise<MovieSentiment> {
    // キャッシュチェック（実装簡略化のため省略）

    const model = this.genAI.getGenerativeModel({ model: 'gemini-pro' });

    const prompt = `
映画の感情的特徴を分析してください。

映画情報:
タイトル: ${movie.title}
ジャンル: ${movie.genres.join(', ')}
プロット: ${movie.plot}
監督: ${movie.director}

以下の形式でJSONで回答してください:
{
  "dominantEmotion": "positive/negative/balanced",
  "intensity": 0.0-1.0,
  "tones": ["tone1", "tone2", ...],
  "emotionalKeywords": ["keyword1", "keyword2", ...]
}

感情の強度は0.0（非常に穏やか）から1.0（非常に強烈）の範囲で評価してください。
`;

    try {
      const result = await model.generateContent(prompt);
      const response = result.response.text();

      // JSON解析を試行
      const analysisResult = JSON.parse(response);

      return {
        dominantEmotion: analysisResult.dominantEmotion || 'balanced',
        intensity: Math.max(0, Math.min(1, analysisResult.intensity || 0.5)),
        tones: Array.isArray(analysisResult.tones) ? analysisResult.tones : [],
        emotionalKeywords: Array.isArray(analysisResult.emotionalKeywords) ? analysisResult.emotionalKeywords : []
      };

    } catch (error) {
      logger.warn('Failed to parse sentiment analysis result', { error });

      // フォールバック: ジャンルベースの簡易分析
      return this.getFallbackSentiment(movie);
    }
  }

  /**
   * フォールバック感情分析
   */
  private getFallbackSentiment(movie: MovieData): MovieSentiment {
    const positiveGenres = ['Comedy', 'Romance', 'Family', 'Animation'];
    const negativeGenres = ['Horror', 'Thriller', 'Drama'];

    const hasPositiveGenre = movie.genres.some(genre => positiveGenres.includes(genre));
    const hasNegativeGenre = movie.genres.some(genre => negativeGenres.includes(genre));

    let dominantEmotion: EmotionalType = 'balanced';
    let intensity = 0.5;
    let tones: string[] = ['engaging'];

    if (hasPositiveGenre && !hasNegativeGenre) {
      dominantEmotion = 'positive';
      tones = ['uplifting', 'entertaining'];
      intensity = 0.7;
    } else if (hasNegativeGenre && !hasPositiveGenre) {
      dominantEmotion = 'negative';
      tones = ['dramatic', 'intense'];
      intensity = 0.8;
    }

    return {
      dominantEmotion,
      intensity,
      tones,
      emotionalKeywords: []
    };
  }

  /**
   * 感情ベース推薦理由を生成
   */
  private generateSentimentReasons(movie: MovieData, profile: EmotionalProfile): string[] {
    const reasons: string[] = [];

    if (profile.dominantEmotion === 'positive') {
      reasons.push('あなたの前向きな気分にマッチ');
    } else if (profile.dominantEmotion === 'negative') {
      reasons.push('深いテーマを扱った作品をお探しのあなたに');
    } else {
      reasons.push('バランスの取れた感情体験を提供');
    }

    if (profile.emotionalIntensity > 0.7) {
      reasons.push('感情的にインパクトのある作品');
    } else if (profile.emotionalIntensity < 0.3) {
      reasons.push('穏やかで心地よい作品');
    }

    return reasons;
  }
}

/**
 * 感情タイプ
 */
type EmotionalType = 'positive' | 'negative' | 'balanced';

/**
 * ユーザーの感情プロファイル
 */
interface EmotionalProfile {
  dominantEmotion: EmotionalType;
  emotionalIntensity: number;
  preferredTones: string[];
  avoidedTones: string[];
}

/**
 * 映画の感情的特徴
 */
interface MovieSentiment {
  dominantEmotion: EmotionalType;
  intensity: number;
  tones: string[];
  emotionalKeywords: string[];
}
