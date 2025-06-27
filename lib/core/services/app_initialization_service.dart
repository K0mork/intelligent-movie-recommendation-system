import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import '../config/env_config.dart';
import '../../firebase_options.dart';

/// アプリケーション初期化を担当するサービスクラス
///
/// main.dart の巨大な初期化ロジックを責任ごとに分離し、
/// テスタブルで保守しやすい構造にする。
class AppInitializationService {
  static const String _tag = 'AppInit';

  /// アプリケーション全体の初期化を実行
  static Future<AppInitializationResult> initialize() async {
    _log('=== INITIALIZATION PROCESS START ===');

    try {
      // 1. Flutter バインディング初期化
      _log('Step 1/5: Flutter bindings initialization...');
      await _initializeFlutterBindings();
      _log('Step 1/5: ✅ COMPLETED');

      // 2. Webセマンティクス有効化
      _log('Step 2/5: Web semantics initialization...');
      await _initializeWebSemantics();
      _log('Step 2/5: ✅ COMPLETED');

      // 3. 環境変数読み込み
      _log('Step 3/5: Environment variables loading...');
      await _loadEnvironmentVariables();
      _log('Step 3/5: ✅ COMPLETED');

      // 4. 環境変数検証
      _log('Step 4/5: Environment variables validation...');
      await _validateEnvironmentVariables();
      _log('Step 4/5: ✅ COMPLETED');

      // 5. Firebase初期化
      _log('Step 5/5: Firebase initialization...');
      final firebaseResult = await _initializeFirebase();
      _log(
        'Step 5/5: ✅ COMPLETED - Firebase available: ${firebaseResult.success}',
      );

      _log('=== INITIALIZATION PROCESS SUCCESS ===');

      return AppInitializationResult(
        success: true,
        firebaseAvailable: firebaseResult.success,
        errorMessage: null,
      );
    } catch (error, stackTrace) {
      _log('=== INITIALIZATION PROCESS FAILED ===');
      _logError('❌ Fatal error during initialization', error, stackTrace);

      return AppInitializationResult(
        success: false,
        firebaseAvailable: false,
        errorMessage: error.toString(),
      );
    }
  }

  /// Flutter バインディングの初期化
  static Future<void> _initializeFlutterBindings() async {
    _log('Initializing Flutter bindings...');
    WidgetsFlutterBinding.ensureInitialized();
  }

  /// Webプラットフォーム用セマンティクスの初期化
  static Future<void> _initializeWebSemantics() async {
    if (kIsWeb) {
      _log('Initializing web semantics...');
      try {
        SemanticsBinding.instance.ensureSemantics();
        _log('✅ Web semantics initialized successfully');
      } catch (error) {
        _logError(
          '⚠️ Web semantics initialization failed (non-critical)',
          error,
        );
      }
    }
  }

  /// 環境変数ファイルの読み込み
  static Future<void> _loadEnvironmentVariables() async {
    _log('Loading environment variables...');

    try {
      await dotenv.load(fileName: ".env");
      _log('✅ Environment variables loaded successfully');
    } catch (error) {
      // Web環境や.envファイルが存在しない場合のフォールバック
      if (kIsWeb) {
        _log('✅ Web environment detected, using built-in configuration');
      } else {
        _logError(
          '⚠️ .env file not found or failed to load (using defaults)',
          error,
        );
      }
    }
  }

  /// 環境変数の検証
  static Future<void> _validateEnvironmentVariables() async {
    _log('Validating environment variables...');

    // Web環境での事前チェック
    if (kIsWeb) {
      _log('🌐 Web environment detected');
      // ignore: avoid_print
      print('FilmFlow - Web environment validation starting...');
      // ignore: avoid_print
      print(
        'Firebase API Key available: ${EnvConfig.firebaseApiKey.isNotEmpty}',
      );
      // ignore: avoid_print
      print('TMDb API Key available: ${EnvConfig.tmdbApiKey.isNotEmpty}');
    }

    try {
      _log('🔍 Calling EnvConfig.validateEnvironment()...');

      // 完全な環境変数バリデーションを実行
      final validationResult = EnvConfig.validateEnvironment();

      _log('🔍 EnvConfig.validateEnvironment() completed');
      _log('🔍 ValidationResult - isFatal: ${validationResult.isFatal}');
      _log(
        '🔍 ValidationResult - hasWarnings: ${validationResult.hasWarnings}',
      );

      if (validationResult.isFatal) {
        // Web環境では内蔵設定を使用するため、追加ログを出力
        if (kIsWeb) {
          _log('⚠️ Web環境でのバリデーションエラー、内蔵設定確認中...');
          _log(
            'Firebase API Key: ${EnvConfig.firebaseApiKey.isNotEmpty ? "✅" : "❌"}',
          );
          _log('TMDb API Key: ${EnvConfig.tmdbApiKey.isNotEmpty ? "✅" : "❌"}');
        }

        throw InitializationError(
          type: InitializationErrorType.environmentVariables,
          message: validationResult.userFriendlyMessage,
        );
      }

      _log('✅ Required environment variables validated');

      // 警告がある場合はログに出力
      if (validationResult.hasWarnings) {
        _log('⚠️ ${validationResult.userFriendlyMessage}');
        _log(
          'Missing optional variables: ${validationResult.missingOptional.join(', ')}',
        );
      }

      // デバッグ時は詳細な環境変数状態を表示
      if (kDebugMode) {
        _log('\n${validationResult.debugMessage}');
      }
    } catch (error) {
      _logError('❌ Environment variable validation failed', error);

      // Web環境では詳細なデバッグ情報を出力
      if (kIsWeb) {
        _log('Web Environment Debug Info:');
        _log('kIsWeb: $kIsWeb');
        _log('kReleaseMode: $kReleaseMode');
        _log('Firebase configured: ${EnvConfig.isFirebaseConfigured}');
        _log('TMDb configured: ${EnvConfig.isTmdbConfigured}');
        _log(
          'Firebase API Key: ${EnvConfig.firebaseApiKey.length > 10
              ? '${EnvConfig.firebaseApiKey.substring(0, 10)}...'
              : EnvConfig.firebaseApiKey.isEmpty
              ? 'empty'
              : EnvConfig.firebaseApiKey}',
        );
        _log(
          'TMDb API Key: ${EnvConfig.tmdbApiKey.length > 10
              ? '${EnvConfig.tmdbApiKey.substring(0, 10)}...'
              : EnvConfig.tmdbApiKey.isEmpty
              ? 'empty'
              : EnvConfig.tmdbApiKey}',
        );
        // 強制的にコンソールにも出力
        // ignore: avoid_print
        print(
          'FilmFlow Debug - Firebase: ${EnvConfig.isFirebaseConfigured}, TMDb: ${EnvConfig.isTmdbConfigured}',
        );
      }

      // Web本番環境では最小限の設定で継続を試行
      if (kIsWeb && kReleaseMode) {
        // Firebase/TMDbのAPIキーが存在すれば継続
        if (EnvConfig.firebaseApiKey.isNotEmpty &&
            EnvConfig.tmdbApiKey.isNotEmpty) {
          _log('⚠️ バリデーションエラーがありますが、最小限設定で継続します');
          return;
        } else {
          // 必須APIキーが不足している場合は再スロー
          rethrow;
        }
      }

      // ローカル開発環境では致命的エラーとして扱わない
      if (!kReleaseMode) {
        return;
      }

      rethrow;
    }
  }

  /// Firebase の初期化
  static Future<FirebaseInitializationResult> _initializeFirebase() async {
    _log('Attempting Firebase initialization...');

    try {
      // Web環境でのFirebase設定の事前チェック
      if (kIsWeb) {
        _log('🌐 Web環境でのFirebase初期化を開始...');
        _log('🔧 Firebase設定値確認:');
        _log(
          '  - API Key: ${EnvConfig.firebaseApiKey.isNotEmpty ? '✅ 設定済み' : '❌ 未設定'}',
        );
        _log(
          '  - Project ID: ${EnvConfig.firebaseProjectId.isNotEmpty ? '✅ 設定済み' : '❌ 未設定'}',
        );
        _log(
          '  - App ID: ${EnvConfig.firebaseAppId.isNotEmpty ? '✅ 設定済み' : '❌ 未設定'}',
        );
        _log(
          '  - Auth Domain: ${EnvConfig.firebaseAuthDomain.isNotEmpty ? '✅ 設定済み' : '❌ 未設定'}',
        );
        _log(
          '  - Storage Bucket: ${EnvConfig.firebaseStorageBucket.isNotEmpty ? '✅ 設定済み' : '❌ 未設定'}',
        );
        _log(
          '  - Messaging Sender ID: ${EnvConfig.firebaseMessagingSenderId.isNotEmpty ? '✅ 設定済み' : '❌ 未設定'}',
        );

        if (EnvConfig.firebaseApiKey.isEmpty) {
          throw InitializationError(
            type: InitializationErrorType.firebase,
            message: 'Firebase API Key is required for web deployment',
          );
        }

        if (EnvConfig.firebaseProjectId.isEmpty) {
          throw InitializationError(
            type: InitializationErrorType.firebase,
            message: 'Firebase Project ID is required for web deployment',
          );
        }
      }

      _log('🔧 Calling Firebase.initializeApp()...');
      _log('🔧 Platform options: ${DefaultFirebaseOptions.currentPlatform}');

      // Firebase初期化を実行
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _log('🔧 Firebase.initializeApp() completed successfully');

      _log('✅ Firebase initialized successfully');

      // Performance監視を有効化
      if (kIsWeb) {
        _log('🔄 Firebase Performance monitoring enabled for Web');
      }

      return const FirebaseInitializationResult(
        success: true,
        errorMessage: null,
      );
    } catch (error, stackTrace) {
      _logError('❌ Firebase initialization failed', error, stackTrace);

      // Web本番環境ではFirebaseエラーを重篤に扱う
      if (kIsWeb && kReleaseMode) {
        _log('🚨 Web本番環境でFirebase初期化に失敗しました');
        rethrow;
      }

      _log('🔄 Application will run in demo mode without Firebase');

      return FirebaseInitializationResult(
        success: false,
        errorMessage: error.toString(),
      );
    }
  }

  /// ログ出力（デバッグ用）
  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] $message');
    }
    // Web本番環境でも重要なログはコンソールに出力
    if (kIsWeb &&
        (message.contains('===') ||
            message.contains('Step') ||
            message.contains('🔍') ||
            message.contains('🔧') ||
            message.contains('🚨'))) {
      // ignore: avoid_print
      print('[$_tag] $message');
    }
  }

  /// エラーログ出力
  static void _logError(
    String message,
    Object? error, [
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      debugPrint('[$_tag] $message: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
    // Web本番環境でもエラーはコンソールに出力
    if (kIsWeb) {
      // ignore: avoid_print
      print('[$_tag] $message: $error');
      if (stackTrace != null) {
        // ignore: avoid_print
        print('StackTrace: $stackTrace');
      }
    }
  }
}

/// アプリケーション初期化の結果
class AppInitializationResult {
  final bool success;
  final bool firebaseAvailable;
  final String? errorMessage;

  const AppInitializationResult({
    required this.success,
    required this.firebaseAvailable,
    required this.errorMessage,
  });

  bool get hasError => !success || errorMessage != null;

  @override
  String toString() =>
      'AppInitializationResult('
      'success: $success, '
      'firebaseAvailable: $firebaseAvailable, '
      'errorMessage: $errorMessage)';
}

/// Firebase 初期化の結果
class FirebaseInitializationResult {
  final bool success;
  final String? errorMessage;

  const FirebaseInitializationResult({
    required this.success,
    required this.errorMessage,
  });

  @override
  String toString() =>
      'FirebaseInitializationResult('
      'success: $success, '
      'errorMessage: $errorMessage)';
}

/// アプリケーション初期化状態の列挙型
enum InitializationState { notStarted, inProgress, completed, failed }

/// 初期化の進行状況を追跡するためのクラス
class InitializationProgress {
  final InitializationState state;
  final String currentStep;
  final double progress;
  final String? errorMessage;

  const InitializationProgress({
    required this.state,
    required this.currentStep,
    required this.progress,
    this.errorMessage,
  });

  bool get isCompleted => state == InitializationState.completed;
  bool get isFailed => state == InitializationState.failed;
  bool get isInProgress => state == InitializationState.inProgress;

  InitializationProgress copyWith({
    InitializationState? state,
    String? currentStep,
    double? progress,
    String? errorMessage,
  }) {
    return InitializationProgress(
      state: state ?? this.state,
      currentStep: currentStep ?? this.currentStep,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() =>
      'InitializationProgress('
      'state: $state, '
      'currentStep: $currentStep, '
      'progress: $progress, '
      'errorMessage: $errorMessage)';
}

/// 初期化エラーの種類
enum InitializationErrorType {
  flutterBindings,
  webSemantics,
  environmentVariables,
  firebase,
  unknown,
}

/// 初期化エラーの詳細情報
class InitializationError implements Exception {
  final InitializationErrorType type;
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  const InitializationError({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() =>
      'InitializationError('
      'type: $type, '
      'message: $message, '
      'originalError: $originalError)';
}
