import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altrupets/core/theme/app_theme.dart';
import 'package:altrupets/core/theme/theme_provider.dart';
import 'package:altrupets/features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-inicializar SharedPreferences para el tema
  // Esto asegura que esté disponible cuando se construya el app
  await SharedPreferences.getInstance();

  runApp(const ProviderScope(child: AltruPetsApp()));
}

class AltruPetsApp extends ConsumerWidget {
  const AltruPetsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(sharedPreferencesProvider);

    // Usar system como default mientras carga
    final themeMode = themeModeAsync.when(
      data: (prefs) {
        final savedTheme = prefs.getString('app_theme_mode');
        if (savedTheme == null) return ThemeMode.system;
        switch (savedTheme) {
          case 'light':
            return ThemeMode.light;
          case 'dark':
            return ThemeMode.dark;
          default:
            return ThemeMode.system;
        }
      },
      loading: () => ThemeMode.system,
      error: (_, _) => ThemeMode.system,
    );

    return MaterialApp(
      title: 'AltruPets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('es', '')],
      home: const HomePage(),
    );
  }
}
