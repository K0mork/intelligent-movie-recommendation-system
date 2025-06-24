abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

class APIException extends AppException {
  const APIException(super.message, {super.code});
}
