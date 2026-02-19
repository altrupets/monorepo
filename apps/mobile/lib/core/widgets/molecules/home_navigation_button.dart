import 'package:flutter/material.dart';
import 'package:altrupets/core/widgets/atoms/app_circular_button.dart';

class HomeNavigationButton extends StatelessWidget {
  const HomeNavigationButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Transform.translate(
      offset: const Offset(0, -24),
      child: AppCircularButton(
        icon: Icons.home_rounded,
        onTap: onTap,
        size: 56,
        iconSize: 30,
        backgroundColor: theme.colorScheme.secondary,
        // The user explicitly requested to avoid gradients for the Home button
        // AppCircularButton allows gradient=null, so we just don't pass it (or ensure it's null).
        // Shadow is kept for depth, consistent with previous design but using the new saturated color.
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
