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
    final movieAsync = ref.watch(movieDetailsProvider(movieId));

    return Scaffold(
      body: movieAsync.when(
        data: (movie) => _MovieDetailView(
          movie: movie, 
          showReviewButton: showReviewButton,
        ),
        loading: () => const _LoadingView(),
        error: (error, stackTrace) => _ErrorView(
          error: error,
          onRetry: () => ref.refresh(movieDetailsProvider(movieId)),
        ),
      ),
    );
  }
}

/// 映画詳細のメインビュー
class _MovieDetailView extends StatelessWidget {
  final Movie movie;
  final bool showReviewButton;

  const _MovieDetailView({
    required this.movie, 
    this.showReviewButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ヘッダー（背景画像付きSliverAppBar）
        MovieDetailHeader(movie: movie),
        
        // パンくずナビゲーション
        SliverToBoxAdapter(
          child: BreadcrumbWidget(
            items: BreadcrumbHelper.createMovieBreadcrumbs(
              context: context,
              movieTitle: movie.title,
            ),
          ),
        ),
        
        // メインコンテンツ
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 映画情報セクション
                MovieInfoSection(movie: movie),
                
                const SizedBox(height: 24),
                
                // レビューセクション
                MovieReviewsSection(
                  movie: movie,
                  showReviewButton: showReviewButton,
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        
        // 関連映画セクション
        SliverToBoxAdapter(
          child: RelatedMoviesSection(
            movieId: movie.id,
            title: 'この映画に関連する作品',
          ),
        ),
        
        // 下部スペース
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }
}

/// ローディング表示
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// エラー表示
class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}

