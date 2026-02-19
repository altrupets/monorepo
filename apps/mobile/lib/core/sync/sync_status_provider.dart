import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/core/storage/app_prefs_store.dart';
import 'package:altrupets/core/sync/profile_update_queue_store.dart';
import 'package:altrupets/core/sync/generic_sync_queue_store.dart';

/// Modelo simple que representa el estado de sincronización
/// MVP: Solo muestra conteo de pendientes y estado de sincronización
class SyncStatus {
  const SyncStatus({
    required this.pendingCount,
    required this.lastSyncEpochMs,
    required this.isSyncing,
  });

  final int pendingCount;
  final int? lastSyncEpochMs;
  final bool isSyncing;

  SyncStatus copyWith({
    int? pendingCount,
    int? lastSyncEpochMs,
    bool? isSyncing,
  }) {
    return SyncStatus(
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncEpochMs: lastSyncEpochMs ?? this.lastSyncEpochMs,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  /// Retorna texto descriptivo del estado
  String get statusText {
    if (isSyncing) return 'Sincronizando...';
    if (pendingCount > 0) {
      return '$pendingCount cambio(s) pendiente(s)';
    }
    return 'Sincronizado';
  }

  /// Retorna el tiempo transcurrido desde la última sincronización
  String? get timeSinceLastSync {
    if (lastSyncEpochMs == null) return null;
    final lastSync = DateTime.fromMillisecondsSinceEpoch(lastSyncEpochMs!);
    final now = DateTime.now();
    final diff = now.difference(lastSync);

    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} d';
  }
}

/// Notifier simple que gestiona el estado de sincronización
/// MVP: Solo cuenta pendientes, sin lógica de conflictos compleja
class SyncStatusNotifier extends Notifier<SyncStatus> {
  @override
  SyncStatus build() {
    return const SyncStatus(
      pendingCount: 0,
      lastSyncEpochMs: null,
      isSyncing: false,
    );
  }

  /// Actualiza el conteo de cambios pendientes
  Future<void> refreshPendingCount() async {
    try {
      final profileUpdates = await ProfileUpdateQueueStore.all();
      final profileCount = profileUpdates.length;

      final genericCount = await GenericSyncQueueStore.getPendingCount();

      final totalCount = profileCount + genericCount;

      await AppPrefsStore.setPendingProfileUpdatesCount(profileCount);

      state = state.copyWith(pendingCount: totalCount);
    } catch (e) {
      debugPrint('[SyncStatusNotifier] ⚠️ Error refreshing pending count: $e');
    }
  }

  /// Marca que se está sincronizando
  void setSyncing(bool isSyncing) {
    state = state.copyWith(isSyncing: isSyncing);
  }

  /// Marca que la sincronización fue exitosa
  Future<void> markSynced() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await AppPrefsStore.setLastCurrentUserSyncNow();
    state = state.copyWith(
      pendingCount: 0,
      lastSyncEpochMs: now,
      isSyncing: false,
    );
  }
}

/// Provider del estado de sincronización
final syncStatusProvider = NotifierProvider<SyncStatusNotifier, SyncStatus>(
  SyncStatusNotifier.new,
);

/// Provider que expone solo el conteo de pendientes
final pendingSyncCountProvider = Provider<int>((ref) {
  return ref.watch(syncStatusProvider).pendingCount;
});

/// Provider que indica si hay cambios pendientes
final hasPendingChangesProvider = Provider<bool>((ref) {
  return ref.watch(syncStatusProvider).pendingCount > 0;
});
