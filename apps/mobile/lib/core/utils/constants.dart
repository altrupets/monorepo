/// Constantes globales de la aplicación
class AppConstants {
  AppConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Local Storage Keys
  static const String cachedSkillsKey = 'CACHED_SKILLS';

  // App Info
  static const String appName = 'Altrupets';
}
