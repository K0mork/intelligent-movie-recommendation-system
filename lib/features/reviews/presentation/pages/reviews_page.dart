import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/review_providers.dart';
import '../providers/review_controller.dart';
import '../widgets/review_card.dart';
import '../../../movies/presentation/pages/movie_detail_page.dart';

class ReviewsPage extends ConsumerStatefulWidget {
  const ReviewsPage({super.key});

  @override
  ConsumerState<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends ConsumerState<ReviewsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('レビュー'),
        backgroundColor: theme.colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.public),
              text: 'すべてのレビュー',
            ),
            Tab(
              icon: Icon(Icons.person),
              text: 'マイレビュー',
            ),
          ],
        ),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'レビューを見るにはログインが必要です',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // All Reviews Tab
              _AllReviewsTab(),
              // My Reviews Tab
              _MyReviewsTab(userId: user.uid),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
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

class _AllReviewsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, show a placeholder since we need to implement a way to get all reviews
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'すべてのレビュー機能は実装中です',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '現在はマイレビューのみ表示できます',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyReviewsTab extends ConsumerWidget {
  final String userId;

  const _MyReviewsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userReviewsAsync = ref.watch(userReviewsProvider(userId));

    return userReviewsAsync.when(
      data: (reviews) {
        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(userReviewsProvider(userId));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ReviewList(
              reviews: reviews,
              showMovieInfo: true,
              onReviewTap: (review) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MovieDetailPage(movieId: int.parse(review.movieId)),
                  ),
                );
              },
              onEditReview: (review) {
                // TODO: Navigate to edit review page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('レビュー編集機能は次の段階で実装します'),
                  ),
                );
              },
              onDeleteReview: (review) {
                _showDeleteConfirmation(context, ref, review);
              },
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
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
      builder: (context) => AlertDialog(
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
                await ref.read(reviewControllerProvider.notifier).deleteReview(review.id);
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}