import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

import 'package:filmflow/features/auth/presentation/providers/auth_providers.dart';
import 'package:filmflow/features/auth/domain/entities/app_user.dart';

// Mock Firebase Auth for testing
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('Auth Providers Simple Tests', () {
    late ProviderContainer container;
    late MockFirebaseAuth mockFirebaseAuth;

    setUpAll(() async {
      // Firebase初期化のモック設定
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      container = ProviderContainer(
        overrides: [
          // Firebase Authをモックでオーバーライド
          firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Provider Instantiation Tests', () {
      test('firebaseAuthProvider should provide FirebaseAuth instance', () {
        final firebaseAuth = container.read(firebaseAuthProvider);
        expect(firebaseAuth, isA<FirebaseAuth>());
        expect(firebaseAuth, same(mockFirebaseAuth));
      });

      test('googleSignInProvider should provide GoogleSignIn instance', () {
        final googleSignIn = container.read(googleSignInProvider);
        expect(googleSignIn, isA<GoogleSignIn>());
      });

      test('authRemoteDataSourceProvider should provide instance', () {
        final dataSource = container.read(authRemoteDataSourceProvider);
        expect(dataSource, isNotNull);
      });

      test('authRepositoryProvider should provide instance', () {
        final repository = container.read(authRepositoryProvider);
        expect(repository, isNotNull);
      });

      test('signInUseCaseProvider should provide instance', () {
        final useCase = container.read(signInUseCaseProvider);
        expect(useCase, isNotNull);
      });

      test('signOutUseCaseProvider should provide instance', () {
        final useCase = container.read(signOutUseCaseProvider);
        expect(useCase, isNotNull);
      });

      test('getCurrentUserUseCaseProvider should provide instance', () {
        final useCase = container.read(getCurrentUserUseCaseProvider);
        expect(useCase, isNotNull);
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

      test('isAuthenticatedProvider should return false initially', () {
        // authStateProviderをオーバーライドしてテスト
        final testContainer = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
            authStateProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
        );
        
        final isAuthenticated = testContainer.read(isAuthenticatedProvider);
        expect(isAuthenticated, isFalse);
        
        testContainer.dispose();
      });
    });

    group('Provider Dependencies Tests', () {
      test('should maintain provider dependencies correctly', () {
        // Verify that all providers can be instantiated without circular dependencies
        expect(() => container.read(authRemoteDataSourceProvider), returnsNormally);
        expect(() => container.read(authRepositoryProvider), returnsNormally);
        expect(() => container.read(signInUseCaseProvider), returnsNormally);
        expect(() => container.read(signOutUseCaseProvider), returnsNormally);
        expect(() => container.read(getCurrentUserUseCaseProvider), returnsNormally);
      });

      test('should return same instance for multiple reads', () {
        final auth1 = container.read(firebaseAuthProvider);
        final auth2 = container.read(firebaseAuthProvider);
        expect(auth1, same(auth2));
        expect(auth1, same(mockFirebaseAuth));
        
        final repo1 = container.read(authRepositoryProvider);
        final repo2 = container.read(authRepositoryProvider);
        expect(repo1, same(repo2));
      });
    });

    group('Provider Configuration Tests', () {
      test('googleSignInProvider should have correct scopes', () {
        final googleSignIn = container.read(googleSignInProvider);
        expect(googleSignIn.scopes, isNotEmpty);
        expect(googleSignIn.scopes, contains('email'));
        expect(googleSignIn.scopes, contains('profile'));
      });
    });

    group('Error Handling Tests', () {
      test('should handle provider disposal correctly', () {
        final provider1 = container.read(authRepositoryProvider);
        expect(provider1, isNotNull);
        
        container.dispose();
        
        // After disposal, creating new container should work
        final newContainer = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
          ],
        );
        expect(() => newContainer.read(authRepositoryProvider), returnsNormally);
        newContainer.dispose();
      });
    });

    group('Performance Tests', () {
      test('should handle multiple concurrent provider reads', () async {
        final futures = List.generate(5, (index) async {
          return container.read(authRepositoryProvider);
        });
        
        final results = await Future.wait(futures);
        
        // All should return the same instance
        for (int i = 1; i < results.length; i++) {
          expect(results[i], same(results[0]));
        }
      });
    });

    group('Type Safety Tests', () {
      test('should provide correct types for all providers', () {
        final firebaseAuth = container.read(firebaseAuthProvider);
        final googleSignIn = container.read(googleSignInProvider);
        final dataSource = container.read(authRemoteDataSourceProvider);
        final repository = container.read(authRepositoryProvider);
        final signInUseCase = container.read(signInUseCaseProvider);
        final signOutUseCase = container.read(signOutUseCaseProvider);
        final getCurrentUserUseCase = container.read(getCurrentUserUseCaseProvider);
        
        expect(firebaseAuth, isA<FirebaseAuth>());
        expect(firebaseAuth, same(mockFirebaseAuth));
        expect(googleSignIn, isA<GoogleSignIn>());
        expect(dataSource, isNotNull);
        expect(repository, isNotNull);
        expect(signInUseCase, isNotNull);
        expect(signOutUseCase, isNotNull);
        expect(getCurrentUserUseCase, isNotNull);
      });
    });
  });
}