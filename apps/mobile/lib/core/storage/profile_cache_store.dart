import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:altrupets/features/auth/domain/entities/user.dart';

class ProfileCacheStore {
  ProfileCacheStore._();

  static const String _boxName = 'profile_cache_box';
  static const String _currentUserKey = 'current_user';

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
    _initialized = true;
  }

  static Future<void> saveCurrentUser(User user) async {
    await ensureInitialized();
    final box = Hive.box<String>(_boxName);
    await box.put(_currentUserKey, jsonEncode(user.toJson()));
  }

  static Future<User?> getCurrentUser() async {
    await ensureInitialized();
    final box = Hive.box<String>(_boxName);
    final raw = box.get(_currentUserKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearCurrentUser() async {
    await ensureInitialized();
    final box = Hive.box<String>(_boxName);
    await box.delete(_currentUserKey);
  }
}
