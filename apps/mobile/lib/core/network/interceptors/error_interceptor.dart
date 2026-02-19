import 'package:dio/dio.dart';

import 'package:altrupets/core/network/exceptions/network_exceptions.dart';

/// Error interceptor for HTTP requests
///
/// Handles error responses and converts them to appropriate exceptions
/// Provides centralized error handling and logging
class ErrorInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Convert DioException to NetworkException
    final networkException = _convertToNetworkException(err);

    // Log the error (in production, this would go to error tracking service)
    _logError(networkException);

    // Create a new DioException with the converted error
    final newErr = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: networkException,
      stackTrace: err.stackTrace,
      message: networkException.message,
    );

    handler.next(newErr);
  }

  /// Convert DioException to NetworkException
  NetworkException _convertToNetworkException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkTimeoutException(
          timeout: const Duration(seconds: 30), // Default timeout
          originalException: err,
        );

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final responseBody = err.response?.data;

        if (statusCode == 401) {
          return AuthenticationException(
            message: 'Unauthorized: Invalid or expired token',
            originalException: err,
          );
        } else if (statusCode == 403) {
          return AuthorizationException(
            message: 'Forbidden: Access denied',
            originalException: err,
          );
        } else if (statusCode == 404) {
          return NotFoundException(
            message: 'Not found: Resource does not exist',
            originalException: err,
          );
        } else if (statusCode >= 500) {
          return ServerException(
            statusCode: statusCode,
            responseBody: responseBody,
            message: 'Server error: $statusCode',
            originalException: err,
          );
        } else if (statusCode >= 400) {
          return ServerException(
            statusCode: statusCode,
            responseBody: responseBody,
            message: 'Client error: $statusCode',
            originalException: err,
          );
        }
        return ServerException(
          statusCode: statusCode,
          responseBody: responseBody,
          originalException: err,
        );

      case DioExceptionType.cancel:
        return CancelledException(originalException: err);

      case DioExceptionType.connectionError:
        return NetworkConnectionException(
          message: 'Connection error: ${err.message}',
          originalException: err,
        );

      case DioExceptionType.unknown:
        return UnknownException(
          message: 'Unknown error: ${err.message}',
          originalException: err,
        );

      case DioExceptionType.badCertificate:
        return UnknownException(
          message: 'Bad certificate: SSL/TLS error',
          originalException: err,
        );
    }
  }

  /// Log error for debugging and monitoring
  void _logError(NetworkException exception) {
    // In production, this would send to error tracking service (Sentry, etc.)
    // For now, we'll just print to console in debug mode
    print('❌ Network Error: ${exception.message}');
    if (exception.originalException != null) {
      print('   Original Exception: ${exception.originalException}');
    }
  }
}
