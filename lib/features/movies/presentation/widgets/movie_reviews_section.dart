import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';
import '../../../reviews/presentation/pages/add_review_page.dart';
import '../../../reviews/presentation/pages/edit_review_page.dart';
import '../../../reviews/presentation/widgets/review_card.dart';
import '../../../reviews/presentation/providers/review_providers.dart';
import '../../../reviews/domain/entities/review.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../../../core/widgets/loading_state_widget.dart';

/// 映画レビューセクション
/// レビューボタン、レビューリスト、認証状態の管理を行う
class MovieReviewsSection extends ConsumerWidget {
  final Movie movie;
  final bool showReviewButton;

  const MovieReviewsSection({
    super.key,
    required this.movie,
    this.showReviewButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final reviewsAsync = ref.watch(movieReviewsProvider(movie.id.toString()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // セクションタイトル
        Text(
          'レビュー',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        
        // レビューボタン
        if (showReviewButton)
          _ReviewButton(
            movie: movie,
            authState: authState,
          ),
        
        const SizedBox(height: 16),
        
        // レビューリスト
        _ReviewsList(
          movie: movie,
          reviewsAsync: reviewsAsync,
          authState: authState,
        ),
      ],
    );
  }
}

/// レビューボタン（認証状態に応じて表示切り替え）
class _ReviewButton extends StatelessWidget {
  final Movie movie;
  final AsyncValue<dynamic> authState;

  const _ReviewButton({
    required this.movie,
    required this.authState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return authState.when(
      data: (user) {
        if (user != null) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToAddReview(context),
              icon: const Icon(Icons.rate_review),
              label: const Text('レビューを書く'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          );
        } else {
          return const AuthRequiredWidget(
            type: AuthRequiredType.reviews,
          );
        }
      },
      loading: () => const LoadingStateWidget.inline(),
      error: (error, stackTrace) => _ErrorView(
        theme: theme,
        error: error,
      ),
    );
  }

  void _navigateToAddReview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewPage(movie: movie),
      ),
    );
  }
}


/// エラー表示ビュー
class _ErrorView extends StatelessWidget {
  final ThemeData theme;
  final Object error;

  const _ErrorView({
    required this.theme,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        'エラーが発生しました',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// レビューリスト
class _ReviewsList extends ConsumerWidget {
  final Movie movie;
  final AsyncValue<List<Review>> reviewsAsync;
  final AsyncValue<dynamic> authState;

  const _ReviewsList({
    required this.movie,
    required this.reviewsAsync,
    required this.authState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return _EmptyReviewsView(theme: theme);
        }
        
        return _ReviewsListView(
          reviews: reviews,
          authState: authState,
          theme: theme,
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => _ReviewsErrorView(
        theme: theme,
        error: error,
        onRetry: () => ref.refresh(movieReviewsProvider(movie.id.toString())),
      ),
    );
  }
}

/// レビューが空の場合のビュー
class _EmptyReviewsView extends StatelessWidget {
  final ThemeData theme;

  const _EmptyReviewsView({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'まだレビューがありません',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '最初のレビューを書いてみませんか？',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// レビューリストビュー
class _ReviewsListView extends StatelessWidget {
  final List<Review> reviews;
  final AsyncValue<dynamic> authState;
  final ThemeData theme;

  const _ReviewsListView({
    required this.reviews,
    required this.authState,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${reviews.length}件のレビュー',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ...reviews.map((review) {
          final currentUser = authState.value;
          final isOwnReview = currentUser?.uid == review.userId;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ReviewCard(
              review: review,
              showMovieInfo: false,
              onEdit: isOwnReview ? () => _editReview(context, review) : null,
              onDelete: isOwnReview ? () => _showDeleteConfirmation(context, review) : null,
            ),
          );
        }),
      ],
    );
  }

  void _editReview(BuildContext context, Review review) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReviewPage(review: review),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('レビューを削除'),
        content: const Text('このレビューを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: レビュー削除処理の実装
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}

/// レビュー読み込みエラー時のビュー
class _ReviewsErrorView extends StatelessWidget {
  final ThemeData theme;
  final Object error;
  final VoidCallback onRetry;

  const _ReviewsErrorView({
    required this.theme,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'レビューの読み込みに失敗しました',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }
}