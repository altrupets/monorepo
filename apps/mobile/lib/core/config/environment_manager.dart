import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Environment configuration
class Environment {
  const Environment({
    required this.name,
    required this.apiBaseUrl,
    this.requestTimeoutSeconds = 30,
    this.enableLogging = true,
    this.onvoApiKey = 'YOUR_ONVO_API_KEY',
    this.onvoSandbox = true,
    this.logsPath,
  });
  final String name;
  final String apiBaseUrl;
  final int requestTimeoutSeconds;
  final bool enableLogging;
  final String onvoApiKey;
  final bool onvoSandbox;

  /// Custom logs directory path (optional - uses default if null)
  final String? logsPath;
}

/// Environment manager for managing app environments
class EnvironmentManager {
  EnvironmentManager({required this.currentEnvironment});
  final Environment currentEnvironment;

  /// Development environment
  static const development = Environment(
    name: 'development',
    apiBaseUrl: 'http://localhost:3000',
    requestTimeoutSeconds: 30,
    enableLogging: true,
    onvoApiKey: 'YOUR_ONVO_API_KEY',
    onvoSandbox: true,
  );

  /// Staging environment
  static const staging = Environment(
    name: 'staging',
    apiBaseUrl: 'https://staging-api.altrupets.com',
    requestTimeoutSeconds: 30,
    enableLogging: true,
    onvoApiKey: 'YOUR_ONVO_API_KEY',
    onvoSandbox: true,
  );

  /// Production environment
  static const production = Environment(
    name: 'production',
    apiBaseUrl: 'https://api.altrupets.com',
    requestTimeoutSeconds: 30,
    enableLogging: false,
    onvoApiKey: 'YOUR_ONVO_API_KEY',
    onvoSandbox: false,
  );
}

/// Riverpod provider for EnvironmentManager
/// Default to development environment
final environmentManagerProvider = Provider<EnvironmentManager>((ref) {
  return EnvironmentManager(currentEnvironment: EnvironmentManager.development);
});
