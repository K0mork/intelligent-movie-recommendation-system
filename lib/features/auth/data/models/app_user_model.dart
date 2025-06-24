import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoURL,
    required super.createdAt,
    required super.lastSignInAt,
    required super.isEmailVerified,
  });

  /// Firebase User から AppUserModel に変換
  factory AppUserModel.fromFirebaseUser(User firebaseUser) {
    return AppUserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastSignInAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
      isEmailVerified: firebaseUser.emailVerified,
    );
  }

  /// JSON から AppUserModel に変換
  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSignInAt: DateTime.parse(json['lastSignInAt'] as String),
      isEmailVerified: json['isEmailVerified'] as bool,
    );
  }

  /// AppUserModel を JSON に変換
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'lastSignInAt': lastSignInAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
    };
  }

  /// Firestore用のデータに変換
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'lastSignInAt': lastSignInAt,
      'isEmailVerified': isEmailVerified,
      'updatedAt': DateTime.now(),
    };
  }

  /// Firebase User のメタデータとの互換性のため
  UserMetadata get metadata => UserMetadata(
    creationTime: createdAt,
    lastSignInTime: lastSignInAt,
  );
}

/// Firebase User metadata との互換性を保つためのクラス
class UserMetadata {
  final DateTime creationTime;
  final DateTime lastSignInTime;

  const UserMetadata({
    required this.creationTime,
    required this.lastSignInTime,
  });
}
