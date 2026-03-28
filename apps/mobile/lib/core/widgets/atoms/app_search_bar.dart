import 'package:flutter/material.dart';

/// Material 3 SearchBar with consistent theming.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    required this.hintText,
    required this.onChanged,
    super.key,
    this.onSubmitted,
    this.controller,
    this.leading,
    this.trailing,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final Widget? leading;
  final List<Widget>? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SearchBar(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      leading: leading ?? Icon(Icons.search, color: colorScheme.onSurfaceVariant),
      trailing: trailing,
      backgroundColor: WidgetStatePropertyAll<Color>(
        colorScheme.surfaceContainerHighest,
      ),
      elevation: const WidgetStatePropertyAll<double>(0),
    );
  }
}
