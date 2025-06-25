import 'package:flutter/material.dart';

/// レビューソート用のポップアップメニュー
///
/// integrated_reviews_page.dartから分離されたソート機能。
/// 再利用可能な形で設計。
class ReviewSortMenu extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;
  final List<SortOption> sortOptions;

  const ReviewSortMenu({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
    this.sortOptions = const [
      SortOption('newest', '新しい順', Icons.schedule),
      SortOption('oldest', '古い順', Icons.history),
      SortOption('rating_high', '評価順（高）', Icons.star),
      SortOption('rating_low', '評価順（低）', Icons.star_border),
      SortOption('title', 'タイトル順', Icons.sort_by_alpha),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      tooltip: 'ソート',
      onSelected: onSortChanged,
      itemBuilder:
          (context) =>
              sortOptions.map((option) {
                final isSelected = currentSort == option.value;

                return PopupMenuItem(
                  value: option.value,
                  child: Row(
                    children: [
                      Icon(
                        option.icon,
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        option.label,
                        style:
                            isSelected
                                ? TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                )
                                : null,
                      ),
                      if (isSelected) ...[
                        const Spacer(),
                        Icon(
                          Icons.check,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
    );
  }
}

/// ソートオプションのデータクラス
class SortOption {
  final String value;
  final String label;
  final IconData icon;

  const SortOption(this.value, this.label, this.icon);
}

/// ソート状態をインジケーター形式で表示するウィジェット
class SortIndicator extends StatelessWidget {
  final String sortBy;
  final VoidCallback? onTap;

  const SortIndicator({super.key, required this.sortBy, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortText = _getSortText(sortBy);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
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
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getSortText(String sortBy) {
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
}

/// ソート機能付きのヘッダーウィジェット
class SortableHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String sortBy;
  final ValueChanged<String> onSortChanged;
  final int? itemCount;

  const SortableHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.sortBy,
    required this.onSortChanged,
    this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 28, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (itemCount != null)
                Text(
                  '$itemCount件',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        ReviewSortMenu(currentSort: sortBy, onSortChanged: onSortChanged),
      ],
    );
  }
}

/// ソート機能のユーティリティクラス
class ReviewSorter {
  /// レビューリストをソートする
  static List<T> sortReviews<T>(
    List<T> reviews,
    String sortBy, {
    required DateTime Function(T) getCreatedAt,
    required double Function(T) getRating,
    required String Function(T) getTitle,
  }) {
    final sorted = List<T>.from(reviews);

    switch (sortBy) {
      case 'newest':
        sorted.sort((a, b) => getCreatedAt(b).compareTo(getCreatedAt(a)));
        break;
      case 'oldest':
        sorted.sort((a, b) => getCreatedAt(a).compareTo(getCreatedAt(b)));
        break;
      case 'rating_high':
        sorted.sort((a, b) => getRating(b).compareTo(getRating(a)));
        break;
      case 'rating_low':
        sorted.sort((a, b) => getRating(a).compareTo(getRating(b)));
        break;
      case 'title':
        sorted.sort((a, b) => getTitle(a).compareTo(getTitle(b)));
        break;
    }

    return sorted;
  }

  /// ソートオプションの一覧を取得
  static List<SortOption> getDefaultSortOptions() {
    return const [
      SortOption('newest', '新しい順', Icons.schedule),
      SortOption('oldest', '古い順', Icons.history),
      SortOption('rating_high', '評価順（高）', Icons.star),
      SortOption('rating_low', '評価順（低）', Icons.star_border),
      SortOption('title', 'タイトル順', Icons.sort_by_alpha),
    ];
  }

  /// ソート値をラベルに変換
  static String getSortLabel(String sortBy) {
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
}
