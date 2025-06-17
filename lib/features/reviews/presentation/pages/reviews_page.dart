import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/review_providers.dart';
import '../widgets/review_card.dart';
import '../../../movies/presentation/pages/movie_detail_page.dart';
import 'edit_review_page.dart';
import '../../../../core/widgets/loading_animations.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../../../core/widgets/animated_widgets.dart';

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
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularWaveLoading(
                color: theme.colorScheme.primary,
                size: 60,
              ),
              const SizedBox(height: 24),
              Text(
                '読み込み中...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => ErrorDisplay(
          title: 'ログインエラー',
          message: 'ユーザー情報の取得に失敗しました',
          icon: Icons.account_circle_outlined,
          onRetry: () {
            ref.invalidate(authStateProvider);
          },
          retryText: '再試行',
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
              onEditReview: (review) async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => EditReviewPage(review: review),
                  ),
                );
                
                if (result == true) {
                  ref.refresh(userReviewsProvider(userId));
                }
              },
              onDeleteReview: (review) {
                _showDeleteConfirmation(context, ref, review);
              },
            ),
          ),
        );
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularWaveLoading(
              color: Colors.blue,
              size: 50,
            ),
            SizedBox(height: 16),
            Text('レビューを読み込み中...'),
          ],
        ),
      ),
      error: (error, stackTrace) => ErrorDisplay(
        title: 'レビューの読み込みエラー',
        message: 'レビューデータの取得に失敗しました',
        icon: Icons.rate_review_outlined,
        onRetry: () {
          ref.refresh(userReviewsProvider(userId));
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, review) async {
    final confirmed = await DialogHelper.showConfirmDialog(
      context,
      title: 'レビューを削除',
      message: '「${review.movieTitle}」のレビューを削除しますか？\nこの操作は取り消せません。',
      confirmText: '削除',
      confirmColor: Colors.red,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(reviewControllerProvider.notifier).deleteReview(review.id);
        if (context.mounted) {
          SnackBarHelper.showSuccess(
            context,
            'レビューを削除しました',
          );
          ref.refresh(userReviewsProvider(userId));
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarHelper.showError(
            context,
            '削除に失敗しました',
          );
        }
      }
    }
  }
}