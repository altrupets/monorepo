import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Retry interceptor with exponential backoff
/// 
/// Implements REQ-REL-004: Reintentos con backoff exponencial
/// Automatically retries failed requests with exponential backoff strategy
class RetryInterceptor extends Interceptor {
  /// Maximum number of retry attempts
  final int maxRetries;

  /// Initial delay in milliseconds before first retry
  final int initialDelayMs;

  /// Maximum delay in milliseconds between retries
  final int maxDelayMs;

  /// Multiplier for exponential backoff
  final double backoffMultiplier;

  /// List of HTTP status codes that should trigger a retry
  final List<int> retryableStatusCodes;

  /// List of exception types that should trigger a retry
  final List<Type> retryableExceptionTypes;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelayMs = 100,
    this.maxDelayMs = 10000,
    this.backoffMultiplier = 2.0,
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.retryableExceptionTypes = const [
      SocketException,
      TimeoutException,
    ],
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if this error should be retried
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    // Get retry count from request options
    final retryCount = _getRetryCount(err.requestOptions);

    if (retryCount >= maxRetries) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Max retries ($maxRetries) reached for ${err.requestOptions.path}',
        );
      }
      handler.next(err);
      return;
    }

    // Calculate delay with exponential backoff
    final delay = _calculateDelay(retryCount);

    if (kDebugMode) {
      debugPrint(
        '🔄 Retrying request (attempt ${retryCount + 1}/$maxRetries) '
        'after ${delay}ms: ${err.requestOptions.path}',
      );
    }

    // Wait before retrying
    await Future.delayed(Duration(milliseconds: delay));

    // Increment retry count
    _setRetryCount(err.requestOptions, retryCount + 1);

    try {
      // Retry the request
      final response = await _retry(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      // If retry fails, pass to next interceptor
      handler.next(e);
    }
  }

  /// Check if the error should be retried
  bool _shouldRetry(DioException err) {
    // Don't retry if it's a client error (4xx) except for specific codes
    if (err.response?.statusCode != null) {
      final statusCode = err.response!.statusCode!;
      if (statusCode >= 400 && statusCode < 500) {
        return retryableStatusCodes.contains(statusCode);
      }
    }

    // Check if exception type is retryable
    if (err.error != null) {
      for (final type in retryableExceptionTypes) {
        if (err.error.runtimeType == type) {
          return true;
        }
      }
    }

    // Retry on timeout or connection errors
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }

  /// Calculate delay with exponential backoff
  int _calculateDelay(int retryCount) {
    final exponentialDelay =
        (initialDelayMs * pow(backoffMultiplier, retryCount)).toInt();
    final delay = exponentialDelay.clamp(0, maxDelayMs);

    // Add jitter to prevent thundering herd
    final jitter = (delay * 0.1 * (2 * (DateTime.now().millisecond % 100) / 100 - 1)).toInt();
    return (delay + jitter).clamp(0, maxDelayMs);
  }

  /// Get retry count from request options
  int _getRetryCount(RequestOptions options) {
    return options.extra['_retry_count'] as int? ?? 0;
  }

  /// Set retry count in request options
  void _setRetryCount(RequestOptions options, int count) {
    options.extra['_retry_count'] = count;
  }

  /// Retry the request
  Future<Response<dynamic>> _retry(RequestOptions options) async {
    final dio = Dio(BaseOptions(
      baseUrl: options.baseUrl,
      connectTimeout: options.connectTimeout,
      receiveTimeout: options.receiveTimeout,
      sendTimeout: options.sendTimeout,
    ));

    return dio.request<dynamic>(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: options.headers,
        contentType: options.contentType,
      ),
    );
  }
}
