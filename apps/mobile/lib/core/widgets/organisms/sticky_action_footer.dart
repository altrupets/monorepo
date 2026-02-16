import 'package:flutter/material.dart';
import 'package:altrupets/core/widgets/atoms/sticky_footer_button.dart';

class StickyActionFooter extends StatelessWidget {
  const StickyActionFooter({
    required this.onCancel,
    required this.onSave,
    super.key,
    this.cancelLabel = 'Cancelar',
    this.saveLabel = 'Guardar Cambios',
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String cancelLabel;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        backgroundBlendMode: BlendMode.srcOver,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: StickyFooterButton(
              label: cancelLabel,
              onTap: onCancel,
              type: StickyFooterButtonType.secondary,
              icon: Icons.close_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: StickyFooterButton(
              label: saveLabel,
              onTap: onSave,
              type: StickyFooterButtonType.primary,
              icon: Icons.check_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
