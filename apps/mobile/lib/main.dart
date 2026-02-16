import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altrupets/core/theme/app_theme.dart';
import 'package:altrupets/core/theme/theme_provider.dart';
import 'package:altrupets/features/home/presentation/pages/home_page.dart';
import 'package:altrupets/core/providers/navigation_provider.dart';

import 'package:altrupets/core/theme/token_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar tokens de diseño desde assets
  await TokenService.initialize();

  // Configurar el estilo del sistema (barra de navegación opaca)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // Se verá el background del app si es edge-to-edge
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  // Forzar que el app dibuje detrás de las barras del sistema
  // Esto permite que el SafeArea maneje el padding correctamente
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Pre-inicializar SharedPreferences para el tema
  // Esto asegura que esté disponible cuando se construya el app
  await SharedPreferences.getInstance();

  runApp(const ProviderScope(child: AltruPetsApp()));
}


class AltruPetsApp extends ConsumerWidget {
  const AltruPetsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: ref.read(navigationProvider).navigatorKey,
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
