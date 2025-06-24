import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/recommendation_remote_datasource.dart';
import '../../data/repositories/recommendation_repository_impl.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../../domain/usecases/get_recommendations_usecase.dart';

// Firebase Instances
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final functionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instance;
});

// Data Source
final recommendationRemoteDataSourceProvider = Provider<RecommendationRemoteDataSource>((ref) {
  final firestore = ref.read(firestoreProvider);
  final functions = ref.read(functionsProvider);

  return RecommendationRemoteDataSourceImpl(
    firestore: firestore,
    functions: functions,
  );
});

// Repository
final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  final remoteDataSource = ref.read(recommendationRemoteDataSourceProvider);

  return RecommendationRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

// Use Cases
final getRecommendationsUseCaseProvider = Provider<GetRecommendationsUseCase>((ref) {
  final repository = ref.read(recommendationRepositoryProvider);
  return GetRecommendationsUseCase(repository);
});

final generateRecommendationsUseCaseProvider = Provider<GenerateRecommendationsUseCase>((ref) {
  final repository = ref.read(recommendationRepositoryProvider);
  return GenerateRecommendationsUseCase(repository);
});

final saveRecommendationUseCaseProvider = Provider<SaveRecommendationUseCase>((ref) {
  final repository = ref.read(recommendationRepositoryProvider);
  return SaveRecommendationUseCase(repository);
});

final getSavedRecommendationsUseCaseProvider = Provider<GetSavedRecommendationsUseCase>((ref) {
  final repository = ref.read(recommendationRepositoryProvider);
  return GetSavedRecommendationsUseCase(repository);
});

final deleteRecommendationUseCaseProvider = Provider<DeleteRecommendationUseCase>((ref) {
  final repository = ref.read(recommendationRepositoryProvider);
  return DeleteRecommendationUseCase(repository);
});

final submitFeedbackUseCaseProvider = Provider<SubmitFeedbackUseCase>((ref) {
  final repository = ref.read(recommendationRepositoryProvider);
  return SubmitFeedbackUseCase(repository);
});

// State Providers
final recommendationsProvider = StateNotifierProvider<RecommendationsNotifier, AsyncValue<List<Recommendation>>>((ref) {
  final getRecommendationsUseCase = ref.read(getRecommendationsUseCaseProvider);
  final generateRecommendationsUseCase = ref.read(generateRecommendationsUseCaseProvider);

  return RecommendationsNotifier(
    getRecommendationsUseCase: getRecommendationsUseCase,
    generateRecommendationsUseCase: generateRecommendationsUseCase,
  );
});

final savedRecommendationsProvider = StateNotifierProvider<SavedRecommendationsNotifier, AsyncValue<List<Recommendation>>>((ref) {
  final getSavedRecommendationsUseCase = ref.read(getSavedRecommendationsUseCaseProvider);
  final saveRecommendationUseCase = ref.read(saveRecommendationUseCaseProvider);
  final deleteRecommendationUseCase = ref.read(deleteRecommendationUseCaseProvider);

  return SavedRecommendationsNotifier(
    getSavedRecommendationsUseCase: getSavedRecommendationsUseCase,
    saveRecommendationUseCase: saveRecommendationUseCase,
    deleteRecommendationUseCase: deleteRecommendationUseCase,
  );
});

final recommendationLoadingProvider = StateProvider<bool>((ref) => false);

// State Notifiers
class RecommendationsNotifier extends StateNotifier<AsyncValue<List<Recommendation>>> {
  final GetRecommendationsUseCase getRecommendationsUseCase;
  final GenerateRecommendationsUseCase generateRecommendationsUseCase;

  RecommendationsNotifier({
    required this.getRecommendationsUseCase,
    required this.generateRecommendationsUseCase,
  }) : super(const AsyncValue.loading());

  Future<void> loadRecommendations(String userId) async {
    state = const AsyncValue.loading();
    try {
      final recommendations = await getRecommendationsUseCase(userId);
      state = AsyncValue.data(recommendations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> generateNewRecommendations(String userId) async {
    state = const AsyncValue.loading();
    try {
      final recommendations = await generateRecommendationsUseCase(userId);
      state = AsyncValue.data(recommendations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearRecommendations() {
    state = const AsyncValue.data([]);
  }
}

class SavedRecommendationsNotifier extends StateNotifier<AsyncValue<List<Recommendation>>> {
  final GetSavedRecommendationsUseCase getSavedRecommendationsUseCase;
  final SaveRecommendationUseCase saveRecommendationUseCase;
  final DeleteRecommendationUseCase deleteRecommendationUseCase;

  SavedRecommendationsNotifier({
    required this.getSavedRecommendationsUseCase,
    required this.saveRecommendationUseCase,
    required this.deleteRecommendationUseCase,
  }) : super(const AsyncValue.loading());

  Future<void> loadSavedRecommendations(String userId) async {
    state = const AsyncValue.loading();
    try {
      final recommendations = await getSavedRecommendationsUseCase(userId);
      state = AsyncValue.data(recommendations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> saveRecommendation(String userId, String recommendationId) async {
    try {
      await saveRecommendationUseCase(userId, recommendationId);
      // 保存済みリストを再読み込み
      await loadSavedRecommendations(userId);
    } catch (error) {
      // エラーハンドリング
      rethrow;
    }
  }

  Future<void> deleteRecommendation(String userId, String recommendationId) async {
    try {
      await deleteRecommendationUseCase(userId, recommendationId);
      // 保存済みリストを再読み込み
      await loadSavedRecommendations(userId);
    } catch (error) {
      // エラーハンドリング
      rethrow;
    }
  }
}
