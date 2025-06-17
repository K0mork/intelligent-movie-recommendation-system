import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recommendation_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final recommendationControllerProvider = Provider<RecommendationController>((ref) {
  return RecommendationController(ref);
});

class RecommendationController {
  final Ref ref;

  RecommendationController(this.ref);

  // 推薦結果を読み込み
  Future<void> loadRecommendations() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final notifier = ref.read(recommendationsProvider.notifier);
    await notifier.loadRecommendations(user.uid);
  }

  // 新しい推薦を生成
  Future<void> generateRecommendations() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    ref.read(recommendationLoadingProvider.notifier).state = true;
    try {
      final notifier = ref.read(recommendationsProvider.notifier);
      await notifier.generateNewRecommendations(user.uid);
    } finally {
      ref.read(recommendationLoadingProvider.notifier).state = false;
    }
  }

  // 保存済み推薦結果を読み込み
  Future<void> loadSavedRecommendations() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final notifier = ref.read(savedRecommendationsProvider.notifier);
    await notifier.loadSavedRecommendations(user.uid);
  }

  // 推薦結果を保存
  Future<void> saveRecommendation(String recommendationId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final notifier = ref.read(savedRecommendationsProvider.notifier);
    await notifier.saveRecommendation(user.uid, recommendationId);
  }

  // 保存済み推薦結果を削除
  Future<void> deleteSavedRecommendation(String recommendationId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final notifier = ref.read(savedRecommendationsProvider.notifier);
    await notifier.deleteRecommendation(user.uid, recommendationId);
  }

  // フィードバックを送信
  Future<void> submitFeedback(
    String recommendationId,
    bool isHelpful,
    String? feedback,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final submitFeedbackUseCase = ref.read(submitFeedbackUseCaseProvider);
    await submitFeedbackUseCase(user.uid, recommendationId, isHelpful, feedback);
  }

  // 推薦結果をクリア
  void clearRecommendations() {
    final notifier = ref.read(recommendationsProvider.notifier);
    notifier.clearRecommendations();
  }
}