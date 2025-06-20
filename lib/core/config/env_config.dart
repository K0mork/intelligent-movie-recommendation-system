import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';

/// 環境変数の管理を行うクラス
class EnvConfig {
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAuthDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  static String get tmdbApiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get tmdbBaseUrl => dotenv.env['TMDB_BASE_URL'] ?? AppConstants.tmdbBaseUrl;

  static String get omdbApiKey => dotenv.env['OMDB_API_KEY'] ?? '';
  static String get omdbBaseUrl => dotenv.env['OMDB_BASE_URL'] ?? AppConstants.omdbBaseUrl;

  static String get googleCloudProjectId => dotenv.env['GOOGLE_CLOUD_PROJECT_ID'] ?? '';
  static String get vertexAiRegion => dotenv.env['VERTEX_AI_REGION'] ?? AppConstants.defaultRegion;

  static bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty &&
      firebaseAuthDomain.isNotEmpty &&
      firebaseProjectId.isNotEmpty &&
      firebaseStorageBucket.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty &&
      firebaseAppId.isNotEmpty;

  static bool get isTmdbConfigured => tmdbApiKey.isNotEmpty;

  static bool get isOmdbConfigured => omdbApiKey.isNotEmpty;

  static bool get isMovieApiConfigured => isTmdbConfigured || isOmdbConfigured;

  /// 起動時に必須環境変数をチェックし、不足があれば例外を投げる
  static void validateRequiredVariables() {
    final ValidationResult result = _performValidation();
    
    if (!result.isValid) {
      throw EnvironmentValidationException(
        missingVariables: result.missingRequired,
        message: result.getDetailedErrorMessage(),
      );
    }
  }

  /// 完全な環境変数バリデーションを実行
  static ValidationResult _performValidation() {
    final List<String> missingRequired = [];
    final List<String> missingOptional = [];

    // Firebase設定チェック（必須）
    if (firebaseApiKey.isEmpty) missingRequired.add('FIREBASE_API_KEY');
    if (firebaseAuthDomain.isEmpty) missingRequired.add('FIREBASE_AUTH_DOMAIN');
    if (firebaseProjectId.isEmpty) missingRequired.add('FIREBASE_PROJECT_ID');
    if (firebaseStorageBucket.isEmpty) missingRequired.add('FIREBASE_STORAGE_BUCKET');
    if (firebaseMessagingSenderId.isEmpty) missingRequired.add('FIREBASE_MESSAGING_SENDER_ID');
    if (firebaseAppId.isEmpty) missingRequired.add('FIREBASE_APP_ID');

    // TMDb API設定チェック（必須）
    if (tmdbApiKey.isEmpty) missingRequired.add('TMDB_API_KEY');

    // オプション設定チェック
    if (googleCloudProjectId.isEmpty) missingOptional.add('GOOGLE_CLOUD_PROJECT_ID');
    if (omdbApiKey.isEmpty) missingOptional.add('OMDB_API_KEY');

    return ValidationResult(
      missingRequired: missingRequired,
      missingOptional: missingOptional,
    );
  }

  /// 起動時に推奨環境変数をチェックし、不足があれば警告を出力
  static List<String> checkOptionalVariables() {
    final List<String> missingOptionals = [];

    // Google Cloud設定（AI推薦機能用）
    if (googleCloudProjectId.isEmpty) missingOptionals.add('GOOGLE_CLOUD_PROJECT_ID');
    
    // OMDB API設定（補助的な映画情報用）
    if (omdbApiKey.isEmpty) missingOptionals.add('OMDB_API_KEY');

    return missingOptionals;
  }

  /// デバッグ用：設定された環境変数の状態を表示
  static String getConfigurationStatus() {
    return '''
環境変数設定状況:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔥 Firebase設定: ${isFirebaseConfigured ? '✅ 完了' : '❌ 不完全'}
  - API Key: ${firebaseApiKey.isNotEmpty ? '✅' : '❌'}
  - Auth Domain: ${firebaseAuthDomain.isNotEmpty ? '✅' : '❌'}
  - Project ID: ${firebaseProjectId.isNotEmpty ? '✅' : '❌'}
  - Storage Bucket: ${firebaseStorageBucket.isNotEmpty ? '✅' : '❌'}
  - Messaging Sender ID: ${firebaseMessagingSenderId.isNotEmpty ? '✅' : '❌'}
  - App ID: ${firebaseAppId.isNotEmpty ? '✅' : '❌'}

🎬 TMDb API設定: ${isTmdbConfigured ? '✅ 完了' : '❌ 未設定'}
  - API Key: ${tmdbApiKey.isNotEmpty ? '✅' : '❌'}
  - Base URL: ${tmdbBaseUrl.isNotEmpty ? '✅' : '❌'}

🎭 OMDb API設定: ${isOmdbConfigured ? '✅ 完了' : '⚠️ 未設定（オプション）'}
  - API Key: ${omdbApiKey.isNotEmpty ? '✅' : '❌'}
  - Base URL: ${omdbBaseUrl.isNotEmpty ? '✅' : '❌'}

☁️ Google Cloud設定: ${googleCloudProjectId.isNotEmpty ? '✅ 完了' : '⚠️ 未設定（オプション）'}
  - Project ID: ${googleCloudProjectId.isNotEmpty ? '✅' : '❌'}
  - Vertex AI Region: ${vertexAiRegion.isNotEmpty ? '✅' : '❌'}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
  }

  /// 完全なバリデーションを実行してユーザー向けメッセージを返す
  static EnvironmentValidationResult validateEnvironment() {
    final ValidationResult result = _performValidation();
    return EnvironmentValidationResult(
      isValid: result.isValid,
      missingRequired: result.missingRequired,
      missingOptional: result.missingOptional,
      userFriendlyMessage: result.getUserFriendlyMessage(),
      debugMessage: getConfigurationStatus(),
    );
  }
}

/// 環境変数バリデーション結果
class ValidationResult {
  final List<String> missingRequired;
  final List<String> missingOptional;

  const ValidationResult({
    required this.missingRequired,
    required this.missingOptional,
  });

  bool get isValid => missingRequired.isEmpty;

  String getDetailedErrorMessage() {
    final buffer = StringBuffer();
    buffer.writeln('🚨 アプリケーションの起動に必要な環境変数が不足しています');
    buffer.writeln();
    
    if (missingRequired.isNotEmpty) {
      buffer.writeln('❌ 必須の環境変数:');
      for (final variable in missingRequired) {
        buffer.writeln('  • $variable');
      }
      buffer.writeln();
    }
    
    buffer.writeln('📋 対処方法:');
    buffer.writeln('1. プロジェクトルートに .env ファイルを作成');
    buffer.writeln('2. 必要な環境変数を設定');
    buffer.writeln('3. アプリケーションを再起動');
    buffer.writeln();
    buffer.writeln('詳細については README.md を参照してください。');
    
    return buffer.toString();
  }

  String getUserFriendlyMessage() {
    if (isValid) {
      final optionalCount = missingOptional.length;
      return optionalCount == 0
          ? '✅ すべての設定が完了しています'
          : '⚠️ 基本設定は完了していますが、$optionalCount個のオプション機能が無効です';
    }
    
    return '❌ ${missingRequired.length}個の必須設定が不足しています';
  }
}

/// ユーザー向け環境変数バリデーション結果
class EnvironmentValidationResult {
  final bool isValid;
  final List<String> missingRequired;
  final List<String> missingOptional;
  final String userFriendlyMessage;
  final String debugMessage;

  const EnvironmentValidationResult({
    required this.isValid,
    required this.missingRequired,
    required this.missingOptional,
    required this.userFriendlyMessage,
    required this.debugMessage,
  });

  /// エラーが致命的（アプリ起動不可）かどうか
  bool get isFatal => !isValid;

  /// 警告レベル（一部機能制限あり）かどうか
  bool get hasWarnings => isValid && missingOptional.isNotEmpty;
}

/// 環境変数バリデーション例外
class EnvironmentValidationException implements Exception {
  final List<String> missingVariables;
  final String message;

  const EnvironmentValidationException({
    required this.missingVariables,
    required this.message,
  });

  @override
  String toString() => 'EnvironmentValidationException: $message';
}