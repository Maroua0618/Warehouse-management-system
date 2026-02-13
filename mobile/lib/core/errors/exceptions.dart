/// Base class for all exceptions in the application.
/// Exceptions are thrown by data sources and caught by repositories.
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when server returns an error
class ServerException extends AppException {
  const ServerException([String message = 'Server error occurred'])
    : super(message);
}

/// Exception thrown when there's no internet connection
class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection'])
    : super(message);
}

/// Exception thrown when local cache/database operation fails
class CacheException extends AppException {
  const CacheException([String message = 'Cache error occurred'])
    : super(message);
}

/// Exception thrown for unauthorized access (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Unauthorized access'])
    : super(message);
}

/// Exception thrown for authentication failures (wrong credentials)
class AuthException extends AppException {
  const AuthException([String message = 'Authentication failed'])
    : super(message);
}

/// Exception thrown when resource is not found (404)
class NotFoundException extends AppException {
  const NotFoundException([String message = 'Resource not found'])
    : super(message);
}
