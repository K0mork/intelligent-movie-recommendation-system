import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/review_providers.dart';
import '../widgets/review_card.dart';
import '../widgets/review_statistics.dart';
import '../../../movies/presentation/pages/movie_detail_page.dart';
import '../../../movies/presentation/widgets/movie_search_delegate.dart';
import 'edit_review_page.dart';
import '../../../../core/widgets/loading_animations.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../../../core/widgets/animated_widgets.dart';

class IntegratedReviewsPage extends ConsumerStatefulWidget {
  const IntegratedReviewsPage({super.key});

  @override
  ConsumerState<IntegratedReviewsPage> createState() => _IntegratedReviewsPageState();
}

class _IntegratedReviewsPageState extends ConsumerState<IntegratedReviewsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'newest';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイ映画'),
        backgroundColor: theme.colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.add_box_outlined),
              text: '新規レビュー',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'レビュー履歴',
            ),
          ],
        ),
        actions: [
          // レビュー履歴タブの時のみソートメニューを表示
          ValueListenableBuilder<int>(
            valueListenable: _tabController,
            builder: (context, index, child) {
              if (index == 1) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  tooltip: 'ソート',
                  onSelected: (value) {
                    setState(() {
                      _sortBy = value;
                    });
                  },
                  itemBuilder: (context) => [
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
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NewReviewTab(),
          _ReviewHistoryTab(sortBy: _sortBy),
        ],
      ),
    );
  }
}

class _NewReviewTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    return authState.when(
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
                  'レビューを投稿するにはログインが必要です',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ヘッダーセクション
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review,
                      size: 48,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '映画を検索してレビューを投稿',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '観た映画の感想を記録して、AIによる推薦精度を向上させましょう',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 映画検索ボタン
              ElevatedButton.icon(
                onPressed: () async {
                  final selectedMovie = await showSearch(
                    context: context,
                    delegate: MovieSearchDelegate(),
                  );
                  
                  if (selectedMovie != null && context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(
                          movieId: selectedMovie.id,
                          showReviewButton: true,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.search),
                label: const Text('映画を検索'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              // または区切り
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'または',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              // 映画一覧から選択ボタン
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/movies');
                },
                icon: const Icon(Icons.movie),
                label: const Text('人気映画から選択'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 32),

              // 使い方説明
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'レビューのコツ',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('星評価で総合的な満足度を表現'),
                    _buildTip('感想は具体的に（好きなシーン、キャラクターなど）'),
                    _buildTip('他の人にとって有益な情報を含める'),
                    _buildTip('ネタバレは控えめに'),
                  ],
                ),
              ),
            ],
          ),
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
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewHistoryTab extends ConsumerWidget {
  final String sortBy;

  const _ReviewHistoryTab({required this.sortBy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    return authState.when(
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
                  'レビュー履歴を見るにはログインが必要です',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return _ReviewHistoryContent(
          userId: user.uid,
          sortBy: sortBy,
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
    );
  }
}

class _ReviewHistoryContent extends ConsumerWidget {
  final String userId;
  final String sortBy;

  const _ReviewHistoryContent({
    required this.userId,
    required this.sortBy,
  });

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
              if (reviews.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ReviewStatistics(reviews: reviews),
                  ),
                ),
              
              // レビューリストヘッダー
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${reviews.length}件',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),

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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '映画を観た感想を共有してみましょう',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // 親ウィジェットの_tabControllerにアクセスする代わりに、
                            // 単純にナビゲーションで映画検索画面に遷移
                            Navigator.of(context).pushNamed('/movies');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('レビューを書く'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
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
                                  builder: (context) => MovieDetailPage(
                                    movieId: int.parse(review.movieId),
                                  ),
                                ),
                              );
                            },
                            onEdit: () async {
                              final result = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (context) => EditReviewPage(review: review),
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
                      },
                      childCount: sortedReviews.length,
                    ),
                  ),
                ),
            ],
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