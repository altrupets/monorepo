import 'package:altrupets/core/payments/domain/entities/card_token.dart';
import 'package:altrupets/core/payments/domain/entities/payment_gateway_configuration.dart';
import 'package:altrupets/core/payments/domain/entities/payment_result.dart';
import 'package:altrupets/core/payments/domain/entities/refund_result.dart';
import 'package:altrupets/core/payments/domain/enums/country.dart';
import 'package:altrupets/core/payments/domain/enums/currency.dart';
import 'package:altrupets/core/payments/domain/enums/payment_method_type.dart';

/// Core interface for all Latin American payment gateways
///
/// This interface defines the contract that all payment gateway
/// implementations must follow to ensure consistency across
/// different providers and countries.
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
  ///
  /// Must be called before any other operations.
  /// Throws [ArgumentError] if configuration is invalid.
  Future<void> initialize(PaymentGatewayConfiguration config);

  /// PCI compliant card tokenization
  ///
  /// Returns a secure token representing the card.
  /// The actual card data never touches your server.
  ///
  /// Throws [PaymentException] if tokenization fails.
  Future<CardToken> tokenizeCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
  });

  /// Process a payment
  ///
  /// [amount]: Amount in smallest currency unit (e.g., 1000 = $10.00)
  /// [currency]: Payment currency
  /// [method]: Payment method type
  /// [description]: Payment description
  /// [orderId]: Optional order identifier
  /// [customer]: Optional customer information
  /// [metadata]: Optional metadata for the transaction
  ///
  /// Returns a [PaymentResult] with transaction details.
  /// Throws [PaymentException] if processing fails.
  Future<PaymentResult> processPayment({
    required int amount,
    required Currency currency,
    required PaymentMethodType method,
    required String description,
    String? orderId,
    Map<String, dynamic>? customer,
    Map<String, dynamic>? metadata,
  });

  /// Check transaction status
  ///
  /// [transactionId]: The transaction ID to check
  ///
  /// Returns current status of the transaction.
  Future<PaymentResult> getTransaction(String transactionId);

  /// Refund a transaction
  ///
  /// [transactionId]: The transaction to refund
  /// [amount]: Amount to refund (if null, full refund)
  /// [reason]: Optional reason for refund
  ///
  /// Returns a [RefundResult] with refund details.
  Future<RefundResult> refund({
    required String transactionId,
    int? amount,
    String? reason,
  });

  /// Check gateway availability
  ///
  /// Returns true if the gateway is operational.
  Future<bool> healthCheck();

  /// Dispose resources
  ///
  /// Call this when the gateway is no longer needed.
  Future<void> dispose();
}

/// Exception thrown by payment operations
class PaymentException implements Exception {
  PaymentException(this.message, {this.code, this.originalError});
  final String message;
  final String? code;
  final dynamic originalError;

  @override
  String toString() =>
      'PaymentException: $message${code != null ? ' (code: $code)' : ''}';
}
