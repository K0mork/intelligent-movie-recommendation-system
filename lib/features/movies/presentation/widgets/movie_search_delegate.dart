import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/movie_providers.dart';
import '../controllers/movie_controller.dart';
import '../../data/models/movie.dart';

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  @override
  String get searchFieldLabel => '映画を検索...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
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
    return _SearchResults(query: query, onMovieSelected: (movie) {
      close(context, movie);
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
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

    return _SearchResults(query: query, onMovieSelected: (movie) {
      close(context, movie);
    });
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  final Function(Movie) onMovieSelected;

  const _SearchResults({
    required this.query,
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
        ref.read(movieControllerProvider.notifier).searchMovies(query);
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

    final movies = movieState.searchResults;

    if (movies.isEmpty && query.isNotEmpty) {
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

    return ListView.builder(
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
              if (movie.releaseDate.isNotEmpty)
                Text(
                  movie.releaseDate.substring(0, 4),
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
    );
  }
}