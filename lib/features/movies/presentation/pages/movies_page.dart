import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmflow/core/config/env_config.dart';
import 'package:filmflow/features/movies/presentation/providers/movie_providers.dart';
import 'package:filmflow/features/movies/presentation/widgets/movie_grid.dart';
import 'package:filmflow/features/movies/presentation/pages/movie_detail_page.dart';
import 'package:filmflow/features/movies/presentation/pages/api_setup_page.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';
import '../../../../core/widgets/breadcrumb_widget.dart';
import '../../../../core/widgets/loading_state_widget.dart';

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
  String? _selectedYear;

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
    final yearInt = _selectedYear != null ? int.tryParse(_selectedYear!) : null;
    ref.read(movieControllerProvider.notifier).searchMovies(query, year: yearInt);
  }

  void _onYearFilterChanged(String? year) {
    setState(() {
      _selectedYear = year;
    });
    if (_searchController.text.isNotEmpty) {
      _onSearchChanged(_searchController.text);
    }
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
      body: Column(
        children: [
          // パンくずナビゲーション
          BreadcrumbWidget(
            items: BreadcrumbHelper.createMovieBreadcrumbs(
              context: context,
            ),
          ),
          Expanded(
            child: TabBarView(
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
                  selectedYear: _selectedYear,
                  onYearFilterChanged: _onYearFilterChanged,
                ),
              ],
            ),
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
      return const LoadingStateWidget.fullScreen();
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
  final String? selectedYear;
  final Function(String?) onYearFilterChanged;

  const _SearchMoviesTab({
    required this.searchController,
    required this.movies,
    required this.isLoading,
    required this.errorMessage,
    required this.onSearchChanged,
    required this.onMovieTap,
    required this.scrollController,
    required this.selectedYear,
    required this.onYearFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Focus(
                  child: TextField(
                    controller: searchController,
                    autofocus: false,
                    decoration: const InputDecoration(
                      hintText: '映画を検索...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 年指定フィルター
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.date_range,
                    color: selectedYear != null ? Theme.of(context).colorScheme.primary : null,
                  ),
                  tooltip: '公開年で絞り込み',
                  onSelected: (year) {
                    onYearFilterChanged(year == 'all' ? null : year);
                  },
                  itemBuilder: (context) {
                    final currentYear = DateTime.now().year;
                    final years = <String>['all'];
                    for (int year = currentYear; year >= 1900; year -= 5) {
                      years.add(year.toString());
                    }
                    
                    return years.map((year) {
                      return PopupMenuItem<String>(
                        value: year,
                        child: Row(
                          children: [
                            if (year == 'all') ...[
                              const Icon(Icons.clear),
                              const SizedBox(width: 8),
                              const Text('全ての年'),
                            ] else ...[
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 8),
                              Text('$year年代'),
                            ],
                            if (selectedYear == year || (selectedYear == null && year == 'all'))
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ],
          ),
        ),
        // 年フィルター状態表示
        if (selectedYear != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  '$selectedYear年代で絞り込み中',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  onPressed: () => onYearFilterChanged(null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
                ),
              ],
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '映画を検索してください',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            if (selectedYear != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$selectedYear年代で絞り込み中',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
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
      return const LoadingStateWidget.fullScreen();
    }

    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              selectedYear != null 
                ? '$selectedYear年代の検索結果が見つかりませんでした'
                : '検索結果が見つかりませんでした',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (selectedYear != null) ...[
              const SizedBox(height: 8),
              const Text(
                '年代フィルターを解除して再度お試しください',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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