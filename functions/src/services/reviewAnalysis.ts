import { GoogleGenerativeAI } from '@google/generative-ai';
import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';

// 感情分析結果の型定義
export interface SentimentAnalysis {
  sentiment: 'positive' | 'negative' | 'neutral';
  score: number; // -1 to 1
  emotions: string[];
}

// 好み抽出結果の型定義
export interface PreferenceAnalysis {
  genres: string[];
  themes: string[];
  actors: string[];
  directors: string[];
  keywords: string[];
}

// 総合分析結果の型定義
export interface ReviewAnalysisResult {
  reviewId: string;
  userId: string;
  movieId: string;
  sentiment: SentimentAnalysis;
  preferences: PreferenceAnalysis;
  analyzedAt: Date;
  confidence: number;
}

export class ReviewAnalysisService {
  private genAI?: GoogleGenerativeAI;

  private getDb() {
    return getFirestore();
  }

  constructor() {
    const apiKey = process.env.GEMINI_API_KEY || '';
    if (apiKey) {
      this.genAI = new GoogleGenerativeAI(apiKey);
    } else {
      // API keyが設定されていない場合は警告のみ
      logger.warn('GEMINI_API_KEY environment variable is not set. AI analysis features will be limited.');
    }
  }

  /**
   * レビューテキストの感情分析を実行
   */
  async analyzeSentiment(reviewText: string): Promise<SentimentAnalysis> {
    try {
      if (!this.genAI) {
        throw new Error('AI service is not available. Please configure GEMINI_API_KEY.');
      }
      const model = this.genAI.getGenerativeModel({ model: 'gemini-pro' });

      const prompt = `
        以下の映画レビューテキストを分析して、感情を判定してください。
        JSON形式で以下の情報を返してください：
        - sentiment: "positive", "negative", "neutral" のいずれか
        - score: -1から1の間の数値（-1が最もネガティブ、1が最もポジティブ）
        - emotions: 感じられる感情のリスト（例：["excitement", "joy", "disappointment"]）

        レビューテキスト: "${reviewText}"

        回答はJSONのみで、他の文章は含めないでください。
      `;

      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();

      // JSONパースを試行
      const analysis = JSON.parse(text.trim());

      // データ検証
      if (!analysis.sentiment || !['positive', 'negative', 'neutral'].includes(analysis.sentiment)) {
        throw new Error('Invalid sentiment value');
      }

      if (typeof analysis.score !== 'number' || analysis.score < -1 || analysis.score > 1) {
        throw new Error('Invalid score value');
      }

      if (!Array.isArray(analysis.emotions)) {
        analysis.emotions = [];
      }

      logger.info('Sentiment analysis completed', {
        sentiment: analysis.sentiment,
        score: analysis.score
      });

      return analysis;
    } catch (error: any) {
      logger.error('Sentiment analysis failed', { error: error?.message });
      throw new Error(`Sentiment analysis failed: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * レビューから好みの要素を抽出
   */
  async extractPreferences(reviewText: string, movieTitle: string): Promise<PreferenceAnalysis> {
    try {
      if (!this.genAI) {
        throw new Error('AI service is not available. Please configure GEMINI_API_KEY.');
      }
      const model = this.genAI.getGenerativeModel({ model: 'gemini-pro' });

      const prompt = `
        以下の映画「${movieTitle}」のレビューテキストを分析して、ユーザーの好みを抽出してください。
        JSON形式で以下の情報を返してください：
        - genres: 言及されているジャンル（例：["action", "comedy", "drama"]）
        - themes: 言及されているテーマ（例：["friendship", "revenge", "love"]）
        - actors: 言及されている俳優名（例：["Tom Hanks", "Meryl Streep"]）
        - directors: 言及されている監督名（例：["Steven Spielberg"]）
        - keywords: その他のキーワード（例：["cinematography", "soundtrack", "plot twist"]）

        レビューテキスト: "${reviewText}"

        回答はJSONのみで、他の文章は含めないでください。
        該当する項目がない場合は空の配列を返してください。
      `;

      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();

      // JSONパースを試行
      const preferences = JSON.parse(text.trim());

      // データ検証と初期化
      const validPreferences: PreferenceAnalysis = {
        genres: Array.isArray(preferences.genres) ? preferences.genres : [],
        themes: Array.isArray(preferences.themes) ? preferences.themes : [],
        actors: Array.isArray(preferences.actors) ? preferences.actors : [],
        directors: Array.isArray(preferences.directors) ? preferences.directors : [],
        keywords: Array.isArray(preferences.keywords) ? preferences.keywords : []
      };

      logger.info('Preference extraction completed', {
        genresCount: validPreferences.genres.length,
        themesCount: validPreferences.themes.length,
        actorsCount: validPreferences.actors.length
      });

      return validPreferences;
    } catch (error: any) {
      logger.error('Preference extraction failed', { error: error?.message });
      throw new Error(`Preference extraction failed: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * 総合的なレビュー分析を実行
   */
  async analyzeReview(
    reviewId: string,
    userId: string,
    movieId: string,
    reviewText: string,
    movieTitle: string
  ): Promise<ReviewAnalysisResult> {
    try {
      logger.info('Starting comprehensive review analysis', {
        reviewId,
        userId,
        movieId
      });

      // 並行して感情分析と好み抽出を実行
      const [sentiment, preferences] = await Promise.all([
        this.analyzeSentiment(reviewText),
        this.extractPreferences(reviewText, movieTitle)
      ]);

      // 信頼度スコアを計算（簡単な実装）
      const confidence = this.calculateConfidence(sentiment, preferences, reviewText);

      const analysisResult: ReviewAnalysisResult = {
        reviewId,
        userId,
        movieId,
        sentiment,
        preferences,
        analyzedAt: new Date(),
        confidence
      };

      logger.info('Review analysis completed successfully', {
        reviewId,
        sentiment: sentiment.sentiment,
        confidence
      });

      return analysisResult;
    } catch (error: any) {
      logger.error('Comprehensive review analysis failed', {
        reviewId,
        error: error?.message
      });
      throw new Error(`Review analysis failed: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * 分析結果をFirestoreに保存
   */
  async saveAnalysisResult(analysisResult: ReviewAnalysisResult): Promise<void> {
    try {
      const analysisRef = this.getDb().collection('reviewAnalysis').doc(analysisResult.reviewId);

      await analysisRef.set({
        ...analysisResult,
        analyzedAt: analysisResult.analyzedAt.toISOString()
      });

      // ユーザーの好み履歴も更新
      await this.updateUserPreferences(analysisResult.userId, analysisResult.preferences);

      logger.info('Analysis result saved successfully', {
        reviewId: analysisResult.reviewId
      });
    } catch (error: any) {
      logger.error('Failed to save analysis result', {
        reviewId: analysisResult.reviewId,
        error: error?.message
      });
      throw new Error(`Failed to save analysis result: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * ユーザーの好み履歴を更新
   */
  private async updateUserPreferences(userId: string, newPreferences: PreferenceAnalysis): Promise<void> {
    try {
      const userPrefsRef = this.getDb().collection('userPreferences').doc(userId);
      const userPrefsDoc = await userPrefsRef.get();

      if (userPrefsDoc.exists) {
        const currentPrefs = userPrefsDoc.data() as any;

        // 既存の好みと新しい好みをマージ
        const updatedPrefs = {
          genres: this.mergeAndCount(currentPrefs.genres || {}, newPreferences.genres),
          themes: this.mergeAndCount(currentPrefs.themes || {}, newPreferences.themes),
          actors: this.mergeAndCount(currentPrefs.actors || {}, newPreferences.actors),
          directors: this.mergeAndCount(currentPrefs.directors || {}, newPreferences.directors),
          keywords: this.mergeAndCount(currentPrefs.keywords || {}, newPreferences.keywords),
          lastUpdated: new Date().toISOString()
        };

        await userPrefsRef.set(updatedPrefs);
      } else {
        // 初回の場合は新規作成
        const initialPrefs = {
          genres: this.arrayToCountMap(newPreferences.genres),
          themes: this.arrayToCountMap(newPreferences.themes),
          actors: this.arrayToCountMap(newPreferences.actors),
          directors: this.arrayToCountMap(newPreferences.directors),
          keywords: this.arrayToCountMap(newPreferences.keywords),
          createdAt: new Date().toISOString(),
          lastUpdated: new Date().toISOString()
        };

        await userPrefsRef.set(initialPrefs);
      }

      logger.info('User preferences updated', { userId });
    } catch (error: any) {
      logger.error('Failed to update user preferences', {
        userId,
        error: error?.message
      });
      // ユーザー好み更新の失敗は致命的エラーではないので、ログのみ
    }
  }

  /**
   * 信頼度スコアを計算
   */
  private calculateConfidence(
    sentiment: SentimentAnalysis,
    preferences: PreferenceAnalysis,
    reviewText: string
  ): number {
    let confidence = 0.5; // 基本信頼度

    // レビューテキストの長さによる調整
    const textLength = reviewText.length;
    if (textLength > 100) confidence += 0.1;
    if (textLength > 300) confidence += 0.1;

    // 感情スコアの絶対値による調整
    confidence += Math.abs(sentiment.score) * 0.2;

    // 抽出された要素の数による調整
    const totalElements = preferences.genres.length +
                         preferences.themes.length +
                         preferences.actors.length +
                         preferences.directors.length;
    confidence += Math.min(totalElements * 0.05, 0.2);

    return Math.min(Math.max(confidence, 0.1), 1.0);
  }

  /**
   * 配列をカウントマップに変換
   */
  private arrayToCountMap(array: string[]): Record<string, number> {
    const countMap: Record<string, number> = {};
    array.forEach(item => {
      countMap[item] = (countMap[item] || 0) + 1;
    });
    return countMap;
  }

  /**
   * 既存のカウントマップと新しい配列をマージ
   */
  private mergeAndCount(existing: Record<string, number>, newItems: string[]): Record<string, number> {
    const merged = { ...existing };
    newItems.forEach(item => {
      merged[item] = (merged[item] || 0) + 1;
    });
    return merged;
  }

  /**
   * 特定のレビューの分析結果を取得
   */
  async getAnalysisResult(reviewId: string): Promise<ReviewAnalysisResult | null> {
    try {
      const analysisRef = this.getDb().collection('reviewAnalysis').doc(reviewId);
      const doc = await analysisRef.get();

      if (!doc.exists) {
        return null;
      }

      const data = doc.data() as any;
      return {
        ...data,
        analyzedAt: new Date(data.analyzedAt)
      };
    } catch (error: any) {
      logger.error('Failed to get analysis result', {
        reviewId,
        error: error?.message
      });
      throw new Error(`Failed to get analysis result: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * ユーザーの好み履歴を取得
   */
  async getUserPreferences(userId: string): Promise<any> {
    try {
      const userPrefsRef = this.getDb().collection('userPreferences').doc(userId);
      const doc = await userPrefsRef.get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (error: any) {
      logger.error('Failed to get user preferences', {
        userId,
        error: error?.message
      });
      throw new Error(`Failed to get user preferences: ${error?.message || 'Unknown error'}`);
    }
  }
}
