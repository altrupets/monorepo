import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/core/sync/sync_status_provider.dart';
import 'package:altrupets/core/widgets/atoms/sync_status_indicator.dart';

/// Molécula: Badge de sincronización con icono y texto
/// Combina el indicador visual con información textual del estado
class SyncBadge extends ConsumerWidget {
  const SyncBadge({
    super.key,
    this.showText = true,
    this.compact = false,
    this.onTap,
  });

  /// Si debe mostrar el texto descriptivo
  final bool showText;

  /// Modo compacto (solo icono con contador superpuesto)
  final bool compact;

  /// Callback al tocar el badge
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    late final Color color;
    if (syncStatus.isSyncing) {
      color = colorScheme.primary;
    } else if (syncStatus.pendingCount > 0) {
      color = colorScheme.tertiary;
    } else {
      color = colorScheme.tertiary;
    }

    if (compact) {
      return _buildCompact(context, syncStatus, color, textTheme);
    }

    return _buildFull(context, syncStatus, color, textTheme);
  }

  Widget _buildCompact(
    BuildContext context,
    SyncStatus status,
    Color color,
    TextTheme textTheme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: SyncStatusIndicator(status: status, size: 20),
          ),
          if (status.pendingCount > 0 && !status.isSyncing)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  status.pendingCount > 9 ? '9+' : '${status.pendingCount}',
                  style: textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFull(
    BuildContext context,
    SyncStatus status,
    Color color,
    TextTheme textTheme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SyncStatusIndicator(status: status, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status.statusText,
                    style: textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (status.timeSinceLastSync != null)
                    Text(
                      status.timeSinceLastSync!,
                      style: textTheme.labelSmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
