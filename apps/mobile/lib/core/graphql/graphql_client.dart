import 'dart:async';

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

  static Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;

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
      defaultHeaders: {
        'Content-Type': 'application/json',
      },
    );

    final authLink = AuthLink(
      getToken: () async {
        final token = await _storage.read(key: _tokenKey);
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
    await _storage.write(key: _tokenKey, value: token);
    // Recrear cliente con nuevo token
    _client = _createClient();
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    // Recrear cliente sin token
    _client = _createClient();
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
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
}
