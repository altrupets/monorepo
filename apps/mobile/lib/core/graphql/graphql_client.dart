import 'package:graphql/client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:altrupets/core/utils/constants.dart';

class GraphQLClientService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static GraphQLClient? _client;

  static GraphQLClient getClient() {
    _client ??= _createClient();
    return _client!;
  }

  static GraphQLClient _createClient() {
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

    final link = authLink.concat(httpLink);

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
}
