/// Network and HTTP related exceptions
abstract class NetworkException implements Exception {
  final String message;
  final dynamic originalException;

  NetworkException({
    required this.message,
    this.originalException,
  });

  @override
  String toString() => message;
}

/// Exception thrown when a network request fails due to no internet connection
class NetworkConnectionException extends NetworkException {
  NetworkConnectionException({
    String message = 'No internet connection',
    dynamic originalException,
  }) : super(
    message: message,
    originalException: originalException,
  );
}

/// Exception thrown when a network request times out
class NetworkTimeoutException extends NetworkException {
  final Duration timeout;

  NetworkTimeoutException({
    required this.timeout,
    String message = 'Request timeout',
    dynamic originalException,
  }) : super(
    message: message,
    originalException: originalException,
  );
}

/// Exception thrown when a server returns an error response
class ServerException extends NetworkException {
  final int statusCode;
  final dynamic responseBody;

  ServerException({
    required this.statusCode,
    this.responseBody,
    String? message,
    dynamic originalException,
  }) : super(
    message: message ?? 'Server error: $statusCode',
    originalException: originalException,
  );
}

/// Exception thrown when a GraphQL request returns errors
class GraphQLException extends NetworkException {
  final List<dynamic> errors;

  GraphQLException({
    required this.errors,
    String? message,
    dynamic originalException,
  }) : super(
    message: message ?? 'GraphQL error: ${errors.length} error(s)',
    originalException: originalException,
  );
}

/// Exception thrown when request parsing fails
class ParseException extends NetworkException {
  ParseException({
    String message = 'Failed to parse response',
    dynamic originalException,
  }) : super(
    message: message,
    originalException: originalException,
  );
}

/// Exception thrown when request validation fails
class ValidationException extends NetworkException {
  final Map<String, dynamic>? validationErrors;

  ValidationException({
    this.validationErrors,
    String message = 'Validation error',
    dynamic originalException,
  }) : super(
    message: message,
    originalException: originalException,
  );
}

/// Exception thrown when authentication fails
class AuthenticationException extends NetworkException {
  AuthenticationException({
    String message = 'Authentication failed',
    dynamic originalException,
  }) : super(
    message: message,
    originalException: originalException,
  );
}

/// Exception thrown when authorization fails
class AuthorizationException extends NetworkException {
  AuthorizationException({
    String message = 'Access denied',
    dynamic originalException,
  }) : super(
    message: message,
    originalException: originalException,
  );
}

/// Exception thrown when a resource is not found
class NotFoundException extends NetworkException {
  NotFoundException({
    String message = 'Resource not found',
    dynamic originalException,
  }) : super(
    message: message,
    originalException: originalException,
  );
}

/// Exception thrown when a request is cancelled
class CancelledException extends NetworkException {
  CancelledException({
    String message = 'Request cancelled',
    dynamic originalException,
  }) : super(
    message: message,
    originalException: originalException,
  );
}

/// Exception thrown for unknown/unexpected errors
class UnknownException extends NetworkException {
  UnknownException({
    String message = 'Unknown error occurred',
    dynamic originalException,
  }) : super(
    message: message,
    originalException: originalException,
  );
}
