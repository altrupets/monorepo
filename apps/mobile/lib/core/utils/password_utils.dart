import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class PasswordUtils {
  PasswordUtils._();

  // Password salt from build configuration (--dart-define)
  // TODO(2FA): Add 2FA verification code to hash in future
  // TODO(2FA): Consider moving to secure key storage or environment variable
  // TODO(2FA): Implement TOTP or SMS-based 2FA for donations/crowdfunding
  static String get _appSalt =>
      const String.fromEnvironment('PASSWORD_SALT', defaultValue: '');

  static bool get _debugPasswords =>
      const bool.fromEnvironment('DEBUG_PASSWORDS', defaultValue: false);

  static String hash(String password, String username) {
    if (_appSalt.isEmpty) {
      throw Exception(
        'PASSWORD_SALT not configured. Build with --dart-define=PASSWORD_SALT=...',
      );
    }

    if (_debugPasswords) {
      debugPrint('[PasswordUtils] Salt (full): $_appSalt');
      debugPrint('[PasswordUtils] Salt length: ${_appSalt.length}');
      debugPrint('[PasswordUtils] Password: $password');
      debugPrint('[PasswordUtils] Username: $username');
    }

    // Double hash: SHA256(SHA256(password) + PASSWORD_SALT + username)
    // First hash: SHA256(password) - reduces password visibility
    // Second hash: adds salt and username for uniqueness
    final firstHash = sha256.convert(utf8.encode(password)).toString();
    final combined = firstHash + _appSalt + username.toLowerCase();
    final secondHash = sha256.convert(utf8.encode(combined)).toString();
    return secondHash;
  }

  static bool verify(String password, String username, String storedHash) {
    final hashedInput = hash(password, username);
    return hashedInput == storedHash;
  }
}
