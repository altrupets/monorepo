import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/core/sync/sync_status_provider.dart';
import 'package:altrupets/core/widgets/atoms/sync_status_indicator.dart';

/// Organismo: Banner de estado de sincronización
/// Sección completa que muestra el estado actual y permite acciones
/// Se usa típicamente en la parte superior de una pantalla
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // No mostrar si todo está sincronizado
    if (syncStatus.pendingCount == 0 && !syncStatus.isSyncing) {
      return const SizedBox.shrink();
    }

    late final Color backgroundColor;
    late final Color foregroundColor;
    late final String message;
    String? actionText;
    VoidCallback? onAction;

    if (syncStatus.isSyncing) {
      backgroundColor = colorScheme.primaryContainer;
      foregroundColor = colorScheme.onPrimaryContainer;
      message = 'Sincronizando cambios...';
    } else if (syncStatus.pendingCount > 0) {
      backgroundColor = colorScheme.tertiaryContainer;
      foregroundColor = colorScheme.onTertiaryContainer;
      message = '${syncStatus.pendingCount} cambio(s) pendiente(s)';
      actionText = 'Sincronizar';
      onAction = () {
        // Forzar sincronización
        ref.read(syncStatusProvider.notifier).setSyncing(true);
      };
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: foregroundColor.withAlpha(50), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            SyncStatusIndicator(status: syncStatus, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (actionText != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: foregroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(actionText),
              ),
          ],
        ),
      ),
    );
  }
}
