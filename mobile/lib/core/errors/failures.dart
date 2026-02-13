import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// Failures represent expected error states that the UI can handle gracefully.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure for server-related errors (API errors, 500s, etc.)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

/// Failure for network/connection errors (no internet, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection']) : super(message);
}

/// Failure for local cache/database errors
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

/// Failure for unauthorized access (401 errors)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Unauthorized access']) : super(message);
}

/// Failure when a resource is not found (404 errors)
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found']) : super(message);
}
