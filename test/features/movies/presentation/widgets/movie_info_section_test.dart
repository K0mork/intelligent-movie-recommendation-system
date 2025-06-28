import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:filmflow/features/movies/presentation/widgets/movie_info_section.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';

void main() {
  group('MovieOverviewSection Widget Tests', () {
    late Movie testMovie;
    late Movie movieWithoutOverview;

    setUp(() {
      testMovie = const Movie(
        id: 12345,
        title: 'Test Movie Title',
        overview:
            'This is a comprehensive test overview for the movie that provides detailed information about the plot and characters.',
        posterPath: '/test-poster.jpg',
        backdropPath: '/test-backdrop.jpg',
        releaseDate: '2023-06-15',
        voteAverage: 7.8,
        voteCount: 1250,
        genreIds: [28, 12, 16],
        adult: false,
        originalLanguage: 'en',
        originalTitle: 'Original Test Movie Title',
        popularity: 125.5,
        video: false,
      );

      movieWithoutOverview = const Movie(
        id: 54321,
        title: 'Movie Without Overview',
        overview: '',
        posterPath: '/test-poster.jpg',
        backdropPath: '/test-backdrop.jpg',
        releaseDate: '2023-06-15',
        voteAverage: 7.8,
        voteCount: 1250,
        genreIds: [28, 12, 16],
        adult: false,
        originalLanguage: 'en',
        originalTitle: 'Movie Without Overview',
        popularity: 125.5,
        video: false,
      );
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(home: Scaffold(body: child));
    }

    group('Overview Display', () {
      testWidgets('should display overview section when overview is provided', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieOverviewSection(movie: testMovie)),
        );

        // Assert
        expect(find.text('あらすじ'), findsOneWidget);
        expect(find.text(testMovie.overview), findsOneWidget);
      });

      testWidgets('should not display anything when overview is empty', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieOverviewSection(movie: movieWithoutOverview)),
        );

        // Assert
        expect(find.text('あらすじ'), findsNothing);
        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('should display long overview correctly', (
        WidgetTester tester,
      ) async {
        // Arrange
        final movieWithLongOverview = testMovie.copyWith(
          overview: 'A' * 1000, // Very long overview
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(MovieOverviewSection(movie: movieWithLongOverview)),
        );

        // Assert
        expect(find.text('あらすじ'), findsOneWidget);
        expect(find.text('A' * 1000), findsOneWidget);
      });
    });

    group('Widget Structure', () {
      testWidgets('should have correct widget structure when overview exists', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieOverviewSection(movie: testMovie)),
        );

        // Assert
        expect(find.byType(Column), findsOneWidget);
        expect(find.byType(Text), findsNWidgets(2)); // Title + overview
        expect(find.byType(SizedBox), findsNWidgets(2)); // Spacing elements
      });

      testWidgets('should have minimal structure when overview is empty', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieOverviewSection(movie: movieWithoutOverview)),
        );

        // Assert
        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(Column), findsNothing);
      });
    });

    group('Theme Integration', () {
      testWidgets('should use correct text styles from theme', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieOverviewSection(movie: testMovie)),
        );

        // Assert
        final titleText = tester.widget<Text>(find.text('あらすじ'));
        final overviewText = tester.widget<Text>(find.text(testMovie.overview));

        expect(titleText.style?.fontWeight, FontWeight.bold);
        expect(overviewText.textAlign, TextAlign.justify);
      });
    });
  });
}
