import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class ProfileUpdateQueueItem {
  const ProfileUpdateQueueItem({
    required this.id,
    required this.payload,
    required this.createdAtEpochMs,
  });

  final int id;
  final Map<String, dynamic> payload;
  final int createdAtEpochMs;
}

class ProfileUpdateQueueStore {
  ProfileUpdateQueueStore._();

  static Database? _db;
  static bool _initFailed = false;
  static const String _tableName = 'pending_profile_updates';

  static Future<Database?> _database() async {
    if (_initFailed) {
      return null;
    }
    if (_db != null) {
      return _db;
    }
    try {
      final basePath = await getDatabasesPath();
      final dbPath = p.join(basePath, 'altrupets_sync_queue.db');
      _db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              payload TEXT NOT NULL,
              created_at_epoch_ms INTEGER NOT NULL
            )
          ''');
        },
      );
      return _db;
    } catch (e) {
      debugPrint('[ProfileUpdateQueueStore] ⚠️ Database init failed: $e');
      _initFailed = true;
      return null;
    }
  }

  static Future<void> enqueue(Map<String, dynamic> payload) async {
    try {
      final db = await _database();
      if (db == null) return;
      await db.insert(_tableName, {
        'payload': jsonEncode(payload),
        'created_at_epoch_ms': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('[ProfileUpdateQueueStore] ⚠️ enqueue failed: $e');
    }
  }

  static Future<List<ProfileUpdateQueueItem>> all() async {
    try {
      final db = await _database();
      if (db == null) return [];
      final rows = await db.query(_tableName, orderBy: 'id ASC');
      return rows.map((row) {
        return ProfileUpdateQueueItem(
          id: row['id'] as int,
          payload: jsonDecode(row['payload'] as String) as Map<String, dynamic>,
          createdAtEpochMs: row['created_at_epoch_ms'] as int,
        );
      }).toList();
    } catch (e) {
      debugPrint('[ProfileUpdateQueueStore] ⚠️ all() failed: $e');
      return [];
    }
  }

  static Future<void> deleteById(int id) async {
    try {
      final db = await _database();
      if (db == null) return;
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('[ProfileUpdateQueueStore] ⚠️ deleteById failed: $e');
    }
  }

  static Future<void> clearAll() async {
    try {
      final db = await _database();
      if (db == null) return;
      await db.delete(_tableName);
    } catch (e) {
      debugPrint('[ProfileUpdateQueueStore] ⚠️ clearAll failed: $e');
    }
  }
}
