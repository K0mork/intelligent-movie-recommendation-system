import * as functions from 'firebase-functions';
import { logger } from 'firebase-functions/v2';
import { MovieDataUtils } from '../services/movieDataUtils';
import { requireAdminPermission } from '../auth/authHandlers';

// 映画データユーティリティのインスタンス
const movieDataUtils = new MovieDataUtils();

/**
 * 映画を検索する機能
 */
export const searchMovies = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { query, limit = 20, year, genre } = data;

    if (!query) {
      throw new functions.https.HttpsError('invalid-argument', '検索クエリが必要です。');
    }

    logger.info('Movie search request', { query, limit, year, genre, userId: context.auth.uid });

    const movies = await movieDataUtils.searchMovies(query, limit, { year, genre });

    logger.info('Movie search completed', {
      query,
      resultCount: movies.length,
      userId: context.auth.uid,
    });

    return {
      success: true,
      movies,
      count: movies.length,
      query,
      filters: { year, genre },
    };

  } catch (error: any) {
    logger.error('Failed to search movies', {
      query: data?.query,
      error: error?.message,
      userId: context.auth?.uid,
    });

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError('internal', `映画検索中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 人気映画を取得する機能
 */
export const getPopularMovies = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { limit = 20, page = 1 } = data;

    logger.info('Popular movies request', { limit, page, userId: context.auth.uid });

    const movies = await movieDataUtils.getPopularMovies(limit, page);

    return {
      success: true,
      movies,
      count: movies.length,
      page,
      limit,
    };

  } catch (error: any) {
    logger.error('Failed to get popular movies', {
      error: error?.message,
      userId: context.auth?.uid,
    });

    throw new functions.https.HttpsError('internal', `人気映画取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * ジャンル別映画を取得する機能
 */
export const getMoviesByGenre = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { genre, limit = 20, page = 1 } = data;

    if (!genre) {
      throw new functions.https.HttpsError('invalid-argument', 'ジャンルが必要です。');
    }

    logger.info('Genre movies request', { genre, limit, page, userId: context.auth.uid });

    const movies = await movieDataUtils.getMoviesByGenre(genre, limit, page);

    return {
      success: true,
      movies,
      genre,
      count: movies.length,
      page,
      limit,
    };

  } catch (error: any) {
    logger.error('Failed to get movies by genre', {
      genre: data?.genre,
      error: error?.message,
      userId: context.auth?.uid,
    });

    throw new functions.https.HttpsError('internal', `ジャンル別映画取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 映画の詳細情報を取得する機能
 */
export const getMovieDetails = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { movieId } = data;

    if (!movieId) {
      throw new functions.https.HttpsError('invalid-argument', '映画IDが必要です。');
    }

    logger.info('Movie details request', { movieId, userId: context.auth.uid });

    const movie = await movieDataUtils.getMovie(movieId);

    if (!movie) {
      throw new functions.https.HttpsError('not-found', '指定された映画が見つかりません。');
    }

    return {
      success: true,
      movie,
    };

  } catch (error: any) {
    logger.error('Failed to get movie details', {
      movieId: data?.movieId,
      error: error?.message,
      userId: context.auth?.uid,
    });

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError('internal', `映画詳細取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 類似映画を取得する機能
 */
export const getSimilarMovies = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { movieId, limit = 10 } = data;

    if (!movieId) {
      throw new functions.https.HttpsError('invalid-argument', '映画IDが必要です。');
    }

    logger.info('Similar movies request', { movieId, limit, userId: context.auth.uid });

    const similarMovies = await movieDataUtils.getSimilarMovies(movieId, limit);

    return {
      success: true,
      movies: similarMovies,
      count: similarMovies.length,
      baseMovieId: movieId,
    };

  } catch (error: any) {
    logger.error('Failed to get similar movies', {
      movieId: data?.movieId,
      error: error?.message,
      userId: context.auth?.uid,
    });

    throw new functions.https.HttpsError('internal', `類似映画取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 映画データの統計情報を取得する機能
 */
export const getMovieStats = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    logger.info('Movie stats request', { userId: context.auth.uid });

    const stats = await movieDataUtils.getMovieStats();

    return {
      success: true,
      stats,
    };

  } catch (error: any) {
    logger.error('Failed to get movie stats', {
      error: error?.message,
      userId: context.auth?.uid,
    });

    throw new functions.https.HttpsError('internal', `映画統計取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * サンプル映画データを初期化する機能（管理者用）
 */
export const initializeSampleMovies = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 管理者権限チェック
    await requireAdminPermission(context);

    logger.info('Sample movies initialization request', { userId: context.auth.uid });

    await movieDataUtils.initializeSampleMovies();

    logger.info('Sample movies initialized successfully', { userId: context.auth.uid });

    return {
      success: true,
      message: 'サンプル映画データが初期化されました。',
    };

  } catch (error: any) {
    logger.error('Failed to initialize sample movies', {
      error: error?.message,
      userId: context.auth?.uid,
    });

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError('internal', `サンプルデータ初期化中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 映画トレンドを取得する機能
 */
export const getMovieTrends = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { timeWindow = 'week', limit = 20 } = data;

    if (!['day', 'week'].includes(timeWindow)) {
      throw new functions.https.HttpsError('invalid-argument', 'timeWindowは "day" または "week" である必要があります。');
    }

    logger.info('Movie trends request', { timeWindow, limit, userId: context.auth.uid });

    const trendingMovies = await movieDataUtils.getTrendingMovies(timeWindow, limit);

    return {
      success: true,
      movies: trendingMovies,
      count: trendingMovies.length,
      timeWindow,
    };

  } catch (error: any) {
    logger.error('Failed to get movie trends', {
      error: error?.message,
      userId: context.auth?.uid,
    });

    throw new functions.https.HttpsError('internal', `映画トレンド取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});

/**
 * 新作映画を取得する機能
 */
export const getNewReleases = functions.https.onCall(async (data: any, context: any) => {
  try {
    // 認証確認
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
    }

    const { limit = 20, region = 'JP' } = data;

    logger.info('New releases request', { limit, region, userId: context.auth.uid });

    const newMovies = await movieDataUtils.getNewReleases(limit, region);

    return {
      success: true,
      movies: newMovies,
      count: newMovies.length,
      region,
    };

  } catch (error: any) {
    logger.error('Failed to get new releases', {
      error: error?.message,
      userId: context.auth?.uid,
    });

    throw new functions.https.HttpsError('internal', `新作映画取得中にエラーが発生しました: ${error?.message || 'Unknown error'}`);
  }
});
