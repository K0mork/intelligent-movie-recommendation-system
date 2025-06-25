import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/review_providers.dart';
import '../widgets/review_card.dart';
import '../widgets/review_statistics.dart';
import '../../../movies/presentation/pages/movie_detail_page.dart';
import 'edit_review_page.dart';

class UserReviewHistoryPage extends ConsumerStatefulWidget {
  const UserReviewHistoryPage({super.key});

  @override
  ConsumerState<UserReviewHistoryPage> createState() =>
      _UserReviewHistoryPageState();
}

class _UserReviewHistoryPageState extends ConsumerState<UserReviewHistoryPage> {
  String _sortBy = 'newest'; // newest, oldest, rating_high, rating_low

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('レビュー履歴'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'newest',
                    child: Row(
                      children: [
                        Icon(Icons.schedule),
                        SizedBox(width: 8),
                        Text('新しい順'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'oldest',
                    child: Row(
                      children: [
                        Icon(Icons.history),
                        SizedBox(width: 8),
                        Text('古い順'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'rating_high',
                    child: Row(
                      children: [
                        Icon(Icons.star),
                        SizedBox(width: 8),
                        Text('評価の高い順'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'rating_low',
                    child: Row(
                      children: [
                        Icon(Icons.star_border),
                        SizedBox(width: 8),
                        Text('評価の低い順'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'レビュー履歴を見るにはログインが必要です',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return _UserReviewHistoryContent(userId: user.uid, sortBy: _sortBy);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('エラーが発生しました', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

class _UserReviewHistoryContent extends ConsumerWidget {
  final String userId;
  final String sortBy;

  const _UserReviewHistoryContent({required this.userId, required this.sortBy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userReviewsAsync = ref.watch(userReviewsProvider(userId));

    return userReviewsAsync.when(
      data: (reviews) {
        // ソート処理
        final sortedReviews = List.from(reviews);
        switch (sortBy) {
          case 'newest':
            sortedReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            break;
          case 'oldest':
            sortedReviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            break;
          case 'rating_high':
            sortedReviews.sort((a, b) => b.rating.compareTo(a.rating));
            break;
          case 'rating_low':
            sortedReviews.sort((a, b) => a.rating.compareTo(b.rating));
            break;
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(userReviewsProvider(userId));
          },
          child: CustomScrollView(
            slivers: [
              // 統計情報セクション
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ReviewStatistics(reviews: reviews),
                ),
              ),

              // レビューリストセクション
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'レビュー一覧',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${reviews.length}件',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // レビューリスト
              if (sortedReviews.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'レビューがありません',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '映画を観た感想を共有してみましょう',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final review = sortedReviews[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == sortedReviews.length - 1 ? 80 : 0,
                        ),
                        child: ReviewCard(
                          review: review,
                          showMovieInfo: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => MovieDetailPage(
                                      movieId: int.parse(review.movieId),
                                    ),
                              ),
                            );
                          },
                          onEdit: () async {
                            final result = await Navigator.of(
                              context,
                            ).push<bool>(
                              MaterialPageRoute(
                                builder:
                                    (context) => EditReviewPage(review: review),
                              ),
                            );

                            if (result == true) {
                              ref.refresh(userReviewsProvider(userId));
                            }
                          },
                          onDelete: () {
                            _showDeleteConfirmation(context, ref, review);
                          },
                        ),
                      );
                    }, childCount: sortedReviews.length),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'レビューの読み込みに失敗しました',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.refresh(userReviewsProvider(userId));
                  },
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, review) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('レビューを削除'),
            content: Text('「${review.movieTitle}」のレビューを削除しますか？\nこの操作は取り消せません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await ref
                        .read(reviewControllerProvider.notifier)
                        .deleteReview(review.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('レビューを削除しました'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      ref.refresh(userReviewsProvider(userId));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('削除に失敗しました: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('削除'),
              ),
            ],
          ),
    );
  }
}
