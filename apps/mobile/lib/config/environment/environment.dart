/// Environment configuration following 12-factor app principles
/// Configuration is externalized and environment-specific
abstract class Environment {
  /// GraphQL endpoint URL
  String get graphqlUrl;

  /// Environment name (development, staging, production)
  String get name;

  /// Whether debug logging is enabled
  bool get enableDebugLogging;

  /// Whether to use mock data
  bool get useMockData;

  /// Request timeout in seconds
  int get requestTimeoutSeconds;

  /// Maximum retry attempts for failed requests
  int get maxRetryAttempts;

  /// Firebase configuration
  FirebaseConfig get firebaseConfig;

  /// Geolocation configuration
  GeolocationConfig get geolocationConfig;

  /// Storage configuration
  StorageConfig get storageConfig;

  /// Onvo configuration
  OnvoConfig get onvoConfig;
}

/// Onvo configuration
class OnvoConfig {
  OnvoConfig({required this.apiKey, required this.sandbox});
  final String apiKey;
  final bool sandbox;
}

/// Firebase configuration
class FirebaseConfig {
  FirebaseConfig({
    required this.projectId,
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
  });
  final String projectId;
  final String apiKey;
  final String appId;
  final String messagingSenderId;
}

/// Geolocation configuration
class GeolocationConfig {
  GeolocationConfig({
    this.defaultSearchRadiusKm = 5.0,
    this.maxSearchRadiusKm = 50.0,
    this.minAccuracyMeters = 50.0,
  });

  /// Default search radius for nearby rescuers in kilometers
  final double defaultSearchRadiusKm;

  /// Maximum search radius in kilometers
  final double maxSearchRadiusKm;

  /// Minimum accuracy required for location in meters
  final double minAccuracyMeters;
}

/// Storage configuration
class StorageConfig {
  StorageConfig({
    this.maxCacheSizeMb = 100,
    this.cacheExpirationHours = 24,
    this.encryptSensitiveData = true,
  });

  /// Maximum cache size in MB
  final int maxCacheSizeMb;

  /// Cache expiration time in hours
  final int cacheExpirationHours;

  /// Whether to encrypt sensitive data
  final bool encryptSensitiveData;
}
