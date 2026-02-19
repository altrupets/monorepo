import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Tipos de entidades soportadas para sync offline
enum SyncEntityType { profile, organization, rescue, donation }

/// Item genérico para la cola de sincronización
class GenericSyncQueueItem {
  factory GenericSyncQueueItem.fromMap(Map<String, dynamic> map) {
    return GenericSyncQueueItem(
      id: map['id'] as int,
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as String,
      operation: map['operation'] as String,
      payload: jsonDecode(map['payload'] as String) as Map<String, dynamic>,
      createdAtEpochMs: map['created_at_epoch_ms'] as int,
      retryCount: map['retry_count'] as int? ?? 0,
    );
  }
  const GenericSyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation, // 'create', 'update', 'delete'
    required this.payload,
    required this.createdAtEpochMs,
    this.retryCount = 0,
  });

  final int id;
  final String entityType;
  final String entityId;
  final String operation;
  final Map<String, dynamic> payload;
  final int createdAtEpochMs;
  final int retryCount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'payload': jsonEncode(payload),
      'created_at_epoch_ms': createdAtEpochMs,
      'retry_count': retryCount,
    };
  }
}

/// Store genérico para manejar la cola de sincronización offline
/// Soporta múltiples tipos de entidades: profile, organization, rescue, donation
class GenericSyncQueueStore {
  GenericSyncQueueStore._();

  static Database? _db;
  static bool _initFailed = false;
  static const String _tableName = 'generic_sync_queue';

  static Future<Database?> _database() async {
    if (_initFailed) return null;
    if (_db != null) return _db;

    try {
      final basePath = await getDatabasesPath();
      final dbPath = p.join(basePath, 'altrupets_generic_sync.db');
      _db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              entity_type TEXT NOT NULL,
              entity_id TEXT NOT NULL,
              operation TEXT NOT NULL,
              payload TEXT NOT NULL,
              created_at_epoch_ms INTEGER NOT NULL,
              retry_count INTEGER DEFAULT 0
            )
          ''');
          // Índice para búsquedas por tipo de entidad
          await db.execute('''
            CREATE INDEX idx_entity_type ON $_tableName (entity_type)
          ''');
        },
      );
      return _db;
    } catch (e) {
      debugPrint('[GenericSyncQueueStore] ⚠️ Database init failed: $e');
      _initFailed = true;
      return null;
    }
  }

  /// Encola una operación para sincronización
  static Future<void> enqueue({
    required SyncEntityType entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final db = await _database();
      if (db == null) return;

      await db.insert(_tableName, {
        'entity_type': entityType.name,
        'entity_id': entityId,
        'operation': operation,
        'payload': jsonEncode(payload),
        'created_at_epoch_ms': DateTime.now().millisecondsSinceEpoch,
        'retry_count': 0,
      });

      debugPrint(
        '[GenericSyncQueueStore] ✅ Enqueued: ${entityType.name} $operation for $entityId',
      );
    } catch (e) {
      debugPrint('[GenericSyncQueueStore] ⚠️ enqueue failed: $e');
    }
  }

  /// Obtiene todos los items pendientes, ordenados por fecha
  static Future<List<GenericSyncQueueItem>> all() async {
    try {
      final db = await _database();
      if (db == null) return [];

      final rows = await db.query(
        _tableName,
        orderBy: 'created_at_epoch_ms ASC',
      );
      return rows.map((row) => GenericSyncQueueItem.fromMap(row)).toList();
    } catch (e) {
      debugPrint('[GenericSyncQueueStore] ⚠️ all() failed: $e');
      return [];
    }
  }

  /// Obtiene items pendientes para un tipo de entidad específico
  static Future<List<GenericSyncQueueItem>> getByEntityType(
    SyncEntityType entityType,
  ) async {
    try {
      final db = await _database();
      if (db == null) return [];

      final rows = await db.query(
        _tableName,
        where: 'entity_type = ?',
        whereArgs: [entityType.name],
        orderBy: 'created_at_epoch_ms ASC',
      );
      return rows.map((row) => GenericSyncQueueItem.fromMap(row)).toList();
    } catch (e) {
      debugPrint('[GenericSyncQueueStore] ⚠️ getByEntityType failed: $e');
      return [];
    }
  }

  /// Obtiene el conteo total de items pendientes
  static Future<int> getPendingCount() async {
    try {
      final db = await _database();
      if (db == null) return 0;

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName',
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      debugPrint('[GenericSyncQueueStore] ⚠️ getPendingCount failed: $e');
      return 0;
    }
  }

  /// Elimina un item por su ID
  static Future<void> deleteById(int id) async {
    try {
      final db = await _database();
      if (db == null) return;

      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('[GenericSyncQueueStore] ⚠️ deleteById failed: $e');
    }
  }

  /// Incrementa el conteo de reintentos para un item
  static Future<void> incrementRetryCount(int id) async {
    try {
      final db = await _database();
      if (db == null) return;

      await db.rawUpdate(
        'UPDATE $_tableName SET retry_count = retry_count + 1 WHERE id = ?',
        [id],
      );
    } catch (e) {
      debugPrint('[GenericSyncQueueStore] ⚠️ incrementRetryCount failed: $e');
    }
  }

  /// Elimina items que han excedido el número máximo de reintentos
  static Future<void> clearFailed(int maxRetries) async {
    try {
      final db = await _database();
      if (db == null) return;

      await db.delete(
        _tableName,
        where: 'retry_count >= ?',
        whereArgs: [maxRetries],
      );
    } catch (e) {
      debugPrint('[GenericSyncQueueStore] ⚠️ clearFailed failed: $e');
    }
  }

  /// Limpia toda la cola
  static Future<void> clearAll() async {
    try {
      final db = await _database();
      if (db == null) return;

      await db.delete(_tableName);
    } catch (e) {
      debugPrint('[GenericSyncQueueStore] ⚠️ clearAll failed: $e');
    }
  }
}
