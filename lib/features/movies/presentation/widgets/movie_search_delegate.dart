import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/movie_providers.dart';
import '../../data/models/movie.dart' as movie_model;

class MovieSearchDelegate extends SearchDelegate<movie_model.Movie?> {
  String? selectedYear;
  
  @override
  String get searchFieldLabel => '映画を検索...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      // 年指定フィルター
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: PopupMenuButton<String>(
          icon: Icon(
            Icons.date_range,
            color: selectedYear != null ? Theme.of(context).colorScheme.primary : null,
          ),
          tooltip: '公開年で絞り込み',
          onSelected: (year) {
            selectedYear = year == 'all' ? null : year;
            showResults(context); // UIを強制的に再描画
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
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          selectedYear = null;
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _SearchResults(
      query: query, 
      selectedYear: selectedYear,
      onMovieSelected: (movie) {
        close(context, movie);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
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

    return _SearchResults(
      query: query, 
      selectedYear: selectedYear,
      onMovieSelected: (movie) {
        close(context, movie);
      },
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  final String? selectedYear;
  final Function(movie_model.Movie) onMovieSelected;

  const _SearchResults({
    required this.query,
    this.selectedYear,
    required this.onMovieSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 検索を実行
    ref.listen(movieControllerProvider, (previous, next) {
      // 状態変化の監視は必要に応じて
    });

    // コントローラーから検索を実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query.isNotEmpty) {
        final yearInt = selectedYear != null ? int.tryParse(selectedYear!) : null;
        ref.read(movieControllerProvider.notifier).searchMovies(query, year: yearInt);
      }
    });

    final movieState = ref.watch(movieControllerProvider);

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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              movieState.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
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

    if (movies.isEmpty && query.isNotEmpty) {
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
        // フィルター状態表示
        if (selectedYear != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(8),
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
                  '$selectedYear年代で絞り込み中 (${movies.length}件)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
                        style: Theme.of(context).textTheme.bodySmall,
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
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
                onTap: () => onMovieSelected(movie),
              );
            },
          ),
        ),
      ],
    );
  }
}