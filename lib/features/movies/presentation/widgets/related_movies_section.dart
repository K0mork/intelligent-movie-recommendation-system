import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/movie_providers.dart';
import 'package:filmflow/features/movies/data/models/movie.dart' as models;
import '../pages/movie_detail_page.dart';
import '../../../../core/widgets/loading_animations.dart';

class RelatedMoviesSection extends ConsumerWidget {
  final int movieId;
  final String title;
  final bool showSimilar;
  final bool showRecommended;

  const RelatedMoviesSection({
    super.key,
    required this.movieId,
    this.title = '関連映画',
    this.showSimilar = true,
    this.showRecommended = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (showSimilar) ...[
          _RelatedMoviesList(
            movieId: movieId,
            title: '類似映画',
            isSimilar: true,
          ),
          const SizedBox(height: 20),
        ],

        if (showRecommended) ...[
          _RelatedMoviesList(
            movieId: movieId,
            title: 'おすすめ映画',
            isSimilar: false,
          ),
        ],
      ],
    );
  }
}

class _RelatedMoviesList extends ConsumerWidget {
  final int movieId;
  final String title;
  final bool isSimilar;

  const _RelatedMoviesList({
    required this.movieId,
    required this.title,
    required this.isSimilar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final moviesAsync = isSimilar
        ? ref.watch(similarMoviesProvider(movieId))
        : ref.watch(recommendedMoviesProvider(movieId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                isSimilar ? Icons.compare_arrows : Icons.recommend,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 200,
          child: moviesAsync.when(
            data: (movies) {
              if (movies.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      '関連する映画が見つかりませんでした',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return _RelatedMovieCard(
                    movie: movie,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MovieDetailPage(movieId: movie.id),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularWaveLoading(
                color: Colors.blue,
                size: 40,
              ),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '読み込みに失敗しました',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RelatedMovieCard extends StatelessWidget {
  final models.Movie movie;
  final VoidCallback onTap;

  const _RelatedMovieCard({
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ポスター画像
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 140,
                width: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                ),
                child: movie.fullPosterUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: movie.fullPosterUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.colorScheme.surfaceContainer,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surfaceContainer,
                          child: Icon(
                            Icons.movie,
                            size: 40,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.movie,
                        size: 40,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
              ),
            ),

            const SizedBox(height: 8),

            // 映画タイトル
            Text(
              movie.title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // 評価
            if (movie.voteAverage > 0)
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 12,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
