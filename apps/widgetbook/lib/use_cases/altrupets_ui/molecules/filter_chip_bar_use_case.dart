import 'package:altrupets_ui/altrupets_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: FilterChipBar,
  path: 'altrupets_ui/[molecules]',
)
Widget buildFilterChipBarUseCase(BuildContext context) {
  return const _InteractiveFilterChipBar(
    labels: ['Todos', 'Perros', 'Gatos', 'Otros'],
  );
}

/// Wrapper con estado para que la selección responda al toque dentro
/// del story (el widget real delega la selección al padre).
class _InteractiveFilterChipBar extends StatefulWidget {
  final List<String> labels;

  const _InteractiveFilterChipBar({required this.labels});

  @override
  State<_InteractiveFilterChipBar> createState() =>
      _InteractiveFilterChipBarState();
}

class _InteractiveFilterChipBarState extends State<_InteractiveFilterChipBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FilterChipBar(
      labels: widget.labels,
      selectedIndex: _selectedIndex,
      onSelected: (index) => setState(() => _selectedIndex = index),
    );
  }
}
