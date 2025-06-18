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
    final List<String> missingVariables = [];

    // Firebase設定チェック（必須）
    if (firebaseApiKey.isEmpty) missingVariables.add('FIREBASE_API_KEY');
    if (firebaseAuthDomain.isEmpty) missingVariables.add('FIREBASE_AUTH_DOMAIN');
    if (firebaseProjectId.isEmpty) missingVariables.add('FIREBASE_PROJECT_ID');
    if (firebaseStorageBucket.isEmpty) missingVariables.add('FIREBASE_STORAGE_BUCKET');
    if (firebaseMessagingSenderId.isEmpty) missingVariables.add('FIREBASE_MESSAGING_SENDER_ID');
    if (firebaseAppId.isEmpty) missingVariables.add('FIREBASE_APP_ID');

    // TMDb API設定チェック（必須）
    if (tmdbApiKey.isEmpty) missingVariables.add('TMDB_API_KEY');

    if (missingVariables.isNotEmpty) {
      throw Exception(
        '必須の環境変数が設定されていません:\n'
        '${missingVariables.map((key) => '  - $key').join('\n')}\n'
        '\n'
        '.envファイルを確認し、必要な環境変数を設定してください。'
      );
    }
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
}