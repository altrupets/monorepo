import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart' as log;

/// Logging interceptor for HTTP requests and responses
///
/// Logs all HTTP requests and responses in a structured format
/// for debugging and monitoring purposes.
/// - In debug mode: logs to console AND file
/// - In release mode: logs to file only
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({this.logsPath});

  final log.Logger _logger = log.Logger('HttpClient');
  bool _initialized = false;
  File? _logFile;

  /// Custom logs directory path - if null, uses default in app data directory
  final String? logsPath;

  Future<void> _initLogger() async {
    if (_initialized) return;

    // Configure logging level based on mode
    _logger.level = kDebugMode ? log.Level.ALL : log.Level.WARNING;

    try {
      String logDirPath;

      if (logsPath != null) {
        // Use custom path from environment config
        logDirPath = logsPath!;
      } else {
        // Fallback: use system temp/app directory
        // This won't work on Linux desktop without path_provider
        logDirPath = '/tmp/altrupets_logs';
      }

      final logsDir = Directory(logDirPath);
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      _logFile = File('${logsDir.path}/http_logs_$timestamp.log');

      // Create log file
      await _logFile!.writeAsString(
        '=== HTTP Client Logs started at $timestamp ===\n',
        mode: FileMode.write,
      );

      debugPrint('📝 HTTP logs writing to: ${_logFile!.path}');
    } catch (e) {
      debugPrint('Failed to initialize log file: $e');
    }

    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _initLogger();
    }
  }

  Future<void> _writeToFile(String message) async {
    await _ensureInitialized();
    if (_logFile == null) return;
    try {
      await _logFile!.writeAsString('$message\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to write to log file: $e');
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logRequest(options);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(err);
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    final timestamp = DateTime.now().toIso8601String();
    final message =
        '''

[$timestamp] 🔵 REQUEST
Method: ${options.method}
URL: ${options.uri}
Headers: ${_sanitizeHeaders(options.headers)}
Query: ${options.queryParameters}
Body: ${_truncateBody(options.data)}
''';

    _log(message);
  }

  void _logResponse(Response<dynamic> response) {
    final timestamp = DateTime.now().toIso8601String();
    final message =
        '''

[$timestamp] 🟢 RESPONSE
Status: ${response.statusCode}
URL: ${response.requestOptions.uri}
Headers: ${_sanitizeHeaders(response.headers)}
Body: ${_truncateBody(response.data)}
''';

    _log(message);
  }

  void _logError(DioException err) {
    final timestamp = DateTime.now().toIso8601String();
    final statusCode = err.response?.statusCode;
    final message =
        '''

[$timestamp] 🔴 ERROR
Type: ${err.type}
Message: ${err.message}
URL: ${err.requestOptions.uri}
Status Code: $statusCode
Error: ${err.error}
Response: ${_truncateBody(err.response?.data)}
''';

    _log(message);
  }

  void _log(String message) {
    // Always log to console in debug mode
    if (kDebugMode) {
      _logger.info(message);
    }

    // Write to file in both debug and release
    _writeToFile(message);
  }

  String _sanitizeHeaders(dynamic headers) {
    if (headers == null) return 'none';

    // Handle Headers object from Dio
    if (headers is Headers) {
      return headers.map
          .map((key, value) => MapEntry(key, value.join(', ')))
          .toString();
    }

    if (headers is Map) {
      final sanitized = Map<String, dynamic>.from(headers);

      // Remove sensitive headers
      if (sanitized.containsKey('authorization')) {
        sanitized['authorization'] = '***REDACTED***';
      }
      if (sanitized.containsKey('cookie')) {
        sanitized['cookie'] = '***REDACTED***';
      }

      return sanitized.toString();
    }

    return headers.toString();
  }

  String _truncateBody(dynamic body) {
    if (body == null) return 'null';

    final str = body.toString();
    const maxLength = 1000;

    if (str.length > maxLength) {
      return '${str.substring(0, maxLength)}...[truncated]';
    }
    return str;
  }
}
