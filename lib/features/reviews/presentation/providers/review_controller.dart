import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class ReviewState {
  final bool isLoading;
  final String? error;
  final List<Review> reviews;
  final bool isSubmitting;

  const ReviewState({
    this.isLoading = false,
    this.error,
    this.reviews = const [],
    this.isSubmitting = false,
  });

  ReviewState copyWith({
    bool? isLoading,
    String? error,
    List<Review>? reviews,
    bool? isSubmitting,
  }) {
    return ReviewState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      reviews: reviews ?? this.reviews,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ReviewController extends StateNotifier<ReviewState> {
  final ReviewRepository repository;

  ReviewController({required this.repository}) : super(const ReviewState());

  Future<void> loadReviews({String? userId, String? movieId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reviews = await repository.getReviews(
        userId: userId,
        movieId: movieId,
      );
      state = state.copyWith(
        isLoading: false,
        reviews: reviews,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<String?> submitReview({
    required String userId,
    required String movieId,
    required String movieTitle,
    String? moviePosterUrl,
    required double rating,
    String? comment,
    DateTime? watchedDate,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final reviewId = await repository.createReview(
        userId: userId,
        movieId: movieId,
        movieTitle: movieTitle,
        moviePosterUrl: moviePosterUrl,
        rating: rating,
        comment: comment,
        watchedDate: watchedDate,
      );

      state = state.copyWith(isSubmitting: false);

      // Refresh reviews after submission
      await loadReviews();

      return reviewId;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<void> updateReview(Review review) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      await repository.updateReview(review);
      state = state.copyWith(isSubmitting: false);

      // Refresh reviews after update
      await loadReviews();
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteReview(String reviewId) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      await repository.deleteReview(reviewId);
      state = state.copyWith(isSubmitting: false);

      // Refresh reviews after deletion
      await loadReviews();
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadUserReviews(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reviews = await repository.getUserReviews(userId);
      state = state.copyWith(
        isLoading: false,
        reviews: reviews,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
