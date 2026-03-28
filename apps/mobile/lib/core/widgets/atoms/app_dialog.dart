import 'package:flutter/material.dart';

/// Material 3 AlertDialog wrapper for confirmations and destructive actions.
class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,
    required this.content,
    required this.confirmLabel,
    required this.onConfirm,
    super.key,
    this.cancelLabel,
    this.onCancel,
    this.isDestructive = false,
  });

  final String title;
  final Widget content;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  /// Shows the dialog using [showDialog].
  static Future<void> show({
    required BuildContext context,
    required String title,
    required Widget content,
    required String confirmLabel,
    required VoidCallback onConfirm,
    String? cancelLabel,
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        cancelLabel: cancelLabel,
        onCancel: onCancel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(title),
      content: content,
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Text(cancelLabel!),
          ),
        FilledButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
