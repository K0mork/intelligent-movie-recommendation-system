import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 映画ポスター表示の共通ウィジェット
///
/// プロジェクト内で重複していた映画ポスター表示ロジックを統一し、
/// 一貫したUI/UXとメンテナンスを容易にする。
class MoviePosterWidget extends StatelessWidget {
  final String? posterPath;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final VoidCallback? onTap;
  final Widget? overlay;
  final bool showPlaceholder;
  final IconData placeholderIcon;

  const MoviePosterWidget({
    super.key,
    required this.posterPath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.onTap,
    this.overlay,
    this.showPlaceholder = true,
    this.placeholderIcon = Icons.movie,
  });

  /// 小サイズ用プリセット (サムネイル)
  const MoviePosterWidget.small({
    super.key,
    required this.posterPath,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.onTap,
    this.overlay,
    this.showPlaceholder = true,
    this.placeholderIcon = Icons.movie,
  }) : width = 46,
       height = 69;

  /// 中サイズ用プリセット (リスト表示)
  const MoviePosterWidget.medium({
    super.key,
    required this.posterPath,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.onTap,
    this.overlay,
    this.showPlaceholder = true,
    this.placeholderIcon = Icons.movie,
  }) : width = 80,
       height = 120;

  /// 大サイズ用プリセット (詳細画面)
  const MoviePosterWidget.large({
    super.key,
    required this.posterPath,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.onTap,
    this.overlay,
    this.showPlaceholder = true,
    this.placeholderIcon = Icons.movie,
  }) : width = 200,
       height = 300;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(8.0);

    Widget posterWidget;

    if (posterPath != null && posterPath!.isNotEmpty) {
      // TMDb APIのベースURL
      final imageUrl =
          posterPath!.startsWith('http')
              ? posterPath!
              : 'https://image.tmdb.org/t/p/w500$posterPath';

      posterWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildLoadingPlaceholder(theme),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(theme),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
      );
    } else {
      posterWidget = _buildErrorPlaceholder(theme);
    }

    // ボーダーラディウス適用
    posterWidget = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: posterWidget,
    );

    // オーバーレイ適用
    if (overlay != null) {
      posterWidget = Stack(
        children: [posterWidget, Positioned.fill(child: overlay!)],
      );
    }

    // Hero animation適用
    if (heroTag != null) {
      posterWidget = Hero(tag: heroTag!, child: posterWidget);
    }

    // タップ処理
    if (onTap != null) {
      posterWidget = GestureDetector(onTap: onTap, child: posterWidget);
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: posterWidget,
    );
  }

  Widget _buildLoadingPlaceholder(ThemeData theme) {
    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceVariant,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder:
              (context, value, child) => Transform.scale(
                scale: value,
                child: const CircularProgressIndicator(),
              ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(ThemeData theme) {
    if (!showPlaceholder) {
      return SizedBox(width: width, height: height);
    }

    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            placeholderIcon,
            size: width * 0.3,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 映画ポスターグリッド表示用のウィジェット
class MoviePosterGrid extends StatelessWidget {
  final List<String?> posterPaths;
  final int crossAxisCount;
  final double aspectRatio;
  final double spacing;
  final EdgeInsets? padding;
  final Function(int index)? onTap;

  const MoviePosterGrid({
    super.key,
    required this.posterPaths,
    this.crossAxisCount = 3,
    this.aspectRatio = 2 / 3,
    this.spacing = 8.0,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: posterPaths.length,
        itemBuilder: (context, index) {
          return MoviePosterWidget(
            posterPath: posterPaths[index],
            width: double.infinity,
            height: double.infinity,
            heroTag: 'movie_poster_$index',
            onTap: onTap != null ? () => onTap!(index) : null,
          );
        },
      ),
    );
  }
}
