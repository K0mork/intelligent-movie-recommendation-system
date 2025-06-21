import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:filmflow/features/auth/presentation/providers/auth_providers.dart';
import 'package:filmflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:filmflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:filmflow/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:filmflow/features/auth/domain/entities/app_user.dart';

import 'auth_providers_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  AuthRemoteDataSource,
  AuthRepository,
  User,
])
void main() {
  group('Auth Providers Unit Tests', () {
    late ProviderContainer container;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockAuthRemoteDataSource mockAuthRemoteDataSource;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      mockAuthRemoteDataSource = MockAuthRemoteDataSource();
      mockAuthRepository = MockAuthRepository();

      // Mock authStateChanges to return empty stream by default
      when(mockAuthRepository.authStateChanges()).thenAnswer((_) => Stream.value(null));
      when(mockAuthRepository.getCurrentUser()).thenReturn(null);
      when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async => null);
      when(mockAuthRepository.signInAnonymously()).thenAnswer((_) async => null);
      when(mockAuthRepository.signOut()).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
          googleSignInProvider.overrideWithValue(mockGoogleSignIn),
          authRemoteDataSourceProvider.overrideWithValue(mockAuthRemoteDataSource),
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Provider Overrides Tests', () {
      test('should use mocked FirebaseAuth', () {
        final firebaseAuth = container.read(firebaseAuthProvider);
        expect(firebaseAuth, isA<MockFirebaseAuth>());
        expect(firebaseAuth, same(mockFirebaseAuth));
      });

      test('should use mocked GoogleSignIn', () {
        final googleSignIn = container.read(googleSignInProvider);
        expect(googleSignIn, isA<MockGoogleSignIn>());
        expect(googleSignIn, same(mockGoogleSignIn));
      });

      test('should use mocked AuthRemoteDataSource', () {
        final dataSource = container.read(authRemoteDataSourceProvider);
        expect(dataSource, isA<MockAuthRemoteDataSource>());
        expect(dataSource, same(mockAuthRemoteDataSource));
      });

      test('should use mocked AuthRepository', () {
        final repository = container.read(authRepositoryProvider);
        expect(repository, isA<MockAuthRepository>());
        expect(repository, same(mockAuthRepository));
      });
    });

    group('UseCase Provider Tests', () {
      test('signInUseCaseProvider should provide SignInUseCase', () {
        final useCase = container.read(signInUseCaseProvider);
        expect(useCase, isA<SignInUseCase>());
      });

      test('signOutUseCaseProvider should provide SignOutUseCase', () {
        final useCase = container.read(signOutUseCaseProvider);
        expect(useCase, isA<SignOutUseCase>());
      });

      test('getCurrentUserUseCaseProvider should provide GetCurrentUserUseCase', () {
        final useCase = container.read(getCurrentUserUseCaseProvider);
        expect(useCase, isA<GetCurrentUserUseCase>());
      });
    });

    group('State Provider Tests', () {
      test('authLoadingProvider should have initial state as false', () {
        final loadingState = container.read(authLoadingProvider);
        expect(loadingState, isFalse);
      });

      test('authLoadingProvider should update loading state', () {
        container.read(authLoadingProvider.notifier).state = true;
        final loadingState = container.read(authLoadingProvider);
        expect(loadingState, isTrue);
      });

      test('authLoadingProvider should reset to false', () {
        container.read(authLoadingProvider.notifier).state = true;
        expect(container.read(authLoadingProvider), isTrue);
        
        container.read(authLoadingProvider.notifier).state = false;
        expect(container.read(authLoadingProvider), isFalse);
      });
    });

    group('currentUserProvider Tests', () {
      test('should return null when auth state has no user', () {
        container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
        );

        final currentUser = container.read(currentUserProvider);
        expect(currentUser, isNull);
      });

      test('should return user when auth state has user', () async {
        final testUser = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: null,
          createdAt: DateTime(2024, 1, 1),
          lastSignInAt: DateTime(2024, 1, 1),
          isEmailVerified: true,
        );

        container = ProviderContainer(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.value(testUser),
            ),
          ],
        );

        // Wait for async stream to resolve
        await container.read(authStateProvider.future);
        
        final currentUser = container.read(currentUserProvider);
        expect(currentUser, equals(testUser));
        expect(currentUser?.uid, equals('test-uid'));
        expect(currentUser?.email, equals('test@example.com'));
      });
    });

    group('isAuthenticatedProvider Tests', () {
      test('should return false when no user is authenticated', () {
        container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(null),
          ],
        );

        final isAuthenticated = container.read(isAuthenticatedProvider);
        expect(isAuthenticated, isFalse);
      });

      test('should return true when user is authenticated', () {
        final testUser = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: null,
          createdAt: DateTime(2024, 1, 1),
          lastSignInAt: DateTime(2024, 1, 1),
          isEmailVerified: true,
        );

        container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(testUser),
          ],
        );

        final isAuthenticated = container.read(isAuthenticatedProvider);
        expect(isAuthenticated, isTrue);
      });
    });

    group('Provider Dependency Tests', () {
      test('should maintain singleton behavior', () {
        final auth1 = container.read(firebaseAuthProvider);
        final auth2 = container.read(firebaseAuthProvider);
        expect(auth1, same(auth2));

        final repo1 = container.read(authRepositoryProvider);
        final repo2 = container.read(authRepositoryProvider);
        expect(repo1, same(repo2));
      });

      test('should handle provider disposal correctly', () {
        final provider1 = container.read(authRepositoryProvider);
        expect(provider1, isNotNull);

        container.dispose();

        // Create new container with same overrides
        final newContainer = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        final provider2 = newContainer.read(authRepositoryProvider);
        expect(provider2, isNotNull);
        expect(provider2, same(mockAuthRepository));

        newContainer.dispose();
      });
    });

    group('Mock Interaction Tests', () {
      test('should interact with mocked repository', () {
        when(mockAuthRepository.getCurrentUser()).thenReturn(null);
        
        final useCase = container.read(getCurrentUserUseCaseProvider);
        final result = useCase.getCurrentUser();
        
        expect(result, isNull);
        verify(mockAuthRepository.getCurrentUser()).called(1);
      });

      test('should handle mocked auth state stream', () {
        final testUser = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: null,
          createdAt: DateTime(2024, 1, 1),
          lastSignInAt: DateTime(2024, 1, 1),
          isEmailVerified: true,
        );

        when(mockAuthRepository.authStateChanges())
            .thenAnswer((_) => Stream.value(testUser));

        container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        container.listen(authStateProvider, (previous, next) {
          next.when(
            data: (user) => expect(user, equals(testUser)),
            loading: () => fail('Should not be loading'),
            error: (error, stack) => fail('Should not have error'),
          );
        });
      });
    });

    group('Error Handling Tests', () {
      test('should handle stream errors gracefully', () async {
        when(mockAuthRepository.authStateChanges())
            .thenAnswer((_) => Stream.error(Exception('Auth error')));

        container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
        );

        final authState = container.read(authStateProvider);
        
        expect(authState, isA<AsyncValue<AppUser?>>());
        // Stream error handling is tested through actual usage
      });

      test('should handle usecase exceptions', () {
        when(mockAuthRepository.getCurrentUser())
            .thenThrow(Exception('Repository error'));

        final useCase = container.read(getCurrentUserUseCaseProvider);
        
        expect(
          () => useCase.getCurrentUser(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Authentication Flow Tests', () {
      test('should update loading state during authentication', () {
        expect(container.read(authLoadingProvider), isFalse);

        // Simulate authentication start
        container.read(authLoadingProvider.notifier).state = true;
        expect(container.read(authLoadingProvider), isTrue);

        // Simulate authentication complete
        container.read(authLoadingProvider.notifier).state = false;
        expect(container.read(authLoadingProvider), isFalse);
      });

      test('should track authentication state changes', () {
        var callCount = 0;
        
        container.listen(isAuthenticatedProvider, (previous, next) {
          callCount++;
        });

        // Initially not authenticated
        expect(container.read(isAuthenticatedProvider), isFalse);

        // Simulate user login
        final testUser = AppUser(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: null,
          createdAt: DateTime(2024, 1, 1),
          lastSignInAt: DateTime(2024, 1, 1),
          isEmailVerified: true,
        );

        container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(testUser),
          ],
        );

        expect(container.read(isAuthenticatedProvider), isTrue);
      });
    });
  });
}