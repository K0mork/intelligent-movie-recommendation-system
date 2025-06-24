import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/review.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/repositories/review_repository.dart';
import 'review_controller.dart';

// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Data source provider
final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>((ref) {
  final firestore = ref.read(firestoreProvider);
  return ReviewRemoteDataSourceImpl(firestore: firestore);
});

// Repository provider
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final remoteDataSource = ref.read(reviewRemoteDataSourceProvider);
  return ReviewRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Controller provider
final reviewControllerProvider = StateNotifierProvider<ReviewController, ReviewState>((ref) {
  final repository = ref.read(reviewRepositoryProvider);
  return ReviewController(repository: repository);
});

// Get reviews by movie ID
final movieReviewsProvider = FutureProvider.family<List<Review>, String>((ref, movieId) async {
  final repository = ref.read(reviewRepositoryProvider);
  return await repository.getReviews(movieId: movieId);
});

// Get user reviews
final userReviewsProvider = FutureProvider.family<List<Review>, String>((ref, userId) async {
  final repository = ref.read(reviewRepositoryProvider);
  return await repository.getUserReviews(userId);
});
