import 'package:flutter/material.dart';
import 'package:altrupets/core/widgets/atoms/app_empty_state.dart';

/// Rich empty state organism with optional illustration and retry action.
///
/// Wraps [AppEmptyState] atom in a centered, padded layout and adds
/// an optional illustration widget above the icon and a secondary
/// "Reintentar" button when [onAction] is provided.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.icon,
    required this.title,
    super.key,
    this.message,
    this.actionLabel,
    this.onAction,
    this.illustration,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null) ...[
              illustration!,
              const SizedBox(height: 24),
            ],
            AppEmptyState(
              icon: icon,
              title: title,
              message: message,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onAction,
                child: Text(
                  actionLabel ?? 'Reintentar',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
