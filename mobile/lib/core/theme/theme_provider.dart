import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider de SharedPreferences (inicializado en main)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
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
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeModeKey = 'app_theme_mode';
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadSavedTheme();
  }

  /// Cargar tema guardado
  void _loadSavedTheme() {
    final savedTheme = _prefs.getString(_themeModeKey);
    if (savedTheme != null) {
      state = _themeModeFromString(savedTheme);
    }
  }

  /// Cambiar tema y guardarlo
  Future<void> setThemeMode(AppThemeMode mode) async {
    final themeMode = mode.themeMode;
    await _prefs.setString(_themeModeKey, mode.name);
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

/// Provider que crea el ThemeNotifier cuando SharedPreferences está disponible
final themeNotifierInstanceProvider = FutureProvider<ThemeNotifier>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return ThemeNotifier(prefs);
});

/// Provider del ThemeMode actual (conveniencia)
/// Maneja el caso donde SharedPreferences aún no está disponible
final themeModeProvider = Provider<ThemeMode>((ref) {
  final notifierAsync = ref.watch(themeNotifierInstanceProvider);
  
  return notifierAsync.when(
    data: (notifier) => notifier.state,
    loading: () => ThemeMode.system, // Default mientras carga
    error: (_, __) => ThemeMode.system, // Default en caso de error
  );
});
