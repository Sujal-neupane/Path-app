/// Base exception class for all failures in the application
abstract class AppFailure implements Exception {
  final String message;
  final int? statusCode;

  const AppFailure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Server error from API
class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {super.statusCode});
}

/// No internet connection
class NetworkFailure extends AppFailure {
  const NetworkFailure() : super('No internet connection. Please check your network.');
}

/// Authentication error (401, 403)
class AuthFailure extends AppFailure {
  const AuthFailure(super.message, {super.statusCode});
}

/// Local storage error
class StorageFailure extends AppFailure {
  const StorageFailure(super.message);
}

/// Unknown/Unexpected error
class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure() : super('An unexpected error occurred. Please try again.');
}
