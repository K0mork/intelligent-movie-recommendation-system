import '../entities/recommendation.dart';

abstract class RecommendationRepository {
  /// ユーザー向けの推薦結果を取得
  Future<List<Recommendation>> getRecommendations(String userId);

  /// 新しい推薦結果を生成（Cloud Functionを呼び出し）
  Future<List<Recommendation>> generateRecommendations(String userId);

  /// 推薦結果をお気に入りに保存
  Future<void> saveRecommendation(String userId, String recommendationId);

  /// 保存済み推薦結果を取得
  Future<List<Recommendation>> getSavedRecommendations(String userId);

  /// 推薦結果を削除
  Future<void> deleteRecommendation(String userId, String recommendationId);

  /// 推薦結果にフィードバックを送信
  Future<void> submitFeedback(
    String userId,
    String recommendationId,
    bool isHelpful,
    String? feedback,
  );
}