/// Constantes globales de la aplicación
class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'https://api.example.com';
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 3);

  // Local Storage Keys
  static const String cachedSkillsKey = 'CACHED_SKILLS';

  // App Info
  static const String appName = 'Altrupets';
}
