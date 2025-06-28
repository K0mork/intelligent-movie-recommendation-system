import 'package:flutter/material.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';

/// 映画のあらすじを表示するセクション
class MovieOverviewSection extends StatelessWidget {
  final Movie movie;

  const MovieOverviewSection({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    if (movie.overview.isEmpty) {
      return const SizedBox.shrink();
    }

    return _MovieOverview(movie: movie);
  }
}


/// 映画のあらすじセクション
class _MovieOverview extends StatelessWidget {
  final Movie movie;

  const _MovieOverview({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'あらすじ',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          movie.overview,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
