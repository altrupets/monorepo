import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Environment configuration
class Environment {
  final String name;
  final String apiBaseUrl;
  final int requestTimeoutSeconds;
  final bool enableLogging;

  const Environment({
    required this.name,
    required this.apiBaseUrl,
    this.requestTimeoutSeconds = 30,
    this.enableLogging = true,
  });
}

/// Environment manager for managing app environments
class EnvironmentManager {
  final Environment currentEnvironment;

  EnvironmentManager({required this.currentEnvironment});

  /// Development environment
  static const development = Environment(
    name: 'development',
    apiBaseUrl: 'http://localhost:3000',
    requestTimeoutSeconds: 30,
    enableLogging: true,
  );

  /// Staging environment
  static const staging = Environment(
    name: 'staging',
    apiBaseUrl: 'https://staging-api.altrupets.com',
    requestTimeoutSeconds: 30,
    enableLogging: true,
  );

  /// Production environment
  static const production = Environment(
    name: 'production',
    apiBaseUrl: 'https://api.altrupets.com',
    requestTimeoutSeconds: 30,
    enableLogging: false,
  );
}

/// Riverpod provider for EnvironmentManager
/// Default to development environment
final environmentManagerProvider = Provider<EnvironmentManager>((ref) {
  return EnvironmentManager(
    currentEnvironment: EnvironmentManager.development,
  );
});
