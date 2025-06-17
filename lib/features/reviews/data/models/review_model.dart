import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.movieId,
    required super.movieTitle,
    super.moviePosterUrl,
    required super.rating,
    super.comment,
    super.watchedDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      movieId: data['movieId'] ?? '',
      movieTitle: data['movieTitle'] ?? '',
      moviePosterUrl: data['moviePosterUrl'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'],
      watchedDate: (data['watchedDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      movieId: map['movieId'] ?? '',
      movieTitle: map['movieTitle'] ?? '',
      moviePosterUrl: map['moviePosterUrl'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      watchedDate: map['watchedDate'] is Timestamp
          ? (map['watchedDate'] as Timestamp).toDate()
          : (map['watchedDate'] != null ? DateTime.parse(map['watchedDate']) : null),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterUrl': moviePosterUrl,
      'rating': rating,
      'comment': comment,
      'watchedDate': watchedDate != null ? Timestamp.fromDate(watchedDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  ReviewModel copyWith({
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
    return ReviewModel(
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

  /// Convert ReviewModel to Review entity
  Review toEntity() {
    return Review(
      id: id,
      userId: userId,
      movieId: movieId,
      movieTitle: movieTitle,
      moviePosterUrl: moviePosterUrl,
      rating: rating,
      comment: comment,
      watchedDate: watchedDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}