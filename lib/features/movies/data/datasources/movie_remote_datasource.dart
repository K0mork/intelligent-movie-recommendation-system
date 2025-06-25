import 'package:dio/dio.dart';
import 'package:filmflow/core/config/env_config.dart';
import 'package:filmflow/core/constants/app_constants.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';

abstract class MovieRemoteDataSource {
  Future<List<Movie>> getPopularMovies({int page = 1});
  Future<List<Movie>> searchMovies(String query, {int page = 1, int? year});
  Future<Movie> getMovieDetails(int movieId);
  Future<List<Movie>> getTopRatedMovies({int page = 1});
  Future<List<Movie>> getNowPlayingMovies({int page = 1});
  Future<List<Movie>> getUpcomingMovies({int page = 1});
  Future<List<Movie>> getSimilarMovies(int movieId, {int page = 1});
  Future<List<Movie>> getRecommendedMovies(int movieId, {int page = 1});
}

class TMDBRemoteDataSource implements MovieRemoteDataSource {
  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;

  TMDBRemoteDataSource({Dio? dio, String? apiKey, String? baseUrl})
    : _dio = dio ?? Dio(),
      _apiKey = apiKey ?? EnvConfig.tmdbApiKey,
      _baseUrl = baseUrl ?? EnvConfig.tmdbBaseUrl {
    _dio.options.connectTimeout = AppConstants.connectTimeout;
    _dio.options.receiveTimeout = AppConstants.receiveTimeout;

    if (_apiKey.isEmpty) {
      throw Exception(
        'TMDb API key is not configured. Please set TMDB_API_KEY in your environment.',
      );
    }
  }

  Map<String, dynamic> get _defaultParams => {
    'api_key': _apiKey,
    'language': AppConstants.defaultLanguage,
  };

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/popular',
        queryParameters: {..._defaultParams, 'page': page},
      );

      final results =
          (response.data['results'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
      return results.map((json) => Movie.fromTMDBJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch popular movies: $e');
    }
  }

  @override
  Future<List<Movie>> searchMovies(
    String query, {
    int page = 1,
    int? year,
  }) async {
    try {
      final queryParams = {..._defaultParams, 'query': query, 'page': page};

      // 年が指定された場合、TMDb APIのyearパラメータを追加
      if (year != null) {
        queryParams['year'] = year;
      }

      final response = await _dio.get(
        '$_baseUrl/search/movie',
        queryParameters: queryParams,
      );

      final results =
          (response.data['results'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
      return results.map((json) => Movie.fromTMDBJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  @override
  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/$movieId',
        queryParameters: {
          ..._defaultParams,
          'append_to_response': 'credits,videos,similar',
        },
      );

      return Movie.fromTMDBJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch movie details: $e');
    }
  }

  @override
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/top_rated',
        queryParameters: {..._defaultParams, 'page': page},
      );

      final results =
          (response.data['results'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
      return results.map((json) => Movie.fromTMDBJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch top rated movies: $e');
    }
  }

  @override
  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/now_playing',
        queryParameters: {..._defaultParams, 'page': page},
      );

      final results =
          (response.data['results'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
      return results.map((json) => Movie.fromTMDBJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch now playing movies: $e');
    }
  }

  @override
  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/upcoming',
        queryParameters: {..._defaultParams, 'page': page},
      );

      final results =
          (response.data['results'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
      return results.map((json) => Movie.fromTMDBJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming movies: $e');
    }
  }

  @override
  Future<List<Movie>> getSimilarMovies(int movieId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/$movieId/similar',
        queryParameters: {..._defaultParams, 'page': page},
      );

      final results =
          (response.data['results'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
      return results.map((json) => Movie.fromTMDBJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch similar movies: $e');
    }
  }

  @override
  Future<List<Movie>> getRecommendedMovies(int movieId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/$movieId/recommendations',
        queryParameters: {..._defaultParams, 'page': page},
      );

      final results =
          (response.data['results'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
      return results.map((json) => Movie.fromTMDBJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch recommended movies: $e');
    }
  }
}

class OMDBRemoteDataSource implements MovieRemoteDataSource {
  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;

  OMDBRemoteDataSource({Dio? dio, String? apiKey, String? baseUrl})
    : _dio = dio ?? Dio(),
      _apiKey = apiKey ?? EnvConfig.omdbApiKey,
      _baseUrl = baseUrl ?? EnvConfig.omdbBaseUrl {
    _dio.options.connectTimeout = AppConstants.connectTimeout;
    _dio.options.receiveTimeout = AppConstants.receiveTimeout;

    if (_apiKey.isEmpty) {
      throw Exception(
        'OMDb API key is not configured. Please set OMDB_API_KEY in your environment.',
      );
    }
  }

  Map<String, dynamic> get _defaultParams => {'apikey': _apiKey};

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    throw UnimplementedError(
      'OMDb API does not support popular movies endpoint. Use TMDb instead.',
    );
  }

  @override
  Future<List<Movie>> searchMovies(
    String query, {
    int page = 1,
    int? year,
  }) async {
    try {
      final queryParams = {..._defaultParams, 's': query, 'page': page};

      // 年が指定された場合、OMDb APIのyパラメータを追加
      if (year != null) {
        queryParams['y'] = year;
      }

      final response = await _dio.get(_baseUrl, queryParameters: queryParams);

      if (response.data['Response'] == 'False') {
        throw Exception(response.data['Error']);
      }

      final results =
          (response.data['Search'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
      return results.map((json) => Movie.fromOMDBJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  @override
  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {..._defaultParams, 'i': 'tt$movieId', 'plot': 'full'},
      );

      if (response.data['Response'] == 'False') {
        throw Exception(response.data['Error']);
      }

      return Movie.fromOMDBJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch movie details: $e');
    }
  }

  @override
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    throw UnimplementedError(
      'OMDb API does not support top rated movies endpoint. Use TMDb instead.',
    );
  }

  @override
  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    throw UnimplementedError(
      'OMDb API does not support now playing movies endpoint. Use TMDb instead.',
    );
  }

  @override
  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    throw UnimplementedError(
      'OMDb API does not support upcoming movies endpoint. Use TMDb instead.',
    );
  }

  @override
  Future<List<Movie>> getSimilarMovies(int movieId, {int page = 1}) async {
    throw UnimplementedError(
      'OMDb API does not support similar movies endpoint. Use TMDb instead.',
    );
  }

  @override
  Future<List<Movie>> getRecommendedMovies(int movieId, {int page = 1}) async {
    throw UnimplementedError(
      'OMDb API does not support recommended movies endpoint. Use TMDb instead.',
    );
  }
}
