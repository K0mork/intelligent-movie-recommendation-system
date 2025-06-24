import 'package:flutter/material.dart';
import 'year_filter_widget.dart';
import 'movie_search_results_widget.dart';
import 'package:filmflow/features/movies/data/models/movie.dart' as movie_model;

/// 映画検索デリゲート（リファクタリング版）
///
/// 複雑だった検索ロジックを個別のウィジェットに分離し、
/// 保守性と再利用性を向上。
class MovieSearchDelegate extends SearchDelegate<movie_model.Movie?> with YearFilterMixin {

  @override
  String get searchFieldLabel => '映画を検索...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      // 年代フィルター
      YearFilterWidget(
        selectedYear: selectedYear,
        onYearChanged: (year) {
          setSelectedYear(year);
          showResults(context); // UIを強制的に再描画
        },
      ),
      // クリアボタン
      IconButton(
        icon: const Icon(Icons.clear),
        tooltip: 'クリア',
        onPressed: () {
          query = '';
          clearYearFilter();
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: '戻る',
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return MovieSearchResultsWidget(
      query: query,
      selectedYear: selectedYear,
      onMovieSelected: (movie) {
        close(context, movie);
      },
      onRetry: () {
        showResults(context);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return MovieSearchInitialState(
        selectedYear: selectedYear,
      );
    }

    // 検索クエリがある場合は結果を表示
    return MovieSearchResultsWidget(
      query: query,
      selectedYear: selectedYear,
      onMovieSelected: (movie) {
        close(context, movie);
      },
      onRetry: () {
        showSuggestions(context);
      },
    );
  }
}
