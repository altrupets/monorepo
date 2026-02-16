import 'dart:convert';

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
  static const String _tableName = 'pending_profile_updates';

  static Future<Database> _database() async {
    if (_db != null) {
      return _db!;
    }
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
    return _db!;
  }

  static Future<void> enqueue(Map<String, dynamic> payload) async {
    final db = await _database();
    await db.insert(_tableName, {
      'payload': jsonEncode(payload),
      'created_at_epoch_ms': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<List<ProfileUpdateQueueItem>> all() async {
    final db = await _database();
    final rows = await db.query(_tableName, orderBy: 'id ASC');
    return rows.map((row) {
      return ProfileUpdateQueueItem(
        id: row['id'] as int,
        payload: jsonDecode(row['payload'] as String) as Map<String, dynamic>,
        createdAtEpochMs: row['created_at_epoch_ms'] as int,
      );
    }).toList();
  }

  static Future<void> deleteById(int id) async {
    final db = await _database();
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearAll() async {
    final db = await _database();
    await db.delete(_tableName);
  }
}
