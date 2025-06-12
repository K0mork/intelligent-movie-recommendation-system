import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movie_recommend_app/core/constants/app_constants.dart';
import 'package:movie_recommend_app/core/theme/scroll_behavior.dart';
import 'package:movie_recommend_app/features/movies/presentation/widgets/movie_card.dart';
import 'package:movie_recommend_app/features/movies/data/models/movie.dart';

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  final Function(Movie)? onMovieTap;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final ScrollController? scrollController;

  const MovieGrid({
    super.key,
    required this.movies,
    this.onMovieTap,
    this.isLoading = false,
    this.onLoadMore,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // レスポンシブなグリッド列数の計算
    int crossAxisCount;
    double childAspectRatio;
    
    if (screenWidth > 1200) {
      crossAxisCount = 4;
      childAspectRatio = 0.75;
    } else if (screenWidth > 800) {
      crossAxisCount = 3;
      childAspectRatio = 0.7;
    } else if (screenWidth > 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.65;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.6;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        // より精密な無限スクロールトリガー
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - AppConstants.loadMoreTriggerDistance &&
            onLoadMore != null &&
            !isLoading) {
          onLoadMore!();
        }
        return false;
      },
      child: ScrollConfiguration(
        behavior: AppScrollBehavior(),
        child: GridView.builder(
          controller: scrollController,
          padding: EdgeInsets.all(kIsWeb ? AppConstants.webPadding : AppConstants.defaultPadding),
          // Macでのスムーズスクロールのためのphysics
          physics: kIsWeb 
              ? const ClampingScrollPhysics()
              : const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: kIsWeb ? AppConstants.webPadding : AppConstants.defaultPadding,
            mainAxisSpacing: kIsWeb ? AppConstants.webPadding : AppConstants.defaultPadding,
          ),
          itemCount: movies.length + (isLoading ? crossAxisCount : 0),
          itemBuilder: (context, index) {
            if (index >= movies.length) {
              return const Card(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final movie = movies[index];
            return MovieCard(
              movie: movie,
              onTap: () => onMovieTap?.call(movie),
            );
          },
        ),
      ),
    );
  }
}