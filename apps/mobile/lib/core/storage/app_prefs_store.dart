import 'package:shared_preferences/shared_preferences.dart';

class AppPrefsStore {
  AppPrefsStore._();

  static const String _lastCurrentUserSyncKey =
      'last_current_user_sync_epoch_ms';
  static const String _pendingProfileUpdatesKey =
      'pending_profile_updates_count';

  static Future<void> setLastCurrentUserSyncNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastCurrentUserSyncKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<int?> getLastCurrentUserSyncEpochMs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastCurrentUserSyncKey);
  }

  static Future<void> setPendingProfileUpdatesCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pendingProfileUpdatesKey, count);
  }

  static Future<int> getPendingProfileUpdatesCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pendingProfileUpdatesKey) ?? 0;
  }
}
