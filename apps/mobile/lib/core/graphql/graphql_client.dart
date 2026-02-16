import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:altrupets/core/utils/constants.dart';

class GraphQLClientService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
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
    final errorLink = ErrorLink(
      onGraphQLError: (request, forward, response) {
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
        if (exception is ServerException &&
            (exception.statusCode == 401 || exception.statusCode == 403)) {
          unawaited(_handleSessionExpired());
        }
        return null;
      },
    );

    final httpLink = HttpLink(
      '${AppConstants.baseUrl}/graphql',
      defaultHeaders: {'Content-Type': 'application/json'},
    );

    final authLink = AuthLink(
      getToken: () async {
        debugPrint('[GraphQLClient] 🔑 Solicitando token para AuthLink...');
        final token = await getToken();
        debugPrint('[GraphQLClient] 🔑 Token ${token != null ? 'encontrado (len: ${token.length})' : 'NO ENCONTRADO'}');
        return token != null ? 'Bearer $token' : null;
      },
    );

    final link = errorLink.concat(authLink.concat(httpLink));

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  static Future<void> saveToken(String token) async {
    debugPrint('[GraphQLClient] 💾 Guardando token (len: ${token.length})...');
    await _storage.write(key: _tokenKey, value: token);
    debugPrint('[GraphQLClient] ✅ Token guardado exitosamente');
    // Recrear cliente con nuevo token
    _client = _createClient();
    debugPrint('[GraphQLClient] 🔄 Cliente GraphQL recreado con nuevo token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
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

  static Future<bool> hasActiveSession() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> _handleSessionExpired() async {
    if (_sessionExpiryHandlingInProgress) {
      return;
    }
    _sessionExpiryHandlingInProgress = true;
    try {
      await clearToken();
      _sessionExpiredController.add(null);
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
