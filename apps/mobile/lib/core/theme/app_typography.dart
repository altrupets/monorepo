import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:altrupets/core/theme/token_service.dart';

/// Tipografía del Design System de AltruPets
/// GENERADO AUTOMATICAMENTE DESDE EL SHOWCASE
class AppTypography {
  static String get headerFontFamily =>
      TokenService.instance.tokens.typography.headerFamily;
  static String get bodyFontFamily =>
      TokenService.instance.tokens.typography.primaryFamily;
  static String get uiFontFamily =>
      TokenService.instance.tokens.typography.tertiaryFamily;

  static TextTheme textTheme({bool isDark = false}) {
    final baseColor = isDark
        ? const Color(0xFFE6E1E5)
        : const Color(0xFF1C1B1F);

    final baseStyle = TextStyle(color: baseColor);

    return TextTheme(
      displayLarge: _getStyle(
        headerFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('displayLarge'),
          fontWeight: _getFontWeight('displayLarge'),
          height: _getLineHeight('displayLarge'),
          letterSpacing: -0.25,
        ),
      ),
      displayMedium: _getStyle(
        headerFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('displayMedium'),
          fontWeight: _getFontWeight('displayMedium'),
          height: _getLineHeight('displayMedium'),
        ),
      ),
      displaySmall: _getStyle(
        headerFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('displaySmall'),
          fontWeight: _getFontWeight('displaySmall'),
          height: _getLineHeight('displaySmall'),
        ),
      ),
      headlineLarge: _getStyle(
        headerFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('headlineLarge'),
          fontWeight: _getFontWeight('headlineLarge'),
          height: _getLineHeight('headlineLarge'),
        ),
      ),
      headlineMedium: _getStyle(
        headerFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('headlineMedium'),
          fontWeight: _getFontWeight('headlineMedium'),
          height: _getLineHeight('headlineMedium'),
        ),
      ),
      headlineSmall: _getStyle(
        headerFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('headlineSmall'),
          fontWeight: _getFontWeight('headlineSmall'),
          height: _getLineHeight('headlineSmall'),
        ),
      ),
      titleLarge: _getStyle(
        bodyFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('titleLarge'),
          fontWeight: _getFontWeight('titleLarge'),
          height: _getLineHeight('titleLarge'),
        ),
      ),
      titleMedium: _getStyle(
        bodyFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('titleMedium'),
          fontWeight: _getFontWeight('titleMedium'),
          height: _getLineHeight('titleMedium'),
          letterSpacing: 0.15,
        ),
      ),
      titleSmall: _getStyle(
        bodyFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('titleSmall'),
          fontWeight: _getFontWeight('titleSmall'),
          height: _getLineHeight('titleSmall'),
          letterSpacing: 0.1,
        ),
      ),
      bodyLarge: _getStyle(
        bodyFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('bodyLarge'),
          fontWeight: _getFontWeight('bodyLarge'),
          height: _getLineHeight('bodyLarge'),
          letterSpacing: 0.5,
        ),
      ),
      bodyMedium: _getStyle(
        bodyFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('bodyMedium'),
          fontWeight: _getFontWeight('bodyMedium'),
          height: _getLineHeight('bodyMedium'),
          letterSpacing: 0.25,
        ),
      ),
      bodySmall: _getStyle(
        bodyFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('bodySmall'),
          fontWeight: _getFontWeight('bodySmall'),
          height: _getLineHeight('bodySmall'),
          letterSpacing: 0.4,
        ),
      ),
      labelLarge: _getStyle(
        bodyFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('labelLarge'),
          fontWeight: _getFontWeight('labelLarge'),
          height: _getLineHeight('labelLarge'),
          letterSpacing: 0.1,
        ),
      ),
      labelMedium: _getStyle(
        bodyFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('labelMedium'),
          fontWeight: _getFontWeight('labelMedium'),
          height: _getLineHeight('labelMedium'),
          letterSpacing: 0.5,
        ),
      ),
      labelSmall: _getStyle(
        bodyFontFamily,
        baseStyle.copyWith(
          fontSize: _getFontSize('labelSmall'),
          fontWeight: _getFontWeight('labelSmall'),
          height: _getLineHeight('labelSmall'),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static TextStyle _getStyle(String fontFamily, TextStyle textStyle) {
    if (['Lemon Milk', 'Poppins'].contains(fontFamily)) {
      return textStyle.copyWith(
        fontFamily: fontFamily,
        package: TokenService.instance.isExternal ? 'altrupets' : null,
      );
    }
    return GoogleFonts.getFont(fontFamily, textStyle: textStyle);
  }

  static double _getFontSize(String style) {
    switch (style) {
      case 'displayLarge':
        return 57;
      case 'displayMedium':
        return 45;
      case 'displaySmall':
        return 36;
      case 'headlineLarge':
        return 32;
      case 'headlineMedium':
        return 28;
      case 'headlineSmall':
        return 24;
      case 'titleLarge':
        return 22;
      case 'titleMedium':
        return 16;
      case 'titleSmall':
        return 14;
      case 'bodyLarge':
        return 16;
      case 'bodyMedium':
        return 14;
      case 'bodySmall':
        return 12;
      case 'labelLarge':
        return 14;
      case 'labelMedium':
        return 12;
      case 'labelSmall':
        return 11;
      default:
        return 14;
    }
  }

  static FontWeight _getFontWeight(String style) {
    switch (style) {
      case 'titleMedium':
      case 'titleSmall':
      case 'labelLarge':
      case 'labelMedium':
      case 'labelSmall':
        return FontWeight.w500;
      default:
        return FontWeight.w400;
    }
  }

  static double _getLineHeight(String style) {
    switch (style) {
      case 'displayLarge':
        return 1.12;
      case 'displayMedium':
        return 1.16;
      case 'displaySmall':
        return 1.22;
      case 'headlineLarge':
        return 1.25;
      case 'headlineMedium':
        return 1.29;
      case 'headlineSmall':
        return 1.33;
      case 'titleLarge':
        return 1.27;
      case 'titleMedium':
        return 1.50;
      case 'titleSmall':
        return 1.43;
      case 'bodyLarge':
        return 1.50;
      case 'bodyMedium':
        return 1.43;
      case 'bodySmall':
        return 1.33;
      case 'labelLarge':
        return 1.43;
      case 'labelMedium':
        return 1.33;
      case 'labelSmall':
        return 1.45;
      default:
        return 1.4;
    }
  }
}
