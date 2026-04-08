import 'package:flutter/material.dart';
import '../theme/altrupets_tokens.dart';

/// A horizontal bar of selectable filter chips.
class FilterChipBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const FilterChipBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AltruPetsTokens.surfaceBorder),
        ),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = i == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: AltruPetsTokens.spacing16),
            child: InkWell(
              onTap: () => onSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AltruPetsTokens.spacing6,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive
                          ? AltruPetsTokens.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive
                        ? AltruPetsTokens.textOnPrimary
                        : AltruPetsTokens.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
