import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Secure storage service for sensitive data
/// Wraps flutter_secure_storage with a clean interface
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Read a value from secure storage
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  /// Write a value to secure storage
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// Delete a value from secure storage
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// Delete all values from secure storage
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Check if a key exists in secure storage
  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  /// Read all values from secure storage
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}

/// Riverpod provider for SecureStorageService
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
