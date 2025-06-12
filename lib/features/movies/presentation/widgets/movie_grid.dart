import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:movie_recommend_app/features/movies/presentation/widgets/movie_card.dart';
import 'package:movie_recommend_app/shared/models/movie.dart';

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
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200 &&
            onLoadMore != null &&
            !isLoading) {
          onLoadMore!();
        }
        return false;
      },
      child: ScrollConfiguration(
        behavior: _CustomGridScrollBehavior(),
        child: GridView.builder(
          controller: scrollController,
          padding: EdgeInsets.all(kIsWeb ? 24 : 16),
          // Macでのスムーズスクロールのためのphysics
          physics: kIsWeb 
              ? const ClampingScrollPhysics()
              : const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: kIsWeb ? 20 : 16,
            mainAxisSpacing: kIsWeb ? 20 : 16,
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

class _CustomGridScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (kIsWeb) {
      return const ClampingScrollPhysics();
    }
    return const BouncingScrollPhysics();
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (kIsWeb) {
      return Scrollbar(
        controller: details.controller,
        thumbVisibility: false,
        trackVisibility: false,
        thickness: 6.0,
        radius: const Radius.circular(3.0),
        child: child,
      );
    }
    return super.buildScrollbar(context, child, details);
  }
}