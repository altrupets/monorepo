import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:altrupets/core/config/environment_manager.dart';
import 'package:altrupets/core/services/logging_service.dart';
import 'package:altrupets/core/network/circuit_breaker.dart';
import 'package:altrupets/core/network/exceptions/network_exceptions.dart';
import 'package:altrupets/core/network/interceptors/auth_interceptor.dart';
import 'package:altrupets/core/network/interceptors/error_interceptor.dart';
import 'package:altrupets/core/network/interceptors/logging_interceptor.dart';
import 'package:altrupets/core/network/interceptors/retry_interceptor.dart';

/// HTTP Client Service for making API requests
///
/// Provides a centralized HTTP client with:
/// - Automatic token injection via AuthInterceptor
/// - Centralized error handling via ErrorInterceptor
/// - Request/response logging via LoggingInterceptor
/// - Automatic retries with exponential backoff (REQ-REL-004)
/// - Circuit breaker pattern for resilience (REQ-REL-002)
/// - Configurable timeouts and retries
/// - Structured logging (REQ-FLT-020)
class HttpClientService {
  HttpClientService({required EnvironmentManager environmentManager})
    : _environmentManager = environmentManager {
    _circuitBreakerManager = CircuitBreakerManager();
    _initializeDio();
  }
  late final Dio _dio;
  late final CircuitBreakerManager _circuitBreakerManager;
  final EnvironmentManager _environmentManager;

  void _initializeDio() {
    final environment = _environmentManager.currentEnvironment;

    _dio = Dio(
      BaseOptions(
        baseUrl: environment.apiBaseUrl,
        connectTimeout: Duration(seconds: environment.requestTimeoutSeconds),
        receiveTimeout: Duration(seconds: environment.requestTimeoutSeconds),
        sendTimeout: Duration(seconds: environment.requestTimeoutSeconds),
        contentType: 'application/json',
        validateStatus: (_) => true, // Handle all status codes
      ),
    );

    // Add interceptors in order (REQ-FLT-031)
    // 1. Logging interceptor (first to log all requests)
    _dio.interceptors.add(LoggingInterceptor());

    // 2. Auth interceptor (inject tokens) - will be added via provider
    // Note: AuthInterceptor requires SecureStorageService, injected externally

    // 3. Retry interceptor (REQ-REL-004: exponential backoff)
    _dio.interceptors.add(
      RetryInterceptor(
        maxRetries: 3,
        initialDelayMs: 100,
        maxDelayMs: 10000,
        backoffMultiplier: 2.0,
      ),
    );

    // 4. Error interceptor (centralized error handling)
    _dio.interceptors.add(ErrorInterceptor());

    logger.info(
      'HTTP Client initialized',
      tag: 'HttpClientService',
      context: {
        'baseUrl': environment.apiBaseUrl,
        'timeout': environment.requestTimeoutSeconds,
      },
    );
  }

  /// Add auth interceptor (must be called after initialization with SecureStorageService)
  void addAuthInterceptor(AuthInterceptor authInterceptor) {
    // Insert auth interceptor after logging but before retry
    _dio.interceptors.insert(1, authInterceptor);
    logger.info('Auth interceptor added', tag: 'HttpClientService');
  }

  /// Make a GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    // Check circuit breaker (REQ-REL-002)
    if (!_circuitBreakerManager.isAvailable(path)) {
      logger.warning(
        'Circuit breaker is open for endpoint',
        tag: 'HttpClientService',
        context: {'endpoint': path},
      );
      throw UnknownException(
        message: 'Service temporarily unavailable (circuit breaker open)',
      );
    }

    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      // Record success for circuit breaker
      _circuitBreakerManager.recordSuccess(path);

      return response;
    } on DioException catch (e) {
      // Record failure for circuit breaker
      _circuitBreakerManager.recordFailure(path);

      logger.error(
        'GET request failed',
        tag: 'HttpClientService',
        context: {'path': path, 'statusCode': e.response?.statusCode},
        exception: e,
      );

      throw _handleDioException(e);
    } catch (e) {
      _circuitBreakerManager.recordFailure(path);

      logger.error(
        'Unexpected error in GET request',
        tag: 'HttpClientService',
        context: {'path': path},
        exception: e,
      );

      throw UnknownException(originalException: e);
    }
  }

  /// Make a POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    // Check circuit breaker (REQ-REL-002)
    if (!_circuitBreakerManager.isAvailable(path)) {
      logger.warning(
        'Circuit breaker is open for endpoint',
        tag: 'HttpClientService',
        context: {'endpoint': path},
      );
      throw UnknownException(
        message: 'Service temporarily unavailable (circuit breaker open)',
      );
    }

    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      // Record success for circuit breaker
      _circuitBreakerManager.recordSuccess(path);

      return response;
    } on DioException catch (e) {
      // Record failure for circuit breaker
      _circuitBreakerManager.recordFailure(path);

      logger.error(
        'POST request failed',
        tag: 'HttpClientService',
        context: {'path': path, 'statusCode': e.response?.statusCode},
        exception: e,
      );

      throw _handleDioException(e);
    } catch (e) {
      _circuitBreakerManager.recordFailure(path);

      logger.error(
        'Unexpected error in POST request',
        tag: 'HttpClientService',
        context: {'path': path},
        exception: e,
      );

      throw UnknownException(originalException: e);
    }
  }

  /// Make a PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    // Check circuit breaker (REQ-REL-002)
    if (!_circuitBreakerManager.isAvailable(path)) {
      logger.warning(
        'Circuit breaker is open for endpoint',
        tag: 'HttpClientService',
        context: {'endpoint': path},
      );
      throw UnknownException(
        message: 'Service temporarily unavailable (circuit breaker open)',
      );
    }

    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      // Record success for circuit breaker
      _circuitBreakerManager.recordSuccess(path);

      return response;
    } on DioException catch (e) {
      // Record failure for circuit breaker
      _circuitBreakerManager.recordFailure(path);

      logger.error(
        'PUT request failed',
        tag: 'HttpClientService',
        context: {'path': path, 'statusCode': e.response?.statusCode},
        exception: e,
      );

      throw _handleDioException(e);
    } catch (e) {
      _circuitBreakerManager.recordFailure(path);

      logger.error(
        'Unexpected error in PUT request',
        tag: 'HttpClientService',
        context: {'path': path},
        exception: e,
      );

      throw UnknownException(originalException: e);
    }
  }

  /// Make a PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    // Check circuit breaker (REQ-REL-002)
    if (!_circuitBreakerManager.isAvailable(path)) {
      logger.warning(
        'Circuit breaker is open for endpoint',
        tag: 'HttpClientService',
        context: {'endpoint': path},
      );
      throw UnknownException(
        message: 'Service temporarily unavailable (circuit breaker open)',
      );
    }

    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      // Record success for circuit breaker
      _circuitBreakerManager.recordSuccess(path);

      return response;
    } on DioException catch (e) {
      // Record failure for circuit breaker
      _circuitBreakerManager.recordFailure(path);

      logger.error(
        'PATCH request failed',
        tag: 'HttpClientService',
        context: {'path': path, 'statusCode': e.response?.statusCode},
        exception: e,
      );

      throw _handleDioException(e);
    } catch (e) {
      _circuitBreakerManager.recordFailure(path);

      logger.error(
        'Unexpected error in PATCH request',
        tag: 'HttpClientService',
        context: {'path': path},
        exception: e,
      );

      throw UnknownException(originalException: e);
    }
  }

  /// Make a DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    // Check circuit breaker (REQ-REL-002)
    if (!_circuitBreakerManager.isAvailable(path)) {
      logger.warning(
        'Circuit breaker is open for endpoint',
        tag: 'HttpClientService',
        context: {'endpoint': path},
      );
      throw UnknownException(
        message: 'Service temporarily unavailable (circuit breaker open)',
      );
    }

    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      // Record success for circuit breaker
      _circuitBreakerManager.recordSuccess(path);

      return response;
    } on DioException catch (e) {
      // Record failure for circuit breaker
      _circuitBreakerManager.recordFailure(path);

      logger.error(
        'DELETE request failed',
        tag: 'HttpClientService',
        context: {'path': path, 'statusCode': e.response?.statusCode},
        exception: e,
      );

      throw _handleDioException(e);
    } catch (e) {
      _circuitBreakerManager.recordFailure(path);

      logger.error(
        'Unexpected error in DELETE request',
        tag: 'HttpClientService',
        context: {'path': path},
        exception: e,
      );

      throw UnknownException(originalException: e);
    }
  }

  /// Handle DioException and convert to NetworkException
  NetworkException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkTimeoutException(
          timeout: Duration(
            seconds:
                _environmentManager.currentEnvironment.requestTimeoutSeconds,
          ),
          originalException: e,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final responseBody = e.response?.data;

        if (statusCode == 401) {
          return AuthenticationException(
            message: 'Unauthorized: Invalid or expired token',
            originalException: e,
          );
        } else if (statusCode == 403) {
          return AuthorizationException(
            message: 'Forbidden: Access denied',
            originalException: e,
          );
        } else if (statusCode == 404) {
          return NotFoundException(
            message: 'Not found: Resource does not exist',
            originalException: e,
          );
        } else if (statusCode >= 500) {
          return ServerException(
            statusCode: statusCode,
            responseBody: responseBody,
            message: 'Server error: $statusCode',
            originalException: e,
          );
        } else if (statusCode >= 400) {
          return ServerException(
            statusCode: statusCode,
            responseBody: responseBody,
            message: 'Client error: $statusCode',
            originalException: e,
          );
        }
        return ServerException(
          statusCode: statusCode,
          responseBody: responseBody,
          originalException: e,
        );

      case DioExceptionType.cancel:
        return CancelledException(originalException: e);

      case DioExceptionType.connectionError:
        if (e.error is SocketException) {
          return NetworkConnectionException(
            message: 'No internet connection',
            originalException: e,
          );
        }
        return NetworkConnectionException(
          message: 'Connection error: ${e.message}',
          originalException: e,
        );

      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return NetworkConnectionException(
            message: 'Network error: ${e.message}',
            originalException: e,
          );
        }
        return UnknownException(
          message: 'Unknown error: ${e.message}',
          originalException: e,
        );

      case DioExceptionType.badCertificate:
        return UnknownException(
          message: 'Bad certificate: SSL/TLS error',
          originalException: e,
        );
    }
  }

  /// Get the underlying Dio instance for advanced usage
  Dio get dio => _dio;

  /// Get circuit breaker manager
  CircuitBreakerManager get circuitBreakerManager => _circuitBreakerManager;

  /// Close the HTTP client and clean up resources
  void close() {
    _dio.close();
    logger.info('HTTP Client closed', tag: 'HttpClientService');
  }
}

/// Riverpod provider for HttpClientService
final httpClientServiceProvider = Provider<HttpClientService>((ref) {
  final environmentManager = ref.watch(environmentManagerProvider);
  return HttpClientService(environmentManager: environmentManager);
});
