// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  movieId: (json['movie_id'] as num).toInt(),
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  sentimentScore: (json['sentiment_score'] as num?)?.toDouble(),
  emotionAnalysis: json['emotion_analysis'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'movie_id': instance.movieId,
  'rating': instance.rating,
  'comment': instance.comment,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'sentiment_score': instance.sentimentScore,
  'emotion_analysis': instance.emotionAnalysis,
};
