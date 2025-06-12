import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_recommend_app/core/config/env_config.dart';
import 'package:movie_recommend_app/features/movies/presentation/providers/movie_providers.dart';
import 'package:movie_recommend_app/features/movies/presentation/widgets/movie_grid.dart';
import 'package:movie_recommend_app/features/movies/presentation/pages/movie_detail_page.dart';
import 'package:movie_recommend_app/features/movies/presentation/pages/api_setup_page.dart';
import 'package:movie_recommend_app/features/movies/data/models/movie.dart';

class MoviesPage extends ConsumerStatefulWidget {
  const MoviesPage({super.key});

  @override
  ConsumerState<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends ConsumerState<MoviesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _popularScrollController = ScrollController();
  final ScrollController _searchScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(movieControllerProvider.notifier).loadPopularMovies();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _popularScrollController.dispose();
    _searchScrollController.dispose();
    super.dispose();
  }

  void _onMovieTap(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailPage(movieId: movie.id),
      ),
    );
  }

  void _onSearchChanged(String query) {
    ref.read(movieControllerProvider.notifier).searchMovies(query);
  }

  @override
  Widget build(BuildContext context) {
    if (!EnvConfig.isMovieApiConfigured) {
      return const ApiSetupPage();
    }

    final movieState = ref.watch(movieControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('映画'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '人気'),
            Tab(text: '検索'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PopularMoviesTab(
            movies: movieState.popularMovies,
            isLoading: movieState.isLoading,
            errorMessage: movieState.errorMessage,
            onMovieTap: _onMovieTap,
            onLoadMore: () {
              final currentPage = (movieState.popularMovies.length / 20).ceil();
              ref.read(movieControllerProvider.notifier).loadPopularMovies(page: currentPage + 1);
            },
            scrollController: _popularScrollController,
          ),
          _SearchMoviesTab(
            searchController: _searchController,
            movies: movieState.searchResults,
            isLoading: movieState.isSearching,
            errorMessage: movieState.errorMessage,
            onSearchChanged: _onSearchChanged,
            onMovieTap: _onMovieTap,
            scrollController: _searchScrollController,
          ),
        ],
      ),
    );
  }
}

class _PopularMoviesTab extends StatelessWidget {
  final List<Movie> movies;
  final bool isLoading;
  final String? errorMessage;
  final Function(Movie) onMovieTap;
  final VoidCallback onLoadMore;
  final ScrollController scrollController;

  const _PopularMoviesTab({
    required this.movies,
    required this.isLoading,
    required this.errorMessage,
    required this.onMovieTap,
    required this.onLoadMore,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null && movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    if (movies.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return MovieGrid(
      movies: movies,
      onMovieTap: onMovieTap,
      isLoading: isLoading,
      onLoadMore: onLoadMore,
      scrollController: scrollController,
    );
  }
}

class _SearchMoviesTab extends StatelessWidget {
  final TextEditingController searchController;
  final List<Movie> movies;
  final bool isLoading;
  final String? errorMessage;
  final Function(String) onSearchChanged;
  final Function(Movie) onMovieTap;
  final ScrollController scrollController;

  const _SearchMoviesTab({
    required this.searchController,
    required this.movies,
    required this.isLoading,
    required this.errorMessage,
    required this.onSearchChanged,
    required this.onMovieTap,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: '映画を検索...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        Expanded(
          child: _buildSearchResults(context),
        ),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (searchController.text.trim().isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '映画を検索してください',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null && movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (movies.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (movies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '検索結果が見つかりませんでした',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return MovieGrid(
      movies: movies,
      onMovieTap: onMovieTap,
      isLoading: isLoading,
      scrollController: scrollController,
    );
  }
}