import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:filmflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:filmflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:filmflow/features/auth/domain/entities/app_user.dart';

@GenerateMocks([AuthRemoteDataSource])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('AuthRepositoryImpl', () {
    final testUser = AppUser(
      uid: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime(2023, 1, 1),
      lastSignInAt: DateTime(2023, 1, 1),
      isEmailVerified: true,
    );

    group('getCurrentUser', () {
      test('returns user when available', () {
        when(mockRemoteDataSource.getCurrentUser()).thenReturn(testUser);

        final result = repository.getCurrentUser();

        expect(result, equals(testUser));
        verify(mockRemoteDataSource.getCurrentUser()).called(1);
      });

      test('returns null when no user', () {
        when(mockRemoteDataSource.getCurrentUser()).thenReturn(null);

        final result = repository.getCurrentUser();

        expect(result, isNull);
        verify(mockRemoteDataSource.getCurrentUser()).called(1);
      });
    });

    group('authStateChanges', () {
      test('returns stream from remote data source', () {
        final stream = Stream<AppUser?>.value(testUser);
        when(mockRemoteDataSource.authStateChanges()).thenAnswer((_) => stream);

        final result = repository.authStateChanges();

        expect(result, equals(stream));
        verify(mockRemoteDataSource.authStateChanges()).called(1);
      });
    });

    group('signInWithGoogle', () {
      test('returns user on successful sign in', () async {
        when(
          mockRemoteDataSource.signInWithGoogle(),
        ).thenAnswer((_) async => testUser);

        final result = await repository.signInWithGoogle();

        expect(result, equals(testUser));
        verify(mockRemoteDataSource.signInWithGoogle()).called(1);
      });

      test('returns null when sign in fails', () async {
        when(
          mockRemoteDataSource.signInWithGoogle(),
        ).thenAnswer((_) async => null);

        final result = await repository.signInWithGoogle();

        expect(result, isNull);
        verify(mockRemoteDataSource.signInWithGoogle()).called(1);
      });

      test('throws exception when remote data source throws', () async {
        when(
          mockRemoteDataSource.signInWithGoogle(),
        ).thenThrow(Exception('Sign in failed'));

        expect(() => repository.signInWithGoogle(), throwsException);
        verify(mockRemoteDataSource.signInWithGoogle()).called(1);
      });
    });

    group('signInAnonymously', () {
      test('returns user on successful anonymous sign in', () async {
        when(
          mockRemoteDataSource.signInAnonymously(),
        ).thenAnswer((_) async => testUser);

        final result = await repository.signInAnonymously();

        expect(result, equals(testUser));
        verify(mockRemoteDataSource.signInAnonymously()).called(1);
      });
    });

    group('signOut', () {
      test('calls remote data source sign out', () async {
        when(mockRemoteDataSource.signOut()).thenAnswer((_) async {});

        await repository.signOut();

        verify(mockRemoteDataSource.signOut()).called(1);
      });

      test('throws exception when remote data source throws', () async {
        when(
          mockRemoteDataSource.signOut(),
        ).thenThrow(Exception('Sign out failed'));

        expect(() => repository.signOut(), throwsException);
        verify(mockRemoteDataSource.signOut()).called(1);
      });
    });

    group('deleteAccount', () {
      test('calls remote data source delete account', () async {
        when(mockRemoteDataSource.deleteAccount()).thenAnswer((_) async {});

        await repository.deleteAccount();

        verify(mockRemoteDataSource.deleteAccount()).called(1);
      });
    });

    group('updateProfile', () {
      test('calls remote data source with provided parameters', () async {
        when(
          mockRemoteDataSource.updateProfile(
            displayName: anyNamed('displayName'),
            photoURL: anyNamed('photoURL'),
          ),
        ).thenAnswer((_) async {});

        await repository.updateProfile(
          displayName: 'New Name',
          photoURL: 'https://example.com/photo.jpg',
        );

        verify(
          mockRemoteDataSource.updateProfile(
            displayName: 'New Name',
            photoURL: 'https://example.com/photo.jpg',
          ),
        ).called(1);
      });

      test('calls remote data source with null values', () async {
        when(
          mockRemoteDataSource.updateProfile(
            displayName: anyNamed('displayName'),
            photoURL: anyNamed('photoURL'),
          ),
        ).thenAnswer((_) async {});

        await repository.updateProfile();

        verify(
          mockRemoteDataSource.updateProfile(displayName: null, photoURL: null),
        ).called(1);
      });
    });
  });
}
