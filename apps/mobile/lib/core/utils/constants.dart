/// Constantes globales de la aplicación
class AppConstants {
  AppConstants._();

  // API - Usa IP de la laptop para conexión WiFi desde dispositivo móvil
  // Para desarrollo local (desktop): http://localhost:3001
  // Para dispositivo móvil vía WiFi: http://192.168.1.81:3001
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.81:3001',
  );
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 3);

  // Local Storage Keys
  static const String cachedSkillsKey = 'CACHED_SKILLS';

  // App Info
  static const String appName = 'Altrupets';
}
