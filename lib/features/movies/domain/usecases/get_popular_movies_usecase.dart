import 'package:movie_recommend_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_recommend_app/shared/models/movie.dart';

class GetPopularMoviesUseCase {
  final MovieRepository _repository;

  GetPopularMoviesUseCase(this._repository);

  Future<List<Movie>> call({int page = 1}) async {
    return await _repository.getPopularMovies(page: page);
  }
}