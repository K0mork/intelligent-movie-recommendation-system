import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/star_rating.dart';
import '../providers/review_providers.dart';
import '../../../../core/widgets/error_widgets.dart';

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
  DateTime? _watchedDate;

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
                                      color: theme.colorScheme.surfaceContainerHighest,
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
                                  color: theme.colorScheme.surfaceContainerHighest,
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
                
                // Watched Date Section
                Text(
                  '鑑賞日',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _watchedDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _watchedDate = selectedDate;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8.0),
                      color: theme.colorScheme.surface,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _watchedDate != null
                              ? '${_watchedDate!.year}年${_watchedDate!.month}月${_watchedDate!.day}日'
                              : '鑑賞日を選択（任意）',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _watchedDate != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        if (_watchedDate != null)
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _watchedDate = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
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
        watchedDate: _watchedDate,
      );

      if (mounted && reviewId != null) {
        SnackBarHelper.showSuccess(
          context,
          'レビューを投稿しました',
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else if (mounted) {
        throw Exception('レビューの投稿に失敗しました');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'レビューの投稿に失敗しました';
        
        if (e.toString().contains('network') || e.toString().contains('internet')) {
          errorMessage = 'ネットワークエラーが発生しました。インターネット接続を確認してください。';
        } else if (e.toString().contains('permission') || e.toString().contains('auth')) {
          errorMessage = 'アクセス権限がありません。ログインし直してください。';
        } else if (e.toString().contains('validation')) {
          errorMessage = '入力内容に問題があります。再度確認してください。';
        }
        
        SnackBarHelper.showError(
          context,
          errorMessage,
          actionLabel: '再試行',
          onAction: () => _submitReview(),
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