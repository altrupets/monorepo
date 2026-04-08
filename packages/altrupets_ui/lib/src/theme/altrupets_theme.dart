import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'altrupets_tokens.dart';

/// Builds the AltruPets dark theme used across all apps.
class AltruPetsTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AltruPetsTokens.surfaceBackground,
      colorScheme: const ColorScheme.dark(
        primary: AltruPetsTokens.primary,
        onPrimary: AltruPetsTokens.textOnPrimary,
        secondary: AltruPetsTokens.primaryLight,
        surface: AltruPetsTokens.surfaceCard,
        onSurface: AltruPetsTokens.textPrimary,
        error: AltruPetsTokens.error,
      ),
      cardColor: AltruPetsTokens.surfaceCard,
      dividerColor: AltruPetsTokens.surfaceBorder,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AltruPetsTokens.surfaceBase,
        foregroundColor: AltruPetsTokens.textPrimary,
        elevation: 0,
      ),
    );
  }
}
