import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  AppUser? getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _remoteDataSource.authStateChanges();
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    return await _remoteDataSource.signInWithGoogle();
  }

  @override
  Future<AppUser?> signInAnonymously() async {
    return await _remoteDataSource.signInAnonymously();
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    await _remoteDataSource.deleteAccount();
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    await _remoteDataSource.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
  }
}
