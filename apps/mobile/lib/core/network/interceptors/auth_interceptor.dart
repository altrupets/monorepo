import 'package:dio/dio.dart';
import 'package:altrupets/core/storage/secure_storage_service.dart';

/// Authentication interceptor for HTTP requests
/// 
/// Automatically injects JWT token into request headers from secure storage
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  
  static const String _authorizationHeader = 'Authorization';
  static const String _bearerPrefix = 'Bearer ';
  static const String _keyAccessToken = 'auth_access_token';

  AuthInterceptor(this._secureStorage);

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
    // Backend should implement refresh token endpoint
    if (response?.statusCode == 401) {
      // TODO: Implement token refresh when backend supports it
      // For now, just clear the invalid token
      await _secureStorage.delete(key: _keyAccessToken);
    }
    
    // Handle 403 Forbidden - insufficient permissions
    // The UI should handle this by showing appropriate error message

    handler.next(err);
  }
}
