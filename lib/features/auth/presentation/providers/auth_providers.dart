import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';

// Firebase Auth インスタンス
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Google Sign In インスタンス
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    scopes: ['email', 'profile'],
  );
});

// Auth Remote Data Source
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final googleSignIn = ref.watch(googleSignInProvider);
  
  return AuthRemoteDataSourceImpl(
    firebaseAuth: firebaseAuth,
    googleSignIn: googleSignIn,
  );
});

// Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

// Use Cases
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

// Auth State Provider
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  return getCurrentUserUseCase.watchAuthState();
});

// Current User Provider (現在のユーザー情報)
final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((user) => user).value;
});

// Authentication Status Provider (認証済みかどうか)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Loading State Provider (サインイン処理中)
final authLoadingProvider = StateProvider<bool>((ref) => false);