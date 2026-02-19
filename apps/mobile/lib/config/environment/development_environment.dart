import 'package:altrupets/config/environment/environment.dart';

/// Development environment configuration
/// Used for local development with mock/staging backend
class DevelopmentEnvironment implements Environment {
  @override
  String get graphqlUrl => 'http://localhost:3000/graphql';

  @override
  String get name => 'development';

  @override
  bool get enableDebugLogging => true;

  @override
  bool get useMockData => false;

  @override
  int get requestTimeoutSeconds => 30;

  @override
  int get maxRetryAttempts => 3;

  @override
  FirebaseConfig get firebaseConfig => FirebaseConfig(
    projectId: 'altrupets-dev',
    apiKey: 'AIzaSyDevelopmentKey',
    appId: '1:123456789:android:abcdef123456',
    messagingSenderId: '123456789',
  );

  @override
  GeolocationConfig get geolocationConfig => GeolocationConfig(
    defaultSearchRadiusKm: 5.0,
    maxSearchRadiusKm: 50.0,
    minAccuracyMeters: 50.0,
  );

  @override
  StorageConfig get storageConfig => StorageConfig(
    maxCacheSizeMb: 100,
    cacheExpirationHours: 24,
    encryptSensitiveData: false, // Disabled for easier debugging
  );
}
