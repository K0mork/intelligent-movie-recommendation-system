import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/review.dart';

class ReviewStatistics extends StatelessWidget {
  final List<Review> reviews;

  const ReviewStatistics({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalReviews = reviews.length;
    final averageRating =
        reviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews;

    // Use fold instead of reduce to avoid type issues
    Review mostRecentReview = reviews.first;
    for (final review in reviews) {
      if (review.createdAt.isAfter(mostRecentReview.createdAt)) {
        mostRecentReview = review;
      }
    }

    Review oldestReview = reviews.first;
    for (final review in reviews) {
      if (review.createdAt.isBefore(oldestReview.createdAt)) {
        oldestReview = review;
      }
    }

    // 評価分布を計算
    final ratingDistribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      ratingDistribution[i] = 0;
    }
    for (final review in reviews) {
      final roundedRating = review.rating.round();
      ratingDistribution[roundedRating] =
          (ratingDistribution[roundedRating] ?? 0) + 1;
    }

    final dateFormat = DateFormat('yyyy年MM月dd日');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'レビュー統計',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 基本統計
            Row(
              children: [
                Expanded(
                  child: _StatisticCard(
                    icon: Icons.format_list_numbered,
                    title: '総レビュー数',
                    value: '$totalReviews件',
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatisticCard(
                    icon: Icons.star,
                    title: '平均評価',
                    value: averageRating.toStringAsFixed(1),
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 期間情報
            Row(
              children: [
                Expanded(
                  child: _StatisticCard(
                    icon: Icons.schedule,
                    title: '最新レビュー',
                    value: dateFormat.format(mostRecentReview.createdAt),
                    color: theme.colorScheme.tertiary,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatisticCard(
                    icon: Icons.history,
                    title: '最初のレビュー',
                    value: dateFormat.format(oldestReview.createdAt),
                    color: theme.colorScheme.outline,
                    isCompact: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 評価分布
            Text(
              '評価分布',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Column(
              children: [
                for (int rating = 5; rating >= 1; rating--)
                  _RatingDistributionBar(
                    rating: rating,
                    count: ratingDistribution[rating] ?? 0,
                    totalCount: totalReviews,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isCompact;

  const _StatisticCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: isCompact ? 16 : 20, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 4 : 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingDistributionBar extends StatelessWidget {
  final int rating;
  final int count;
  final int totalCount;

  const _RatingDistributionBar({
    required this.rating,
    required this.count,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = totalCount > 0 ? (count / totalCount) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          // 星の評価表示
          SizedBox(
            width: 60,
            child: Row(
              children: [
                Text(
                  '$rating',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.star, size: 16, color: Colors.amber),
              ],
            ),
          ),

          // プログレスバー
          Expanded(
            child: Container(
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getRatingColor(rating, theme),
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // 件数表示
          SizedBox(
            width: 40,
            child: Text(
              '$count件',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating, ThemeData theme) {
    switch (rating) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow.shade700;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }
}
