import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/recommendation_model.dart';

abstract class RecommendationRemoteDataSource {
  Future<List<RecommendationModel>> getRecommendations(String userId);
  Future<List<RecommendationModel>> generateRecommendations(String userId);
  Future<void> saveRecommendation(String userId, String recommendationId);
  Future<List<RecommendationModel>> getSavedRecommendations(String userId);
  Future<void> deleteRecommendation(String userId, String recommendationId);
  Future<void> submitFeedback(
    String userId,
    String recommendationId,
    bool isHelpful,
    String? feedback,
  );
}

class RecommendationRemoteDataSourceImpl implements RecommendationRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  RecommendationRemoteDataSourceImpl({
    required this.firestore,
    required this.functions,
  });

  @override
  Future<List<RecommendationModel>> getRecommendations(String userId) async {
    try {
      final snapshot = await firestore
          .collection('recommendations')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return RecommendationModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      throw Exception('推薦結果の取得に失敗しました: $e');
    }
  }

  @override
  Future<List<RecommendationModel>> generateRecommendations(String userId) async {
    try {
      final callable = functions.httpsCallable('generateRecommendations');
      final result = await callable.call({'userId': userId});

      final data = result.data;
      if (data == null || data['recommendations'] == null) {
        return [];
      }

      final recommendationsList = data['recommendations'] as List<dynamic>;
      final recommendations = recommendationsList.map((item) {
        return RecommendationModel.fromCloudFunction(
          item as Map<String, dynamic>,
          userId,
        );
      }).toList();

      // 生成された推薦結果をFirestoreに保存
      final batch = firestore.batch();
      for (final recommendation in recommendations) {
        final docRef = firestore.collection('recommendations').doc();
        final recommendationWithId = RecommendationModel(
          id: docRef.id,
          userId: recommendation.userId,
          movieId: recommendation.movieId,
          movieTitle: recommendation.movieTitle,
          posterPath: recommendation.posterPath,
          confidenceScore: recommendation.confidenceScore,
          reason: recommendation.reason,
          reasonCategories: recommendation.reasonCategories,
          createdAt: recommendation.createdAt,
          additionalData: recommendation.additionalData,
        );
        batch.set(docRef, recommendationWithId.toFirestore());
      }
      await batch.commit();

      return recommendations;
    } catch (e) {
      throw Exception('推薦結果の生成に失敗しました: $e');
    }
  }

  @override
  Future<void> saveRecommendation(String userId, String recommendationId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('savedRecommendations')
          .doc(recommendationId)
          .set({
        'recommendationId': recommendationId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('推薦結果の保存に失敗しました: $e');
    }
  }

  @override
  Future<List<RecommendationModel>> getSavedRecommendations(String userId) async {
    try {
      final savedSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('savedRecommendations')
          .orderBy('savedAt', descending: true)
          .get();

      final recommendationIds = savedSnapshot.docs
          .map((doc) => doc.data()['recommendationId'] as String)
          .toList();

      if (recommendationIds.isEmpty) {
        return [];
      }

      final recommendationsSnapshot = await firestore
          .collection('recommendations')
          .where(FieldPath.documentId, whereIn: recommendationIds)
          .get();

      return recommendationsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return RecommendationModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      throw Exception('保存済み推薦結果の取得に失敗しました: $e');
    }
  }

  @override
  Future<void> deleteRecommendation(String userId, String recommendationId) async {
    try {
      // 保存済みリストから削除
      await firestore
          .collection('users')
          .doc(userId)
          .collection('savedRecommendations')
          .doc(recommendationId)
          .delete();
    } catch (e) {
      throw Exception('推薦結果の削除に失敗しました: $e');
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
      await firestore
          .collection('recommendationFeedback')
          .add({
        'userId': userId,
        'recommendationId': recommendationId,
        'isHelpful': isHelpful,
        'feedback': feedback,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // 推薦結果にフィードバック情報を更新
      await firestore
          .collection('recommendations')
          .doc(recommendationId)
          .update({
        'feedbackCount': FieldValue.increment(1),
        'helpfulCount': isHelpful ? FieldValue.increment(1) : FieldValue.increment(0),
      });
    } catch (e) {
      throw Exception('フィードバックの送信に失敗しました: $e');
    }
  }
}