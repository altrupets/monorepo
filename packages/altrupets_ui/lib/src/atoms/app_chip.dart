import 'package:flutter/material.dart';
import '../theme/altrupets_tokens.dart';

/// A small status badge / chip with background and text color.
class AppChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const AppChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AltruPetsTokens.spacing8,
        vertical: AltruPetsTokens.spacing2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AltruPetsTokens.surfaceCard,
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: textColor ?? AltruPetsTokens.textSecondary,
        ),
      ),
    );
  }
}
