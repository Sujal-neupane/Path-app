

sealed class AppException implements Exception {
  /// Human-readable error message
  final String message;

  /// HTTP status code if applicable
  final int? statusCode;

  /// Original exception (for debugging)
  final Exception? originalException;

  AppException({
    required this.message,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() => '$runtimeType: $message';

  /// Get user-friendly error message
  String getUserMessage();
}

/// ═══════════════════════════════════════════════════════════════════════
/// Network-Related Errors
/// ═══════════════════════════════════════════════════════════════════════

sealed class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.statusCode,
    super.originalException,
  });
}

class NoInternetException extends NetworkException {
  NoInternetException()
      : super(
          message: 'No internet connection',
        );

  @override
  String getUserMessage() => 'You\'re offline. Using cached data.';
}

class RequestTimeoutException extends NetworkException {
  RequestTimeoutException({int? durationSeconds = 30})
      : super(
          message: 'Request timed out after ${durationSeconds}s',
        );

  @override
  String getUserMessage() => 'Request took too long. Please try again.';
}

class ConnectionLostException extends NetworkException {
  ConnectionLostException()
      : super(
          message: 'Connection lost mid-request',
        );

  @override
  String getUserMessage() => 'Connection lost. Retrying...';
}

class ServerException extends NetworkException {
  ServerException({
    required int statusCode,
    required String message,
    Exception? original,
  }) : super(
          message: 'Server error ($statusCode): $message',
          statusCode: statusCode,
          originalException: original,
        );

  /// Check if this is an auth error
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Check if this is a client error
  bool get isClientError => statusCode! >= 400 && statusCode! < 500;

  /// Check if this is a server error
  bool get isServerError => statusCode! >= 500;

  @override
  String getUserMessage() {
    if (isAuthError) return 'Unauthorized. Please log in again.';
    if (statusCode == 404) return 'Resource not found.';
    if (statusCode == 429) return 'Too many requests. Please wait.';
    if (isServerError) return 'Server error. Please try later.';
    return message;
  }
}

/// ═══════════════════════════════════════════════════════════════════════
/// Authentication Errors
/// ═══════════════════════════════════════════════════════════════════════

sealed class AuthException extends AppException {
  AuthException({
    required super.message,
    super.statusCode,
    super.originalException,
  });
}

class UnauthorizedException extends AuthException {
  UnauthorizedException()
      : super(
          message: 'User not authenticated',
          statusCode: 401,
        );

  @override
  String getUserMessage() => 'Please sign in to continue.';
}

class TokenExpiredException extends AuthException {
  TokenExpiredException()
      : super(
          message: 'JWT token expired',
          statusCode: 401,
        );

  @override
  String getUserMessage() => 'Session expired. Please sign in again.';
}

class PermissionDeniedException extends AuthException {
  PermissionDeniedException({required String resource})
      : super(
          message: 'Permission denied for: $resource',
          statusCode: 403,
        );

  @override
  String getUserMessage() => 'You don\'t have permission to access this.';
}

/// ═══════════════════════════════════════════════════════════════════════
/// Cache & Data Errors
/// ═══════════════════════════════════════════════════════════════════════

sealed class DataException extends AppException {
  DataException({
    required super.message,
    super.statusCode,
    super.originalException,
  });
}

class CacheCorruptedException extends DataException {
  CacheCorruptedException({required String key})
      : super(
          message: 'Cached data corrupted for key: $key',
        );

  @override
  String getUserMessage() => 'Refreshing your data...';
}

class CacheExpiredException extends DataException {
  CacheExpiredException({required String key})
      : super(
          message: 'Cache expired for key: $key',
        );

  @override
  String getUserMessage() => 'Data is outdated. Fetching fresh data...';
}

class ValidationException extends DataException {
  final List<String> errors;

  ValidationException({
    required this.errors,
  }) : super(
          message: 'Validation failed: ${errors.join(", ")}',
        );

  @override
  String getUserMessage() => 'Invalid data received: ${errors.first}';
}

class DeserializationException extends DataException {
  DeserializationException({required String type})
      : super(
          message: 'Failed to deserialize $type',
        );

  @override
  String getUserMessage() => 'Data format error. Please try again.';
}

/// ═══════════════════════════════════════════════════════════════════════
/// Security Errors
/// ═══════════════════════════════════════════════════════════════════════

sealed class SecurityException extends AppException {
  SecurityException({
    required super.message,
    super.statusCode,
    super.originalException,
  });
}

class EncryptionFailedException extends SecurityException {
  EncryptionFailedException({required String operation})
      : super(
          message: 'Encryption failed during: $operation',
        );

  @override
  String getUserMessage() => 'Security error. Please try again.';
}

class IntegrityCheckFailedException extends SecurityException {
  IntegrityCheckFailedException({required String dataType})
      : super(
          message: 'Integrity check failed for: $dataType',
        );

  @override
  String getUserMessage() => 'Data integrity compromised. Clearing cache.';
}

/// ═══════════════════════════════════════════════════════════════════════
/// Dashboard-Specific Errors
/// ═══════════════════════════════════════════════════════════════════════

sealed class DashboardException extends AppException {
  DashboardException({
    required super.message,
    super.statusCode,
    super.originalException,
  });
}

class DashboardFetchException extends DashboardException {
  final bool isNetworkError;

  DashboardFetchException({
    required String message,
    this.isNetworkError = false,
    int? statusCode,
  }) : super(
          message: message,
          statusCode: statusCode,
        );

  @override
  String getUserMessage() {
    if (isNetworkError) {
      return 'Unable to fetch dashboard. Using cached data.';
    }
    return 'Failed to load dashboard. Please try again.';
  }
}

/// ═══════════════════════════════════════════════════════════════════════
/// Generic/Unknown Errors
/// ═══════════════════════════════════════════════════════════════════════

class GenericAppException extends AppException {
  GenericAppException({
    required super.message,
    super.statusCode,
    super.originalException,
  });

  @override
  String getUserMessage() => message;
}

/// ═══════════════════════════════════════════════════════════════════════
/// Utility Extensions
/// ═══════════════════════════════════════════════════════════════════════

extension ExceptionHandler on Exception {
  /// Convert any exception to AppException
  AppException toAppException() {
    if (this is AppException) return this as AppException;

    return GenericAppException(
      message: toString(),
      originalException: this,
    );
  }
}
