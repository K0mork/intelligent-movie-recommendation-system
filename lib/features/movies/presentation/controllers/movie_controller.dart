import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmflow/features/movies/domain/usecases/get_popular_movies_usecase.dart';
import 'package:filmflow/features/movies/domain/usecases/search_movies_usecase.dart';
import 'package:filmflow/features/movies/domain/usecases/get_movie_details_usecase.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';

class MovieState {
  final List<Movie> popularMovies;
  final List<Movie> searchResults;
  final Movie? selectedMovie;
  final bool isLoading;
  final String? errorMessage;
  final bool isSearching;
  final String searchQuery;

  const MovieState({
    this.popularMovies = const [],
    this.searchResults = const [],
    this.selectedMovie,
    this.isLoading = false,
    this.errorMessage,
    this.isSearching = false,
    this.searchQuery = '',
  });

  MovieState copyWith({
    List<Movie>? popularMovies,
    List<Movie>? searchResults,
    Movie? selectedMovie,
    bool? isLoading,
    String? errorMessage,
    bool? isSearching,
    String? searchQuery,
    bool clearSelectedMovie = false,
    bool clearError = false,
  }) {
    return MovieState(
      popularMovies: popularMovies ?? this.popularMovies,
      searchResults: searchResults ?? this.searchResults,
      selectedMovie:
          clearSelectedMovie ? null : selectedMovie ?? this.selectedMovie,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class MovieController extends StateNotifier<MovieState> {
  final GetPopularMoviesUseCase _getPopularMoviesUseCase;
  final SearchMoviesUseCase _searchMoviesUseCase;
  final GetMovieDetailsUseCase _getMovieDetailsUseCase;

  MovieController({
    required GetPopularMoviesUseCase getPopularMoviesUseCase,
    required SearchMoviesUseCase searchMoviesUseCase,
    required GetMovieDetailsUseCase getMovieDetailsUseCase,
  }) : _getPopularMoviesUseCase = getPopularMoviesUseCase,
       _searchMoviesUseCase = searchMoviesUseCase,
       _getMovieDetailsUseCase = getMovieDetailsUseCase,
       super(const MovieState());

  Future<void> loadPopularMovies({int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final movies = await _getPopularMoviesUseCase.call(page: page);

      if (page == 1) {
        state = state.copyWith(popularMovies: movies, isLoading: false);
      } else {
        state = state.copyWith(
          popularMovies: [...state.popularMovies, ...movies],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> searchMovies(String query, {int page = 1, int? year}) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(
        searchResults: [],
        searchQuery: '',
        isSearching: false,
        clearError: true,
      );
      return;
    }

    if (page == 1) {
      state = state.copyWith(
        isSearching: true,
        searchQuery: query,
        clearError: true,
      );
    }

    try {
      final movies = await _searchMoviesUseCase.call(
        query,
        page: page,
        year: year,
      );

      if (page == 1) {
        state = state.copyWith(searchResults: movies, isSearching: false);
      } else {
        state = state.copyWith(
          searchResults: [...state.searchResults, ...movies],
          isSearching: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isSearching: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMovieDetails(int movieId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final movie = await _getMovieDetailsUseCase.call(movieId);
      state = state.copyWith(selectedMovie: movie, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearSelectedMovie() {
    state = state.copyWith(clearSelectedMovie: true);
  }

  void clearSearchResults() {
    state = state.copyWith(
      searchResults: [],
      searchQuery: '',
      isSearching: false,
      clearError: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
