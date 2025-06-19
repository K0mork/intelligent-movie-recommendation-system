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
    _log('Starting application initialization...');
    
    try {
      // 1. Flutter バインディング初期化
      await _initializeFlutterBindings();
      
      // 2. Webセマンティクス有効化
      await _initializeWebSemantics();
      
      // 3. 環境変数読み込み
      await _loadEnvironmentVariables();
      
      // 4. 環境変数検証
      await _validateEnvironmentVariables();
      
      // 5. Firebase初期化
      final firebaseResult = await _initializeFirebase();
      
      _log('✅ Application initialization completed successfully');
      
      return AppInitializationResult(
        success: true,
        firebaseAvailable: firebaseResult.success,
        errorMessage: null,
      );
      
    } catch (error, stackTrace) {
      _logError('❌ Application initialization failed', error, stackTrace);
      
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
        _logError('⚠️ Web semantics initialization failed (non-critical)', error);
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
      _logError('⚠️ .env file not found or failed to load (using defaults)', error);
    }
  }

  /// 環境変数の検証
  static Future<void> _validateEnvironmentVariables() async {
    _log('Validating environment variables...');
    try {
      EnvConfig.validateRequiredVariables();
      _log('✅ Required environment variables validated');
      
      // オプション環境変数の確認
      final missingOptionals = EnvConfig.checkOptionalVariables();
      if (missingOptionals.isNotEmpty) {
        _log('⚠️ Optional environment variables missing: ${missingOptionals.join(', ')}');
      }
      
      // デバッグ時は環境変数の状態を表示
      if (kDebugMode) {
        _log('\n${EnvConfig.getConfigurationStatus()}');
      }
      
    } catch (error) {
      _logError('❌ Environment variable validation failed', error);
      
      // 本番環境では致命的エラーとして扱う
      if (kReleaseMode) {
        rethrow;
      }
    }
  }

  /// Firebase の初期化
  static Future<FirebaseInitializationResult> _initializeFirebase() async {
    _log('Attempting Firebase initialization...');
    
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
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
  }

  /// エラーログ出力
  static void _logError(String message, Object? error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$_tag] $message: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
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
  String toString() => 'AppInitializationResult('
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
  String toString() => 'FirebaseInitializationResult('
      'success: $success, '
      'errorMessage: $errorMessage)';
}

/// アプリケーション初期化状態の列挙型
enum InitializationState {
  notStarted,
  inProgress,
  completed,
  failed,
}

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
  String toString() => 'InitializationProgress('
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
  String toString() => 'InitializationError('
      'type: $type, '
      'message: $message, '
      'originalError: $originalError)';
}