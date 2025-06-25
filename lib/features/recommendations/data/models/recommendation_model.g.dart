// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationModel _$RecommendationModelFromJson(Map<String, dynamic> json) =>
    RecommendationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      movieId: (json['movieId'] as num).toInt(),
      movieTitle: json['movieTitle'] as String,
      posterPath: json['posterPath'] as String?,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      reason: json['reason'] as String,
      reasonCategories: (json['reasonCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RecommendationModelToJson(
        RecommendationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'movieId': instance.movieId,
      'movieTitle': instance.movieTitle,
      'posterPath': instance.posterPath,
      'confidenceScore': instance.confidenceScore,
      'reason': instance.reason,
      'reasonCategories': instance.reasonCategories,
      'createdAt': instance.createdAt.toIso8601String(),
      'additionalData': instance.additionalData,
    };
