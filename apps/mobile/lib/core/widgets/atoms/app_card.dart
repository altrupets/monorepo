import 'package:flutter/material.dart';

/// Material 3 Card wrapper with consistent styling and optional tap behavior.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.elevation = 1,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 12,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
