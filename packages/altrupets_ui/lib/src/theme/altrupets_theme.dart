import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_ui_core/shared_ui_core.dart';
import 'altrupets_tokens.dart';

/// Builds the AltruPets dark theme used across all apps.
///
/// Colors and fonts intentionally match the previous hardcoded look; they now
/// resolve through [AltruPetsTokens] (backed by [DesignTokenModel] once
/// [AltruPetsTokens.initialize] is awaited, same values either way).
///
/// [backend] selects the render backend ([UiBackend.material] default,
/// [UiBackend.fluent] for a fluent_2 shell). The Material ThemeData below is
/// backend-agnostic: fluent hosts reuse the same tokens via their own style
/// mapping.
class AltruPetsTheme {
  static ThemeData dark({UiBackend? backend}) {
    final effective = backend ?? ChimeranextUi.backend;
    assert(
      effective == UiBackend.material || effective == UiBackend.fluent,
      'AltruPetsTheme supports material/fluent backends only',
    );
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
