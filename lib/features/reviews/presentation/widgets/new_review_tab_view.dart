import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../movies/presentation/widgets/custom_movie_search_page.dart';
import '../../../../core/widgets/loading_state_widget.dart';
import '../../../../core/widgets/error_widgets.dart';

/// 新規レビュータブのビュー
/// 
/// 映画選択とレビュー作成の機能を担当。
/// integrated_reviews_page.dartから責任を分離。
class NewReviewTabView extends ConsumerWidget {
  const NewReviewTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const AuthRequiredView();
        }
        return _buildNewReviewContent(context);
      },
      loading: () => const LoadingStateWidget.fullScreen(),
      error: (error, stackTrace) => ErrorDisplay(
        message: 'ユーザー情報の取得に失敗しました',
        onRetry: () => ref.refresh(authStateProvider),
      ),
    );
  }

  Widget _buildNewReviewContent(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー部分
          _buildHeaderSection(theme),
          const SizedBox(height: 24),
          
          // メインコンテンツ
          Expanded(
            child: _buildMainContent(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.movie_creation_outlined,
              size: 28,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              '新規レビュー',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '映画を選択してレビューを投稿しましょう',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // 映画選択カード
        _buildMovieSelectionCard(context, theme),
        const SizedBox(height: 24),
        
        // ガイド情報
        _buildGuideSection(theme),
        
        const Spacer(),
        
        // フッター情報
        _buildFooterInfo(theme),
      ],
    );
  }

  Widget _buildMovieSelectionCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToMovieSearch(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.search,
                  size: 40,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '映画を検索',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'レビューしたい映画を検索して選択してください',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'レビューのコツ',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._buildGuideTips(theme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGuideTips(ThemeData theme) {
    final tips = [
      '感じたことを率直に書きましょう',
      'ネタバレは避けて書きましょう',
      '具体的なシーンや印象を含めると良いでしょう',
      '他の人の参考になるように書きましょう',
    ];

    return tips.map((tip) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildFooterInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'レビューは投稿後も編集・削除できます',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMovieSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CustomMovieSearchPage(),
      ),
    );
  }
}

/// 認証が必要であることを表示するウィジェット
class AuthRequiredView extends StatelessWidget {
  const AuthRequiredView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'ログインが必要です',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'レビューを投稿するにはログインしてください',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}