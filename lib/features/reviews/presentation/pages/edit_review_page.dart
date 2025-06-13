import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/review.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/star_rating.dart';
import '../providers/review_providers.dart';
import '../providers/review_controller.dart';

class EditReviewPage extends ConsumerStatefulWidget {
  final Review review;

  const EditReviewPage({
    super.key,
    required this.review,
  });

  @override
  ConsumerState<EditReviewPage> createState() => _EditReviewPageState();
}

class _EditReviewPageState extends ConsumerState<EditReviewPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _commentController;
  late double _rating;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.review.comment ?? '');
    _rating = widget.review.rating;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('レビューを編集'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: widget.review.moviePosterUrl != null
                              ? Image.network(
                                  widget.review.moviePosterUrl!,
                                  width: 80,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 120,
                                      color: theme.colorScheme.surfaceVariant,
                                      child: Icon(
                                        Icons.movie,
                                        size: 40,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: 80,
                                  height: 120,
                                  color: theme.colorScheme.surfaceVariant,
                                  child: Icon(
                                    Icons.movie,
                                    size: 40,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.review.movieTitle,
                                style: theme.textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '作成日: ${_formatDate(widget.review.createdAt)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (widget.review.updatedAt != widget.review.createdAt) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '最終更新: ${_formatDate(widget.review.updatedAt)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Rating Section
                Text(
                  '評価',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InteractiveStarRating(
                      initialRating: _rating,
                      onRatingChanged: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${_rating.toStringAsFixed(1)} / 5.0',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Comment Section
                Text(
                  'レビューコメント',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _commentController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'この映画についてどう思いましたか？（任意）',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value != null && value.length > 1000) {
                      return 'コメントは1000文字以内で入力してください';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _updateReview,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('レビューを更新'),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('キャンセル'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  Future<void> _updateReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      // Check if user owns this review
      if (widget.review.userId != user.uid) {
        throw Exception('このレビューを編集する権限がありません');
      }

      final updatedReview = Review(
        id: widget.review.id,
        userId: widget.review.userId,
        movieId: widget.review.movieId,
        movieTitle: widget.review.movieTitle,
        moviePosterUrl: widget.review.moviePosterUrl,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        createdAt: widget.review.createdAt,
        updatedAt: DateTime.now(),
      );

      await ref.read(reviewControllerProvider.notifier).updateReview(updatedReview);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('レビューを更新しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}