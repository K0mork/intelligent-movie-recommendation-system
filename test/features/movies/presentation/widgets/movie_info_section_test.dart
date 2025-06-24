import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:filmflow/features/movies/presentation/widgets/movie_info_section.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';

void main() {
  group('MovieInfoSection Widget Tests', () {
    late Movie testMovie;

    setUp(() {
      testMovie = const Movie(
        id: 12345,
        title: 'Test Movie Title',
        overview: 'This is a comprehensive test overview for the movie that provides detailed information about the plot and characters.',
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
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display movie title correctly', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert
        expect(find.text('Test Movie Title'), findsOneWidget);
      });

      testWidgets('should display original title when different from title', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert
        expect(find.text('Original Test Movie Title'), findsOneWidget);
      });

      testWidgets('should not display original title when same as title', (WidgetTester tester) async {
        // Arrange
        final movieWithSameTitle = testMovie.copyWith(
          originalTitle: 'Test Movie Title', // Same as title
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: movieWithSameTitle)),
        );

        // Assert
        expect(find.text('Test Movie Title'), findsOneWidget);
        // Original title should not appear twice
        expect(find.text('Test Movie Title'), findsOneWidget);
      });

      testWidgets('should display release date when available', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert
        expect(find.text('2023-06-15'), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });

      testWidgets('should not display release date when empty', (WidgetTester tester) async {
        // Arrange
        final movieWithoutDate = testMovie.copyWith(releaseDate: '');

        // Act
        await tester.pumpWidget(
          createTestWidget(
            MovieInfoSection(movie: movieWithoutDate),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.calendar_today), findsNothing);
      });

      testWidgets('should not display release date when null', (WidgetTester tester) async {
        // Arrange
        const movieWithNullDate = Movie(
          id: 12345,
          title: 'Test Movie Title',
          overview: 'Test overview',
          posterPath: '/test-poster.jpg',
          backdropPath: '/test-backdrop.jpg',
          releaseDate: null, // 明示的にnull
          voteAverage: 7.8,
          voteCount: 1250,
          genreIds: [28, 12, 16],
          adult: false,
          originalLanguage: 'en',
          originalTitle: 'Original Test Movie Title',
          popularity: 125.5,
          video: false,
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            MovieInfoSection(movie: movieWithNullDate),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.calendar_today), findsNothing);
      });
    });

    group('Rating Information', () {
      testWidgets('should display vote average correctly', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert
        expect(find.text('7.8'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('should display vote count correctly', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert
        expect(find.text(' (1250 votes)'), findsOneWidget);
      });

      testWidgets('should handle zero vote count', (WidgetTester tester) async {
        // Arrange
        final movieWithZeroVotes = testMovie.copyWith(voteCount: 0);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            MovieInfoSection(movie: movieWithZeroVotes),
          ),
        );

        // Assert
        expect(find.text(' (0 votes)'), findsOneWidget);
      });

      testWidgets('should format vote average to one decimal place', (WidgetTester tester) async {
        // Arrange
        final movieWithPreciseRating = testMovie.copyWith(voteAverage: 8.567);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            MovieInfoSection(movie: movieWithPreciseRating),
          ),
        );

        // Assert
        expect(find.text('8.6'), findsOneWidget);
      });
    });

    group('Poster Image', () {
      testWidgets('should display CachedNetworkImage for poster', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert
        expect(find.byType(CachedNetworkImage), findsOneWidget);
      });

      testWidgets('should use correct poster URL', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert
        final cachedImageWidget = tester.widget<CachedNetworkImage>(
          find.byType(CachedNetworkImage),
        );
        expect(cachedImageWidget.imageUrl, equals(testMovie.fullPosterUrl));
      });

      testWidgets('should have correct poster dimensions', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert
        final cachedImageWidget = tester.widget<CachedNetworkImage>(
          find.byType(CachedNetworkImage),
        );
        expect(cachedImageWidget.width, equals(120));
        expect(cachedImageWidget.height, equals(180));
      });
    });

    group('Overview Section', () {
      testWidgets('should display overview when available', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert
        expect(find.text('あらすじ'), findsOneWidget);
        expect(find.text(testMovie.overview), findsOneWidget);
      });

      testWidgets('should not display overview when empty', (WidgetTester tester) async {
        // Arrange
        final movieWithoutOverview = testMovie.copyWith(overview: '');

        // Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: movieWithoutOverview)),
        );

        // Assert
        expect(find.text('あらすじ'), findsNothing);
      });

      testWidgets('should handle long overview text', (WidgetTester tester) async {
        // Arrange
        final longOverview = 'This is a very long overview that contains multiple sentences and provides extensive detail about the movie plot, characters, and setting. ' * 5;
        final movieWithLongOverview = testMovie.copyWith(overview: longOverview);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            MovieInfoSection(movie: movieWithLongOverview),
          ),
        );

        // Assert
        expect(find.text('あらすじ'), findsOneWidget);
        expect(find.text(longOverview), findsOneWidget);
      });
    });

    group('Layout and Structure', () {
      testWidgets('should have proper widget structure', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert
        expect(find.byType(Column), findsWidgets);
        expect(find.byType(Row), findsWidgets);
        expect(find.byType(ClipRRect), findsOneWidget);
      });

      testWidgets('should have rounded corners on poster image', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert
        final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
        final borderRadius = clipRRect.borderRadius as BorderRadius;
        expect(borderRadius.topLeft.x, equals(8.0));
      });

      testWidgets('should be responsive to different screen sizes', (WidgetTester tester) async {
        // Arrange - Set small screen size
        await tester.binding.setSurfaceSize(const Size(400, 600));

        // Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert - Widget should render without overflow
        expect(tester.takeException(), isNull);

        // Arrange - Set large screen size
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pump();

        // Assert - Widget should still render properly
        expect(tester.takeException(), isNull);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle movie with minimal data', (WidgetTester tester) async {
        // Arrange
        const minimalMovie = Movie(
          id: 1,
          title: 'Minimal Movie',
          overview: '',
          posterPath: null,
          backdropPath: null,
          releaseDate: null,
          voteAverage: 0.0,
          voteCount: 0,
          genreIds: [],
          adult: false,
          originalLanguage: '',
          originalTitle: 'Minimal Movie',
          popularity: 0.0,
          video: false,
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            MovieInfoSection(movie: minimalMovie),
          ),
        );

        // Assert
        expect(find.text('Minimal Movie'), findsOneWidget);
        expect(find.text('0.0'), findsOneWidget);
        expect(find.text(' (0 votes)'), findsOneWidget);
        expect(find.text('あらすじ'), findsNothing);
        expect(find.byIcon(Icons.calendar_today), findsNothing);
      });

      testWidgets('should handle very high vote counts', (WidgetTester tester) async {
        // Arrange
        final movieWithHighVotes = testMovie.copyWith(voteCount: 999999);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            MovieInfoSection(movie: movieWithHighVotes),
          ),
        );

        // Assert
        expect(find.text(' (999999 votes)'), findsOneWidget);
      });

      testWidgets('should handle extreme rating values', (WidgetTester tester) async {
        // Arrange
        final movieWithExtremeRating = testMovie.copyWith(voteAverage: 10.0);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            MovieInfoSection(movie: movieWithExtremeRating),
          ),
        );

        // Assert
        expect(find.text('10.0'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantic structure', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(MovieInfoSection(movie: testMovie)),
        );

        // Assert - Basic semantic structure exists
        expect(find.byType(MovieInfoSection), findsOneWidget);

        // Verify text elements are readable
        expect(find.text('Test Movie Title'), findsOneWidget);
        expect(find.text('7.8'), findsOneWidget);
      });
    });

    group('Theme Integration', () {
      testWidgets('should adapt to dark theme', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            MovieInfoSection(movie: testMovie),
          ),
        );

        // Assert - Widget should render without issues in dark theme
        expect(find.text('Test Movie Title'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should adapt to light theme', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(
            MovieInfoSection(movie: testMovie),
          ),
        );

        // Assert - Widget should render without issues in light theme
        expect(find.text('Test Movie Title'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
