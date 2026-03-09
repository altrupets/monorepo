import 'package:dio/dio.dart';
import 'package:altrupets/core/services/auth_service.dart';
import 'package:altrupets/core/storage/secure_storage_service.dart';

/// Authentication interceptor for HTTP requests
///
/// Automatically injects JWT token into request headers from secure storage.
/// Handles 401 (token refresh + retry) and 403 (immediate rejection).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStorageService secureStorage,
    required AuthService authService,
    required Dio dio,
  }) : _secureStorage = secureStorage,
       _authService = authService,
       _dio = dio;

  final SecureStorageService _secureStorage;
  final AuthService _authService;
  final Dio _dio;

  static const String _authorizationHeader = 'Authorization';
  static const String _bearerPrefix = 'Bearer ';
  static const String _keyAccessToken = 'auth_access_token';
  static const String _retryCountHeader = 'x-retry-count';

  /// Retry backoff delays: 1s, 2s, 4s (max 3 retries)
  static const List<Duration> _retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Get token from secure storage
      final token = await _secureStorage.read(key: _keyAccessToken);

      // Inject token if available
      if (token != null && token.isNotEmpty) {
        options.headers[_authorizationHeader] = '$_bearerPrefix$token';
      }

      handler.next(options);
    } catch (e) {
      // If token retrieval fails, continue without token
      handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final statusCode = response?.statusCode;

    // Handle 403 Forbidden — do NOT retry, reject immediately
    if (statusCode == 403) {
      return handler.next(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: DioExceptionType.badResponse,
          message: 'Acceso denegado',
        ),
      );
    }

    // Handle 401 Unauthorized — attempt token refresh and retry
    if (statusCode == 401 && _shouldRetry(err.requestOptions)) {
      final retryCount = _getRetryCount(err.requestOptions);

      try {
        // Refresh token through AuthService
        final newToken = await _authService.refreshToken();

        // Wait before retry with exponential backoff
        await Future<void>.delayed(_retryDelays[retryCount]);

        // Retry the original request
        final options = err.requestOptions;
        options.headers[_authorizationHeader] = '$_bearerPrefix$newToken';
        options.headers[_retryCountHeader] = retryCount + 1;

        final retryResponse = await _dio.request<dynamic>(
          options.path,
          data: options.data,
          queryParameters: options.queryParameters,
          options: Options(
            method: options.method,
            headers: options.headers,
            responseType: options.responseType,
            contentType: options.contentType,
          ),
        );
        return handler.resolve(retryResponse);
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  /// Check if the request should be retried (has not exceeded max retries)
  bool _shouldRetry(RequestOptions options) {
    final retryCount = _getRetryCount(options);
    return retryCount < _retryDelays.length;
  }

  /// Get the current retry count from request headers
  int _getRetryCount(RequestOptions options) {
    final count = options.headers[_retryCountHeader];
    if (count is int) return count;
    return 0;
  }
}
