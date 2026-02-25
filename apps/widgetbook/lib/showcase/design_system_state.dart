import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class DesignSystemManager extends ChangeNotifier {
  // Brand Colors
  Color primaryColor = const Color(0xFF094F72);
  Color secondaryColor = const Color(0xFFEA840B);
  Color accentColor = const Color(0xFF1370A6);
  Color warningColor = const Color(0xFFF4AE22);
  Color errorColor = const Color(0xFFE54C12);
  Color successColor = const Color(0xFF2E7D32);

  // Typography
  String headerFont = 'Lemon Milk';
  String bodyFont = 'Poppins';

  // Paths
  static const String rootPath = '/home/kvttvrsis/Documentos/GitHub/altrupets-monorepo';
  static const String tokensPath = '$rootPath/apps/mobile/assets/style_dictionary/tokens.json';
  static const String appColorsPath = '$rootPath/apps/mobile/lib/core/theme/app_colors.dart';
  static const String appTypographyPath = '$rootPath/apps/mobile/lib/core/theme/app_typography.dart';
  static const String appThemePath = '$rootPath/apps/mobile/lib/core/theme/app_theme.dart';
  static const String themeProviderPath = '$rootPath/apps/mobile/lib/core/theme/theme_provider.dart';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void updateColor(String key, Color color) {
    switch (key) {
      case 'primary': primaryColor = color; break;
      case 'secondary': secondaryColor = color; break;
      case 'accent': accentColor = color; break;
      case 'warning': warningColor = color; break;
      case 'error': errorColor = color; break;
      case 'success': successColor = color; break;
    }
    notifyListeners();
  }

  void updateFonts({String? header, String? body}) {
    if (header != null) headerFont = header;
    if (body != null) bodyFont = body;
    notifyListeners();
  }

  Future<void> loadTokens() async {
    if (kIsWeb) return;
    _isLoading = true;
    notifyListeners();

    try {
      final file = File(tokensPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);

        final colorData = json['color']['brand'];
        final typographyData = json['typography']['family'];

        primaryColor = _hexToColor(colorData['primary']['value']);
        secondaryColor = _hexToColor(colorData['secondary']['value']);
        accentColor = _hexToColor(colorData['accent']['value']);
        warningColor = _hexToColor(colorData['warning']['value']);
        errorColor = _hexToColor(colorData['error']['value']);
        successColor = _hexToColor(colorData['success']?['value'] ?? '#2E7D32');

        headerFont = typographyData['header']['value'];
        bodyFont = typographyData['primary']['value'];

        await applyTheme(skipSave: true); // Apply loaded values immediately
      }
    } catch (e) {
      debugPrint('Error loading tokens: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      await applyTheme();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveTokens() async {
    if (kIsWeb) return;

    try {
      final Map<String, dynamic> tokens = {
        "color": {
          "brand": {
            "primary": { "value": _toHex(primaryColor.toARGB32()), "type": "color" },
            "secondary": { "value": _toHex(secondaryColor.toARGB32()), "type": "color" },
            "accent": { "value": _toHex(accentColor.toARGB32()), "type": "color" },
            "warning": { "value": _toHex(warningColor.toARGB32()), "type": "color" },
            "error": { "value": _toHex(errorColor.toARGB32()), "type": "color" },
            "success": { "value": _toHex(successColor.toARGB32()), "type": "color" },
          },
          "palette": {
            // ignore: deprecated_member_use
            "primary": _paletteToMap(CorePalette.of(primaryColor.toARGB32()).primary),
            // ignore: deprecated_member_use
            "secondary": _paletteToMap(CorePalette.of(secondaryColor.toARGB32()).primary),
            // ignore: deprecated_member_use
            "accent": _paletteToMap(CorePalette.of(accentColor.toARGB32()).primary),
            // ignore: deprecated_member_use
            "warning": _paletteToMap(CorePalette.of(warningColor.toARGB32()).primary),
            // ignore: deprecated_member_use
            "error": _paletteToMap(CorePalette.of(errorColor.toARGB32()).primary),
            // ignore: deprecated_member_use
            "success": _paletteToMap(CorePalette.of(successColor.toARGB32()).primary),
            // ignore: deprecated_member_use
            "neutral": _paletteToMap(CorePalette.of(primaryColor.toARGB32()).neutral),
            // ignore: deprecated_member_use
            "neutralVariant": _paletteToMap(CorePalette.of(primaryColor.toARGB32()).neutralVariant),
          }
        },
        "typography": {
          "family": {
            "primary": { "value": bodyFont, "type": "fontFamily" },
            "header": { "value": headerFont, "type": "fontFamily" }
          }
        }
      };

      final file = File(tokensPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(tokens));
    } catch (e) {
      debugPrint('Error saving tokens: $e');
      rethrow;
    }
  }

  Future<void> applyTheme({bool skipSave = false}) async {
    if (kIsWeb) return;

    try {
      if (!skipSave) {
        // First, ensure tokens.json is up to date with current state
        await saveTokens();
      }

      await _updateAppColors();
      await _updateAppTypography();

      // Touch these files to trigger hot reload if needed
      await _touchFile(appThemePath);
      await _touchFile(themeProviderPath);

    } catch (e) {
      debugPrint('Error applying theme: $e');
      rethrow;
    }
  }

  Future<void> _updateAppColors() async {
    // We no longer regenerate AppColors as a static file.
    // The mobile app now uses a dynamic AppColors class that reads from the Singleton TokenService.
    debugPrint('AppColors regeneration skipped (using dynamic runtime loading)');
  }

  Future<void> _updateAppTypography() async {
    final bool isHeaderGoogle = !['Lemon Milk', 'Poppins'].contains(headerFont);
    final bool isBodyGoogle = !['Lemon Milk', 'Poppins'].contains(bodyFont);

    final String googleImport = (isHeaderGoogle || isBodyGoogle) ? "import 'package:google_fonts/google_fonts.dart';\n" : "";

    String getTextStyle(String font, bool isGoogle, String styleName, {double? letterSpacing}) {
      final String ls = letterSpacing != null ? ', letterSpacing: $letterSpacing' : '';
      if (isGoogle) {
        return "GoogleFonts.getFont('$font', textStyle: baseStyle.copyWith(fontSize: _getFontSize('$styleName'), fontWeight: _getFontWeight('$styleName'), height: _getLineHeight('$styleName')$ls))";
      } else {
        return "TextStyle(fontFamily: '$font', package: 'altrupets', fontSize: _getFontSize('$styleName'), fontWeight: _getFontWeight('$styleName'), color: baseColor, height: _getLineHeight('$styleName')$ls)";
      }
    }

    final String content = '''
import 'package:flutter/material.dart';
$googleImport
/// Tipografía del Design System de AltruPets
/// GENERADO AUTOMATICAMENTE DESDE EL SHOWCASE
class AppTypography {
  static TextTheme textTheme({bool isDark = false}) {
    final baseColor = isDark
        ? const Color(0xFFE6E1E5)
        : const Color(0xFF1C1B1F);

    final baseStyle = TextStyle(color: baseColor);

    return TextTheme(
      // Display Styles ($headerFont)
      displayLarge: ${getTextStyle(headerFont, isHeaderGoogle, 'displayLarge', letterSpacing: -0.25)},
      displayMedium: ${getTextStyle(headerFont, isHeaderGoogle, 'displayMedium')},
      displaySmall: ${getTextStyle(headerFont, isHeaderGoogle, 'displaySmall')},

      // Headline Styles ($headerFont)
      headlineLarge: ${getTextStyle(headerFont, isHeaderGoogle, 'headlineLarge')},
      headlineMedium: ${getTextStyle(headerFont, isHeaderGoogle, 'headlineMedium')},
      headlineSmall: ${getTextStyle(headerFont, isHeaderGoogle, 'headlineSmall')},

      // Title Styles ($bodyFont)
      titleLarge: ${getTextStyle(bodyFont, isBodyGoogle, 'titleLarge')},
      titleMedium: ${getTextStyle(bodyFont, isBodyGoogle, 'titleMedium', letterSpacing: 0.15)},
      titleSmall: ${getTextStyle(bodyFont, isBodyGoogle, 'titleSmall', letterSpacing: 0.1)},

      // Body Styles ($bodyFont)
      bodyLarge: ${getTextStyle(bodyFont, isBodyGoogle, 'bodyLarge', letterSpacing: 0.5)},
      bodyMedium: ${getTextStyle(bodyFont, isBodyGoogle, 'bodyMedium', letterSpacing: 0.25)},
      bodySmall: ${getTextStyle(bodyFont, isBodyGoogle, 'bodySmall', letterSpacing: 0.4)},

      // Label Styles ($bodyFont)
      labelLarge: ${getTextStyle(bodyFont, isBodyGoogle, 'labelLarge', letterSpacing: 0.1)},
      labelMedium: ${getTextStyle(bodyFont, isBodyGoogle, 'labelMedium', letterSpacing: 0.5)},
      labelSmall: ${getTextStyle(bodyFont, isBodyGoogle, 'labelSmall', letterSpacing: 0.5)},
    );
  }

  static double _getFontSize(String style) {
    switch (style) {
      case 'displayLarge': return 57;
      case 'displayMedium': return 45;
      case 'displaySmall': return 36;
      case 'headlineLarge': return 32;
      case 'headlineMedium': return 28;
      case 'headlineSmall': return 24;
      case 'titleLarge': return 22;
      case 'titleMedium': return 16;
      case 'titleSmall': return 14;
      case 'bodyLarge': return 16;
      case 'bodyMedium': return 14;
      case 'bodySmall': return 12;
      case 'labelLarge': return 14;
      case 'labelMedium': return 12;
      case 'labelSmall': return 11;
      default: return 14;
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
      case 'displayLarge': return 1.12;
      case 'displayMedium': return 1.16;
      case 'displaySmall': return 1.22;
      case 'headlineLarge': return 1.25;
      case 'headlineMedium': return 1.29;
      case 'headlineSmall': return 1.33;
      case 'titleLarge': return 1.27;
      case 'titleMedium': return 1.50;
      case 'titleSmall': return 1.43;
      case 'bodyLarge': return 1.50;
      case 'bodyMedium': return 1.43;
      case 'bodySmall': return 1.33;
      case 'labelLarge': return 1.43;
      case 'labelMedium': return 1.33;
      case 'labelSmall': return 1.45;
      default: return 1.4;
    }
  }
}
''';
    await File(appTypographyPath).writeAsString(content);
  }

  Future<void> _touchFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        await file.writeAsString(content);
      }
    } catch (_) {}
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', 'FF'), radix: 16));
  }

  String _toHex(int value) {
    return '#${Color(value).toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  Map<String, dynamic> _paletteToMap(TonalPalette palette) {
    final tones = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99, 100];
    final Map<String, dynamic> map = {};
    for (var tone in tones) {
      final color = Color(palette.get(tone));
      final hex = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      map[tone.toString()] = { "value": hex, "type": "color" };
    }
    return map;
  }
}
