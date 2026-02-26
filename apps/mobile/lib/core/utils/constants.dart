/// Constantes globales de la aplicación
class AppConstants {
  AppConstants._();

  // API - Kubernetes Gateway via port-forward
  // Para desarrollo: http://192.168.1.81:3001
  // Para producción: cambiar a la URL del LoadBalancer
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.81:3001',
  );
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Local Storage Keys
  static const String cachedSkillsKey = 'CACHED_SKILLS';

  // App Info
  static const String appName = 'Altrupets';
}
