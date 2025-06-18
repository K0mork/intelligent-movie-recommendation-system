import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmflow/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:filmflow/features/reviews/data/models/review_model.dart';
import 'package:filmflow/core/errors/app_exceptions.dart';

// Mock classes will be generated
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  Query,
])
import 'review_remote_datasource_test.mocks.dart';

/// Firestore統合テスト：レビューデータソース
/// レビューのCRUD操作をテストし、Firestoreとの統合を検証
void main() {
  group('ReviewRemoteDataSource Firestore Integration Tests', () {
    late ReviewRemoteDataSourceImpl dataSource;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
    late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
    late MockQueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshot;
    late MockQuery<Map<String, dynamic>> mockQuery;

    // テストデータ
    final testReview = ReviewModel(
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

    final testReviewData = {
      'userId': 'test-user-id',
      'movieId': 'test-movie-id',
      'movieTitle': 'Test Movie',
      'moviePosterUrl': 'https://example.com/poster.jpg',
      'rating': 4.5,
      'comment': 'Great movie!',
      'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
    };

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockDocumentRef = MockDocumentReference<Map<String, dynamic>>();
      mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      mockQueryDocumentSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      mockQuery = MockQuery<Map<String, dynamic>>();
      
      dataSource = ReviewRemoteDataSourceImpl(firestore: mockFirestore);

      // Firestoreコレクション参照の設定
      when(mockFirestore.collection('reviews')).thenReturn(mockCollection);
    });

    group('レビュー作成テスト (createReview)', () {
      test('レビューが正常に作成される', () async {
        // Arrange
        when(mockCollection.doc()).thenReturn(mockDocumentRef);
        when(mockDocumentRef.id).thenReturn('new-review-id');
        when(mockDocumentRef.set(any)).thenAnswer((_) => Future.value());

        // Act
        final result = await dataSource.createReview(testReview);

        // Assert
        expect(result, equals('new-review-id'));
        verify(mockCollection.doc()).called(1);
        verify(mockDocumentRef.set(testReview.toMap())).called(1);
      });

      test('レビュー作成に失敗した場合、APIExceptionがスローされる', () async {
        // Arrange
        when(mockCollection.doc()).thenReturn(mockDocumentRef);
        when(mockDocumentRef.set(any)).thenThrow(Exception('Firestore error'));

        // Act & Assert
        expect(
          () => dataSource.createReview(testReview),
          throwsA(isA<APIException>()),
        );
      });
    });

    group('レビュー取得テスト (getReview)', () {
      test('レビューが正常に取得される', () async {
        // Arrange
        when(mockCollection.doc('test-review-id')).thenReturn(mockDocumentRef);
        when(mockDocumentRef.get()).thenAnswer((_) => Future.value(mockDocumentSnapshot));
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.id).thenReturn('test-review-id');
        when(mockDocumentSnapshot.data()).thenReturn(testReviewData);

        // Act
        final result = await dataSource.getReview('test-review-id');

        // Assert
        expect(result.id, equals('test-review-id'));
        expect(result.userId, equals('test-user-id'));
        expect(result.movieTitle, equals('Test Movie'));
        verify(mockCollection.doc('test-review-id')).called(1);
        verify(mockDocumentRef.get()).called(1);
      });

      test('存在しないレビューIDの場合、APIExceptionがスローされる', () async {
        // Arrange
        when(mockCollection.doc('non-existent-id')).thenReturn(mockDocumentRef);
        when(mockDocumentRef.get()).thenAnswer((_) => Future.value(mockDocumentSnapshot));
        when(mockDocumentSnapshot.exists).thenReturn(false);

        // Act & Assert
        expect(
          () => dataSource.getReview('non-existent-id'),
          throwsA(isA<APIException>()),
        );
      });
    });

    group('レビューリスト取得テスト (getReviews)', () {
      test('全てのレビューが正常に取得される', () async {
        // Arrange
        final mockQueryDocumentSnapshots = [mockQueryDocumentSnapshot];
        
        when(mockCollection.orderBy('createdAt', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) => Future.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs).thenReturn(mockQueryDocumentSnapshots);
        when(mockQueryDocumentSnapshot.id).thenReturn('test-review-id');
        when(mockQueryDocumentSnapshot.data()).thenReturn(testReviewData);

        // Act
        final result = await dataSource.getReviews();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.id, equals('test-review-id'));
        verify(mockCollection.orderBy('createdAt', descending: true)).called(1);
        verify(mockQuery.get()).called(1);
      });

      test('ユーザーIDでフィルタリングされたレビューが取得される', () async {
        // Arrange
        final mockQueryDocumentSnapshots = [mockQueryDocumentSnapshot];
        
        when(mockCollection.where('userId', isEqualTo: 'test-user-id'))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy('createdAt', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) => Future.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs).thenReturn(mockQueryDocumentSnapshots);
        when(mockQueryDocumentSnapshot.id).thenReturn('test-review-id');
        when(mockQueryDocumentSnapshot.data()).thenReturn(testReviewData);

        // Act
        final result = await dataSource.getReviews(userId: 'test-user-id');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.userId, equals('test-user-id'));
        verify(mockCollection.where('userId', isEqualTo: 'test-user-id')).called(1);
      });

      test('映画IDでフィルタリングされたレビューが取得される', () async {
        // Arrange
        final mockQueryDocumentSnapshots = [mockQueryDocumentSnapshot];
        
        when(mockCollection.where('movieId', isEqualTo: 'test-movie-id'))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy('createdAt', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) => Future.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs).thenReturn(mockQueryDocumentSnapshots);
        when(mockQueryDocumentSnapshot.id).thenReturn('test-review-id');
        when(mockQueryDocumentSnapshot.data()).thenReturn(testReviewData);

        // Act
        final result = await dataSource.getReviews(movieId: 'test-movie-id');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.movieId, equals('test-movie-id'));
        verify(mockCollection.where('movieId', isEqualTo: 'test-movie-id')).called(1);
      });
    });

    group('レビュー更新テスト (updateReview)', () {
      test('レビューが正常に更新される', () async {
        // Arrange
        when(mockCollection.doc('test-review-id')).thenReturn(mockDocumentRef);
        when(mockDocumentRef.update(any)).thenAnswer((_) => Future.value());

        // Act
        await dataSource.updateReview(testReview);

        // Assert
        verify(mockCollection.doc('test-review-id')).called(1);
        verify(mockDocumentRef.update(testReview.toMap())).called(1);
      });

      test('レビュー更新に失敗した場合、APIExceptionがスローされる', () async {
        // Arrange
        when(mockCollection.doc('test-review-id')).thenReturn(mockDocumentRef);
        when(mockDocumentRef.update(any)).thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(
          () => dataSource.updateReview(testReview),
          throwsA(isA<APIException>()),
        );
      });
    });

    group('レビュー削除テスト (deleteReview)', () {
      test('レビューが正常に削除される', () async {
        // Arrange
        when(mockCollection.doc('test-review-id')).thenReturn(mockDocumentRef);
        when(mockDocumentRef.delete()).thenAnswer((_) => Future.value());

        // Act
        await dataSource.deleteReview('test-review-id');

        // Assert
        verify(mockCollection.doc('test-review-id')).called(1);
        verify(mockDocumentRef.delete()).called(1);
      });

      test('レビュー削除に失敗した場合、APIExceptionがスローされる', () async {
        // Arrange
        when(mockCollection.doc('test-review-id')).thenReturn(mockDocumentRef);
        when(mockDocumentRef.delete()).thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => dataSource.deleteReview('test-review-id'),
          throwsA(isA<APIException>()),
        );
      });
    });

    group('ユーザーレビュー取得テスト (getUserReviews)', () {
      test('特定ユーザーのレビューが正常に取得される', () async {
        // Arrange
        final mockQueryDocumentSnapshots = [mockQueryDocumentSnapshot];
        
        when(mockCollection.where('userId', isEqualTo: 'test-user-id'))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy('createdAt', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) => Future.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs).thenReturn(mockQueryDocumentSnapshots);
        when(mockQueryDocumentSnapshot.id).thenReturn('test-review-id');
        when(mockQueryDocumentSnapshot.data()).thenReturn(testReviewData);

        // Act
        final result = await dataSource.getUserReviews('test-user-id');

        // Assert
        expect(result, hasLength(1));
        expect(result.first.userId, equals('test-user-id'));
        verify(mockCollection.where('userId', isEqualTo: 'test-user-id')).called(1);
        verify(mockQuery.orderBy('createdAt', descending: true)).called(1);
      });
    });

    group('エラーハンドリングテスト', () {
      test('Firestoreのエラーが適切にキャッチされる', () async {
        // Arrange
        when(mockCollection.orderBy('createdAt', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenThrow(Exception('Firestore connection error'));

        // Act & Assert
        expect(
          () => dataSource.getReviews(),
          throwsA(
            allOf(
              isA<APIException>(),
              predicate<APIException>((e) => e.message.contains('Failed to get reviews')),
            ),
          ),
        );
      });
    });
  });
}