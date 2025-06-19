import 'package:flutter/foundation.dart';

/// アプリケーション全体で統一されたエラーハンドリングとローディング状態を管理するクラス
/// 
/// Success、Loading、Error の3つの状態を明確に区別し、
/// 型安全な方法で結果を処理できるようにする。
@immutable
sealed class ResultState<T> {
  const ResultState();

  /// 成功状態
  const factory ResultState.success(T data) = Success<T>;
  
  /// ローディング状態
  const factory ResultState.loading([String? message]) = Loading<T>;
  
  /// エラー状態
  const factory ResultState.error(String message, [Object? error, StackTrace? stackTrace]) = Error<T>;

  /// 初期状態
  const factory ResultState.initial() = Initial<T>;

  /// パターンマッチング用の when メソッド
  R when<R>({
    required R Function(T data) success,
    required R Function(String? message) loading,
    required R Function(String message, Object? error, StackTrace? stackTrace) onError,
    required R Function() initial,
  }) {
    return switch (this) {
      Success<T>(data: final data) => success(data),
      Loading<T>(message: final message) => loading(message),
      Error<T>(message: final message, error: final error, stackTrace: final stackTrace) => 
        onError(message, error, stackTrace),
      Initial<T>() => initial(),
    };
  }

  /// 部分的なパターンマッチング（オプション引数）
  R maybeWhen<R>({
    R Function(T data)? success,
    R Function(String? message)? loading,
    R Function(String message, Object? error, StackTrace? stackTrace)? onError,
    R Function()? initial,
    required R Function() orElse,
  }) {
    return switch (this) {
      Success<T>(data: final data) when success != null => success(data),
      Loading<T>(message: final message) when loading != null => loading(message),
      Error<T>(message: final message, error: final error, stackTrace: final stackTrace) when onError != null => 
        onError(message, error, stackTrace),
      Initial<T>() when initial != null => initial(),
      _ => orElse(),
    };
  }

  /// データが利用可能かどうか
  bool get hasData => this is Success<T>;
  
  /// ローディング中かどうか
  bool get isLoading => this is Loading<T>;
  
  /// エラー状態かどうか
  bool get hasError => this is Error<T>;
  
  /// 初期状態かどうか
  bool get isInitial => this is Initial<T>;

  /// データを安全に取得（null許可）
  T? get dataOrNull => switch (this) {
    Success<T>(data: final data) => data,
    _ => null,
  };

  /// エラーメッセージを安全に取得（null許可）
  String? get errorMessageOrNull => switch (this) {
    Error<T>(message: final message) => message,
    _ => null,
  };

  /// ローディングメッセージを安全に取得（null許可）
  String? get loadingMessageOrNull => switch (this) {
    Loading<T>(message: final message) => message,
    _ => null,
  };

  /// データを変換する（成功時のみ）
  ResultState<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success<T>(data: final data) => ResultState.success(mapper(data)),
      Loading<T>(message: final message) => ResultState.loading(message),
      Error<T>(message: final message, error: final error, stackTrace: final stackTrace) => 
        ResultState.error(message, error, stackTrace),
      Initial<T>() => ResultState.initial(),
    };
  }

  /// 非同期データ変換
  Future<ResultState<R>> mapAsync<R>(Future<R> Function(T data) mapper) async {
    return switch (this) {
      Success<T>(data: final data) => await _mapAsyncSuccess(mapper, data),
      Loading<T>(message: final message) => ResultState.loading(message),
      Error<T>(message: final message, error: final error, stackTrace: final stackTrace) => 
        ResultState.error(message, error, stackTrace),
      Initial<T>() => ResultState.initial(),
    };
  }

  Future<ResultState<R>> _mapAsyncSuccess<R>(Future<R> Function(T data) mapper, T data) async {
    try {
      final result = await mapper(data);
      return ResultState.success(result);
    } catch (error, stackTrace) {
      return ResultState.error('データ変換エラー', error, stackTrace);
    }
  }

  /// エラー時のフォールバック値を提供
  T getOrElse(T fallback) {
    return switch (this) {
      Success<T>(data: final data) => data,
      _ => fallback,
    };
  }

  /// エラー時の例外をスロー
  T getOrThrow() {
    return switch (this) {
      Success<T>(data: final data) => data,
      Error<T>(message: final message, error: final error) => 
        throw error ?? Exception(message),
      Loading<T>() => throw Exception('データはまだローディング中です'),
      Initial<T>() => throw Exception('データが初期化されていません'),
    };
  }
}

/// 成功状態
final class Success<T> extends ResultState<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && runtimeType == other.runtimeType && data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

/// ローディング状態
final class Loading<T> extends ResultState<T> {
  final String? message;
  const Loading([this.message]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loading<T> && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'Loading(message: $message)';
}

/// エラー状態
final class Error<T> extends ResultState<T> {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const Error(this.message, [this.error, this.stackTrace]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error<T> && 
      runtimeType == other.runtimeType && 
      message == other.message &&
      error == other.error;

  @override
  int get hashCode => Object.hash(message, error);

  @override
  String toString() => 'Error(message: $message, error: $error)';
}

/// 初期状態
final class Initial<T> extends ResultState<T> {
  const Initial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Initial<T> && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Initial()';
}

/// ResultState を扱うためのユーティリティ拡張
extension ResultStateUtils<T> on ResultState<T> {
  /// リストのResultStateを単一のResultStateに集約
  static ResultState<List<T>> combine<T>(List<ResultState<T>> states) {
    if (states.any((state) => state.hasError)) {
      final errorState = states.firstWhere((state) => state.hasError) as Error<T>;
      return ResultState.error(errorState.message, errorState.error, errorState.stackTrace);
    }
    
    if (states.any((state) => state.isLoading)) {
      return const ResultState.loading('読み込み中...');
    }
    
    if (states.any((state) => state.isInitial)) {
      return const ResultState.initial();
    }
    
    final data = states.map((state) => state.dataOrNull!).toList();
    return ResultState.success(data);
  }

  /// 条件付きでデータを変換
  ResultState<T> where(bool Function(T data) predicate, String errorMessage) {
    return switch (this) {
      Success<T>(data: final data) when predicate(data) => this,
      Success<T>() => ResultState.error(errorMessage),
      _ => this,
    };
  }

  /// デバッグ用ログ出力
  ResultState<T> debug([String? tag]) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      print('${tagPrefix}ResultState: $this');
    }
    return this;
  }
}

/// Future<T> から ResultState<T> への変換ユーティリティ
extension FutureResultState<T> on Future<T> {
  /// Future を ResultState に変換
  Future<ResultState<T>> toResultState() async {
    try {
      final result = await this;
      return ResultState.success(result);
    } catch (error, stackTrace) {
      return ResultState.error(
        error.toString(),
        error,
        stackTrace,
      );
    }
  }

  /// カスタムエラーメッセージ付きで ResultState に変換
  Future<ResultState<T>> toResultStateWithMessage(String errorMessage) async {
    try {
      final result = await this;
      return ResultState.success(result);
    } catch (error, stackTrace) {
      return ResultState.error(
        errorMessage,
        error,
        stackTrace,
      );
    }
  }
}