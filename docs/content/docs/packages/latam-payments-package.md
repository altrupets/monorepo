# LatinAmericanPaymentGateway - Package Documentation

## Overview

A comprehensive payment gateway SDK for Latin America supporting Costa Rica, Panama, Colombia, Mexico, Brazil, and more with native payment methods like SINPE, PSE, SPEI, PIX, and OXXO.

**Target:** pub.dev package `latam_payments`

## 1. Package Structure

```
lib/
├── src/
│   ├── core/
│   │   ├── entities/
│   │   │   ├── money.dart
│   │   │   ├── card_token.dart
│   │   │   ├── payment_result.dart
│   │   │   ├── refund_result.dart
│   │   │   └── payment_gateway_configuration.dart
│   │   ├── enums/
│   │   │   ├── country.dart
│   │   │   ├── currency.dart
│   │   │   ├── payment_method_type.dart
│   │   │   └── payment_status.dart
│   │   └── interfaces/
│   │       └── latin_american_payment_gateway.dart
│   ├── gateways/
│   │   ├── costa_rica/
│   │   │   ├── onvo_pay_payment_gateway.dart
│   │   │   └── tilopay_payment_gateway.dart
│   │   ├── panama/
│   │   │   └── [to be defined]
│   │   ├── colombia/
│   │   │   ├── wompi_payment_gateway.dart
│   │   │   └── payu_colombia_payment_gateway.dart
│   │   ├── mexico/
│   │   │   ├── openpay_payment_gateway.dart
│   │   │   └── conekta_payment_gateway.dart
│   │   └── brazil/
│   │       ├── pix/
│   │       │   ├── pix_payment_method.dart
│   │       │   └── pix_payment_gateway.dart
│   │       └── mercado_pago_brazil_payment_gateway.dart
│   └── services/
│       ├── payment_gateway_factory.dart
│       └── payment_gateway_registry.dart
├── latam_payments.dart
└── latam_payments_core.dart
```

## 2. Core Interface

### `latin_american_payment_gateway.dart`

```dart
abstract class LatinAmericanPaymentGateway {
  /// Unique identifier for the gateway
  String get id;
  
  /// Display name
  String get name;
  
  /// Primary country of operation
  Country get primaryCountry;
  
  /// Additional supported countries (for multi-country gateways)
  Set<Country> get supportedCountries;
  
  /// Supported payment methods
  Set<PaymentMethodType> get supportedMethods;
  
  /// Supported currencies
  Set<Currency> get supportedCurrencies;
  
  /// Initialize with configuration
  Future<void> initialize(PaymentGatewayConfiguration config);
  
  /// PCI compliant card tokenization
  /// Returns a secure token representing the card
  Future<CardToken> tokenizeCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
    CardBillingAddress? billingAddress,
  });
  
  /// Process a payment
  /// [amount]: Amount in smallest currency unit (e.g., 1000 = $10.00)
  /// [currency]: Payment currency
  /// [method]: Payment method (CardToken, Pix, Sinpe, etc.)
  Future<PaymentResult> processPayment({
    required int amount,
    required Currency currency,
    required PaymentMethodType method,
    required String description,
    String? orderId,
    Customer? customer,
    Map<String, dynamic>? metadata,
  });
  
  /// Check transaction status
  Future<PaymentResult> getTransaction(String transactionId);
  
  /// Refund transaction
  /// [amount]: If null, full refund
  Future<RefundResult> refund({
    required String transactionId,
    int? amount,
    String? reason,
  });
  
  /// Check gateway availability
  Future<bool> healthCheck();
  
  /// Dispose resources
  Future<void> dispose();
}
```

## 3. Configuration

### `payment_gateway_configuration.dart`

```dart
/// Configuration for any LATAM payment gateway
class PaymentGatewayConfiguration {
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
  }) => PaymentGatewayConfiguration(
    publicKey: publicKey,
    sandbox: sandbox,
  );
}
```

## 4. Enums

### Country
```dart
enum Country {
  costaRica('CR', 'Costa Rica'),
  panama('PA', 'Panamá'),
  colombia('CO', 'Colombia'),
  mexico('MX', 'México'),
  brazil('BR', 'Brasil'),
  argentina('AR', 'Argentina'),
  chile('CL', 'Chile'),
  peru('PE', 'Perú');
  
  final String code;
  final String displayName;
  const Country(this.code, this.displayName);
}
```

### Currency
```dart
enum Currency {
  crc('CRC', 'Costa Rican Colón', '₡'),
  pab('PAB', 'Panamanian Balboa', 'B/.'),
  cop('COP', 'Colombian Peso', r'$'),
  mxn('MXN', 'Mexican Peso', r'$'),
  brl('BRL', 'Brazilian Real', r'R$'),
  usd('USD', 'US Dollar', r'$');
  
  final String code;
  final String name;
  final String symbol;
  const Currency(this.code, this.name, this.symbol);
}
```

### PaymentMethodType
```dart
enum PaymentMethodType {
  creditCard,
  debitCard,
  sinpeMovil,      // Costa Rica
  pse,             // Colombia
  nequi,           // Colombia
  spei,            // México
  oxxo,            // México
  pix,             // Brasil
  boleto,          // Brasil
  yape,            // Perú
  plin,            // Perú
}
```

## 5. Factory & Registry

### `payment_gateway_factory.dart`
```dart
enum PaymentGatewayType {
  onvoPay,
  tilopay,
  wompi,
  openpay,
  conekta,
  mercadoPago,
  ebanx,
}

class PaymentGatewayFactory {
  static LatinAmericanPaymentGateway create({
    required PaymentGatewayType type,
    required PaymentGatewayConfiguration config,
  }) {
    switch (type) {
      case PaymentGatewayType.onvoPay:
        return OnvoPayPaymentGateway(config);
      case PaymentGatewayType.tilopay:
        return TilopayPaymentGateway(config);
      case PaymentGatewayType.wompi:
        return WompiPaymentGateway(config);
      case PaymentGatewayType.openpay:
        return OpenpayPaymentGateway(config);
      case PaymentGatewayType.conekta:
        return ConektaPaymentGateway(config);
      case PaymentGatewayType.mercadoPago:
        return MercadoPagoPaymentGateway(config);
      case PaymentGatewayType.ebanx:
        return EbanxPaymentGateway(config);
    }
  }
  
  static List<PaymentGatewayType> availableFor(Country country) {
    return PaymentGatewayRegistry.gatewaysByCountry[country] ?? [];
  }
  
  static Set<PaymentMethodType> nativeMethodsFor(Country country) {
    return switch (country) {
      Country.costaRica => {PaymentMethodType.sinpeMovil},
      Country.colombia => {PaymentMethodType.pse, PaymentMethodType.nequi},
      Country.mexico => {PaymentMethodType.spei, PaymentMethodType.oxxo},
      Country.brazil => {PaymentMethodType.pix, PaymentMethodType.boleto},
      _ => {},
    };
  }
}
```

### `payment_gateway_registry.dart`
```dart
class PaymentGatewayRegistry {
  static const Map<Country, List<PaymentGatewayType>> gatewaysByCountry = {
    Country.costaRica: [
      PaymentGatewayType.onvoPay,
      PaymentGatewayType.tilopay,
    ],
    Country.panama: [
      // To be defined
    ],
    Country.colombia: [
      PaymentGatewayType.wompi,
      PaymentGatewayType.mercadoPago,
      PaymentGatewayType.ebanx,
    ],
    Country.mexico: [
      PaymentGatewayType.openpay,
      PaymentGatewayType.conekta,
      PaymentGatewayType.mercadoPago,
    ],
    Country.brazil: [
      PaymentGatewayType.mercadoPago,
      PaymentGatewayType.ebanx,
    ],
  };
}
```

## 6. Implementation Roadmap

### Sprint 1: Foundations (This Week)
1. Create directory structure
2. Define base interfaces (`LatinAmericanPaymentGateway`, enums, entities)
3. Migrate `OnvoPayPaymentGateway` and `TilopayPaymentGateway`
4. Create `PaymentGatewayFactory` and `PaymentGatewayRegistry`
5. Unit tests

### Sprint 2: Colombia (Week 2)
1. Implement `WompiPaymentGateway`
2. PSE support
3. Nequi support (if API available)

### Sprint 3: Mexico (Week 3)
1. Implement `OpenpayPaymentGateway`
2. SPEI support
3. OXXO support

### Sprint 4: Brazil PIX (Week 4)
1. Implement `MercadoPagoBrazilPaymentGateway`
2. PIX QR code generation
3. PIX confirmation webhooks

### Sprint 5: Package Release (Week 5)
1. Extract to separate repository
2. Create example app
3. Documentation
4. Publish to pub.dev as `latam_payments: ^0.1.0`

## 7. Usage Example

```dart
import 'package:latam_payments/latam_payments.dart';

// Initialize gateway
final gateway = PaymentGatewayFactory.create(
  type: PaymentGatewayType.onvoPay,
  config: PaymentGatewayConfiguration(
    publicKey: 'pk_live_...',
    sandbox: false,
  ),
);

// Tokenize card
final token = await gateway.tokenizeCard(
  cardNumber: '4242424242424242',
  expiryMonth: '12',
  expiryYear: '2025',
  cvv: '123',
  cardHolderName: 'John Doe',
);

// Process payment
final result = await gateway.processPayment(
  amount: 50000, // ₡50,000
  currency: Currency.crc,
  method: PaymentMethodType.creditCard,
  description: 'Purchase',
);

if (result.success) {
  print('Payment successful: ${result.transactionId}');
}
```

## 8. Package Configuration

### pubspec.yaml
```yaml
name: latam_payments
description: A comprehensive payment gateway SDK for Latin America supporting Costa Rica, Panama, Colombia, Mexico, Brazil, and more.
version: 0.1.0
homepage: https://github.com/yourorg/latam_payments
repository: https://github.com/yourorg/latam_payments

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  crypto: ^3.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  mockito: ^5.4.0

topics:
  - payments
  - latam
  - gateway
  - costa-rica
  - colombia
  - mexico
  - brazil
```

## 9. Naming Conventions

All classes use `PaymentGateway` suffix to avoid conflicts:
- ✅ `LatinAmericanPaymentGateway`
- ✅ `PaymentGatewayConfiguration`
- ✅ `PaymentGatewayFactory`
- ✅ `PaymentGatewayRegistry`
- ✅ `PaymentGatewayType`
- ✅ `OnvoPayPaymentGateway`
- ✅ `TilopayPaymentGateway`
- ✅ `WompiPaymentGateway`

## 10. Integration Example

```dart
// Consumer app configuration
class MyAppPaymentConfig {
  static LatinAmericanPaymentGateway gatewayFor(Country country) {
    return PaymentGatewayFactory.create(
      type: _gatewayTypeFor(country),
      config: PaymentGatewayConfiguration(
        publicKey: _getPublicKeyFor(country),
        sandbox: const bool.fromEnvironment('SANDBOX', defaultValue: true),
      ),
    );
  }
  
  static PaymentGatewayType _gatewayTypeFor(Country country) {
    return switch (country) {
      Country.costaRica => PaymentGatewayType.onvoPay,
      Country.colombia => PaymentGatewayType.wompi,
      Country.mexico => PaymentGatewayType.openpay,
      Country.brazil => PaymentGatewayType.mercadoPago,
      _ => throw UnsupportedError('Country not supported yet: $country'),
    };
  }
}
```

---

**License:** MIT
**Version:** 0.1.0
**Last Updated:** February 2026
