import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';

// Firebase Auth インスタンス
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  try {
    return FirebaseAuth.instance;
  } catch (e) {
    // Firebase初期化に失敗した場合はException
    throw Exception('Firebase認証の初期化に失敗しました: $e');
  }
});

// Google Sign In インスタンス
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
    clientId: kIsWeb 
      ? '519346109803-b527n0aduaa262qv0sv57uml4f3q7ad6.apps.googleusercontent.com'
      : null, // モバイルではnullを指定（firebase_optionsから取得）
  );
});

// Auth Remote Data Source
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final firebaseAuth = ref.read(firebaseAuthProvider);
  final googleSignIn = ref.read(googleSignInProvider);
  
  return AuthRemoteDataSourceImpl(
    firebaseAuth: firebaseAuth,
    googleSignIn: googleSignIn,
  );
});

// Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

// Use Cases
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return SignInUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return SignOutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

// Auth State Provider
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
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