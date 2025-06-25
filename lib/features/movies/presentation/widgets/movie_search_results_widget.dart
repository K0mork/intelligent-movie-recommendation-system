import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/movie_providers.dart';
import '../../../../core/widgets/movie_poster_widget.dart';
import '../../../../core/widgets/loading_state_widget.dart';
import '../../../../core/widgets/error_widgets.dart';
import 'year_filter_widget.dart';
import 'package:filmflow/features/movies/data/models/movie.dart' as movie_model;

/// 映画検索結果表示ウィジェット
///
/// MovieSearchDelegateから検索結果表示ロジックを分離し、
/// 再利用可能で保守しやすい形にする。
class MovieSearchResultsWidget extends ConsumerWidget {
  final String query;
  final String? selectedYear;
  final Function(movie_model.Movie) onMovieSelected;
  final VoidCallback? onRetry;

  const MovieSearchResultsWidget({
    super.key,
    required this.query,
    this.selectedYear,
    required this.onMovieSelected,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 検索を実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query.isNotEmpty) {
        final yearInt =
            selectedYear != null ? int.tryParse(selectedYear!) : null;
        ref
            .read(movieControllerProvider.notifier)
            .searchMovies(query, year: yearInt);
      }
    });

    final movieState = ref.watch(movieControllerProvider);

    return Column(
      children: [
        // 年代フィルター状態表示
        if (selectedYear != null)
          YearFilterIndicator(
            selectedYear: selectedYear,
            resultCount: movieState.searchResults.length,
          ),
        // 検索結果
        Expanded(child: _buildSearchResults(context, movieState)),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, movieState) {
    if (movieState.isSearching) {
      return const LoadingStateWidget.fullScreen(message: '映画を検索中...');
    }

    if (movieState.errorMessage != null) {
      return ErrorDisplay(
        title: 'エラーが発生しました',
        message: movieState.errorMessage!,
        icon: Icons.error_outline,
        onRetry: onRetry,
        retryText: '再試行',
      );
    }

    var movies = movieState.searchResults;

    // 年フィルタリング処理
    if (selectedYear != null && movies.isNotEmpty) {
      movies =
          movies.where((movie) {
            return YearFilterOptions.isInYearRange(
              movie.releaseDate,
              selectedYear,
            );
          }).toList();
    }

    if (movies.isEmpty && query.isNotEmpty) {
      return _buildEmptyResults(context);
    }

    return MovieSearchResultsList(
      movies: movies,
      onMovieSelected: onMovieSelected,
    );
  }

  Widget _buildEmptyResults(BuildContext context) {
    return EmptyStateWidget(
      title: '検索結果が見つかりませんでした',
      message:
          selectedYear != null
              ? '$selectedYear年代の「$query」に該当する映画が見つかりませんでした'
              : '「$query」に該当する映画が見つかりませんでした',
      icon: Icons.movie_outlined,
      action:
          selectedYear != null
              ? Column(
                children: [
                  const Text(
                    '年代フィルターを解除して再度お試しください',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('再検索'),
                  ),
                ],
              )
              : ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
              ),
    );
  }
}

/// 検索結果リスト表示ウィジェット
class MovieSearchResultsList extends StatelessWidget {
  final List<movie_model.Movie> movies;
  final Function(movie_model.Movie) onMovieSelected;

  const MovieSearchResultsList({
    super.key,
    required this.movies,
    required this.onMovieSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieSearchResultItem(
          movie: movie,
          onTap: () => onMovieSelected(movie),
        );
      },
    );
  }
}

/// 検索結果アイテムウィジェット
class MovieSearchResultItem extends StatelessWidget {
  final movie_model.Movie movie;
  final VoidCallback onTap;

  const MovieSearchResultItem({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: MoviePosterWidget.small(
        posterPath: movie.posterPath,
        heroTag: 'search_result_${movie.id}',
      ),
      title: Text(
        movie.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: _buildSubtitle(context),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 公開年
        if (movie.releaseDate?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            '公開年: ${movie.releaseDate!.substring(0, 4)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        // 評価
        if (movie.voteAverage > 0) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber[600]),
              const SizedBox(width: 4),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${movie.voteCount} votes)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
        // 概要（最初の100文字）
        if (movie.overview?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            movie.overview!.length > 100
                ? '${movie.overview!.substring(0, 100)}...'
                : movie.overview!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// 検索初期状態表示ウィジェット
class MovieSearchInitialState extends StatelessWidget {
  final String? selectedYear;

  const MovieSearchInitialState({super.key, this.selectedYear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '映画を検索してください',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'タイトルや出演者名で映画を探せます',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (selectedYear != null) ...[
            const SizedBox(height: 16),
            YearFilterIndicator(selectedYear: selectedYear),
          ],
        ],
      ),
    );
  }
}

/// 検索ヒント表示ウィジェット
class MovieSearchHints extends StatelessWidget {
  const MovieSearchHints({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '検索のコツ',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildHintItem(
            context,
            icon: Icons.movie,
            title: 'タイトル検索',
            description: '映画のタイトルで検索できます',
          ),
          _buildHintItem(
            context,
            icon: Icons.person,
            title: '出演者検索',
            description: '俳優・女優名で検索できます',
          ),
          _buildHintItem(
            context,
            icon: Icons.date_range,
            title: '年代絞り込み',
            description: '右上のカレンダーアイコンで年代を絞り込めます',
          ),
        ],
      ),
    );
  }

  Widget _buildHintItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
