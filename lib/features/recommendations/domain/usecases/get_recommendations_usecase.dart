import '../entities/recommendation.dart';
import '../repositories/recommendation_repository.dart';

class GetRecommendationsUseCase {
  final RecommendationRepository repository;

  GetRecommendationsUseCase(this.repository);

  Future<List<Recommendation>> call(String userId) async {
    return await repository.getRecommendations(userId);
  }
}

class GenerateRecommendationsUseCase {
  final RecommendationRepository repository;

  GenerateRecommendationsUseCase(this.repository);

  Future<List<Recommendation>> call(String userId) async {
    return await repository.generateRecommendations(userId);
  }
}

class SaveRecommendationUseCase {
  final RecommendationRepository repository;

  SaveRecommendationUseCase(this.repository);

  Future<void> call(String userId, String recommendationId) async {
    return await repository.saveRecommendation(userId, recommendationId);
  }
}

class GetSavedRecommendationsUseCase {
  final RecommendationRepository repository;

  GetSavedRecommendationsUseCase(this.repository);

  Future<List<Recommendation>> call(String userId) async {
    return await repository.getSavedRecommendations(userId);
  }
}

class DeleteRecommendationUseCase {
  final RecommendationRepository repository;

  DeleteRecommendationUseCase(this.repository);

  Future<void> call(String userId, String recommendationId) async {
    return await repository.deleteRecommendation(userId, recommendationId);
  }
}

class SubmitFeedbackUseCase {
  final RecommendationRepository repository;

  SubmitFeedbackUseCase(this.repository);

  Future<void> call(
    String userId,
    String recommendationId,
    bool isHelpful,
    String? feedback,
  ) async {
    return await repository.submitFeedback(
      userId,
      recommendationId,
      isHelpful,
      feedback,
    );
  }
}
