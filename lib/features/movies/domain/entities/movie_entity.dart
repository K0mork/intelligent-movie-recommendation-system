/// 映画のドメインエンティティ
/// ビジネスロジックで使用される映画の基本情報を表現
class MovieEntity {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;
  final bool adult;
  final String originalLanguage;
  final String originalTitle;
  final double popularity;
  final bool video;
  
  // ジャンル名のリスト（UI表示用）
  final List<String>? genres;

  const MovieEntity({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    required this.adult,
    required this.originalLanguage,
    required this.originalTitle,
    required this.popularity,
    required this.video,
    this.genres,
  });

  /// 完全なポスター画像URLを取得
  String? getFullPosterUrl(String baseUrl) {
    if (posterPath == null) return null;
    return '$baseUrl$posterPath';
  }

  /// 完全な背景画像URLを取得
  String? getFullBackdropUrl(String baseUrl) {
    if (backdropPath == null) return null;
    return '$baseUrl$backdropPath';
  }

  /// 評価のパーセンテージを取得（0-100）
  double get votePercentage => (voteAverage * 10).clamp(0, 100);

  /// リリース年を取得
  int? get releaseYear {
    if (releaseDate == null) return null;
    try {
      return DateTime.parse(releaseDate!).year;
    } catch (e) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MovieEntity(id: $id, title: $title)';
}