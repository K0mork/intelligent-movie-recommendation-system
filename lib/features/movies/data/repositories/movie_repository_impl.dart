import 'package:movie_recommend_app/core/errors/app_exceptions.dart';
import 'package:movie_recommend_app/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:movie_recommend_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_recommend_app/features/movies/data/models/movie.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remoteDataSource;

  MovieRepositoryImpl({
    required MovieRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      return await _remoteDataSource.getPopularMovies(page: page);
    } on NetworkException {
      rethrow;
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException('Failed to get popular movies: $e');
    }
  }

  @override
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    try {
      return await _remoteDataSource.searchMovies(query, page: page);
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  @override
  Future<Movie> getMovieDetails(int movieId) async {
    try {
      return await _remoteDataSource.getMovieDetails(movieId);
    } catch (e) {
      throw Exception('Failed to get movie details: $e');
    }
  }

  @override
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    try {
      return await _remoteDataSource.getTopRatedMovies(page: page);
    } catch (e) {
      throw Exception('Failed to get top rated movies: $e');
    }
  }

  @override
  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    try {
      return await _remoteDataSource.getNowPlayingMovies(page: page);
    } catch (e) {
      throw Exception('Failed to get now playing movies: $e');
    }
  }

  @override
  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    try {
      return await _remoteDataSource.getUpcomingMovies(page: page);
    } catch (e) {
      throw Exception('Failed to get upcoming movies: $e');
    }
  }
}