// AI推薦結果のエンティティクラス
class Recommendation {
  final String id;
  final String userId;
  final int movieId;
  final String movieTitle;
  final String? posterPath;
  final double confidenceScore;
  final String reason;
  final List<String> reasonCategories;
  final DateTime createdAt;
  final Map<String, dynamic>? additionalData;

  const Recommendation({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    this.posterPath,
    required this.confidenceScore,
    required this.reason,
    required this.reasonCategories,
    required this.createdAt,
    this.additionalData,
  });

  Recommendation copyWith({
    String? id,
    String? userId,
    int? movieId,
    String? movieTitle,
    String? posterPath,
    double? confidenceScore,
    String? reason,
    List<String>? reasonCategories,
    DateTime? createdAt,
    Map<String, dynamic>? additionalData,
  }) {
    return Recommendation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      posterPath: posterPath ?? this.posterPath,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      reason: reason ?? this.reason,
      reasonCategories: reasonCategories ?? this.reasonCategories,
      createdAt: createdAt ?? this.createdAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recommendation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Recommendation{id: $id, movieTitle: $movieTitle, confidenceScore: $confidenceScore}';
  }
}