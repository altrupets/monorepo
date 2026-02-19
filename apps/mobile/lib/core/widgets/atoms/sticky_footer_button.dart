import 'package:flutter/material.dart';
import 'package:altrupets/core/theme/app_colors.dart';
import 'package:altrupets/core/theme/app_typography.dart';
import 'package:google_fonts/google_fonts.dart';

enum StickyFooterButtonType { primary, secondary }

class StickyFooterButton extends StatelessWidget {
  const StickyFooterButton({
    required this.label,
    required this.onTap,
    required this.type,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final StickyFooterButtonType type;
  final IconData? icon;

  bool get _isPrimary => type == StickyFooterButtonType.primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define colors based on type
    final backgroundColor = _isPrimary
        ? (isDark ? AppColorsDark.success : AppColors.success)
        : (isDark ? AppColorsDark.error : AppColors.error);

    final foregroundColor = _isPrimary
        ? (isDark ? AppColorsDark.onSuccess : AppColors.onSuccess)
        : (isDark ? AppColorsDark.onError : AppColors.onError);

    // Both now have solid backgrounds, so border can be transparent or match background
    const borderColor = Colors.transparent;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          // Reduced horizontal padding to prevent overflow
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: foregroundColor),
                const SizedBox(width: 4), // Reduced gap
              ],
              Flexible(
                // Added Flexible to handle text overflow gracefully
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.getFont(
                    AppTypography.uiFontFamily,
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14, // Slightly reduced font size
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
