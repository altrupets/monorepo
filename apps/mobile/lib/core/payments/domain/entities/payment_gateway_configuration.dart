/// Configuration for any LATAM payment gateway
class PaymentGatewayConfiguration {
  const PaymentGatewayConfiguration({
    this.publicKey,
    this.privateKey,
    this.apiSecret,
    this.sandbox = true,
    this.timeout = const Duration(seconds: 30),
    this.extraConfig,
  });

  /// Factory for minimal configuration (tokenization only)
  factory PaymentGatewayConfiguration.minimal({
    required String publicKey,
    bool sandbox = true,
  }) => PaymentGatewayConfiguration(publicKey: publicKey, sandbox: sandbox);

  /// Public API Key (for client-side tokenization)
  final String? publicKey;

  /// Private API Key (for backend, if applicable)
  final String? privateKey;

  /// API Secret (for gateways requiring it)
  final String? apiSecret;

  /// Environment: sandbox or production
  final bool sandbox;

  /// Request timeout (default: 30s)
  final Duration timeout;

  /// Gateway-specific configuration
  final Map<String, dynamic>? extraConfig;

  /// Validate required fields
  void validate() {
    if (publicKey == null && privateKey == null) {
      throw ArgumentError(
        'At least one of publicKey or privateKey must be provided',
      );
    }
  }

  PaymentGatewayConfiguration copyWith({
    String? publicKey,
    String? privateKey,
    String? apiSecret,
    bool? sandbox,
    Duration? timeout,
    Map<String, dynamic>? extraConfig,
  }) {
    return PaymentGatewayConfiguration(
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
      apiSecret: apiSecret ?? this.apiSecret,
      sandbox: sandbox ?? this.sandbox,
      timeout: timeout ?? this.timeout,
      extraConfig: extraConfig ?? this.extraConfig,
    );
  }
}
