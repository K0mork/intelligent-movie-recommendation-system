import 'package:flutter_test/flutter_test.dart';
import 'package:movie_recommend_app/features/reviews/domain/entities/review.dart';

void main() {
  group('Review', () {
    final testDateTime = DateTime(2023, 1, 1, 12, 0, 0);
    
    final testReview = Review(
      id: 'test-id',
      userId: 'user-123',
      movieId: 'movie-456',
      movieTitle: 'Test Movie',
      moviePosterUrl: 'https://example.com/poster.jpg',
      rating: 4.5,
      comment: 'Great movie!',
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

    test('creates instance with all required properties', () {
      final review = Review(
        id: 'review-1',
        userId: 'user-1',
        movieId: 'movie-1',
        movieTitle: 'Amazing Film',
        rating: 5.0,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      expect(review.id, 'review-1');
      expect(review.userId, 'user-1');
      expect(review.movieId, 'movie-1');
      expect(review.movieTitle, 'Amazing Film');
      expect(review.moviePosterUrl, isNull);
      expect(review.rating, 5.0);
      expect(review.comment, isNull);
      expect(review.createdAt, testDateTime);
      expect(review.updatedAt, testDateTime);
    });

    test('creates instance with optional properties', () {
      expect(testReview.moviePosterUrl, 'https://example.com/poster.jpg');
      expect(testReview.comment, 'Great movie!');
    });

    test('copyWith returns new instance with updated values', () {
      final updatedReview = testReview.copyWith(
        rating: 3.5,
        comment: 'Updated comment',
        updatedAt: DateTime(2023, 1, 2),
      );

      expect(updatedReview.id, testReview.id);
      expect(updatedReview.userId, testReview.userId);
      expect(updatedReview.movieId, testReview.movieId);
      expect(updatedReview.movieTitle, testReview.movieTitle);
      expect(updatedReview.moviePosterUrl, testReview.moviePosterUrl);
      expect(updatedReview.rating, 3.5);
      expect(updatedReview.comment, 'Updated comment');
      expect(updatedReview.createdAt, testReview.createdAt);
      expect(updatedReview.updatedAt, DateTime(2023, 1, 2));
    });

    test('copyWith preserves values when null parameters are provided', () {
      final reviewWithNulls = testReview.copyWith(
        moviePosterUrl: null,
        comment: null,
      );

      // Due to null-aware operator in copyWith, original values are preserved
      expect(reviewWithNulls.moviePosterUrl, testReview.moviePosterUrl);
      expect(reviewWithNulls.comment, testReview.comment);
      expect(reviewWithNulls.id, testReview.id);
      expect(reviewWithNulls.rating, testReview.rating);
    });

    test('equality works correctly for identical reviews', () {
      final review1 = Review(
        id: 'same-id',
        userId: 'same-user',
        movieId: 'same-movie',
        movieTitle: 'Same Title',
        rating: 4.0,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      final review2 = Review(
        id: 'same-id',
        userId: 'same-user',
        movieId: 'same-movie',
        movieTitle: 'Same Title',
        rating: 4.0,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      expect(review1, equals(review2));
      expect(review1.hashCode, equals(review2.hashCode));
    });

    test('equality works correctly for different reviews', () {
      final review1 = testReview;
      final review2 = testReview.copyWith(id: 'different-id');

      expect(review1, isNot(equals(review2)));
      expect(review1.hashCode, isNot(equals(review2.hashCode)));
    });

    test('toString includes all important properties', () {
      final toString = testReview.toString();
      
      expect(toString, contains('test-id'));
      expect(toString, contains('user-123'));
      expect(toString, contains('movie-456'));
      expect(toString, contains('Test Movie'));
      expect(toString, contains('4.5'));
      expect(toString, contains('Great movie!'));
    });

    test('rating validation - accepts valid range', () {
      final validRatings = [0.0, 0.5, 1.0, 2.5, 5.0];
      
      for (final rating in validRatings) {
        final review = testReview.copyWith(rating: rating);
        expect(review.rating, rating);
      }
    });

    test('handles edge cases for optional fields', () {
      final reviewWithEmptyComment = testReview.copyWith(comment: '');
      expect(reviewWithEmptyComment.comment, '');
      
      final reviewWithEmptyPosterUrl = testReview.copyWith(moviePosterUrl: '');
      expect(reviewWithEmptyPosterUrl.moviePosterUrl, '');
    });

    test('copyWith preserves original values when no parameters provided', () {
      final copiedReview = testReview.copyWith();
      
      expect(copiedReview, equals(testReview));
      expect(copiedReview.hashCode, equals(testReview.hashCode));
    });
  });
}