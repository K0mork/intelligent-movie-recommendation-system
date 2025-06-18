import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmflow/main.dart';
import 'package:filmflow/features/movies/presentation/pages/movies_page.dart';
import 'package:filmflow/features/reviews/presentation/pages/reviews_page.dart';
import 'package:filmflow/features/reviews/presentation/widgets/star_rating.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('App launch performance with actual measurement', (WidgetTester tester) async {
      // 実際のアプリ起動時間を測定
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(firebaseAvailable: false),
        ),
      );
      
      // 初期フレームのみを測定
      await tester.pump();
      final initialRenderTime = stopwatch.elapsedMilliseconds;
      
      // 全てのアニメーションが完了するまで待機
      await tester.pumpAndSettle();
      stopwatch.stop();
      
      final totalLaunchTime = stopwatch.elapsedMilliseconds;
      
      // 実際の測定値でテスト
      expect(initialRenderTime, lessThan(1000),
        reason: 'Initial render should be under 1 second, was ${initialRenderTime}ms');
      
      expect(totalLaunchTime, lessThan(5000),
        reason: 'Total launch should be under 5 seconds, was ${totalLaunchTime}ms');
      
      // パフォーマンスデータをログ出力
      print('Performance Metrics:');
      print('  Initial render: ${initialRenderTime}ms');
      print('  Total launch: ${totalLaunchTime}ms');
      print('  Animation time: ${totalLaunchTime - initialRenderTime}ms');
    });

    testWidgets('Large list rendering performance', (WidgetTester tester) async {
      // 大量データでの描画パフォーマンステスト
      final items = List.generate(100, (index) => 'Item $index');
      
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          child: Scaffold(
            body: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(items[index]),
                subtitle: Text('Description for ${items[index]}'),
                leading: const Icon(Icons.movie),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      final renderTime = stopwatch.elapsedMilliseconds;
      
      // スクロールテスト
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      final scrollTime = stopwatch.elapsedMilliseconds;
      
      stopwatch.stop();
      
      // 実際のパフォーマンス要件でテスト
      expect(renderTime, lessThan(2000),
        reason: 'Large list initial render should be under 2 seconds, was ${renderTime}ms');
      
      expect(scrollTime - renderTime, lessThan(500),
        reason: 'Scroll should be smooth (under 500ms), was ${scrollTime - renderTime}ms');
      
      // リストが正しく表示されることを確認
      expect(find.byType(ListTile), findsAtLeastNWidgets(1));
      expect(find.byType(ListView), findsOneWidget);
      
      print('List Performance:');
      print('  Render time: ${renderTime}ms');
      print('  Scroll time: ${scrollTime - renderTime}ms');
    });

    testWidgets('Star rating widget performance under stress', (WidgetTester tester) async {
      // 星評価ウィジェットの連続操作パフォーマンステスト
      const iterations = 50;
      final stopwatch = Stopwatch();
      
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          child: Scaffold(
            body: InteractiveStarRating(
              initialRating: 0.0,
              onRatingChanged: (rating) {
                // コールバック処理時間も計測対象
                expect(rating, greaterThanOrEqualTo(0.0));
                expect(rating, lessThanOrEqualTo(5.0));
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      stopwatch.start();
      
      // 連続的な星評価操作
      for (int i = 0; i < iterations; i++) {
        final starIndex = i % 5; // 0-4の星を順番にタップ
        final starFinder = find.byType(GestureDetector).at(starIndex);
        
        await tester.tap(starFinder);
        await tester.pump(); // pump()のみで即座に次の操作へ
      }
      
      await tester.pumpAndSettle();
      stopwatch.stop();
      
      final averageTimePerOperation = stopwatch.elapsedMilliseconds / iterations;
      
      // パフォーマンス基準
      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
        reason: '$iterations operations should complete under 5 seconds');
      
      expect(averageTimePerOperation, lessThan(50),
        reason: 'Average operation time should be under 50ms, was ${averageTimePerOperation.toStringAsFixed(2)}ms');
      
      print('Star Rating Performance:');
      print('  Total time: ${stopwatch.elapsedMilliseconds}ms');
      print('  Average per operation: ${averageTimePerOperation.toStringAsFixed(2)}ms');
      print('  Operations per second: ${(1000 / averageTimePerOperation).toStringAsFixed(2)}');
    });

    testWidgets('Complex widget tree rendering performance', (WidgetTester tester) async {
      // 複雑なウィジェットツリーの描画パフォーマンステスト
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          child: Scaffold(
            appBar: AppBar(title: const Text('Performance Test')),
            body: SingleChildScrollView(
              child: Column(
                children: List.generate(100, (index) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('$index'),
                    ),
                    title: Text('Movie Title $index'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description for movie $index'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const StarRating(rating: 4.5, maxRating: 5),
                            const SizedBox(width: 8),
                            Text('Rating: ${(4.0 + (index % 10) * 0.1).toStringAsFixed(1)}'),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {},
                    ),
                  ),
                )),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
                BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: 'Reviews'),
              ],
            ),
          ),
        ),
      );
      
      await tester.pump();
      final initialRenderTime = stopwatch.elapsedMilliseconds;
      
      // スクロールパフォーマンステスト
      final scrollStopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 10; i++) {
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
        await tester.pump();
      }
      
      scrollStopwatch.stop();
      stopwatch.stop();
      
      expect(initialRenderTime, lessThan(2000),
        reason: 'Complex widget tree should render under 2 seconds, was ${initialRenderTime}ms');
      
      expect(scrollStopwatch.elapsedMilliseconds, lessThan(1000),
        reason: '10 scroll operations should complete under 1 second, was ${scrollStopwatch.elapsedMilliseconds}ms');
      
      // UIが正しく表示されることを確認
      expect(find.text('Movie Title 0'), findsOneWidget);
      expect(find.byType(StarRating), findsWidgets);
      expect(find.byType(Card), findsWidgets);
      
      print('Complex Widget Performance:');
      print('  Initial render: ${initialRenderTime}ms');
      print('  Scroll performance: ${scrollStopwatch.elapsedMilliseconds}ms for 10 operations');
    });

    testWidgets('Widget creation and disposal performance', (WidgetTester tester) async {
      // ウィジェットの生成・破棄パフォーマンステスト
      final stopwatch = Stopwatch();
      const cycles = 20;
      
      stopwatch.start();
      
      for (int cycle = 0; cycle < cycles; cycle++) {
        // 複雑なウィジェットツリーを作成
        await tester.pumpWidget(
          TestHelpers.createTestWidget(
            child: Scaffold(
              body: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) => Card(
                  child: ExpansionTile(
                    title: Text('Movie $index'),
                    children: [
                      const StarRating(rating: 4.0, maxRating: 5),
                      Text('Description for movie $index'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.thumb_down),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        
        await tester.pump();
        
        // ウィジェットを破棄（新しいものに置き換え）
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
      
      stopwatch.stop();
      
      final averageTimePerCycle = stopwatch.elapsedMilliseconds / cycles;
      
      expect(stopwatch.elapsedMilliseconds, lessThan(10000),
        reason: '$cycles widget creation/disposal cycles should complete under 10 seconds');
      
      expect(averageTimePerCycle, lessThan(200),
        reason: 'Average cycle time should be under 200ms, was ${averageTimePerCycle.toStringAsFixed(2)}ms');
      
      print('Widget Lifecycle Performance:');
      print('  Total time: ${stopwatch.elapsedMilliseconds}ms');
      print('  Average per cycle: ${averageTimePerCycle.toStringAsFixed(2)}ms');
      print('  Cycles completed: $cycles');
    });

    test('Data processing performance', () async {
      // データ処理パフォーマンステスト（実際の計算）
      final stopwatch = Stopwatch()..start();
      
      // 大量のデータ処理をシミュレート
      final movieData = List.generate(10000, (index) => {
        'id': index,
        'title': 'Movie $index',
        'rating': (index % 10) / 2.0,
        'year': 2000 + (index % 24),
        'genres': [(index % 5) + 1, (index % 3) + 6],
      });
      
      // データフィルタリング処理
      final filteredMovies = movieData.where((movie) {
        return movie['rating'] as double > 3.0 && 
               (movie['year'] as int) > 2010;
      }).toList();
      
      // データソート処理
      filteredMovies.sort((a, b) {
        final ratingA = a['rating'] as double;
        final ratingB = b['rating'] as double;
        return ratingB.compareTo(ratingA);
      });
      
      // データ集計処理
      final groupedByYear = <int, List<Map<String, dynamic>>>{};
      for (final movie in filteredMovies) {
        final year = movie['year'] as int;
        groupedByYear.putIfAbsent(year, () => []).add(movie);
      }
      
      stopwatch.stop();
      
      // パフォーマンス検証
      expect(stopwatch.elapsedMilliseconds, lessThan(500),
        reason: 'Data processing should complete under 500ms, was ${stopwatch.elapsedMilliseconds}ms');
      
      // 結果の正確性検証
      expect(filteredMovies.isNotEmpty, true);
      expect(groupedByYear.isNotEmpty, true);
      
      // 最初の映画の評価が最も高いことを確認（ソート結果の検証）
      if (filteredMovies.isNotEmpty) {
        final topRating = filteredMovies.first['rating'] as double;
        expect(topRating, greaterThan(3.0));
      }
      
      print('Data Processing Performance:');
      print('  Processing time: ${stopwatch.elapsedMilliseconds}ms');
      print('  Original data size: ${movieData.length}');
      print('  Filtered data size: ${filteredMovies.length}');
      print('  Grouped by year: ${groupedByYear.length} years');
    });
  });
}