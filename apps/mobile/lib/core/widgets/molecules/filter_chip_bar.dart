import 'package:flutter/material.dart';
import 'package:altrupets/core/widgets/atoms/app_chip.dart';

/// Horizontal scrollable row of [AppChip] atoms in filter variant.
///
/// Supports both multi-select and single-select modes via [singleSelect].
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    required this.options,
    required this.selected,
    required this.onSelectionChanged,
    super.key,
    this.singleSelect = false,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onSelectionChanged;
  final bool singleSelect;

  void _onChipSelected(String option, bool isSelected) {
    final updated = Set<String>.of(selected);

    if (singleSelect) {
      updated.clear();
      if (isSelected) {
        updated.add(option);
      }
    } else {
      if (isSelected) {
        updated.add(option);
      } else {
        updated.remove(option);
      }
    }

    onSelectionChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            AppChip(
              label: options[i],
              selected: selected.contains(options[i]),
              onSelected: (isSelected) =>
                  _onChipSelected(options[i], isSelected),
              variant: AppChipVariant.filter,
            ),
          ],
        ],
      ),
    );
  }
}
