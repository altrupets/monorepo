import 'package:flutter/material.dart';

/// TabBar + TabBarView wrapper molecule.
///
/// Wraps [DefaultTabController] around a Column containing a styled
/// [TabBar] and an [Expanded] [TabBarView].
class AppTabs extends StatelessWidget {
  const AppTabs({
    required this.tabs,
    required this.children,
    super.key,
    this.initialIndex = 0,
    this.onChanged,
  }) : assert(
          tabs.length == children.length,
          'tabs and children must have the same length',
        );

  final List<String> tabs;
  final List<Widget> children;
  final int initialIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex,
      child: Column(
        children: [
          TabBar(
            onTap: onChanged,
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.onSurface,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            tabs: [for (final label in tabs) Tab(text: label)],
          ),
          Expanded(
            child: TabBarView(children: children),
          ),
        ],
      ),
    );
  }
}
