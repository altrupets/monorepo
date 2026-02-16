import 'package:flutter/material.dart';

class AppInputCard extends StatelessWidget {
  const AppInputCard({
    required this.label,
    required this.initialValue,
    required this.hint,
    super.key,
    this.enabled = true,
    this.isDropdown = false,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String initialValue;
  final String hint;
  final bool enabled;
  final bool isDropdown;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      readOnly: isDropdown, // To prevent typing if it's strictly a dropdown trigger
      keyboardType: keyboardType,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: enabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
          ),
        ),
        suffixIcon: isDropdown 
            ? Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              )
            : null,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
