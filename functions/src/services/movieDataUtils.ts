import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { MovieData } from './recommendationEngine';

/**
 * 映画データ管理用のユーティリティクラス
 */
export class MovieDataUtils {
  private db: FirebaseFirestore.Firestore;

  constructor() {
    this.db = getFirestore();
  }

  /**
   * サンプル映画データを初期化
   */
  async initializeSampleMovies(): Promise<void> {
    try {
      const sampleMovies: Omit<MovieData, 'id'>[] = [
        {
          title: "千と千尋の神隠し",
          genres: ["animation", "adventure", "family"],
          director: "宮崎駿",
          actors: ["柊瑠美", "入野自由", "夏木マリ"],
          year: 2001,
          rating: 9.2,
          plot: "10歳の少女千尋が不思議な世界に迷い込み、両親を豚にされてしまう。魔女湯婆婆の湯屋で働きながら、元の世界に戻る方法を探す冒険物語。",
          keywords: ["スタジオジブリ", "ファンタジー", "成長", "冒険", "魔法"],
          tmdbId: "129"
        },
        {
          title: "君の名は。",
          genres: ["animation", "romance", "drama"],
          director: "新海誠",
          actors: ["神木隆之介", "上白石萌音", "長澤まさみ"],
          year: 2016,
          rating: 8.4,
          plot: "東京の男子高校生と飛騨の女子高校生が入れ替わる現象を体験し、やがて運命的な出会いを果たす恋愛ファンタジー。",
          keywords: ["入れ替わり", "恋愛", "運命", "美しい映像", "感動"]
        },
        {
          title: "アベンジャーズ/エンドゲーム",
          genres: ["action", "adventure", "sci-fi"],
          director: "ルッソ兄弟",
          actors: ["ロバート・ダウニー・Jr.", "クリス・エヴァンス", "マーク・ラファロ"],
          year: 2019,
          rating: 8.4,
          plot: "サノスに敗北したアベンジャーズが、失われた仲間たちを取り戻すために最後の戦いに挑む壮大なフィナーレ。",
          keywords: ["スーパーヒーロー", "アクション", "友情", "犠牲", "壮大"]
        },
        {
          title: "パラサイト 半地下の家族",
          genres: ["thriller", "drama", "comedy"],
          director: "ポン・ジュノ",
          actors: ["ソン・ガンホ", "イ・ソンギュン", "チョ・ヨジョン"],
          year: 2019,
          rating: 8.6,
          plot: "半地下住宅に住む貧困家族が、富裕層の家庭に入り込んでいくサスペンス・ドラマ。",
          keywords: ["社会格差", "韓国映画", "ブラックコメディ", "サスペンス", "現代社会"]
        },
        {
          title: "インターステラー",
          genres: ["sci-fi", "drama", "adventure"],
          director: "クリストファー・ノーラン",
          actors: ["マシュー・マコノヒー", "アン・ハサウェイ", "ジェシカ・チャステイン"],
          year: 2014,
          rating: 8.6,
          plot: "地球の環境悪化により、宇宙に新たな居住地を求める宇宙飛行士の物語。愛と科学が交錯する壮大なSF映画。",
          keywords: ["宇宙", "時間", "父娘の愛", "科学", "壮大"]
        },
        {
          title: "ジョーカー",
          genres: ["crime", "drama", "thriller"],
          director: "トッド・フィリップス",
          actors: ["ホアキン・フェニックス", "ロバート・デ・ニーロ"],
          year: 2019,
          rating: 8.4,
          plot: "コメディアンを夢見る男アーサーが、社会から疎外されジョーカーへと変貌していく心理ドラマ。",
          keywords: ["ダークヒーロー", "社会問題", "精神的苦痛", "演技力", "リアリズム"]
        },
        {
          title: "となりのトトロ",
          genres: ["animation", "family", "fantasy"],
          director: "宮崎駿",
          actors: ["日高のり子", "坂本千夏", "糸井重里"],
          year: 1988,
          rating: 8.2,
          plot: "父と田舎に引っ越してきた姉妹が、森の精霊トトロと出会い、不思議な体験をする心温まる物語。",
          keywords: ["スタジオジブリ", "子供", "自然", "家族愛", "純真"]
        },
        {
          title: "ラ・ラ・ランド",
          genres: ["romance", "musical", "drama"],
          director: "デイミアン・チャゼル",
          actors: ["ライアン・ゴズリング", "エマ・ストーン"],
          year: 2016,
          rating: 8.0,
          plot: "ロサンゼルスで夢を追う女優と音楽家の恋愛を描いたミュージカル映画。",
          keywords: ["ミュージカル", "恋愛", "夢", "音楽", "美しい映像"]
        },
        {
          title: "フォレスト・ガンプ/一期一会",
          genres: ["drama", "romance", "comedy"],
          director: "ロバート・ゼメキス",
          actors: ["トム・ハンクス", "ロビン・ライト", "ゲイリー・シニーズ"],
          year: 1994,
          rating: 8.8,
          plot: "知的障害を持つ男性フォレストが、純粋な心で人生を歩んでいく感動的な物語。",
          keywords: ["人生", "純粋", "愛", "友情", "感動"]
        },
        {
          title: "ダークナイト",
          genres: ["action", "crime", "drama"],
          director: "クリストファー・ノーラン",
          actors: ["クリスチャン・ベール", "ヒース・レジャー", "アーロン・エックハート"],
          year: 2008,
          rating: 9.0,
          plot: "バットマンとジョーカーの対決を描いた、ダークで心理的なスーパーヒーロー映画。",
          keywords: ["バットマン", "善悪", "心理戦", "アクション", "深い"]
        }
      ];

      // 映画データをFirestoreに保存
      const batch = this.db.batch();

      for (const movie of sampleMovies) {
        const movieRef = this.db.collection('movies').doc();
        batch.set(movieRef, movie);
      }

      await batch.commit();
      logger.info('Sample movies initialized successfully', { count: sampleMovies.length });

    } catch (error: any) {
      logger.error('Failed to initialize sample movies', { error: error?.message });
      throw new Error(`Failed to initialize sample movies: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * 映画データを検索
   */
  async searchMovies(query: string, limit: number = 20): Promise<MovieData[]> {
    try {
      // タイトルでの部分一致検索
      const titleQuery = this.db.collection('movies')
        .where('title', '>=', query)
        .where('title', '<=', query + '\uf8ff')
        .limit(limit);

      const titleSnapshot = await titleQuery.get();
      const movies: MovieData[] = titleSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      } as MovieData));

      // ジャンルでの検索も追加
      if (movies.length < limit) {
        const genreQuery = this.db.collection('movies')
          .where('genres', 'array-contains', query.toLowerCase())
          .limit(limit - movies.length);

        const genreSnapshot = await genreQuery.get();
        genreSnapshot.docs.forEach(doc => {
          const movieData = { id: doc.id, ...doc.data() } as MovieData;
          if (!movies.find(m => m.id === movieData.id)) {
            movies.push(movieData);
          }
        });
      }

      return movies;

    } catch (error: any) {
      logger.error('Failed to search movies', { query, error: error?.message });
      throw new Error(`Failed to search movies: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * 人気映画を取得
   */
  async getPopularMovies(limit: number = 20): Promise<MovieData[]> {
    try {
      const moviesQuery = this.db.collection('movies')
        .where('rating', '>=', 7.0)
        .orderBy('rating', 'desc')
        .limit(limit);

      const snapshot = await moviesQuery.get();

      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      } as MovieData));

    } catch (error: any) {
      logger.error('Failed to get popular movies', { error: error?.message });
      throw new Error(`Failed to get popular movies: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * ジャンル別映画を取得
   */
  async getMoviesByGenre(genre: string, limit: number = 20): Promise<MovieData[]> {
    try {
      const moviesQuery = this.db.collection('movies')
        .where('genres', 'array-contains', genre.toLowerCase())
        .orderBy('rating', 'desc')
        .limit(limit);

      const snapshot = await moviesQuery.get();

      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      } as MovieData));

    } catch (error: any) {
      logger.error('Failed to get movies by genre', { genre, error: error?.message });
      throw new Error(`Failed to get movies by genre: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * 特定の映画データを取得
   */
  async getMovie(movieId: string): Promise<MovieData | null> {
    try {
      const movieDoc = await this.db.collection('movies').doc(movieId).get();

      if (!movieDoc.exists) {
        return null;
      }

      return {
        id: movieDoc.id,
        ...movieDoc.data()
      } as MovieData;

    } catch (error: any) {
      logger.error('Failed to get movie', { movieId, error: error?.message });
      throw new Error(`Failed to get movie: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * 映画データを更新
   */
  async updateMovie(movieId: string, updates: Partial<Omit<MovieData, 'id'>>): Promise<void> {
    try {
      await this.db.collection('movies').doc(movieId).update(updates);
      logger.info('Movie updated successfully', { movieId });

    } catch (error: any) {
      logger.error('Failed to update movie', { movieId, error: error?.message });
      throw new Error(`Failed to update movie: ${error?.message || 'Unknown error'}`);
    }
  }

  /**
   * データベースから映画の統計情報を取得
   */
  async getMovieStats(): Promise<{
    totalMovies: number;
    genreDistribution: Record<string, number>;
    averageRating: number;
    yearDistribution: Record<string, number>;
  }> {
    try {
      const moviesSnapshot = await this.db.collection('movies').get();
      const movies: MovieData[] = moviesSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      } as MovieData));

      const genreDistribution: Record<string, number> = {};
      const yearDistribution: Record<string, number> = {};
      let totalRating = 0;

      movies.forEach(movie => {
        // ジャンル分布
        movie.genres.forEach(genre => {
          genreDistribution[genre] = (genreDistribution[genre] || 0) + 1;
        });

        // 年代分布
        const decade = Math.floor(movie.year / 10) * 10;
        const decadeKey = `${decade}s`;
        yearDistribution[decadeKey] = (yearDistribution[decadeKey] || 0) + 1;

        // 評価合計
        totalRating += movie.rating;
      });

      return {
        totalMovies: movies.length,
        genreDistribution,
        averageRating: movies.length > 0 ? totalRating / movies.length : 0,
        yearDistribution
      };

    } catch (error: any) {
      logger.error('Failed to get movie stats', { error: error?.message });
      throw new Error(`Failed to get movie stats: ${error?.message || 'Unknown error'}`);
    }
  }
}
