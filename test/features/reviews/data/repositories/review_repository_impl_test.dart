import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:filmflow/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:filmflow/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:filmflow/features/reviews/data/models/review_model.dart';
import 'package:filmflow/features/reviews/domain/entities/review.dart';
import 'package:filmflow/core/errors/app_exceptions.dart';

// Mock classes will be generated
@GenerateMocks([ReviewRemoteDataSource])
import 'review_repository_impl_test.mocks.dart';

/// レビューリポジトリ統合テスト
/// リポジトリとデータソースの統合を検証し、ビジネスロジックの正確性を確認
void main() {
  group('ReviewRepository Integration Tests', () {
    late ReviewRepositoryImpl repository;
    late MockReviewRemoteDataSource mockDataSource;

    // テストデータ
    final testReviewModel = ReviewModel(
      id: 'test-review-id',
      userId: 'test-user-id',
      movieId: 'test-movie-id',
      movieTitle: 'Test Movie',
      moviePosterUrl: 'https://example.com/poster.jpg',
      rating: 4.5,
      comment: 'Great movie!',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final testReview = Review(
      id: 'test-review-id',
      userId: 'test-user-id',
      movieId: 'test-movie-id',
      movieTitle: 'Test Movie',
      moviePosterUrl: 'https://example.com/poster.jpg',
      rating: 4.5,
      comment: 'Great movie!',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    setUp(() {
      mockDataSource = MockReviewRemoteDataSource();
      repository = ReviewRepositoryImpl(remoteDataSource: mockDataSource);
    });

    group('レビュー作成統合テスト (createReview)', () {
      test('レビューが正常に作成され、IDが返される', () async {
        // Arrange
        const expectedReviewId = 'new-review-id';
        when(mockDataSource.createReview(any))
            .thenAnswer((_) => Future.value(expectedReviewId));

        // Act
        final result = await repository.createReview(
          userId: 'test-user-id',
          movieId: 'test-movie-id',
          movieTitle: 'Test Movie',
          moviePosterUrl: 'https://example.com/poster.jpg',
          rating: 4.5,
          comment: 'Great movie!',
        );

        // Assert
        expect(result, equals(expectedReviewId));
        
        // データソースが正しいパラメータで呼ばれることを確認
        final captured = verify(mockDataSource.createReview(captureAny)).captured;
        final capturedReview = captured.first as ReviewModel;
        
        expect(capturedReview.userId, equals('test-user-id'));
        expect(capturedReview.movieId, equals('test-movie-id'));
        expect(capturedReview.movieTitle, equals('Test Movie'));
        expect(capturedReview.rating, equals(4.5));
        expect(capturedReview.comment, equals('Great movie!'));
      });

      test('レビュー作成時にタイムスタンプが正しく設定される', () async {
        // Arrange
        const expectedReviewId = 'new-review-id';
        when(mockDataSource.createReview(any))
            .thenAnswer((_) => Future.value(expectedReviewId));

        final beforeCreate = DateTime.now();

        // Act
        await repository.createReview(
          userId: 'test-user-id',
          movieId: 'test-movie-id',
          movieTitle: 'Test Movie',
          rating: 4.5,
        );

        final afterCreate = DateTime.now();

        // Assert
        final captured = verify(mockDataSource.createReview(captureAny)).captured;
        final capturedReview = captured.first as ReviewModel;
        
        expect(capturedReview.createdAt.isAfter(beforeCreate) || 
               capturedReview.createdAt.isAtSameMomentAs(beforeCreate), isTrue);
        expect(capturedReview.createdAt.isBefore(afterCreate) || 
               capturedReview.createdAt.isAtSameMomentAs(afterCreate), isTrue);
        expect(capturedReview.updatedAt, equals(capturedReview.createdAt));
      });

      test('データソースでエラーが発生した場合、APIExceptionが適切に処理される', () async {
        // Arrange
        when(mockDataSource.createReview(any))
            .thenThrow(APIException('Database connection failed'));

        // Act & Assert
        expect(
          () => repository.createReview(
            userId: 'test-user-id',
            movieId: 'test-movie-id',
            movieTitle: 'Test Movie',
            rating: 4.5,
          ),
          throwsA(
            allOf(
              isA<APIException>(),
              predicate<APIException>((e) => e.message.contains('Failed to create review')),
            ),
          ),
        );
      });
    });

    group('レビュー取得統合テスト (getReview)', () {
      test('指定されたIDのレビューがエンティティとして正常に返される', () async {
        // Arrange
        when(mockDataSource.getReview('test-review-id'))
            .thenAnswer((_) => Future.value(testReviewModel));

        // Act
        final result = await repository.getReview('test-review-id');

        // Assert
        expect(result, isA<Review>());
        expect(result.id, equals('test-review-id'));
        expect(result.userId, equals('test-user-id'));
        expect(result.movieTitle, equals('Test Movie'));
        verify(mockDataSource.getReview('test-review-id')).called(1);
      });

      test('存在しないレビューの場合、APIExceptionが適切に処理される', () async {
        // Arrange
        when(mockDataSource.getReview('non-existent-id'))
            .thenThrow(APIException('Review not found'));

        // Act & Assert
        expect(
          () => repository.getReview('non-existent-id'),
          throwsA(
            allOf(
              isA<APIException>(),
              predicate<APIException>((e) => e.message.contains('Failed to get review')),
            ),
          ),
        );
      });
    });

    group('レビューリスト取得統合テスト (getReviews)', () {
      test('フィルタなしで全てのレビューが取得される', () async {
        // Arrange
        final mockReviews = [testReviewModel];
        when(mockDataSource.getReviews())
            .thenAnswer((_) => Future.value(mockReviews));

        // Act
        final result = await repository.getReviews();

        // Assert
        expect(result, hasLength(1));
        expect(result.first, isA<Review>());
        expect(result.first.id, equals('test-review-id'));
        verify(mockDataSource.getReviews()).called(1);
      });

      test('ユーザーIDフィルタが正しく適用される', () async {
        // Arrange
        final mockReviews = [testReviewModel];
        when(mockDataSource.getReviews(userId: 'test-user-id'))
            .thenAnswer((_) => Future.value(mockReviews));

        // Act
        final result = await repository.getReviews(userId: 'test-user-id');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.userId, equals('test-user-id'));
        verify(mockDataSource.getReviews(userId: 'test-user-id')).called(1);
      });

      test('映画IDフィルタが正しく適用される', () async {
        // Arrange
        final mockReviews = [testReviewModel];
        when(mockDataSource.getReviews(movieId: 'test-movie-id'))
            .thenAnswer((_) => Future.value(mockReviews));

        // Act
        final result = await repository.getReviews(movieId: 'test-movie-id');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.movieId, equals('test-movie-id'));
        verify(mockDataSource.getReviews(movieId: 'test-movie-id')).called(1);
      });

      test('複数フィルタが同時に適用される', () async {
        // Arrange
        final mockReviews = [testReviewModel];
        when(mockDataSource.getReviews(
          userId: 'test-user-id',
          movieId: 'test-movie-id',
        )).thenAnswer((_) => Future.value(mockReviews));

        // Act
        final result = await repository.getReviews(
          userId: 'test-user-id',
          movieId: 'test-movie-id',
        );

        // Assert
        expect(result, hasLength(1));
        expect(result.first.userId, equals('test-user-id'));
        expect(result.first.movieId, equals('test-movie-id'));
        verify(mockDataSource.getReviews(
          userId: 'test-user-id',
          movieId: 'test-movie-id',
        )).called(1);
      });
    });

    group('レビュー更新統合テスト (updateReview)', () {
      test('レビューが正常に更新され、updatedAtが更新される', () async {
        // Arrange
        when(mockDataSource.updateReview(any))
            .thenAnswer((_) => Future.value());

        final beforeUpdate = DateTime.now();

        // Act
        await repository.updateReview(testReview);

        final afterUpdate = DateTime.now();

        // Assert
        final captured = verify(mockDataSource.updateReview(captureAny)).captured;
        final capturedReview = captured.first as ReviewModel;
        
        expect(capturedReview.id, equals(testReview.id));
        expect(capturedReview.userId, equals(testReview.userId));
        expect(capturedReview.createdAt, equals(testReview.createdAt));
        
        // updatedAtが更新されることを確認
        expect(capturedReview.updatedAt.isAfter(beforeUpdate) || 
               capturedReview.updatedAt.isAtSameMomentAs(beforeUpdate), isTrue);
        expect(capturedReview.updatedAt.isBefore(afterUpdate) || 
               capturedReview.updatedAt.isAtSameMomentAs(afterUpdate), isTrue);
      });

      test('更新に失敗した場合、APIExceptionが適切に処理される', () async {
        // Arrange
        when(mockDataSource.updateReview(any))
            .thenThrow(APIException('Update operation failed'));

        // Act & Assert
        expect(
          () => repository.updateReview(testReview),
          throwsA(
            allOf(
              isA<APIException>(),
              predicate<APIException>((e) => e.message.contains('Failed to update review')),
            ),
          ),
        );
      });
    });

    group('レビュー削除統合テスト (deleteReview)', () {
      test('レビューが正常に削除される', () async {
        // Arrange
        when(mockDataSource.deleteReview('test-review-id'))
            .thenAnswer((_) => Future.value());

        // Act
        await repository.deleteReview('test-review-id');

        // Assert
        verify(mockDataSource.deleteReview('test-review-id')).called(1);
      });

      test('削除に失敗した場合、APIExceptionが適切に処理される', () async {
        // Arrange
        when(mockDataSource.deleteReview('test-review-id'))
            .thenThrow(APIException('Delete operation failed'));

        // Act & Assert
        expect(
          () => repository.deleteReview('test-review-id'),
          throwsA(
            allOf(
              isA<APIException>(),
              predicate<APIException>((e) => e.message.contains('Failed to delete review')),
            ),
          ),
        );
      });
    });

    group('ユーザーレビュー取得統合テスト (getUserReviews)', () {
      test('特定ユーザーのレビューが正常に取得される', () async {
        // Arrange
        final mockReviews = [testReviewModel];
        when(mockDataSource.getUserReviews('test-user-id'))
            .thenAnswer((_) => Future.value(mockReviews));

        // Act
        final result = await repository.getUserReviews('test-user-id');

        // Assert
        expect(result, hasLength(1));
        expect(result.first, isA<Review>());
        expect(result.first.userId, equals('test-user-id'));
        verify(mockDataSource.getUserReviews('test-user-id')).called(1);
      });

      test('ユーザーレビュー取得に失敗した場合、APIExceptionが適切に処理される', () async {
        // Arrange
        when(mockDataSource.getUserReviews('test-user-id'))
            .thenThrow(APIException('User reviews query failed'));

        // Act & Assert
        expect(
          () => repository.getUserReviews('test-user-id'),
          throwsA(
            allOf(
              isA<APIException>(),
              predicate<APIException>((e) => e.message.contains('Failed to get user reviews')),
            ),
          ),
        );
      });
    });

    group('データ変換統合テスト', () {
      test('ReviewModelからReviewエンティティへの変換が正確に行われる', () async {
        // Arrange
        when(mockDataSource.getReview('test-review-id'))
            .thenAnswer((_) => Future.value(testReviewModel));

        // Act
        final result = await repository.getReview('test-review-id');

        // Assert
        expect(result.id, equals(testReviewModel.id));
        expect(result.userId, equals(testReviewModel.userId));
        expect(result.movieId, equals(testReviewModel.movieId));
        expect(result.movieTitle, equals(testReviewModel.movieTitle));
        expect(result.moviePosterUrl, equals(testReviewModel.moviePosterUrl));
        expect(result.rating, equals(testReviewModel.rating));
        expect(result.comment, equals(testReviewModel.comment));
        expect(result.createdAt, equals(testReviewModel.createdAt));
        expect(result.updatedAt, equals(testReviewModel.updatedAt));
      });

      test('ReviewエンティティからReviewModelへの変換が正確に行われる', () async {
        // Arrange
        when(mockDataSource.updateReview(any))
            .thenAnswer((_) => Future.value());

        // Act
        await repository.updateReview(testReview);

        // Assert
        final captured = verify(mockDataSource.updateReview(captureAny)).captured;
        final capturedReview = captured.first as ReviewModel;
        
        expect(capturedReview.id, equals(testReview.id));
        expect(capturedReview.userId, equals(testReview.userId));
        expect(capturedReview.movieId, equals(testReview.movieId));
        expect(capturedReview.movieTitle, equals(testReview.movieTitle));
        expect(capturedReview.moviePosterUrl, equals(testReview.moviePosterUrl));
        expect(capturedReview.rating, equals(testReview.rating));
        expect(capturedReview.comment, equals(testReview.comment));
        expect(capturedReview.createdAt, equals(testReview.createdAt));
      });
    });
  });
}