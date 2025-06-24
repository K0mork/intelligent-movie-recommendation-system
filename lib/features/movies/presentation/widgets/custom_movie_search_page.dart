import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/movie_providers.dart';

class CustomMovieSearchPage extends ConsumerStatefulWidget {
  const CustomMovieSearchPage({super.key});

  @override
  ConsumerState<CustomMovieSearchPage> createState() => _CustomMovieSearchPageState();
}

class _CustomMovieSearchPageState extends ConsumerState<CustomMovieSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedYear;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      final yearInt = selectedYear != null ? int.tryParse(selectedYear!) : null;
      ref.read(movieControllerProvider.notifier).searchMovies(query, year: yearInt);
    }
  }

  void _onYearSelected(String year) {
    setState(() {
      selectedYear = year == 'all' ? null : year;
    });
    // 検索クエリがある場合は再検索
    if (_searchController.text.isNotEmpty) {
      _onSearch(_searchController.text);
    }
  }

  List<PopupMenuItem<String>> _buildYearMenuItems() {
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final movieState = ref.watch(movieControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('映画を検索'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // 年指定フィルター
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.date_range,
                color: selectedYear != null ? theme.colorScheme.primary : null,
              ),
              tooltip: '公開年で絞り込み',
              onSelected: _onYearSelected,
              itemBuilder: (context) => _buildYearMenuItems(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                selectedYear = null;
              });
              // 検索結果をクリア
              ref.read(movieControllerProvider.notifier).clearSearchResults();
            },
          ),
        ],
      ),
      body: Focus(
        autofocus: false, // 重要: これがフォーカス問題を解決
        child: Column(
          children: [
            // 検索フィールド
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '映画を検索...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainer,
                ),
                onChanged: (value) {
                  // リアルタイム検索（500ms遅延）
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value && value.isNotEmpty) {
                      _onSearch(value);
                    }
                  });
                },
                onSubmitted: _onSearch,
              ),
            ),

            // 年フィルター表示
            if (selectedYear != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$selectedYear年代で絞り込み中',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // 検索結果
            Expanded(
              child: _buildSearchResults(context, movieState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, dynamic movieState) {
    final theme = Theme.of(context);

    if (_searchController.text.isEmpty) {
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
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$selectedYear年代で絞り込み中',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (movieState.isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (movieState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              movieState.errorMessage!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    var movies = movieState.searchResults;

    // 年フィルタリング処理
    if (selectedYear != null && movies.isNotEmpty) {
      final yearInt = int.tryParse(selectedYear!);
      if (yearInt != null) {
        movies = movies.where((movie) {
          if (movie.releaseDate?.isNotEmpty == true) {
            try {
              final movieYear = int.parse(movie.releaseDate!.substring(0, 4));
              // 年代範囲での絞り込み（例：2020年代 = 2020-2024）
              return movieYear >= yearInt && movieYear < yearInt + 5;
            } catch (e) {
              return false;
            }
          }
          return false;
        }).toList();
      }
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

    return Column(
      children: [
        // 検索結果件数表示
        if (movies.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${movies.length}件の映画が見つかりました',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

        Expanded(
          child: ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                leading: movie.posterPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                          width: 46,
                          height: 69,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 46,
                              height: 69,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.movie,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 46,
                        height: 69,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.movie,
                          color: Colors.grey,
                        ),
                      ),
                title: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (movie.releaseDate?.isNotEmpty == true)
                      Text(
                        movie.releaseDate!.substring(0, 4),
                        style: theme.textTheme.bodySmall,
                      ),
                    if (movie.voteAverage > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
                onTap: () => Navigator.of(context).pop(movie),
              );
            },
          ),
        ),
      ],
    );
  }
}
