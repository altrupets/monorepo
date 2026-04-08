import 'package:flutter/material.dart';

/// AltruPets design tokens — colors, spacing, and typography constants.
abstract class AltruPetsTokens {
  // ─── Brand Colors ───
  static const Color primary = Color(0xFF094F72);
  static const Color primaryLight = Color(0xFF0D6E9E);
  static const Color primaryDark = Color(0xFF063A55);

  // ─── Surface Colors (dark theme) ───
  static const Color surfaceBackground = Color(0xFF080812);
  static const Color surfaceBase = Color(0xFF0A0A14);
  static const Color surfaceElevated = Color(0xFF0F0F1E);
  static const Color surfaceCard = Color(0xFF1A1A2E);
  static const Color surfaceContent = Color(0xFF12121E);
  static const Color surfaceBorder = Color(0xFF2A2A40);

  // ─── Status Colors ───
  static const Color success = Color(0xFF4CAF50);
  static const Color successBg = Color(0xFF0D2E1A);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningBg = Color(0xFF2E1A00);
  static const Color error = Color(0xFFEF5350);
  static const Color errorBg = Color(0xFF2E0D0D);
  static const Color info = Color(0xFF3B6FE0);
  static const Color infoBg = Color(0xFF1A2540);

  // ─── Text Colors ───
  static const Color textPrimary = Color(0xFFE0E0F0);
  static const Color textSecondary = Color(0xFF666680);
  static const Color textOnPrimary = Colors.white;

  // ─── Spacing ───
  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing6 = 6;
  static const double spacing8 = 8;
  static const double spacing10 = 10;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;

  // ─── Border Radius ───
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 10;
  static const double radiusXl = 12;
}
