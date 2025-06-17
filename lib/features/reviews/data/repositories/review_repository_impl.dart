import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';
import '../models/review_model.dart';
import '../../../../core/errors/app_exceptions.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Review>> getReviews({String? userId, String? movieId}) async {
    try {
      final reviewModels = await remoteDataSource.getReviews(
        userId: userId,
        movieId: movieId,
      );
      return reviewModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw APIException('Failed to get reviews: ${e.toString()}');
    }
  }

  @override
  Future<Review> getReview(String reviewId) async {
    try {
      final reviewModel = await remoteDataSource.getReview(reviewId);
      return reviewModel.toEntity();
    } catch (e) {
      throw APIException('Failed to get review: ${e.toString()}');
    }
  }

  @override
  Future<String> createReview({
    required String userId,
    required String movieId,
    required String movieTitle,
    String? moviePosterUrl,
    required double rating,
    String? comment,
    DateTime? watchedDate,
  }) async {
    try {
      final now = DateTime.now();
      final review = ReviewModel(
        id: '', // Will be set by Firestore
        userId: userId,
        movieId: movieId,
        movieTitle: movieTitle,
        moviePosterUrl: moviePosterUrl,
        rating: rating,
        comment: comment,
        watchedDate: watchedDate,
        createdAt: now,
        updatedAt: now,
      );

      final reviewId = await remoteDataSource.createReview(review);
      return reviewId;
    } catch (e) {
      throw APIException('Failed to create review: ${e.toString()}');
    }
  }

  @override
  Future<void> updateReview(Review review) async {
    try {
      final reviewModel = ReviewModel(
        id: review.id,
        userId: review.userId,
        movieId: review.movieId,
        movieTitle: review.movieTitle,
        moviePosterUrl: review.moviePosterUrl,
        rating: review.rating,
        comment: review.comment,
        watchedDate: review.watchedDate,
        createdAt: review.createdAt,
        updatedAt: DateTime.now(),
      );

      await remoteDataSource.updateReview(reviewModel);
    } catch (e) {
      throw APIException('Failed to update review: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await remoteDataSource.deleteReview(reviewId);
    } catch (e) {
      throw APIException('Failed to delete review: ${e.toString()}');
    }
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async {
    try {
      final reviewModels = await remoteDataSource.getUserReviews(userId);
      return reviewModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw APIException('Failed to get user reviews: ${e.toString()}');
    }
  }
}