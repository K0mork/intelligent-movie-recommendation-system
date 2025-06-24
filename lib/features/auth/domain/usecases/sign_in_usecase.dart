import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  /// Googleアカウントでサインイン
  Future<AppUser?> signInWithGoogle() async {
    try {
      final user = await _authRepository.signInWithGoogle();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// 匿名ユーザーとしてサインイン
  Future<AppUser?> signInAnonymously() async {
    try {
      final user = await _authRepository.signInAnonymously();
      return user;
    } catch (e) {
      rethrow;
    }
  }
}

class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  /// サインアウト
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      rethrow;
    }
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  /// 現在のユーザーを取得
  AppUser? getCurrentUser() {
    return _authRepository.getCurrentUser();
  }

  /// 認証状態の変更を監視
  Stream<AppUser?> watchAuthState() {
    return _authRepository.authStateChanges();
  }
}
