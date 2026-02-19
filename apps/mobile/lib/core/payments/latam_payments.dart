/// Latin American Payment Gateways SDK
library;

///
/// A comprehensive payment gateway SDK for Latin America supporting
/// Costa Rica, Panama, Colombia, Mexico, Brazil, and more with native
/// payment methods like SINPE, PSE, SPEI, PIX, and OXXO.
///
/// ## Usage
///
/// ```dart
/// import 'package:latam_payments/latam_payments.dart';
///
/// final gateway = PaymentGatewayFactory.create(
///   type: PaymentGatewayType.onvoPay,
///   config: PaymentGatewayConfiguration(
///     publicKey: 'pk_live_...',
///     sandbox: false,
///   ),
/// );
///
/// final token = await gateway.tokenizeCard(
///   cardNumber: '4242424242424242',
///   expiryMonth: '12',
///   expiryYear: '2025',
///   cvv: '123',
///   cardHolderName: 'John Doe',
/// );
///
/// final result = await gateway.processPayment(
///   amount: 50000, // ₡50,000
///   currency: Currency.crc,
///   method: PaymentMethodType.creditCard,
///   description: 'Purchase',
/// );
/// ```

// Domain - Enums
export 'domain/enums/country.dart';
export 'domain/enums/currency.dart';
export 'domain/enums/payment_method_type.dart';
export 'domain/enums/payment_status.dart';

// Domain - Entities
export 'domain/entities/card_token.dart';
export 'domain/entities/money.dart';
export 'domain/entities/payment_gateway_configuration.dart';
export 'domain/entities/payment_result.dart';
export 'domain/entities/refund_result.dart';

// Domain - Interfaces
export 'domain/interfaces/latin_american_payment_gateway.dart';

// Services
export 'services/payment_gateway_factory.dart';
export 'services/payment_gateway_registry.dart';

// Gateways - Costa Rica
export 'data/gateways/costa_rica/onvo_pay_payment_gateway.dart';
export 'data/gateways/costa_rica/tilopay_payment_gateway.dart';

// Gateways - Colombia
export 'data/gateways/colombia/wompi_payment_gateway.dart';
