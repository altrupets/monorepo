/// Network and HTTP related exceptions
abstract class NetworkException implements Exception {
  NetworkException({required this.message, this.originalException});
  final String message;
  final dynamic originalException;

  @override
  String toString() => message;
}

/// Exception thrown when a network request fails due to no internet connection
class NetworkConnectionException extends NetworkException {
  NetworkConnectionException({
    super.message = 'No internet connection',
    super.originalException,
  });
}

/// Exception thrown when a network request times out
class NetworkTimeoutException extends NetworkException {
  NetworkTimeoutException({
    required this.timeout,
    super.message = 'Request timeout',
    super.originalException,
  });
  final Duration timeout;
}

/// Exception thrown when a server returns an error response
class ServerException extends NetworkException {
  ServerException({
    required this.statusCode,
    this.responseBody,
    String? message,
    super.originalException,
  }) : super(message: message ?? 'Server error: $statusCode');
  final int statusCode;
  final dynamic responseBody;
}

/// Exception thrown when a GraphQL request returns errors
class GraphQLException extends NetworkException {
  GraphQLException({
    required this.errors,
    String? message,
    super.originalException,
  }) : super(message: message ?? 'GraphQL error: ${errors.length} error(s)');
  final List<dynamic> errors;
}

/// Exception thrown when request parsing fails
class ParseException extends NetworkException {
  ParseException({
    super.message = 'Failed to parse response',
    super.originalException,
  });
}

/// Exception thrown when request validation fails
class ValidationException extends NetworkException {
  ValidationException({
    this.validationErrors,
    super.message = 'Validation error',
    super.originalException,
  });
  final Map<String, dynamic>? validationErrors;
}

/// Exception thrown when authentication fails
class AuthenticationException extends NetworkException {
  AuthenticationException({
    super.message = 'Authentication failed',
    super.originalException,
  });
}

/// Exception thrown when authorization fails
class AuthorizationException extends NetworkException {
  AuthorizationException({
    super.message = 'Access denied',
    super.originalException,
  });
}

/// Exception thrown when a resource is not found
class NotFoundException extends NetworkException {
  NotFoundException({
    super.message = 'Resource not found',
    super.originalException,
  });
}

/// Exception thrown when a request is cancelled
class CancelledException extends NetworkException {
  CancelledException({
    super.message = 'Request cancelled',
    super.originalException,
  });
}

/// Exception thrown for unknown/unexpected errors
class UnknownException extends NetworkException {
  UnknownException({
    super.message = 'Unknown error occurred',
    super.originalException,
  });
}
