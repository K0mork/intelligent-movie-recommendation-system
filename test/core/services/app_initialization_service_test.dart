import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:filmflow/core/services/app_initialization_service.dart';
import 'package:filmflow/core/config/env_config.dart';

void main() {
  group('AppInitializationService Tests', () {
    setUp(() {
      // Initialize test widgets binding
      TestWidgetsFlutterBinding.ensureInitialized();
      // Reset dotenv for each test
      dotenv.clean();
    });

    tearDown(() {
      dotenv.clean();
    });

    group('Environment Variable Validation Tests', () {
      test(
        'should validate environment variables correctly with all required vars',
        () {
          // Setup environment variables
          dotenv.testLoad(
            fileInput: '''
FIREBASE_API_KEY=test_firebase_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
TMDB_API_KEY=test_tmdb_key
GOOGLE_CLOUD_PROJECT_ID=test-project
OMDB_API_KEY=test_omdb_key
''',
          );

          // Verify environment configuration
          expect(EnvConfig.isFirebaseConfigured, isTrue);
          expect(EnvConfig.isTmdbConfigured, isTrue);
          expect(EnvConfig.isOmdbConfigured, isTrue);

          // Verify validation passes
          expect(() => EnvConfig.validateRequiredVariables(), returnsNormally);
        },
      );

      test('should detect missing required variables', () {
        // Setup - no environment variables
        dotenv.testLoad(fileInput: '');

        // Verify configuration state
        expect(EnvConfig.isFirebaseConfigured, isFalse);
        expect(EnvConfig.isTmdbConfigured, isFalse);

        // Verify validation fails
        expect(
          () => EnvConfig.validateRequiredVariables(),
          throwsA(isA<EnvironmentValidationException>()),
        );
      });

      test('should detect missing Firebase variables', () {
        // Setup - only TMDb key
        dotenv.testLoad(fileInput: 'TMDB_API_KEY=test_tmdb_key');

        // Verify configuration state
        expect(EnvConfig.isFirebaseConfigured, isFalse);
        expect(EnvConfig.isTmdbConfigured, isTrue);

        // Verify validation fails with specific error
        expect(
          () => EnvConfig.validateRequiredVariables(),
          throwsA(
            predicate<EnvironmentValidationException>(
              (e) =>
                  e.missingVariables.contains('FIREBASE_API_KEY') &&
                  e.missingVariables.contains('FIREBASE_AUTH_DOMAIN'),
            ),
          ),
        );
      });

      test('should detect missing TMDb API key', () {
        // Setup - only Firebase keys
        dotenv.testLoad(
          fileInput: '''
FIREBASE_API_KEY=test_firebase_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
''',
        );

        // Verify configuration state
        expect(EnvConfig.isFirebaseConfigured, isTrue);
        expect(EnvConfig.isTmdbConfigured, isFalse);

        // Verify validation fails with TMDb error
        expect(
          () => EnvConfig.validateRequiredVariables(),
          throwsA(
            predicate<EnvironmentValidationException>(
              (e) => e.missingVariables.contains('TMDB_API_KEY'),
            ),
          ),
        );
      });
    });

    group('Environment Validation Result Tests', () {
      test('should return comprehensive validation result', () {
        // Setup valid configuration
        dotenv.testLoad(
          fileInput: '''
FIREBASE_API_KEY=test_firebase_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
TMDB_API_KEY=test_tmdb_key
GOOGLE_CLOUD_PROJECT_ID=test-project
OMDB_API_KEY=test_omdb_key
''',
        );

        // Execute validation
        final result = EnvConfig.validateEnvironment();

        // Verify result
        expect(result.isValid, isTrue);
        expect(result.missingRequired, isEmpty);
        expect(result.missingOptional, isEmpty);
        expect(result.userFriendlyMessage, contains('すべての設定が完了'));
        expect(result.isFatal, isFalse);
        expect(result.hasWarnings, isFalse);
      });

      test('should return validation result with warnings', () {
        // Setup configuration with missing optional variables
        dotenv.testLoad(
          fileInput: '''
FIREBASE_API_KEY=test_firebase_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
TMDB_API_KEY=test_tmdb_key
''',
        );

        // Execute validation
        final result = EnvConfig.validateEnvironment();

        // Verify result with warnings
        expect(result.isValid, isTrue);
        expect(result.missingRequired, isEmpty);
        expect(result.missingOptional, isNotEmpty);
        expect(result.userFriendlyMessage, contains('オプション機能が無効'));
        expect(result.isFatal, isFalse);
        expect(result.hasWarnings, isTrue);
      });

      test('should return invalid result for missing required variables', () {
        // Setup invalid configuration
        dotenv.testLoad(fileInput: '');

        // Execute validation
        final result = EnvConfig.validateEnvironment();

        // Verify invalid result
        expect(result.isValid, isFalse);
        expect(result.missingRequired, isNotEmpty);
        expect(result.userFriendlyMessage, contains('必須設定が不足'));
        expect(result.isFatal, isTrue);
      });
    });

    group('Result Classes Tests', () {
      test('AppInitializationResult should have correct properties', () {
        // Test success result
        const successResult = AppInitializationResult(
          success: true,
          firebaseAvailable: true,
          errorMessage: null,
        );

        expect(successResult.success, isTrue);
        expect(successResult.firebaseAvailable, isTrue);
        expect(successResult.errorMessage, isNull);
        expect(successResult.hasError, isFalse);

        // Test failure result
        const failureResult = AppInitializationResult(
          success: false,
          firebaseAvailable: false,
          errorMessage: 'Test error',
        );

        expect(failureResult.success, isFalse);
        expect(failureResult.firebaseAvailable, isFalse);
        expect(failureResult.errorMessage, equals('Test error'));
        expect(failureResult.hasError, isTrue);
      });

      test('FirebaseInitializationResult should have correct properties', () {
        // Test success result
        const successResult = FirebaseInitializationResult(
          success: true,
          errorMessage: null,
        );

        expect(successResult.success, isTrue);
        expect(successResult.errorMessage, isNull);
        expect(successResult.toString(), contains('success: true'));

        // Test failure result
        const failureResult = FirebaseInitializationResult(
          success: false,
          errorMessage: 'Firebase error',
        );

        expect(failureResult.success, isFalse);
        expect(failureResult.errorMessage, equals('Firebase error'));
        expect(failureResult.toString(), contains('success: false'));
      });

      test(
        'InitializationProgress should handle state transitions correctly',
        () {
          // Test different states
          const notStarted = InitializationProgress(
            state: InitializationState.notStarted,
            currentStep: 'Waiting to start',
            progress: 0.0,
          );

          const inProgress = InitializationProgress(
            state: InitializationState.inProgress,
            currentStep: 'Loading environment variables',
            progress: 0.5,
          );

          const completed = InitializationProgress(
            state: InitializationState.completed,
            currentStep: 'Initialization complete',
            progress: 1.0,
          );

          const failed = InitializationProgress(
            state: InitializationState.failed,
            currentStep: 'Initialization failed',
            progress: 0.3,
            errorMessage: 'Test error',
          );

          // Verify state checks
          expect(notStarted.isCompleted, isFalse);
          expect(notStarted.isFailed, isFalse);
          expect(notStarted.isInProgress, isFalse);

          expect(inProgress.isCompleted, isFalse);
          expect(inProgress.isFailed, isFalse);
          expect(inProgress.isInProgress, isTrue);

          expect(completed.isCompleted, isTrue);
          expect(completed.isFailed, isFalse);
          expect(completed.isInProgress, isFalse);

          expect(failed.isCompleted, isFalse);
          expect(failed.isFailed, isTrue);
          expect(failed.isInProgress, isFalse);
        },
      );

      test('InitializationProgress.copyWith should work correctly', () {
        // Setup original
        const original = InitializationProgress(
          state: InitializationState.notStarted,
          currentStep: 'Initial step',
          progress: 0.0,
        );

        // Execute copyWith
        final updated = original.copyWith(
          state: InitializationState.inProgress,
          progress: 0.5,
        );

        // Verify changes
        expect(updated.state, equals(InitializationState.inProgress));
        expect(updated.currentStep, equals('Initial step')); // unchanged
        expect(updated.progress, equals(0.5));
        expect(updated.errorMessage, isNull); // unchanged
      });

      test('InitializationError should have correct properties', () {
        // Test basic error
        const error = InitializationError(
          type: InitializationErrorType.environmentVariables,
          message: 'Environment validation failed',
        );

        expect(
          error.type,
          equals(InitializationErrorType.environmentVariables),
        );
        expect(error.message, equals('Environment validation failed'));
        expect(error.originalError, isNull);
        expect(error.toString(), contains('InitializationError'));

        // Test error with details
        const errorWithDetails = InitializationError(
          type: InitializationErrorType.firebase,
          message: 'Firebase initialization failed',
          originalError: 'Original error message',
        );

        expect(errorWithDetails.type, equals(InitializationErrorType.firebase));
        expect(
          errorWithDetails.originalError,
          equals('Original error message'),
        );
      });
    });

    group('Enums and Constants Tests', () {
      test('InitializationState enum should have all expected values', () {
        // Verify all states exist
        expect(InitializationState.values, hasLength(4));
        expect(
          InitializationState.values,
          contains(InitializationState.notStarted),
        );
        expect(
          InitializationState.values,
          contains(InitializationState.inProgress),
        );
        expect(
          InitializationState.values,
          contains(InitializationState.completed),
        );
        expect(
          InitializationState.values,
          contains(InitializationState.failed),
        );
      });

      test('InitializationErrorType enum should have all expected values', () {
        // Verify all error types exist
        expect(InitializationErrorType.values, hasLength(5));
        expect(
          InitializationErrorType.values,
          contains(InitializationErrorType.flutterBindings),
        );
        expect(
          InitializationErrorType.values,
          contains(InitializationErrorType.webSemantics),
        );
        expect(
          InitializationErrorType.values,
          contains(InitializationErrorType.environmentVariables),
        );
        expect(
          InitializationErrorType.values,
          contains(InitializationErrorType.firebase),
        );
        expect(
          InitializationErrorType.values,
          contains(InitializationErrorType.unknown),
        );
      });
    });

    group('Optional Variables Check Tests', () {
      test('should detect all missing optional variables', () {
        // Setup with no optional variables
        dotenv.testLoad(
          fileInput: '''
FIREBASE_API_KEY=test_firebase_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
TMDB_API_KEY=test_tmdb_key
''',
        );

        // Execute check
        final missing = EnvConfig.checkOptionalVariables();

        // Verify missing optionals
        expect(missing, contains('GOOGLE_CLOUD_PROJECT_ID'));
        expect(missing, contains('OMDB_API_KEY'));
        expect(missing, hasLength(2));
      });

      test('should return empty list when all optional variables are set', () {
        // Setup with all variables
        dotenv.testLoad(
          fileInput: '''
FIREBASE_API_KEY=test_firebase_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
TMDB_API_KEY=test_tmdb_key
GOOGLE_CLOUD_PROJECT_ID=test-project
OMDB_API_KEY=test_omdb_key
''',
        );

        // Execute check
        final missing = EnvConfig.checkOptionalVariables();

        // Verify no missing optionals
        expect(missing, isEmpty);
      });
    });

    group('Configuration Status Tests', () {
      test('should generate detailed status with all configurations', () {
        // Setup complete configuration
        dotenv.testLoad(
          fileInput: '''
FIREBASE_API_KEY=test_firebase_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
TMDB_API_KEY=test_tmdb_key
GOOGLE_CLOUD_PROJECT_ID=test-project
OMDB_API_KEY=test_omdb_key
''',
        );

        // Execute
        final status = EnvConfig.getConfigurationStatus();

        // Verify status content
        expect(status, contains('環境変数設定状況'));
        expect(status, contains('Firebase設定: ✅ 完了'));
        expect(status, contains('TMDb API設定: ✅ 完了'));
        expect(status, contains('OMDb API設定: ✅ 完了'));
        expect(status, contains('Google Cloud設定: ✅ 完了'));
      });

      test('should show incomplete status for missing configurations', () {
        // Setup incomplete configuration
        dotenv.testLoad(fileInput: 'FIREBASE_API_KEY=test_key');

        // Execute
        final status = EnvConfig.getConfigurationStatus();

        // Verify incomplete status
        expect(status, contains('Firebase設定: ❌ 不完全'));
        expect(status, contains('TMDb API設定: ❌ 未設定'));
        expect(status, contains('OMDb API設定: ⚠️ 未設定（オプション）'));
      });
    });
  });
}
