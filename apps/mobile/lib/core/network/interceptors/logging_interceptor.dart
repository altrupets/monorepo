import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logging interceptor for HTTP requests and responses
///
/// Logs all HTTP requests and responses in a structured format
/// for debugging and monitoring purposes. Only logs in debug mode.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔵 HTTP REQUEST');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Method: ${options.method}');
      debugPrint('URL: ${options.uri}');
      debugPrint('Headers: ${options.headers}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('Query Parameters: ${options.queryParameters}');
      }
      if (options.data != null) {
        debugPrint('Body: ${options.data}');
      }
      debugPrint('═══════════════════════════════════════════════════════════');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🟢 HTTP RESPONSE');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('URL: ${response.requestOptions.uri}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Body: ${response.data}');
      debugPrint('═══════════════════════════════════════════════════════════');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔴 HTTP ERROR');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Type: ${err.type}');
      debugPrint('Message: ${err.message}');
      debugPrint('URL: ${err.requestOptions.uri}');
      if (err.response != null) {
        debugPrint('Status Code: ${err.response?.statusCode}');
        debugPrint('Response Body: ${err.response?.data}');
      }
      debugPrint('Error: ${err.error}');
      debugPrint('═══════════════════════════════════════════════════════════');
    }
    handler.next(err);
  }
}
