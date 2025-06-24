import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/review_providers.dart';
import '../widgets/review_card.dart';
import '../widgets/review_statistics.dart';
import '../../domain/entities/review.dart';
import '../../../movies/presentation/pages/movie_detail_page.dart';
import '../../../../core/widgets/loading_state_widget.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../../../core/widgets/breadcrumb_widget.dart';

/// レビュー履歴タブのビュー
///
/// ユーザーの過去のレビュー表示とソート機能を担当。
/// integrated_reviews_page.dartから責任を分離。
class ReviewHistoryTabView extends ConsumerWidget {
  final String sortBy;
  final VoidCallback? onRefresh;

  const ReviewHistoryTabView({
    super.key,
    required this.sortBy,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const AuthRequiredWidget(
            title: 'ログインが必要です',
            message: 'レビュー履歴を見るにはログインしてください',
            type: AuthRequiredType.reviews,
            padding: EdgeInsets.all(32.0),
          );
        }
        return _buildHistoryContent(context, ref, user.uid);
      },
      loading: () => const LoadingStateWidget.fullScreen(),
      error: (error, stackTrace) => ErrorDisplay(
        message: 'ユーザー情報の取得に失敗しました',
        onRetry: () => ref.refresh(authStateProvider),
      ),
    );
  }

  Widget _buildHistoryContent(BuildContext context, WidgetRef ref, String userId) {
    final reviewsState = ref.watch(userReviewsProvider(userId));
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(userReviewsProvider(userId));
        onRefresh?.call();
      },
      child: reviewsState.when(
        data: (reviews) => _buildReviewsList(context, ref, reviews, theme),
        loading: () => const LoadingStateWidget.fullScreen(),
        error: (error, stackTrace) => ErrorDisplay(
          message: 'レビューの取得に失敗しました',
          onRetry: () => ref.refresh(userReviewsProvider(userId)),
        ),
      ),
    );
  }

  Widget _buildReviewsList(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> reviews,
    ThemeData theme,
  ) {
    if (reviews.isEmpty) {
      return _buildEmptyState(theme);
    }

    // ソート処理
    final sortedReviews = _sortReviews(reviews);

    return CustomScrollView(
      slivers: [
        // 統計情報
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(theme, reviews.length),
                const SizedBox(height: 16),
                ReviewStatistics(reviews: reviews.cast<Review>()),
                const SizedBox(height: 24),
                _buildSortIndicator(theme),
              ],
            ),
          ),
        ),

        // レビューリスト
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ReviewCard(
                  review: sortedReviews[index],
                  onTap: () => _navigateToMovieDetail(context, sortedReviews[index]),
                  onEdit: () => _navigateToEditReview(context, sortedReviews[index]),
                  onDelete: () => _showDeleteConfirmation(
                    context,
                    ref,
                    sortedReviews[index],
                  ),
                ),
              ),
              childCount: sortedReviews.length,
            ),
          ),
        ),

        // フッター
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(ThemeData theme, int reviewCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              size: 28,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'レビュー履歴',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$reviewCount件のレビューがあります',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSortIndicator(ThemeData theme) {
    final sortText = _getSortText();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sort,
            size: 16,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            sortText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'まだレビューがありません',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '映画を選択してレビューを投稿してみましょう',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            BreadcrumbWidget(
              items: const [
                BreadcrumbItem(
                  label: '新規レビュータブに移動',
                  icon: Icons.arrow_back,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _sortReviews(List<dynamic> reviews) {
    final sorted = List.from(reviews);

    switch (sortBy) {
      case 'newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'rating_high':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'rating_low':
        sorted.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case 'title':
        sorted.sort((a, b) => a.movieTitle.compareTo(b.movieTitle));
        break;
    }

    return sorted;
  }

  String _getSortText() {
    switch (sortBy) {
      case 'newest':
        return '新しい順';
      case 'oldest':
        return '古い順';
      case 'rating_high':
        return '評価順（高）';
      case 'rating_low':
        return '評価順（低）';
      case 'title':
        return 'タイトル順';
      default:
        return '新しい順';
    }
  }

  void _navigateToMovieDetail(BuildContext context, dynamic review) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailPage(movieId: review.movieId),
      ),
    );
  }

  void _navigateToEditReview(BuildContext context, dynamic review) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _buildEditReviewDialog(context, review),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    dynamic review,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        movieTitle: review.movieTitle,
      ),
    );

    if (result == true && context.mounted) {
      await _deleteReview(ref, review);
    }
  }

  Future<void> _deleteReview(WidgetRef ref, dynamic review) async {
    try {
      await ref.read(reviewRepositoryProvider).deleteReview(review.id);
      ref.refresh(userReviewsProvider(review.userId));
    } catch (e) {
      // エラーハンドリングは上位で処理
      rethrow;
    }
  }

  Widget _buildEditReviewDialog(BuildContext context, dynamic review) {
    return AlertDialog(
      title: const Text('レビュー編集'),
      content: const Text('レビュー編集機能は現在開発中です。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}

/// 削除確認ダイアログ
class _DeleteConfirmationDialog extends StatelessWidget {
  final String movieTitle;

  const _DeleteConfirmationDialog({
    required this.movieTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('レビューを削除'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('「$movieTitle」のレビューを削除しますか？'),
          const SizedBox(height: 8),
          Text(
            'この操作は取り消すことができません。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: const Text('削除'),
        ),
      ],
    );
  }
}
