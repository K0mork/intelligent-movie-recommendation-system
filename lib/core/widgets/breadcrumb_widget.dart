import 'package:flutter/material.dart';

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  const BreadcrumbItem({
    required this.label,
    this.onTap,
    this.icon,
  });
}

class BreadcrumbWidget extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Color? textColor;
  final Color? separatorColor;
  final double fontSize;
  final IconData separatorIcon;

  const BreadcrumbWidget({
    super.key,
    required this.items,
    this.textColor,
    this.separatorColor,
    this.fontSize = 14,
    this.separatorIcon = Icons.chevron_right,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextColor = textColor ?? theme.colorScheme.onSurfaceVariant;
    final effectiveSeparatorColor = separatorColor ?? theme.colorScheme.outline;

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildBreadcrumbItems(
                  context,
                  effectiveTextColor,
                  effectiveSeparatorColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems(
    BuildContext context,
    Color textColor,
    Color separatorColor,
  ) {
    final List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      // アイテム
      widgets.add(
        InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: fontSize,
                    color: isLast ? textColor : textColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: isLast ? textColor : textColor.withOpacity(0.7),
                    fontWeight: isLast ? FontWeight.w500 : FontWeight.normal,
                    decoration: item.onTap != null && !isLast
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // セパレーター
      if (!isLast) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              separatorIcon,
              size: fontSize,
              color: separatorColor,
            ),
          ),
        );
      }
    }

    return widgets;
  }
}

// パンくずナビゲーションのヘルパークラス
class BreadcrumbHelper {
  static List<BreadcrumbItem> createMovieBreadcrumbs({
    required BuildContext context,
    String? genre,
    String? movieTitle,
  }) {
    final List<BreadcrumbItem> breadcrumbs = [
      BreadcrumbItem(
        label: 'ホーム',
        icon: Icons.home,
        onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        ),
      ),
      BreadcrumbItem(
        label: '映画',
        onTap: () => Navigator.of(context).pushNamed('/movies'),
      ),
    ];

    if (genre != null) {
      breadcrumbs.add(
        BreadcrumbItem(
          label: genre,
          onTap: () {
            // ジャンルフィルタリング画面があれば遷移
            Navigator.of(context).pushNamed('/movies');
          },
        ),
      );
    }

    if (movieTitle != null) {
      breadcrumbs.add(
        BreadcrumbItem(
          label: movieTitle.length > 20
              ? '${movieTitle.substring(0, 20)}...'
              : movieTitle,
        ),
      );
    }

    return breadcrumbs;
  }

  static List<BreadcrumbItem> createReviewBreadcrumbs({
    required BuildContext context,
    String? reviewType,
  }) {
    final List<BreadcrumbItem> breadcrumbs = [
      BreadcrumbItem(
        label: 'ホーム',
        icon: Icons.home,
        onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        ),
      ),
      BreadcrumbItem(
        label: 'マイ映画',
        onTap: () => Navigator.of(context).pushNamed('/reviews'),
      ),
    ];

    if (reviewType != null) {
      breadcrumbs.add(
        BreadcrumbItem(
          label: reviewType,
        ),
      );
    }

    return breadcrumbs;
  }

  static List<BreadcrumbItem> createRecommendationBreadcrumbs({
    required BuildContext context,
  }) {
    return [
      BreadcrumbItem(
        label: 'ホーム',
        icon: Icons.home,
        onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        ),
      ),
      BreadcrumbItem(
        label: 'AI映画推薦',
      ),
    ];
  }
}
