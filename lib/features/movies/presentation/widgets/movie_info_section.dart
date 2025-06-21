import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';

/// 映画の基本情報を表示するセクション
/// ポスター、タイトル、公開日、評価、あらすじを含む
class MovieInfoSection extends StatelessWidget {
  final Movie movie;

  const MovieInfoSection({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ポスターと基本情報
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ポスター画像
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: movie.fullPosterUrl,
                width: 120,
                height: 180,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 120,
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 120,
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.movie,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 映画情報
            Expanded(
              child: _MovieBasicInfo(movie: movie),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // あらすじ
        if (movie.overview.isNotEmpty) _MovieOverview(movie: movie),
      ],
    );
  }
}

/// 映画の基本情報（タイトル、公開日、評価）
class _MovieBasicInfo extends StatelessWidget {
  final Movie movie;

  const _MovieBasicInfo({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // タイトル
        Text(
          movie.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        // 原題（タイトルと異なる場合のみ表示）
        if (movie.originalTitle != movie.title) ...[
          const SizedBox(height: 4),
          Text(
            movie.originalTitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
        const SizedBox(height: 8),
        // 公開日
        if (movie.releaseDate != null && movie.releaseDate!.isNotEmpty)
          _InfoRow(
            icon: Icons.calendar_today,
            text: movie.releaseDate!,
          ),
        const SizedBox(height: 8),
        // 評価
        _RatingInfo(movie: movie),
      ],
    );
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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

/// 映画の評価情報
class _RatingInfo extends StatelessWidget {
  final Movie movie;

  const _RatingInfo({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          movie.voteAverage.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          ' (${movie.voteCount} votes)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

/// 汎用的な情報行（アイコン + テキスト）
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}