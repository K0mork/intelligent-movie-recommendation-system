import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../../../../core/errors/app_exceptions.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviews({String? userId, String? movieId});
  Future<ReviewModel> getReview(String reviewId);
  Future<String> createReview(ReviewModel review);
  Future<void> updateReview(ReviewModel review);
  Future<void> deleteReview(String reviewId);
  Future<List<ReviewModel>> getUserReviews(String userId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final FirebaseFirestore firestore;

  ReviewRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ReviewModel>> getReviews({
    String? userId,
    String? movieId,
  }) async {
    try {
      Query query = firestore.collection('reviews');

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (movieId != null) {
        query = query.where('movieId', isEqualTo: movieId);
      }

      query = query.orderBy('createdAt', descending: true);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw APIException('Failed to get reviews: ${e.toString()}');
    }
  }

  @override
  Future<ReviewModel> getReview(String reviewId) async {
    try {
      final docSnapshot =
          await firestore.collection('reviews').doc(reviewId).get();

      if (!docSnapshot.exists) {
        throw APIException('Review not found');
      }

      return ReviewModel.fromFirestore(docSnapshot);
    } catch (e) {
      throw APIException('Failed to get review: ${e.toString()}');
    }
  }

  @override
  Future<String> createReview(ReviewModel review) async {
    try {
      final docRef = firestore.collection('reviews').doc();
      final reviewData = review.toMap();

      await docRef.set(reviewData);

      return docRef.id;
    } catch (e) {
      throw APIException('Failed to create review: ${e.toString()}');
    }
  }

  @override
  Future<void> updateReview(ReviewModel review) async {
    try {
      await firestore
          .collection('reviews')
          .doc(review.id)
          .update(review.toMap());
    } catch (e) {
      throw APIException('Failed to update review: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw APIException('Failed to delete review: ${e.toString()}');
    }
  }

  @override
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    try {
      final querySnapshot =
          await firestore
              .collection('reviews')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw APIException('Failed to get user reviews: ${e.toString()}');
    }
  }
}
