import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:filmflow/core/config/env_config.dart';
import 'package:filmflow/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:filmflow/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:filmflow/features/movies/domain/repositories/movie_repository.dart';
import 'package:filmflow/features/movies/domain/usecases/get_popular_movies_usecase.dart';
import 'package:filmflow/features/movies/domain/usecases/search_movies_usecase.dart';
import 'package:filmflow/features/movies/domain/usecases/get_movie_details_usecase.dart';
import 'package:filmflow/features/movies/domain/usecases/get_similar_movies_usecase.dart';
import 'package:filmflow/features/movies/domain/usecases/get_recommended_movies_usecase.dart';
import 'package:filmflow/features/movies/presentation/controllers/movie_controller.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 10);
  return dio;
});

final movieRemoteDataSourceProvider = Provider<MovieRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);

  if (EnvConfig.isTmdbConfigured) {
    return TMDBRemoteDataSource(dio: dio);
  } else if (EnvConfig.isOmdbConfigured) {
    return OMDBRemoteDataSource(dio: dio);
  } else {
    throw Exception('映画API設定が見つかりません。TMDB_API_KEYまたはOMDB_API_KEYを設定してください。');
  }
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final remoteDataSource = ref.read(movieRemoteDataSourceProvider);
  return MovieRepositoryImpl(remoteDataSource: remoteDataSource);
});

final getPopularMoviesUseCaseProvider = Provider<GetPopularMoviesUseCase>((
  ref,
) {
  final repository = ref.read(movieRepositoryProvider);
  return GetPopularMoviesUseCase(repository);
});

final searchMoviesUseCaseProvider = Provider<SearchMoviesUseCase>((ref) {
  final repository = ref.read(movieRepositoryProvider);
  return SearchMoviesUseCase(repository);
});

final getMovieDetailsUseCaseProvider = Provider<GetMovieDetailsUseCase>((ref) {
  final repository = ref.read(movieRepositoryProvider);
  return GetMovieDetailsUseCase(repository);
});

final getSimilarMoviesUseCaseProvider = Provider<GetSimilarMoviesUseCase>((
  ref,
) {
  final repository = ref.read(movieRepositoryProvider);
  return GetSimilarMoviesUseCase(repository);
});

final getRecommendedMoviesUseCaseProvider =
    Provider<GetRecommendedMoviesUseCase>((ref) {
      final repository = ref.read(movieRepositoryProvider);
      return GetRecommendedMoviesUseCase(repository);
    });

final movieControllerProvider =
    StateNotifierProvider<MovieController, MovieState>((ref) {
      final getPopularMoviesUseCase = ref.read(getPopularMoviesUseCaseProvider);
      final searchMoviesUseCase = ref.read(searchMoviesUseCaseProvider);
      final getMovieDetailsUseCase = ref.read(getMovieDetailsUseCaseProvider);

      return MovieController(
        getPopularMoviesUseCase: getPopularMoviesUseCase,
        searchMoviesUseCase: searchMoviesUseCase,
        getMovieDetailsUseCase: getMovieDetailsUseCase,
      );
    });

final popularMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final useCase = ref.read(getPopularMoviesUseCaseProvider);
  return await useCase.call();
});

final movieSearchProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Movie>>((ref) async {
  final searchQuery = ref.watch(movieSearchProvider);
  if (searchQuery.trim().isEmpty) {
    return [];
  }

  final useCase = ref.read(searchMoviesUseCaseProvider);
  return await useCase.call(searchQuery);
});

final movieDetailsProvider = FutureProvider.family<Movie, int>((
  ref,
  movieId,
) async {
  final useCase = ref.read(getMovieDetailsUseCaseProvider);
  return await useCase.call(movieId);
});

final similarMoviesProvider = FutureProvider.family<List<Movie>, int>((
  ref,
  movieId,
) async {
  final useCase = ref.read(getSimilarMoviesUseCaseProvider);
  return await useCase.call(movieId);
});

final recommendedMoviesProvider = FutureProvider.family<List<Movie>, int>((
  ref,
  movieId,
) async {
  final useCase = ref.read(getRecommendedMoviesUseCaseProvider);
  return await useCase.call(movieId);
});
