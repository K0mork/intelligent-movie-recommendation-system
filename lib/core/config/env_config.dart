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
}