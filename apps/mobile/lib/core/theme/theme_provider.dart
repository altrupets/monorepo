import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider de SharedPreferences (inicializado en main)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

/// Estado del tema de la aplicación
enum AppThemeMode {
  light,
  dark,
  system;

  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Notifier para gestión del tema con Riverpod
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.dark;
  }

  static const String _themeModeKey = 'app_theme_mode';
  SharedPreferences? _prefs;

  /// Inicializar con SharedPreferences
  void init(SharedPreferences prefs) {
    _prefs = prefs;
    _loadSavedTheme();
  }

  /// Exponer el estado de forma pública para el provider
  ThemeMode get themeMode => state;

  /// Cargar tema guardado
  void _loadSavedTheme() {
    if (_prefs == null) return;
    final savedTheme = _prefs!.getString(_themeModeKey);
    if (savedTheme != null) {
      state = _themeModeFromString(savedTheme);
    }
  }

  /// Cambiar tema y guardarlo
  Future<void> setThemeMode(AppThemeMode mode) async {
    final themeMode = mode.themeMode;
    await _prefs?.setString(_themeModeKey, mode.name);
    state = themeMode;
  }

  /// Obtener modo de tema actual
  AppThemeMode get currentAppThemeMode {
    switch (state) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
        return AppThemeMode.system;
    }
  }

  /// Convertir string a ThemeMode
  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

/// Provider que crea el ThemeNotifier
final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

/// Provider del ThemeMode actual (conveniencia)
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeNotifierProvider);
});
