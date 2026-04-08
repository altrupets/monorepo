import 'package:flutter/material.dart';
import '../theme/altrupets_tokens.dart';

/// A themed card widget with AltruPets dark surface styling.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AltruPetsTokens.surfaceCard,
      borderRadius: BorderRadius.circular(AltruPetsTokens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusLg),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AltruPetsTokens.spacing12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AltruPetsTokens.radiusLg),
            border: Border.all(
              color: borderColor ?? AltruPetsTokens.surfaceBorder,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
