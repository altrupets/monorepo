import 'package:flutter/material.dart';

class AppAccentBar extends StatelessWidget {
  const AppAccentBar({
    super.key,
    this.color = const Color(0xFF2B8CEE),
    this.width = 4,
    this.height = 18,
  });

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
