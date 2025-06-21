import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmflow/features/movies/data/models/movie.dart';

/// 映画詳細ヘッダーウィジェット
/// 
/// 映画のポスター、タイトル、基本情報を表示。
/// movie_detail_page.dartから分離。
class MovieDetailHeader extends StatelessWidget {
  final Movie movie;
  final bool showReviewButton;
  final VoidCallback? onReviewPressed;

  const MovieDetailHeader({
    super.key,
    required this.movie,
    this.showReviewButton = false,
    this.onReviewPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 400,
      decoration: _buildBackgroundDecoration(),
      child: Stack(
        children: [
          // 背景画像（グラデーション付き）
          _buildBackgroundImage(),
          
          // グラデーションオーバーレイ
          _buildGradientOverlay(),
          
          // メインコンテンツ
          _buildMainContent(context, theme),
        ],
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      color: Colors.grey[900],
      image: movie.backdropPath != null
          ? DecorationImage(
              image: CachedNetworkImageProvider(
                movie.fullBackdropUrl,
              ),
              fit: BoxFit.cover,
              opacity: 0.3,
            )
          : null,
    );
  }

  Widget _buildBackgroundImage() {
    if (movie.backdropPath == null) {
      return const SizedBox.expand();
    }
    
    return SizedBox.expand(
      child: CachedNetworkImage(
        imageUrl: movie.fullBackdropUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[900],
          child: const Icon(
            Icons.error_outline,
            color: Colors.white54,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black87,
          ],
          stops: [0.0, 1.0],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ナビゲーションバー
            _buildNavigationBar(context),
            
            const Spacer(),
            
            // 映画情報
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ポスター
                _buildPosterImage(),
                
                const SizedBox(width: 16),
                
                // 映画詳細
                Expanded(
                  child: _buildMovieInfo(theme),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        if (showReviewButton && onReviewPressed != null)
          IconButton(
            icon: const Icon(Icons.rate_review, color: Colors.white),
            onPressed: onReviewPressed,
            tooltip: 'レビューを書く',
          ),
      ],
    );
  }

  Widget _buildPosterImage() {
    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: movie.posterPath != null
            ? CachedNetworkImage(
                imageUrl: movie.fullPosterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.movie,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              )
            : Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.movie,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
      ),
    );
  }

  Widget _buildMovieInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // タイトル
        Text(
          movie.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 8),
        
        // 公開年
        if (movie.releaseDate != null) ...[
          Text(
            _getReleaseYear(movie.releaseDate!),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // 評価
        if (movie.voteAverage > 0) ...[
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' / 10',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  String _getReleaseYear(String releaseDate) {
    try {
      return DateTime.parse(releaseDate).year.toString();
    } catch (e) {
      return '';
    }
  }
}

/// 映画の基本情報を表示するシンプルなカード
class MovieInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;

  const MovieInfoCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}