import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/recommendation.dart';

part 'recommendation_model.g.dart';

@JsonSerializable()
class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.id,
    required super.userId,
    required super.movieId,
    required super.movieTitle,
    super.posterPath,
    required super.confidenceScore,
    required super.reason,
    required super.reasonCategories,
    required super.createdAt,
    super.additionalData,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendationModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationModelToJson(this);

  // Firestoreから取得したデータを変換
  factory RecommendationModel.fromFirestore(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      movieId: json['movieId'] ?? 0,
      movieTitle: json['movieTitle'] ?? '',
      posterPath: json['posterPath'],
      confidenceScore: double.tryParse(json['confidenceScore']?.toString() ?? '0.0') ?? 0.0,
      reason: json['reason'] ?? '',
      reasonCategories: (json['reasonCategories'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  // Firestoreに保存するためのMap変換
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'posterPath': posterPath,
      'confidenceScore': confidenceScore,
      'reason': reason,
      'reasonCategories': reasonCategories,
      'createdAt': createdAt.toIso8601String(),
      'additionalData': additionalData,
    };
  }

  // Cloud Functionからの推薦結果を変換
  factory RecommendationModel.fromCloudFunction(
    Map<String, dynamic> json,
    String userId,
  ) {
    return RecommendationModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      movieId: json['movieId'] ?? 0,
      movieTitle: json['movieTitle'] ?? '',
      posterPath: json['posterPath'],
      confidenceScore: double.tryParse(json['confidenceScore']?.toString() ?? '0.0') ?? 0.0,
      reason: json['reason'] ?? '',
      reasonCategories: (json['reasonCategories'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Recommendation toEntity() {
    return Recommendation(
      id: id,
      userId: userId,
      movieId: movieId,
      movieTitle: movieTitle,
      posterPath: posterPath,
      confidenceScore: confidenceScore,
      reason: reason,
      reasonCategories: reasonCategories,
      createdAt: createdAt,
      additionalData: additionalData,
    );
  }

  String get fullPosterUrl {
    if (posterPath == null) return '';

    if (posterPath!.startsWith('http')) {
      return posterPath!;
    }

    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
}
