import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviews({String? userId, String? movieId});
  Future<Review> getReview(String reviewId);
  Future<String> createReview({
    required String userId,
    required String movieId,
    required String movieTitle,
    String? moviePosterUrl,
    required double rating,
    String? comment,
  });
  Future<void> updateReview(Review review);
  Future<void> deleteReview(String reviewId);
  Future<List<Review>> getUserReviews(String userId);
}