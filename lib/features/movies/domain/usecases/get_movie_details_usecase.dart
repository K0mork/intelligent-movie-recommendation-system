import 'package:filmflow/features/movies/domain/repositories/movie_repository.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';

class GetMovieDetailsUseCase {
  final MovieRepository _repository;

  GetMovieDetailsUseCase(this._repository);

  Future<Movie> call(int movieId) async {
    if (movieId <= 0) {
      throw ArgumentError('Movie ID must be positive');
    }
    return await _repository.getMovieDetails(movieId);
  }
}
