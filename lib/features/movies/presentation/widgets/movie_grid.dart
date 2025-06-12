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
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            onLoadMore != null &&
            !isLoading) {
          onLoadMore!();
        }
        return false;
      },
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: movies.length + (isLoading ? 2 : 0),
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
    );
  }
}