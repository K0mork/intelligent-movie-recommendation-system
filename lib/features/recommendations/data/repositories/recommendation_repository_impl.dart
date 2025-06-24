import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_remote_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationRemoteDataSource remoteDataSource;

  RecommendationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<Recommendation>> getRecommendations(String userId) async {
    try {
      final recommendationModels = await remoteDataSource.getRecommendations(userId);
      return recommendationModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Recommendation>> generateRecommendations(String userId) async {
    try {
      final recommendationModels = await remoteDataSource.generateRecommendations(userId);
      return recommendationModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveRecommendation(String userId, String recommendationId) async {
    try {
      await remoteDataSource.saveRecommendation(userId, recommendationId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Recommendation>> getSavedRecommendations(String userId) async {
    try {
      final recommendationModels = await remoteDataSource.getSavedRecommendations(userId);
      return recommendationModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteRecommendation(String userId, String recommendationId) async {
    try {
      await remoteDataSource.deleteRecommendation(userId, recommendationId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> submitFeedback(
    String userId,
    String recommendationId,
    bool isHelpful,
    String? feedback,
  ) async {
    try {
      await remoteDataSource.submitFeedback(userId, recommendationId, isHelpful, feedback);
    } catch (e) {
      rethrow;
    }
  }
}
