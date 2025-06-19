import 'package:filmflow/features/movies/data/models/movie.dart';

abstract class MovieRepository {
  Future<List<Movie>> getPopularMovies({int page = 1});
  Future<List<Movie>> searchMovies(String query, {int page = 1, int? year});
  Future<Movie> getMovieDetails(int movieId);
  Future<List<Movie>> getTopRatedMovies({int page = 1});
  Future<List<Movie>> getNowPlayingMovies({int page = 1});
  Future<List<Movie>> getUpcomingMovies({int page = 1});
  Future<List<Movie>> getSimilarMovies(int movieId, {int page = 1});
  Future<List<Movie>> getRecommendedMovies(int movieId, {int page = 1});
}