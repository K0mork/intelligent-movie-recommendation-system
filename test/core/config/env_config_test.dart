import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:filmflow/core/config/env_config.dart';

// Mock classes
@GenerateMocks([DotEnv])
class MockDotEnv extends Mock implements DotEnv {}

void main() {
  group('EnvConfig Tests', () {
    late MockDotEnv mockDotEnv;

    setUp(() {
      mockDotEnv = MockDotEnv();
      // Reset dotenv for each test
      dotenv.clean();
    });

    tearDown(() {
      dotenv.clean();
    });

    group('Environment Variable Access', () {
      test('should return Firebase API key from environment', () {
        // Setup
        dotenv.testLoad(fileInput: 'FIREBASE_API_KEY=test_firebase_key');

        // Execute & Verify
        expect(EnvConfig.firebaseApiKey, equals('test_firebase_key'));
      });

      test('should return empty string when Firebase API key is not set', () {
        // Setup
        dotenv.testLoad(fileInput: '');

        // Execute & Verify
        expect(EnvConfig.firebaseApiKey, equals(''));
      });

      test('should return TMDb API key from environment', () {
        // Setup
        dotenv.testLoad(fileInput: 'TMDB_API_KEY=test_tmdb_key');

        // Execute & Verify
        expect(EnvConfig.tmdbApiKey, equals('test_tmdb_key'));
      });

      test('should return default TMDb base URL when not set', () {
        // Setup
        dotenv.testLoad(fileInput: '');

        // Execute & Verify
        expect(EnvConfig.tmdbBaseUrl, isNotEmpty);
        expect(EnvConfig.tmdbBaseUrl, contains('api.themoviedb.org'));
      });

      test('should return custom TMDb base URL when set', () {
        // Setup
        dotenv.testLoad(fileInput: 'TMDB_BASE_URL=https://custom.api.com');

        // Execute & Verify
        expect(EnvConfig.tmdbBaseUrl, equals('https://custom.api.com'));
      });
    });

    group('Configuration Validation', () {
      test('should return true when all Firebase variables are configured', () {
        // Setup
        dotenv.testLoad(fileInput: '''
FIREBASE_API_KEY=test_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
''');

        // Execute & Verify
        expect(EnvConfig.isFirebaseConfigured, isTrue);
      });

      test('should return false when Firebase variables are missing', () {
        // Setup
        dotenv.testLoad(fileInput: 'FIREBASE_API_KEY=test_key');

        // Execute & Verify
        expect(EnvConfig.isFirebaseConfigured, isFalse);
      });

      test('should return true when TMDb is configured', () {
        // Setup
        dotenv.testLoad(fileInput: 'TMDB_API_KEY=test_tmdb_key');

        // Execute & Verify
        expect(EnvConfig.isTmdbConfigured, isTrue);
      });

      test('should return false when TMDb is not configured', () {
        // Setup
        dotenv.testLoad(fileInput: '');

        // Execute & Verify
        expect(EnvConfig.isTmdbConfigured, isFalse);
      });

      test('should return true when OMDb is configured', () {
        // Setup
        dotenv.testLoad(fileInput: 'OMDB_API_KEY=test_omdb_key');

        // Execute & Verify
        expect(EnvConfig.isOmdbConfigured, isTrue);
      });

      test('should return false when OMDb is not configured', () {
        // Setup
        dotenv.testLoad(fileInput: '');

        // Execute & Verify
        expect(EnvConfig.isOmdbConfigured, isFalse);
      });

      test('should return true for movie API when TMDb is configured', () {
        // Setup
        dotenv.testLoad(fileInput: 'TMDB_API_KEY=test_tmdb_key');

        // Execute & Verify
        expect(EnvConfig.isMovieApiConfigured, isTrue);
      });

      test('should return true for movie API when OMDb is configured', () {
        // Setup
        dotenv.testLoad(fileInput: 'OMDB_API_KEY=test_omdb_key');

        // Execute & Verify
        expect(EnvConfig.isMovieApiConfigured, isTrue);
      });

      test('should return false for movie API when neither is configured', () {
        // Setup
        dotenv.testLoad(fileInput: '');

        // Execute & Verify
        expect(EnvConfig.isMovieApiConfigured, isFalse);
      });
    });

    group('Required Variables Validation', () {
      test('should pass validation when all required variables are set', () {
        // Setup
        dotenv.testLoad(fileInput: '''
FIREBASE_API_KEY=test_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
TMDB_API_KEY=test_tmdb_key
''');

        // Execute & Verify
        expect(() => EnvConfig.validateRequiredVariables(), returnsNormally);
      });

      test('should throw exception when required variables are missing', () {
        // Setup
        dotenv.testLoad(fileInput: '');

        // Execute & Verify
        expect(
          () => EnvConfig.validateRequiredVariables(),
          throwsA(isA<EnvironmentValidationException>()),
        );
      });

      test('should throw exception with detailed message when Firebase variables are missing', () {
        // Setup
        dotenv.testLoad(fileInput: 'TMDB_API_KEY=test_tmdb_key');

        // Execute & Verify
        expect(
          () => EnvConfig.validateRequiredVariables(),
          throwsA(
            predicate<EnvironmentValidationException>((e) =>
              e.missingVariables.contains('FIREBASE_API_KEY') &&
              e.missingVariables.contains('FIREBASE_AUTH_DOMAIN')
            )
          ),
        );
      });

      test('should throw exception when TMDb API key is missing', () {
        // Setup
        dotenv.testLoad(fileInput: '''
FIREBASE_API_KEY=test_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
''');

        // Execute & Verify
        expect(
          () => EnvConfig.validateRequiredVariables(),
          throwsA(
            predicate<EnvironmentValidationException>((e) =>
              e.missingVariables.contains('TMDB_API_KEY')
            )
          ),
        );
      });
    });

    group('Optional Variables Check', () {
      test('should return empty list when all optional variables are set', () {
        // Setup
        dotenv.testLoad(fileInput: '''
GOOGLE_CLOUD_PROJECT_ID=test-project
OMDB_API_KEY=test_omdb_key
''');

        // Execute & Verify
        final missing = EnvConfig.checkOptionalVariables();
        expect(missing, isEmpty);
      });

      test('should return missing optional variables', () {
        // Setup
        dotenv.testLoad(fileInput: '');

        // Execute & Verify
        final missing = EnvConfig.checkOptionalVariables();
        expect(missing, contains('GOOGLE_CLOUD_PROJECT_ID'));
        expect(missing, contains('OMDB_API_KEY'));
      });

      test('should return only missing optional variables', () {
        // Setup
        dotenv.testLoad(fileInput: 'GOOGLE_CLOUD_PROJECT_ID=test-project');

        // Execute & Verify
        final missing = EnvConfig.checkOptionalVariables();
        expect(missing, isNot(contains('GOOGLE_CLOUD_PROJECT_ID')));
        expect(missing, contains('OMDB_API_KEY'));
      });
    });

    group('Configuration Status', () {
      test('should generate detailed configuration status', () {
        // Setup
        dotenv.testLoad(fileInput: '''
FIREBASE_API_KEY=test_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
TMDB_API_KEY=test_tmdb_key
''');

        // Execute
        final status = EnvConfig.getConfigurationStatus();

        // Verify
        expect(status, contains('環境変数設定状況'));
        expect(status, contains('Firebase設定: ✅ 完了'));
        expect(status, contains('TMDb API設定: ✅ 完了'));
        expect(status, contains('OMDb API設定: ⚠️ 未設定（オプション）'));
      });

      test('should show incomplete status for missing required variables', () {
        // Setup
        dotenv.testLoad(fileInput: 'FIREBASE_API_KEY=test_key');

        // Execute
        final status = EnvConfig.getConfigurationStatus();

        // Verify
        expect(status, contains('Firebase設定: ❌ 不完全'));
        expect(status, contains('TMDb API設定: ❌ 未設定'));
      });
    });

    group('Environment Validation Result', () {
      test('should return valid result when all required variables are set', () {
        // Setup
        dotenv.testLoad(fileInput: '''
FIREBASE_API_KEY=test_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
TMDB_API_KEY=test_tmdb_key
GOOGLE_CLOUD_PROJECT_ID=test-project
OMDB_API_KEY=test_omdb_key
''');

        // Execute
        final result = EnvConfig.validateEnvironment();

        // Verify
        expect(result.isValid, isTrue);
        expect(result.missingRequired, isEmpty);
        expect(result.missingOptional, isEmpty);
        expect(result.userFriendlyMessage, contains('すべての設定が完了'));
        expect(result.isFatal, isFalse);
        expect(result.hasWarnings, isFalse);
      });

      test('should return invalid result when required variables are missing', () {
        // Setup
        dotenv.testLoad(fileInput: '');

        // Execute
        final result = EnvConfig.validateEnvironment();

        // Verify
        expect(result.isValid, isFalse);
        expect(result.missingRequired, isNotEmpty);
        expect(result.userFriendlyMessage, contains('必須設定が不足'));
        expect(result.isFatal, isTrue);
      });

      test('should return valid result with warnings when optional variables are missing', () {
        // Setup
        dotenv.testLoad(fileInput: '''
FIREBASE_API_KEY=test_key
FIREBASE_AUTH_DOMAIN=test.firebaseapp.com
FIREBASE_PROJECT_ID=test-project
FIREBASE_STORAGE_BUCKET=test-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef
TMDB_API_KEY=test_tmdb_key
''');

        // Execute
        final result = EnvConfig.validateEnvironment();

        // Verify
        expect(result.isValid, isTrue);
        expect(result.missingRequired, isEmpty);
        expect(result.missingOptional, isNotEmpty);
        expect(result.userFriendlyMessage, contains('オプション機能が無効'));
        expect(result.isFatal, isFalse);
        expect(result.hasWarnings, isTrue);
      });
    });

    group('Validation Result Classes', () {
      test('ValidationResult should correctly identify valid state', () {
        // Setup
        const result = ValidationResult(
          missingRequired: [],
          missingOptional: ['OMDB_API_KEY'],
        );

        // Verify
        expect(result.isValid, isTrue);
      });

      test('ValidationResult should correctly identify invalid state', () {
        // Setup
        const result = ValidationResult(
          missingRequired: ['FIREBASE_API_KEY'],
          missingOptional: [],
        );

        // Verify
        expect(result.isValid, isFalse);
      });

      test('ValidationResult should generate detailed error message', () {
        // Setup
        const result = ValidationResult(
          missingRequired: ['FIREBASE_API_KEY', 'TMDB_API_KEY'],
          missingOptional: [],
        );

        // Execute
        final message = result.getDetailedErrorMessage();

        // Verify
        expect(message, contains('必要な環境変数が不足'));
        expect(message, contains('FIREBASE_API_KEY'));
        expect(message, contains('TMDB_API_KEY'));
        expect(message, contains('.env ファイルを作成'));
      });

      test('ValidationResult should generate user-friendly message', () {
        // Setup
        const validResult = ValidationResult(
          missingRequired: [],
          missingOptional: [],
        );
        const invalidResult = ValidationResult(
          missingRequired: ['FIREBASE_API_KEY'],
          missingOptional: [],
        );
        const warningResult = ValidationResult(
          missingRequired: [],
          missingOptional: ['OMDB_API_KEY'],
        );

        // Verify
        expect(validResult.getUserFriendlyMessage(), contains('すべての設定が完了'));
        expect(invalidResult.getUserFriendlyMessage(), contains('必須設定が不足'));
        expect(warningResult.getUserFriendlyMessage(), contains('オプション機能が無効'));
      });

      test('EnvironmentValidationException should have correct properties', () {
        // Setup
        const exception = EnvironmentValidationException(
          missingVariables: ['FIREBASE_API_KEY'],
          message: 'Test error message',
        );

        // Verify
        expect(exception.missingVariables, equals(['FIREBASE_API_KEY']));
        expect(exception.message, equals('Test error message'));
        expect(exception.toString(), contains('EnvironmentValidationException'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty string values correctly', () {
        // Setup
        dotenv.testLoad(fileInput: '''
FIREBASE_API_KEY=
TMDB_API_KEY=
''');

        // Verify
        expect(EnvConfig.firebaseApiKey, equals(''));
        expect(EnvConfig.tmdbApiKey, equals(''));
        expect(EnvConfig.isFirebaseConfigured, isFalse);
        expect(EnvConfig.isTmdbConfigured, isFalse);
      });

      test('should handle whitespace values correctly', () {
        // Setup
        dotenv.testLoad(fileInput: '''
FIREBASE_API_KEY=
TMDB_API_KEY=
''');

        // Verify - dotenv typically trims whitespace
        expect(EnvConfig.firebaseApiKey.trim(), equals(''));
        expect(EnvConfig.tmdbApiKey.trim(), equals(''));
      });
    });
  });
}
