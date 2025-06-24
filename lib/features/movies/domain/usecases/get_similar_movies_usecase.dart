import 'package:filmflow/features/movies/domain/repositories/movie_repository.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';

class GetSimilarMoviesUseCase {
  final MovieRepository _repository;

  GetSimilarMoviesUseCase(this._repository);

  Future<List<Movie>> call(int movieId, {int page = 1}) async {
    return await _repository.getSimilarMovies(movieId, page: page);
  }
}
