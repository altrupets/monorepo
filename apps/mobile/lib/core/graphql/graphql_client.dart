import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:altrupets/core/utils/constants.dart';
import 'package:altrupets/core/utils/network_utils.dart';

class GraphQLClientService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static GraphQLClient? _client;
  static final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();
  static bool _sessionExpiryHandlingInProgress = false;

  static Stream<void> get sessionExpiredStream =>
      _sessionExpiredController.stream;

  static GraphQLClient getClient() {
    _client ??= _createClient();
    return _client!;
  }

  static GraphQLClient _createClient() {
    final networkInfo = NetworkUtils.getDebugNetworkInfo(
      overrideUrl: AppConstants.baseUrl.isNotEmpty
          ? AppConstants.baseUrl
          : null,
    );
    debugPrint('');
    debugPrint(networkInfo.toString());
    debugPrint('');

    final errorLink = ErrorLink(
      onGraphQLError: (request, forward, response) {
        debugPrint(
          '[GraphQLClient] ⚠️ GraphQL Error: ${response.errors?.map((e) => e.message).join(', ')}',
        );
        final hasUnauthorizedError = (response.errors ?? const []).any((error) {
          final message = error.message.toLowerCase();
          return message.contains('unauthorized') ||
              message.contains('unauthenticated');
        });
        if (hasUnauthorizedError) {
          unawaited(_handleSessionExpired());
        }
        return null;
      },
      onException: (request, forward, exception) {
        debugPrint(
          '[GraphQLClient] ❌ Exception caught: ${exception.runtimeType}',
        );

        // Log detailed information about network errors
        if (exception is ServerException) {
          debugPrint(
            '[GraphQLClient]   └─ Status Code: ${exception.statusCode}',
          );
          if (exception.originalException != null) {
            debugPrint(
              '[GraphQLClient]   └─ Original: ${exception.originalException}',
            );
          }

          if (exception.statusCode == 401 || exception.statusCode == 403) {
            unawaited(_handleSessionExpired());
          }
        }

        // Check for SocketException in originalException
        final originalException = exception is ServerException
            ? exception.originalException
            : null;
        if (originalException != null) {
          debugPrint(
            '[GraphQLClient]   └─ Checking wrapped exception: ${originalException.runtimeType}',
          );
          if (originalException is SocketException) {
            debugPrint('[GraphQLClient]   └─ 🔌 SocketException detected!');
            debugPrint(
              '[GraphQLClient]      ├─ Message: ${originalException.message}',
            );
            debugPrint(
              '[GraphQLClient]      ├─ OS Error: ${originalException.osError}',
            );
            debugPrint(
              '[GraphQLClient]      ├─ Address: ${originalException.address}',
            );
            debugPrint(
              '[GraphQLClient]      └─ Port: ${originalException.port}',
            );
            debugPrint(
              '[GraphQLClient] 💡 Backend URL: ${NetworkUtils.getBackendUrl(overrideUrl: AppConstants.baseUrl.isNotEmpty ? AppConstants.baseUrl : null)}',
            );
            debugPrint(
              '[GraphQLClient] 💡 Tip: Verify backend is running and reachable',
            );
          } else if (originalException.toString().contains('SocketException') ||
              originalException.toString().contains('Connection refused')) {
            debugPrint(
              '[GraphQLClient]   └─ 🌐 Network error detected: ${originalException.toString().substring(0, originalException.toString().length > 200 ? 200 : originalException.toString().length)}',
            );
            debugPrint(
              '[GraphQLClient] 💡 Backend URL: ${NetworkUtils.getBackendUrl(overrideUrl: AppConstants.baseUrl.isNotEmpty ? AppConstants.baseUrl : null)}',
            );
          }
        }

        return null;
      },
    );

    final httpLink = HttpLink(
      NetworkUtils.getGraphQLEndpoint(
        baseUrl: NetworkUtils.getBackendUrl(
          overrideUrl: AppConstants.baseUrl.isNotEmpty
              ? AppConstants.baseUrl
              : null,
        ),
      ),
      defaultHeaders: {'Content-Type': 'application/json'},
    );

    final authLink = AuthLink(
      getToken: () async {
        debugPrint('[GraphQLClient] 🔑 Solicitando token para AuthLink...');
        final token = await getToken();
        debugPrint(
          '[GraphQLClient] 🔑 Token ${token != null ? 'encontrado (len: ${token.length})' : 'NO ENCONTRADO'}',
        );
        return token != null ? 'Bearer $token' : null;
      },
    );

    final link = errorLink.concat(authLink.concat(httpLink));

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  static Future<void> saveToken(String token, {String? refreshToken}) async {
    debugPrint('[GraphQLClient] 💾 Guardando token (len: ${token.length})...');
    await _storage.write(key: _tokenKey, value: token);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    debugPrint('[GraphQLClient] ✅ Token guardado exitosamente');
    // Recrear cliente con nuevo token
    _client = _createClient();
    debugPrint('[GraphQLClient] 🔄 Cliente GraphQL recreado con nuevo token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    // Recrear cliente sin token
    _client = _createClient();
  }

  static Future<String?> getToken() async {
    debugPrint('[GraphQLClient] 📖 Leyendo token desde storage...');
    final token = await _storage.read(key: _tokenKey);
    if (token == null) {
      debugPrint('[GraphQLClient] ⚠️ Token no encontrado en storage');
      return null;
    }
    debugPrint('[GraphQLClient] 📋 Token encontrado (len: ${token.length})');
    if (_isJwtExpired(token)) {
      debugPrint('[GraphQLClient] ⏰ Token expirado - limpiando');
      await clearToken();
      return null;
    }
    debugPrint('[GraphQLClient] ✅ Token válido');
    return token;
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<bool> hasActiveSession() async {
    final token = await getToken();
    return token != null;
  }

  static Future<Either<String, String>> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      return const Left('No refresh token available');
    }

    final client = getClient();
    const String mutation = r'''
      mutation RefreshToken($input: RefreshTokenInput!) {
        refreshToken(refreshTokenInput: $input) {
          access_token
          refresh_token
          expires_in
        }
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {'refresh_token': refreshToken},
          },
        ),
      );

      if (result.hasException) {
        return Left(result.exception.toString());
      }

      final data = result.data?['refreshToken'];
      if (data == null) {
        return const Left('Invalid refresh response');
      }

      final accessToken = data['access_token'] as String;
      final newRefreshToken = data['refresh_token'] as String;

      await saveToken(accessToken, refreshToken: newRefreshToken);
      return Right(accessToken);
    } catch (e) {
      return Left(e.toString());
    }
  }

  static Future<void> _handleSessionExpired() async {
    if (_sessionExpiryHandlingInProgress) {
      return;
    }
    _sessionExpiryHandlingInProgress = true;
    try {
      debugPrint('[GraphQLClient] ⏰ Sesión expirada - Intentando refrescar...');
      final result = await refreshToken();
      result.fold(
        (error) async {
          debugPrint(
            '[GraphQLClient] ❌ Error al refrescar: $error - Cerrando sesión',
          );
          await clearToken();
          _sessionExpiredController.add(null);
        },
        (newToken) {
          debugPrint('[GraphQLClient] ✅ Token refrescado exitosamente');
        },
      );
    } finally {
      _sessionExpiryHandlingInProgress = false;
    }
  }

  static bool _isJwtExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }
      final payloadRaw = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(payloadRaw));
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is! int) {
        return true;
      }
      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return nowSeconds >= exp;
    } catch (_) {
      return true;
    }
  }
}
