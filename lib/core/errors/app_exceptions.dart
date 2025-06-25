/// アプリケーション固有の例外クラス
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message';
}

/// ネットワーク関連の例外
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.details,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// API関連の例外
class APIException extends AppException {
  final int? statusCode;

  const APIException(
    super.message, {
    this.statusCode,
    super.code,
    super.details,
  });

  @override
  String toString() =>
      'APIException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// 認証関連の例外
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.details,
  });

  @override
  String toString() => 'AuthException: $message';
}

/// データ変換関連の例外
class DataParsingException extends AppException {
  const DataParsingException(
    super.message, {
    super.code,
    super.details,
  });

  @override
  String toString() => 'DataParsingException: $message';
}

/// 設定関連の例外
class ConfigurationException extends AppException {
  const ConfigurationException(
    super.message, {
    super.code,
    super.details,
  });

  @override
  String toString() => 'ConfigurationException: $message';
}

/// キャッシュ関連の例外
class CacheException extends AppException {
  const CacheException(
    super.message, {
    super.code,
    super.details,
  });

  @override
  String toString() => 'CacheException: $message';
}
