import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/app_user.dart';
import 'auth_providers.dart';

class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  final Ref _ref;

  AuthController(this._ref) : super(const AsyncValue.data(null));

  /// Googleサインイン
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;

    try {
      final signInUseCase = _ref.read(signInUseCaseProvider);
      final user = await signInUseCase.signInWithGoogle();
      
      state = AsyncValue.data(user);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(
        AuthException('Unexpected error during Google sign in: $e'),
        StackTrace.current,
      );
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  /// 匿名サインイン
  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;

    try {
      final signInUseCase = _ref.read(signInUseCaseProvider);
      final user = await signInUseCase.signInAnonymously();
      
      state = AsyncValue.data(user);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(
        AuthException('Unexpected error during anonymous sign in: $e'),
        StackTrace.current,
      );
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    _ref.read(authLoadingProvider.notifier).state = true;

    try {
      final signOutUseCase = _ref.read(signOutUseCaseProvider);
      await signOutUseCase.signOut();
      
      state = const AsyncValue.data(null);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(
        AuthException('Unexpected error during sign out: $e'),
        StackTrace.current,
      );
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  /// エラーをクリア
  void clearError() {
    if (state.hasError) {
      final currentUser = _ref.read(currentUserProvider);
      state = AsyncValue.data(currentUser);
    }
  }
}

// Auth Controller Provider
final authControllerProvider = 
    StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
  return AuthController(ref);
});