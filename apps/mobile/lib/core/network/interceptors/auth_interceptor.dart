import 'dart:async';

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

  /// Concurrency guard: prevents parallel refresh token calls
  Completer<String>? _refreshCompleter;

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

    // Handle 401 Unauthorized — attempt token refresh and retry once
    if (statusCode == 401) {
      final alreadyRefreshed =
          err.requestOptions.extra['tokenRefreshed'] == true;

      // If we already refreshed the token and still got 401, give up
      if (alreadyRefreshed) {
        return handler.next(err);
      }

      try {
        // Concurrency guard: if a refresh is already in progress, wait for it
        final String newToken;
        if (_refreshCompleter != null) {
          newToken = await _refreshCompleter!.future;
        } else {
          _refreshCompleter = Completer<String>();
          try {
            newToken = await _authService.refreshToken();
            _refreshCompleter!.complete(newToken);
          } catch (e) {
            _refreshCompleter!.completeError(e);
            rethrow;
          } finally {
            _refreshCompleter = null;
          }
        }

        // Retry with new token (one attempt only)
        final options = err.requestOptions;
        options.headers[_authorizationHeader] = '$_bearerPrefix$newToken';
        options.extra['tokenRefreshed'] = true;

        final retryResponse = await _dio.request<dynamic>(
          options.path,
          data: options.data,
          queryParameters: options.queryParameters,
          options: Options(
            method: options.method,
            headers: options.headers,
            responseType: options.responseType,
            contentType: options.contentType,
            extra: options.extra,
          ),
        );
        return handler.resolve(retryResponse);
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }
}
