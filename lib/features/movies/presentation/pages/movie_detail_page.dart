import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmflow/features/movies/presentation/providers/movie_providers.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';
import '../widgets/movie_detail_header.dart';
import '../widgets/movie_info_section.dart';
import '../widgets/movie_reviews_section.dart';
import '../widgets/related_movies_section.dart';
import '../../../../core/widgets/breadcrumb_widget.dart';

/// 映画詳細画面
/// 映画の詳細情報、レビュー、関連映画を表示
class MovieDetailPage extends ConsumerWidget {
  final int movieId;
  final bool showReviewButton;

  const MovieDetailPage({
    super.key,
    required this.movieId,
    this.showReviewButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final movieAsync = ref.watch(movieDetailsProvider(movieId));

      return Scaffold(
        body: movieAsync.when(
          data: (movie) {
            return _MovieDetailView(
              movie: movie,
              showReviewButton: showReviewButton,
            );
          },
          loading: () => const _LoadingView(),
          error: (error, _) => _ErrorView(
            error: error,
            onRetry: () => ref.refresh(movieDetailsProvider(movieId)),
          ),
        ),
      );
    } catch (e, _) {
      return Scaffold(
        body: _ErrorView(
          error: Exception('映画詳細画面の読み込みに失敗しました: $e'),
          onRetry: () => ref.refresh(movieDetailsProvider(movieId)),
        ),
      );
    }
  }
}

/// 映画詳細のメインビュー
class _MovieDetailView extends StatelessWidget {
  final Movie movie;
  final bool showReviewButton;

  const _MovieDetailView({required this.movie, this.showReviewButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 映画詳細ヘッダー（ポスター、背景画像、基本情報）
            MovieDetailHeader(
              movie: movie,
              showReviewButton: showReviewButton,
            ),

            // 映画詳細情報セクション
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MovieInfoSection(movie: movie),
            ),

            const SizedBox(height: 24),

            // レビューセクション（レビュー表示・追加・編集・削除）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MovieReviewsSection(
                movie: movie,
                showReviewButton: showReviewButton,
              ),
            ),

            const SizedBox(height: 24),

            // 関連映画セクション（類似映画・おすすめ映画）
            RelatedMoviesSection(
              movieId: movie.id,
              title: '関連映画',
              showSimilar: true,
              showRecommended: true,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// ローディング表示
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// エラー表示
class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('再試行')),
          ],
        ),
      ),
    );
  }
}
