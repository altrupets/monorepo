import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altrupets/core/theme/app_theme.dart';
import 'package:altrupets/core/theme/theme_provider.dart';
import 'package:altrupets/features/home/presentation/pages/home_page.dart';
import 'package:altrupets/core/providers/navigation_provider.dart';
import 'package:altrupets/features/auth/presentation/pages/login_page.dart';
import 'package:altrupets/features/auth/presentation/providers/auth_provider.dart';
import 'package:altrupets/core/storage/profile_cache_store.dart';
import 'package:altrupets/core/error/error_logging_observer.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';

import 'package:altrupets/core/theme/token_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:altrupets/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[Firebase] ✅ Initialized successfully');
  } catch (e) {
    debugPrint('[Firebase] ⚠️ Error initializing: $e');
  }

  // Configurar icono de ventana para desktop
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const WindowOptions windowOptions = WindowOptions(
      title: 'AltruPets',
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Configurar manejador de errores global de Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FlutterError] ❌ ${details.exception}');
    debugPrint('[FlutterError] 📍 ${details.stack}');

    // Detectar errores de red específicos
    final errorStr = details.exception.toString();
    if (errorStr.contains('SocketException') ||
        errorStr.contains('Connection refused')) {
      debugPrint('[FlutterError] 🔌 Network error detected!');
    }
  };

  // Inicializar tokens de diseño desde assets
  await TokenService.initialize();

  // Configurar el estilo del sistema (barra de navegación opaca)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors
          .transparent, // Se verá el background del app si es edge-to-edge
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );

  // Forzar que el app dibuje detrás de las barras del sistema
  // Esto permite que el SafeArea maneje el padding correctamente
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Pre-inicializar SharedPreferences para el tema
  // Esto asegura que esté disponible cuando se construya el app
  await SharedPreferences.getInstance();
  await ProfileCacheStore.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://2ea2fcc86c52bb528987c448c3c2a1bc@o4510946376876032.ingest.us.sentry.io/4510946378579968';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      // ignore: experimental_member_use
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: ProviderScope(
          observers: [ErrorLoggingObserver()],
          child: const AltruPetsApp(),
        ),
      ),
    ),
  );
}

class AltruPetsApp extends ConsumerStatefulWidget {
  const AltruPetsApp({super.key});

  @override
  ConsumerState<AltruPetsApp> createState() => _AltruPetsAppState();
}

class _AltruPetsAppState extends ConsumerState<AltruPetsApp> {
  bool _launchedPrinted = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isAuthenticatedAsync = ref.watch(isAuthenticatedProvider);
    final navigation = ref.read(navigationProvider);

    ref.listen<AsyncValue<void>>(sessionExpiredProvider, (previous, next) {
      next.whenData((_) async {
        await ref.read(authProvider.notifier).logout();
        navigation.navigateAndRemoveAllGlobal(const LoginPage());
      });
    });

    if (!_launchedPrinted) {
      _launchedPrinted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('🚀 Launched successfully!');
      });
    }

    return MaterialApp(
      navigatorKey: navigation.navigatorKey,
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
      home: isAuthenticatedAsync.when(
        data: (isAuthenticated) =>
            isAuthenticated ? const HomePage() : const LoginPage(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) => const LoginPage(),
      ),
    );
  }
}
