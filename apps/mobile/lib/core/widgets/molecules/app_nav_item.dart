import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppNavItem extends StatelessWidget {
  const AppNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final color = isSelected
        ? theme.colorScheme.secondary
        : (isDark ? Colors.grey.shade500 : Colors.grey.shade400);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontWeight: FontWeight.normal,
                fontSize: 11,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
