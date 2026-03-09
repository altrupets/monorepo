import 'package:dio/dio.dart';
import 'package:altrupets/core/storage/secure_storage_service.dart';
import 'package:altrupets/core/graphql/graphql_client.dart';

/// Authentication interceptor for HTTP requests
///
/// Automatically injects JWT token into request headers from secure storage
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage;
  final SecureStorageService _secureStorage;

  static const String _authorizationHeader = 'Authorization';
  static const String _bearerPrefix = 'Bearer ';
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _retryFlag = 'x-is-retry';

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

    // Handle 401 Unauthorized - token expired or invalid
    if (response?.statusCode == 401 &&
        err.requestOptions.headers[_retryFlag] == null) {
      final refreshResult = await GraphQLClientService.refreshToken();

      return refreshResult.fold(
        (error) async {
          // If refresh fails, clear everything and fail
          await _secureStorage.delete(key: _keyAccessToken);
          await _secureStorage.delete(key: _keyRefreshToken);
          return handler.next(err);
        },
        (newToken) async {
          // If refresh succeeds, retry the original request
          final options = err.requestOptions;
          options.headers[_authorizationHeader] = '$_bearerPrefix$newToken';
          options.headers[_retryFlag] = 'true';

          // Use a new Dio instance or the current one (if available) to retry
          // For simplicity and to avoid circular deps, we can just use the options to re-execute
          final dio = Dio(); // Basic dio for retry
          try {
            final response = await dio.request<dynamic>(
              options.path,
              data: options.data,
              queryParameters: options.queryParameters,
              options: Options(
                method: options.method,
                headers: options.headers,
              ),
            );
            return handler.resolve(response);
          } catch (e) {
            return handler.next(err);
          } finally {
            dio.close();
          }
        },
      );
    }

    handler.next(err);
  }
}
