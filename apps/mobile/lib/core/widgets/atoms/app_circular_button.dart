import 'package:flutter/material.dart';

class AppCircularButton extends StatelessWidget {
  const AppCircularButton({
    required this.icon,
    required this.onTap,
    super.key,
    this.size = 56,
    this.backgroundColor,
    this.iconColor = Colors.white,
    this.iconSize = 24,
    this.gradient,
    this.boxShadow,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? backgroundColor;
  final Color iconColor;
  final double iconSize;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: gradient == null
              ? (backgroundColor ?? Theme.of(context).colorScheme.secondary)
              : null,
          gradient: gradient,
          shape: BoxShape.circle,
          boxShadow: boxShadow,
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
