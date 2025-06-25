import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/app_user_model.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthRemoteDataSource {
  AppUser? getCurrentUser();
  Stream<AppUser?> authStateChanges();
  Future<AppUser?> signInWithGoogle();
  Future<AppUser?> signInAnonymously();
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<void> updateProfile({String? displayName, String? photoURL});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn;

  @override
  AppUser? getCurrentUser() {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;
      return AppUserModel.fromFirebaseUser(firebaseUser);
    } catch (e) {
      throw AuthException('Failed to get current user: $e');
    }
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(
      (firebaseUser) =>
          firebaseUser != null
              ? AppUserModel.fromFirebaseUser(firebaseUser)
              : null,
    );
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        // Web用の処理: まず silent sign-in を試す
        googleUser = await _googleSignIn.signInSilently();
        if (googleUser == null) {
          // Silent sign-in が失敗した場合は通常のサインイン
          googleUser = await _googleSignIn.signIn();
        }
      } else {
        // モバイル用の処理
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        // ユーザーがサインインをキャンセル
        return null;
      }

      // Google認証情報を取得
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase認証クレデンシャルを作成
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Authでサインイン
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw AuthException('Firebase sign in failed');
      }

      return AppUserModel.fromFirebaseUser(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Google sign in failed: ${e.message}', code: e.code);
    } catch (e) {
      throw AuthException('Google sign in failed: $e');
    }
  }

  @override
  Future<AppUser?> signInAnonymously() async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInAnonymously();

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw AuthException('Anonymous sign in failed');
      }

      return AppUserModel.fromFirebaseUser(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        'Anonymous sign in failed: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw AuthException('Anonymous sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('No user to delete');
      }

      await user.delete();
      await _googleSignIn.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        'Account deletion failed: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw AuthException('Account deletion failed: $e');
    }
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('No user to update');
      }

      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException('Profile update failed: ${e.message}', code: e.code);
    } catch (e) {
      throw AuthException('Profile update failed: $e');
    }
  }
}
