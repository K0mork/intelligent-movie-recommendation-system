class Review {
  final String id;
  final String userId;
  final String movieId;
  final String movieTitle;
  final String? moviePosterUrl;
  final double rating;
  final String? comment;
  final DateTime? watchedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Review({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterUrl,
    required this.rating,
    this.comment,
    this.watchedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Review copyWith({
    String? id,
    String? userId,
    String? movieId,
    String? movieTitle,
    String? moviePosterUrl,
    double? rating,
    String? comment,
    DateTime? watchedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterUrl: moviePosterUrl ?? this.moviePosterUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      watchedDate: watchedDate ?? this.watchedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review &&
        other.id == id &&
        other.userId == userId &&
        other.movieId == movieId &&
        other.movieTitle == movieTitle &&
        other.moviePosterUrl == moviePosterUrl &&
        other.rating == rating &&
        other.comment == comment &&
        other.watchedDate == watchedDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      movieId,
      movieTitle,
      moviePosterUrl,
      rating,
      comment,
      watchedDate,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Review(id: $id, userId: $userId, movieId: $movieId, movieTitle: $movieTitle, rating: $rating, comment: $comment, watchedDate: $watchedDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
