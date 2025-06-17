import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../../lib/features/reviews/presentation/pages/add_review_page.dart';
import '../../lib/features/reviews/presentation/pages/edit_review_page.dart';
import '../../lib/features/reviews/presentation/pages/reviews_page.dart';
import '../../lib/features/reviews/domain/entities/review.dart';
import '../../lib/features/movies/domain/entities/movie_entity.dart';
import '../../lib/features/auth/domain/entities/app_user.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Review Flow Integration Tests', () {
    late MockReviewRepository mockReviewRepository;
    late MockAuthRepository mockAuthRepository;
    late MockMovieRepository mockMovieRepository;

    setUp(() {
      mockReviewRepository = MockReviewRepository();
      mockAuthRepository = MockAuthRepository();
      mockMovieRepository = MockMovieRepository();
    });

    testWidgets('Complete review creation flow', (WidgetTester tester) async {
      // Arrange
      final testUser = AppUser(
        uid: 'test-user-id',
        displayName: 'Test User',
        email: 'test@example.com',
      );

      final testMovie = MovieEntity(
        id: 12345,
        title: 'Test Movie',
        overview: 'A great test movie',
        posterPath: '/test-poster.jpg',
        releaseYear: 2023,
        voteAverage: 7.5,
        genres: ['Action', 'Adventure'],
      );

      // Mock the authentication state
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => testUser);

      // Mock review creation
      when(mockReviewRepository.createReview(
        userId: anyNamed('userId'),
        movieId: anyNamed('movieId'),
        movieTitle: anyNamed('movieTitle'),
        moviePosterUrl: anyNamed('moviePosterUrl'),
        rating: anyNamed('rating'),
        comment: anyNamed('comment'),
        watchedDate: anyNamed('watchedDate'),
      )).thenAnswer((_) async => 'new-review-id');

      // Create the test widget
      final widget = TestHelpers.createTestWidget(
        child: AddReviewPage(movie: testMovie),
        overrides: [
          // Add provider overrides here
        ],
      );

      // Act & Assert
      await TestHelpers.pumpAndSettle(tester, widget);

      // Verify initial state
      expect(find.text('レビューを書く'), findsOneWidget);
      expect(find.text('Test Movie'), findsOneWidget);

      // Test rating interaction
      final starFinder = find.byIcon(Icons.star_border).first;
      await TestHelpers.tapAndPump(tester, starFinder);

      // Verify rating was set
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));

      // Test date picker
      final dateFinder = find.text('鑑賞日を選択（任意）');
      expect(dateFinder, findsOneWidget);
      await TestHelpers.tapAndPump(tester, dateFinder);

      // Note: DatePicker testing in integration tests can be complex
      // This would need to be expanded based on actual UI behavior

      // Test comment input
      final commentField = find.byType(TextFormField);
      await TestHelpers.enterTextAndPump(
        tester,
        commentField,
        'This is a great test movie!',
      );

      // Test form submission
      final submitButton = find.text('レビューを投稿');
      expect(submitButton, findsOneWidget);
      await TestHelpers.tapAndPump(tester, submitButton);

      // Verify success message
      await tester.pumpAndSettle();
      expect(find.text('レビューを投稿しました'), findsOneWidget);

      // Verify repository method was called
      verify(mockReviewRepository.createReview(
        userId: 'test-user-id',
        movieId: '12345',
        movieTitle: 'Test Movie',
        rating: anyNamed('rating'),
        comment: 'This is a great test movie!',
        watchedDate: anyNamed('watchedDate'),
      )).called(1);
    });

    testWidgets('Review editing flow', (WidgetTester tester) async {
      // Arrange
      final testReview = Review(
        id: 'test-review-id',
        userId: 'test-user-id',
        movieId: '12345',
        movieTitle: 'Test Movie',
        rating: 4.0,
        comment: 'Original comment',
        watchedDate: DateTime(2023, 6, 15),
        createdAt: DateTime(2023, 6, 15),
        updatedAt: DateTime(2023, 6, 15),
      );

      when(mockReviewRepository.updateReview(any))
          .thenAnswer((_) async {});

      final widget = TestHelpers.createTestWidget(
        child: EditReviewPage(review: testReview),
      );

      // Act & Assert
      await TestHelpers.pumpAndSettle(tester, widget);

      // Verify initial state
      expect(find.text('レビューを編集'), findsOneWidget);
      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('Original comment'), findsOneWidget);

      // Test rating modification
      final starFinder = find.byIcon(Icons.star_border).first;
      await TestHelpers.tapAndPump(tester, starFinder);

      // Test comment modification
      final commentField = find.byType(TextFormField);
      await tester.clear(commentField);
      await TestHelpers.enterTextAndPump(
        tester,
        commentField,
        'Updated comment',
      );

      // Test form submission
      final updateButton = find.text('レビューを更新');
      await TestHelpers.tapAndPump(tester, updateButton);

      // Verify success message
      await tester.pumpAndSettle();
      expect(find.text('レビューを更新しました'), findsOneWidget);
    });

    testWidgets('Review list and navigation flow', (WidgetTester tester) async {
      // Arrange
      final testReviews = [
        Review(
          id: 'review-1',
          userId: 'test-user-id',
          movieId: '12345',
          movieTitle: 'Movie 1',
          rating: 4.5,
          comment: 'Great movie!',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Review(
          id: 'review-2',
          userId: 'test-user-id',
          movieId: '67890',
          movieTitle: 'Movie 2',
          rating: 3.5,
          comment: 'Good movie!',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockReviewRepository.getUserReviews('test-user-id'))
          .thenAnswer((_) async => testReviews);

      final widget = TestHelpers.createTestWidgetWithNavigation(
        child: const ReviewsPage(),
        routes: {
          '/': (context) => const ReviewsPage(),
          '/edit': (context) => EditReviewPage(review: testReviews[0]),
        },
      );

      // Act & Assert
      await TestHelpers.pumpAndSettle(tester, widget);

      // Verify reviews are displayed
      expect(find.text('Movie 1'), findsOneWidget);
      expect(find.text('Movie 2'), findsOneWidget);
      expect(find.text('Great movie!'), findsOneWidget);
      expect(find.text('Good movie!'), findsOneWidget);

      // Test tab switching
      final myReviewsTab = find.text('マイレビュー');
      await TestHelpers.tapAndPump(tester, myReviewsTab);

      // Test review card interaction
      final reviewCard = find.text('Movie 1').first;
      await TestHelpers.tapAndPump(tester, reviewCard);

      // Test edit menu
      final menuButton = find.byType(PopupMenuButton).first;
      await TestHelpers.tapAndPump(tester, menuButton);

      final editButton = find.text('編集');
      expect(editButton, findsOneWidget);
      await TestHelpers.tapAndPump(tester, editButton);

      // Verify navigation to edit page
      await tester.pumpAndSettle();
      expect(find.text('レビューを編集'), findsOneWidget);
    });

    testWidgets('Review deletion flow', (WidgetTester tester) async {
      // Arrange
      final testReview = Review(
        id: 'test-review-id',
        userId: 'test-user-id',
        movieId: '12345',
        movieTitle: 'Test Movie',
        rating: 4.0,
        comment: 'Test comment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockReviewRepository.getUserReviews('test-user-id'))
          .thenAnswer((_) async => [testReview]);

      when(mockReviewRepository.deleteReview('test-review-id'))
          .thenAnswer((_) async {});

      final widget = TestHelpers.createTestWidget(
        child: const ReviewsPage(),
      );

      // Act & Assert
      await TestHelpers.pumpAndSettle(tester, widget);

      // Open menu
      final menuButton = find.byType(PopupMenuButton);
      await TestHelpers.tapAndPump(tester, menuButton);

      // Tap delete
      final deleteButton = find.text('削除');
      await TestHelpers.tapAndPump(tester, deleteButton);

      // Confirm deletion
      final confirmButton = find.text('削除').last;
      await TestHelpers.tapAndPump(tester, confirmButton);

      // Verify success message
      await tester.pumpAndSettle();
      expect(find.text('レビューを削除しました'), findsOneWidget);

      // Verify repository method was called
      verify(mockReviewRepository.deleteReview('test-review-id')).called(1);
    });

    testWidgets('Error handling in review creation', (WidgetTester tester) async {
      // Arrange
      final testMovie = MovieEntity(
        id: 12345,
        title: 'Test Movie',
        overview: 'A test movie',
        posterPath: '/test.jpg',
        releaseYear: 2023,
        voteAverage: 7.5,
        genres: ['Action'],
      );

      // Mock error
      when(mockReviewRepository.createReview(
        userId: anyNamed('userId'),
        movieId: anyNamed('movieId'),
        movieTitle: anyNamed('movieTitle'),
        rating: anyNamed('rating'),
      )).thenThrow(Exception('Network error'));

      final widget = TestHelpers.createTestWidget(
        child: AddReviewPage(movie: testMovie),
      );

      // Act & Assert
      await TestHelpers.pumpAndSettle(tester, widget);

      // Submit form to trigger error
      final submitButton = find.text('レビューを投稿');
      await TestHelpers.tapAndPump(tester, submitButton);

      // Verify error message
      await tester.pumpAndSettle();
      expect(find.textContaining('エラー'), findsOneWidget);
    });

    testWidgets('Accessibility compliance', (WidgetTester tester) async {
      // Arrange
      final testMovie = MovieEntity(
        id: 12345,
        title: 'Test Movie',
        overview: 'A test movie',
        posterPath: '/test.jpg',
        releaseYear: 2023,
        voteAverage: 7.5,
        genres: ['Action'],
      );

      final widget = TestHelpers.createTestWidget(
        child: AddReviewPage(movie: testMovie),
      );

      // Act & Assert
      await TestHelpers.pumpAndSettle(tester, widget);

      // Test semantic labels
      TestHelpers.verifyAccessibility(
        tester,
        find.text('レビューを投稿'),
        expectedLabel: 'レビューを投稿',
        expectedButton: true,
      );

      // Test star rating accessibility
      final starRating = find.byType(InteractiveStarRating);
      if (tester.any(starRating)) {
        TestHelpers.verifyAccessibility(
          tester,
          starRating,
          expectedLabel: '評価を選択してください',
        );
      }
    });
  });
}

// Mock classes would be generated by Mockito
class MockReviewRepository extends Mock {}
class MockAuthRepository extends Mock {}
class MockMovieRepository extends Mock {}