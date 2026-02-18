import 'package:flutter/material.dart';
import 'package:altrupets/core/sync/sync_status_provider.dart';

/// Átomo: Indicador visual del estado de sincronización
/// Muestra solo un icono representativo del estado actual
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({required this.status, this.size = 20, super.key});

  final SyncStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    late final Color color;
    late final IconData icon;

    if (status.isSyncing) {
      color = colorScheme.primary;
      icon = Icons.sync;
    } else if (status.pendingCount > 0) {
      color = colorScheme.tertiary;
      icon = Icons.cloud_upload_outlined;
    } else {
      color = colorScheme.tertiary;
      icon = Icons.cloud_done_outlined;
    }

    if (status.isSyncing) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Icon(icon, color: color, size: size);
  }
}
