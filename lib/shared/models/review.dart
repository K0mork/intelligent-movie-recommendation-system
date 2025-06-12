import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'movie_id')
  final int movieId;
  final double rating;
  final String comment;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'sentiment_score')
  final double? sentimentScore;
  @JsonKey(name: 'emotion_analysis')
  final Map<String, dynamic>? emotionAnalysis;

  const Review({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.sentimentScore,
    this.emotionAnalysis,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  Review copyWith({
    String? id,
    String? userId,
    int? movieId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? sentimentScore,
    Map<String, dynamic>? emotionAnalysis,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      emotionAnalysis: emotionAnalysis ?? this.emotionAnalysis,
    );
  }
}