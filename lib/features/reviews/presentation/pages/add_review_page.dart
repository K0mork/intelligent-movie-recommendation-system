import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/star_rating.dart';
import '../providers/review_controller.dart';
import '../providers/review_providers.dart';

class AddReviewPage extends ConsumerStatefulWidget {
  final MovieEntity movie;

  const AddReviewPage({
    super.key,
    required this.movie,
  });

  @override
  ConsumerState<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends ConsumerState<AddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 3.0;
  bool _isSubmitting = false;

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
        title: const Text('レビューを書く'),
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
                          child: widget.movie.posterPath != null
                              ? Image.network(
                                  'https://image.tmdb.org/t/p/w200${widget.movie.posterPath}',
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
                                widget.movie.title,
                                style: theme.textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              if (widget.movie.releaseYear != null)
                                Text(
                                  '公開日: ${widget.movie.releaseYear}年',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.movie.voteAverage.toStringAsFixed(1),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
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
                    onPressed: _isSubmitting ? null : _submitReview,
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
                        : const Text('レビューを投稿'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      final reviewId = await ref.read(reviewControllerProvider.notifier).submitReview(
        userId: user.uid,
        movieId: widget.movie.id.toString(),
        movieTitle: widget.movie.title,
        moviePosterUrl: widget.movie.posterPath != null
            ? 'https://image.tmdb.org/t/p/w200${widget.movie.posterPath}'
            : null,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      if (mounted && reviewId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('レビューを投稿しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        throw Exception('レビューの投稿に失敗しました');
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