import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/review.dart';
import 'star_rating.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/widgets/accessibility_widgets.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool showMovieInfo;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.showMovieInfo = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy年MM月dd日');

    final semanticLabel = _buildSemanticLabel(dateFormat);

    return AccessibleCard(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      onTap: onTap,
      semanticLabel: semanticLabel,
      semanticHint: onTap != null ? 'タップして詳細を表示' : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              if (showMovieInfo && review.moviePosterUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: Image.network(
                    review.moviePosterUrl!,
                    width: 40,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 60,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.movie,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showMovieInfo) ...[
                      Text(
                        review.movieTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        StarRating(rating: review.rating, size: 18.0),
                        const SizedBox(width: 8),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('編集'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('削除', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                ),
            ],
          ),

          // Comment Section
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: theme.textTheme.bodyMedium,
              maxLines: showMovieInfo ? 3 : null,
              overflow: showMovieInfo ? TextOverflow.ellipsis : null,
            ),
          ],

          // Footer
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (review.watchedDate != null)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '鑑賞日: ${dateFormat.format(review.watchedDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '投稿日: ${dateFormat.format(review.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (review.updatedAt != review.createdAt)
                    Text(
                      '編集済み',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildSemanticLabel(DateFormat dateFormat) {
    String label = '映画: ${review.movieTitle}';
    label +=
        ', 評価: ${AccessibilityHelper.formatRatingForScreenReader(review.rating, 5.0)}';

    if (review.comment != null && review.comment!.isNotEmpty) {
      label += ', コメント: ${review.comment}';
    }

    if (review.watchedDate != null) {
      label +=
          ', 鑑賞日: ${AccessibilityHelper.formatDateForScreenReader(review.watchedDate!)}';
    }

    label +=
        ', 投稿日: ${AccessibilityHelper.formatDateForScreenReader(review.createdAt)}';

    return label;
  }
}

class ReviewList extends StatelessWidget {
  final List<Review> reviews;
  final bool showMovieInfo;
  final Function(Review)? onReviewTap;
  final Function(Review)? onEditReview;
  final Function(Review)? onDeleteReview;

  const ReviewList({
    super.key,
    required this.reviews,
    this.showMovieInfo = false,
    this.onReviewTap,
    this.onEditReview,
    this.onDeleteReview,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return EmptyStateWidget(
        title: 'レビューがありません',
        message: '映画を見たらレビューを書いてみましょう',
        icon: Icons.rate_review_outlined,
      );
    }

    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return FadeInWidget(
          delay: Duration(milliseconds: index * 100),
          child: SlideInWidget(
            delay: Duration(milliseconds: index * 100),
            begin: const Offset(0.0, 0.2),
            child: ReviewCard(
              review: review,
              showMovieInfo: showMovieInfo,
              onTap: onReviewTap != null ? () => onReviewTap!(review) : null,
              onEdit: onEditReview != null ? () => onEditReview!(review) : null,
              onDelete:
                  onDeleteReview != null ? () => onDeleteReview!(review) : null,
            ),
          ),
        );
      },
    );
  }
}
