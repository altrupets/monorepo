import 'package:flutter/material.dart';

/// Variant modes for [AppChip].
enum AppChipVariant { filter, input, suggestion }

/// Generic chip that renders as FilterChip, InputChip, or SuggestionChip
/// based on the selected [variant].
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    super.key,
    this.selected = false,
    this.onSelected,
    this.icon,
    this.onDeleted,
    this.variant = AppChipVariant.filter,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;
  final VoidCallback? onDeleted;
  final AppChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatar = icon != null ? Icon(icon, size: 18) : null;

    switch (variant) {
      case AppChipVariant.filter:
        return FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: onSelected,
          avatar: avatar,
          selectedColor: colorScheme.primaryContainer,
          checkmarkColor: colorScheme.onPrimaryContainer,
        );
      case AppChipVariant.input:
        return InputChip(
          label: Text(label),
          selected: selected,
          onSelected: onSelected,
          avatar: avatar,
          onDeleted: onDeleted,
          selectedColor: colorScheme.primaryContainer,
        );
      case AppChipVariant.suggestion:
        return ActionChip(
          label: Text(label),
          onPressed: onSelected != null ? () => onSelected!(!selected) : null,
          avatar: avatar,
        );
    }
  }
}
