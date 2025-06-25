import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmflow/features/reviews/presentation/widgets/star_rating.dart';

void main() {
  group('StarRating', () {
    testWidgets('displays correct number of stars', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StarRating(rating: 3.0, maxRating: 5)),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('displays half stars when allowHalfRating is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRating(rating: 3.5, maxRating: 5, allowHalfRating: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_half), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('does not display half stars when allowHalfRating is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRating(rating: 3.5, maxRating: 5, allowHalfRating: false),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_half), findsNothing);
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('calls onRatingChanged when star is tapped', (tester) async {
      double? tappedRating;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRating(
              rating: 2.0,
              maxRating: 5,
              onRatingChanged: (rating) {
                tappedRating = rating;
              },
            ),
          ),
        ),
      );

      // Tap the third star (should be Icons.star_border, rating 3.0)
      await tester.tap(find.byIcon(Icons.star_border).first);
      await tester.pump();

      expect(tappedRating, equals(3.0));
    });

    testWidgets('does not respond to taps when onRatingChanged is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StarRating(rating: 2.0, maxRating: 5)),
        ),
      );

      // Try to tap a star
      await tester.tap(find.byIcon(Icons.star_border).first);
      await tester.pump();

      // Should not crash or cause any issues
      expect(find.byIcon(Icons.star), findsNWidgets(2));
    });

    testWidgets('uses custom colors when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRating(
              rating: 3.0,
              maxRating: 5,
              color: Colors.red,
              unratedColor: Colors.grey,
            ),
          ),
        ),
      );

      final starIcons = tester.widgetList<Icon>(find.byType(Icon));

      // Check that filled stars have the active color
      final filledStars = starIcons.where((icon) => icon.icon == Icons.star);
      for (final star in filledStars) {
        expect(star.color, equals(Colors.red));
      }

      // Check that empty stars have the inactive color
      final emptyStars = starIcons.where(
        (icon) => icon.icon == Icons.star_border,
      );
      for (final star in emptyStars) {
        expect(star.color, equals(Colors.grey));
      }
    });

    testWidgets('uses custom size when provided', (tester) async {
      const customSize = 32.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRating(rating: 3.0, maxRating: 5, size: customSize),
          ),
        ),
      );

      final starIcons = tester.widgetList<Icon>(find.byType(Icon));
      for (final star in starIcons) {
        expect(star.size, equals(customSize));
      }
    });

    testWidgets('handles edge case ratings correctly', (tester) async {
      // Test rating of 0
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StarRating(rating: 0.0, maxRating: 5)),
        ),
      );

      expect(find.byIcon(Icons.star_border), findsNWidgets(5));
      expect(find.byIcon(Icons.star), findsNothing);

      // Test maximum rating
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StarRating(rating: 5.0, maxRating: 5)),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(5));
      expect(find.byIcon(Icons.star_border), findsNothing);
    });
  });

  group('InteractiveStarRating', () {
    testWidgets('displays initial rating correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveStarRating(
              initialRating: 3.0,
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('updates rating when star is tapped', (tester) async {
      double? receivedRating;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveStarRating(
              initialRating: 2.0,
              onRatingChanged: (rating) {
                receivedRating = rating;
              },
            ),
          ),
        ),
      );

      // Tap the fourth star
      final forthStar = find.byType(GestureDetector).at(3);
      await tester.tap(forthStar);
      await tester.pump();

      expect(receivedRating, equals(4.0));
      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('updates visual state when rating changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveStarRating(
              initialRating: 1.0,
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      // Initially should show 1 star
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNWidgets(4));

      // Tap the third star
      await tester.tap(find.byType(GestureDetector).at(2));
      await tester.pump();

      // Should now show 3 stars
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('uses custom size and colors', (tester) async {
      const customSize = 40.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveStarRating(
              initialRating: 3.0,
              onRatingChanged: (_) {},
              size: customSize,
              color: Colors.orange,
              unratedColor: Colors.grey,
            ),
          ),
        ),
      );

      final starIcons = tester.widgetList<Icon>(find.byType(Icon));

      // Check size
      for (final star in starIcons) {
        expect(star.size, equals(customSize));
      }

      // Check colors
      final filledStars = starIcons.where((icon) => icon.icon == Icons.star);
      for (final star in filledStars) {
        expect(star.color, equals(Colors.orange));
      }

      final emptyStars = starIcons.where(
        (icon) => icon.icon == Icons.star_border,
      );
      for (final star in emptyStars) {
        expect(star.color, equals(Colors.grey));
      }
    });

    testWidgets('has proper padding between stars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveStarRating(
              initialRating: 3.0,
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      final paddingWidgets = tester.widgetList<Padding>(find.byType(Padding));
      for (final padding in paddingWidgets) {
        expect(
          padding.padding,
          equals(const EdgeInsets.symmetric(horizontal: 2.0)),
        );
      }
    });

    testWidgets('works with different maxRating values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveStarRating(
              initialRating: 3.0,
              maxRating: 10,
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNWidgets(10));
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(7));
    });
  });
}
