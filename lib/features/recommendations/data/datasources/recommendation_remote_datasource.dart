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
      // インデックス作成中のため、まずuserIdでフィルタリングのみ実行
      final snapshot = await firestore
          .collection('recommendations')
          .where('userId', isEqualTo: userId)
          .limit(20)
          .get();

      // クライアント側でソート（インデックス作成完了まで）
      final recommendations = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return RecommendationModel.fromFirestore(data);
      }).toList();

      // 作成日時でソート
      recommendations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return recommendations;
    } catch (e) {
      throw Exception('推薦結果の取得に失敗しました: $e');
    }
  }

  @override
  Future<List<RecommendationModel>> generateRecommendations(String userId) async {
    // 開発中のため、一時的にサンプル推薦を生成
    // （Cloud Functionsのデプロイには有料プランが必要）
    print('サンプル推薦を生成中...');
    
    // サンプル推薦を生成
    final sampleRecommendations = _generateSampleRecommendations(userId);
    
    // Firestoreに保存（将来的な取得のため）
    try {
      final batch = firestore.batch();
      for (final recommendation in sampleRecommendations) {
        final docRef = firestore.collection('recommendations').doc(recommendation.id);
        batch.set(docRef, recommendation.toFirestore());
      }
      await batch.commit();
    } catch (e) {
      print('Firestore保存エラー（一時的な推薦は正常に生成されました）: $e');
    }
    
    return sampleRecommendations;
  }

  // 一時的なサンプル推薦を生成（開発・テスト用）
  List<RecommendationModel> _generateSampleRecommendations(String userId) {
    final now = DateTime.now();
    return [
      RecommendationModel(
        id: 'sample_1',
        userId: userId,
        movieId: 550,
        movieTitle: 'ファイト・クラブ',
        posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
        confidenceScore: 0.95,
        reason: 'あなたの好みに基づいて推薦します。心理的なスリラーとダークなテーマがお好みのようです。',
        reasonCategories: ['心理スリラー', 'ダークテーマ', 'クラシック映画'],
        createdAt: now,
        additionalData: {'isSample': true},
      ),
      RecommendationModel(
        id: 'sample_2',
        userId: userId,
        movieId: 13,
        movieTitle: 'フォレスト・ガンプ/一期一会',
        posterPath: '/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg',
        confidenceScore: 0.88,
        reason: '感動的なストーリーと優れた演技で高く評価されている作品です。',
        reasonCategories: ['ドラマ', '感動作品', 'トム・ハンクス'],
        createdAt: now.subtract(const Duration(minutes: 1)),
        additionalData: {'isSample': true},
      ),
      RecommendationModel(
        id: 'sample_3',
        userId: userId,
        movieId: 155,
        movieTitle: 'ダークナイト',
        posterPath: '/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
        confidenceScore: 0.92,
        reason: 'スーパーヒーロー映画の傑作で、深いキャラクター描写が特徴です。',
        reasonCategories: ['アクション', 'スーパーヒーロー', 'クリストファー・ノーラン'],
        createdAt: now.subtract(const Duration(minutes: 2)),
        additionalData: {'isSample': true},
      ),
    ];
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