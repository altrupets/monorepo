import 'package:flutter/material.dart';
import 'package:shared_ui_core/shared_ui_core.dart';

/// AltruPets design tokens — colors, spacing, and typography constants.
///
/// Canonical visual values mirror `assets/style_dictionary/tokens.json`
/// (brand primary #094F72, Poppins/Lemon Milk/Inter families). The hardcoded
/// constants below are the visual source of truth and are used as fallbacks;
/// call [initialize] at startup to load the canonical `DesignTokenModel` via
/// [TokensReader] (same pattern as `vertivolatam_ui`'s `VertivoTokens`).
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

  // ─── Shared-core token model (optional, loaded at startup) ───
  static DesignTokenModel? _tokens;

  /// Load the canonical tokens via [TokensReader] (app-local first,
  /// package fallback). Visuals are unchanged: the bundled tokens.json
  /// carries the same values as the constants above.
  static Future<void> initialize() async {
    _tokens ??= await TokensReader.load([
      'assets/style_dictionary/tokens.json',
      'packages/altrupets_ui/assets/style_dictionary/tokens.json',
    ]);
  }

  /// Override for tests / previews.
  @visibleForTesting
  static void debugSetTokens(DesignTokenModel tokens) => _tokens = tokens;

  /// The loaded token model. Throws if [initialize] was not awaited.
  static DesignTokenModel get tokens {
    final t = _tokens;
    if (t == null) {
      throw StateError('AltruPetsTokens.initialize() must be awaited first');
    }
    return t;
  }

  static bool get isLoaded => _tokens != null;

  /// Token-backed brand primary (falls back to [primary] before init).
  static Color get brandPrimary => _tokens?.brand.primary ?? primary;

  /// Token-backed primary font family (falls back to 'Poppins').
  static String get primaryFamily =>
      _tokens?.typography.primaryFamily ?? 'Poppins';

  /// Token-backed header font family (falls back to 'Lemon Milk').
  static String get headerFamily =>
      _tokens?.typography.headerFamily ?? 'Lemon Milk';
}
