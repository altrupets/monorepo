import 'package:dio/dio.dart';
import 'package:altrupets/core/storage/secure_storage_service.dart';
import '../../services/auth_service.dart';

/// Authentication interceptor for HTTP requests
///
/// Automatically injects JWT token into request headers from secure storage
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStorageService secureStorage,
    required AuthService authService,
    Dio? dio,
  }) : _secureStorage = secureStorage,
       _authService = authService,
       _dio = dio ?? Dio();

  final SecureStorageService _secureStorage;
  final AuthService _authService;
  final Dio _dio;

  static const String _authorizationHeader = 'Authorization';
  static const String _bearerPrefix = 'Bearer ';
  static const String _keyAccessToken = 'auth_access_token';
  static const String _retryCountHeader = 'x-retry-count';
  static const int _maxRetries = 3;

  static const List<Duration> _retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 3),
    Duration(seconds: 10),
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

    // Handle 401 Unauthorized (expired token) or 403 Forbidden (unexpected but worth one retry)
    if ((statusCode == 401 || statusCode == 403) &&
        _shouldRetry(err.requestOptions)) {
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

        final response = await _dio.request<dynamic>(
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
        return handler.resolve(response);
      } catch (e) {
        // If refresh fails fatally or all retries fail, continue with error
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(RequestOptions options) {
    final retryCount = _getRetryCount(options);
    return retryCount < _maxRetries;
  }

  int _getRetryCount(RequestOptions options) {
    final count = options.headers[_retryCountHeader];
    if (count is int) return count;
    if (count is String) return int.tryParse(count) ?? 0;
    return 0;
  }
}
