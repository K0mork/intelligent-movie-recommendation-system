import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/new_review_tab_view.dart';
import '../widgets/review_history_tab_view.dart';
import '../widgets/review_sort_menu.dart';
import '../../../../core/widgets/breadcrumb_widget.dart';

/// 統合レビューページ
///
/// 新規レビュー作成とレビュー履歴表示を統合したタブ形式のページ。
/// 責任分離により各タブは独立したウィジェットとして実装。
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
      appBar: _buildAppBar(theme),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
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
        _buildSortButton(),
      ],
    );
  }

  Widget _buildSortButton() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        // レビュー履歴タブ（index: 1）の時のみソートメニューを表示
        if (_tabController.index == 1) {
          return ReviewSortMenu(
            currentSort: _sortBy,
            onSortChanged: (value) {
              setState(() {
                _sortBy = value;
              });
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // パンくずナビゲーション
        BreadcrumbWidget(
          items: BreadcrumbHelper.createReviewBreadcrumbs(
            context: context,
          ),
        ),

        // タブビュー
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const NewReviewTabView(),
              ReviewHistoryTabView(
                sortBy: _sortBy,
                onRefresh: _onRefresh,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onRefresh() {
    // リフレッシュ時の処理
    // 必要に応じて追加の処理を実装
  }
}
