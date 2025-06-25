import '../entities/app_user.dart';

abstract class AuthRepository {
  /// 現在のユーザーを取得
  AppUser? getCurrentUser();

  /// 認証状態の変更を監視
  Stream<AppUser?> authStateChanges();

  /// Googleサインイン
  Future<AppUser?> signInWithGoogle();

  /// 匿名サインイン
  Future<AppUser?> signInAnonymously();

  /// サインアウト
  Future<void> signOut();

  /// アカウント削除
  Future<void> deleteAccount();

  /// ユーザープロファイル更新
  Future<void> updateProfile({String? displayName, String? photoURL});
}
