import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';

// Firebase Auth インスタンス
final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  try {
    return FirebaseAuth.instance;
  } catch (e) {
    // Firebase初期化に失敗した場合はnullを返す
    return null;
  }
});

// Google Sign In インスタンス
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    scopes: ['email', 'profile'],
  );
});

// Auth Remote Data Source
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource?>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final googleSignIn = ref.watch(googleSignInProvider);
  
  // Firebase Authが利用できない場合はnullを返す
  if (firebaseAuth == null) {
    return null;
  }
  
  return AuthRemoteDataSourceImpl(
    firebaseAuth: firebaseAuth,
    googleSignIn: googleSignIn,
  );
});

// Auth Repository
final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  
  // Data Sourceが利用できない場合はnullを返す
  if (remoteDataSource == null) {
    return null;
  }
  
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

// Use Cases
final signInUseCaseProvider = Provider<SignInUseCase?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  if (repository == null) return null;
  return SignInUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  if (repository == null) return null;
  return SignOutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  if (repository == null) return null;
  return GetCurrentUserUseCase(repository);
});

// Auth State Provider
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  
  // Firebase Authが利用できない場合はnullを返すStreamを提供
  if (firebaseAuth == null) {
    return Stream.value(null);
  }
  
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  if (getCurrentUserUseCase == null) {
    return Stream.value(null);
  }
  
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