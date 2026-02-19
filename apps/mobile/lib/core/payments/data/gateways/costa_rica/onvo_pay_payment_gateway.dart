import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:altrupets/core/payments/domain/entities/card_token.dart';
import 'package:altrupets/core/payments/domain/entities/payment_gateway_configuration.dart';
import 'package:altrupets/core/payments/domain/entities/payment_result.dart';
import 'package:altrupets/core/payments/domain/entities/refund_result.dart';
import 'package:altrupets/core/payments/domain/entities/money.dart';
import 'package:altrupets/core/payments/domain/enums/country.dart';
import 'package:altrupets/core/payments/domain/enums/currency.dart';
import 'package:altrupets/core/payments/domain/enums/payment_method_type.dart';
import 'package:altrupets/core/payments/domain/enums/payment_status.dart';
import 'package:altrupets/core/payments/domain/interfaces/latin_american_payment_gateway.dart';

/// ONVO Pay Payment Gateway Implementation
///
/// Supports Costa Rica with SINPE Móvil and card payments.
///
/// API Documentation: https://docs.onvopay.com
class OnvoPayPaymentGateway implements LatinAmericanPaymentGateway {
  OnvoPayPaymentGateway(this._config) {
    _baseUrl = _config.sandbox
        ? 'https://api-sandbox.onvopay.com'
        : 'https://api.onvopay.com';
  }
  final PaymentGatewayConfiguration _config;
  late final String _baseUrl;

  @override
  String get id => 'onvo_pay';

  @override
  String get name => 'ONVO Pay';

  @override
  Country get primaryCountry => Country.costaRica;

  @override
  Set<Country> get supportedCountries => {Country.costaRica};

  @override
  Set<PaymentMethodType> get supportedMethods => {
    PaymentMethodType.creditCard,
    PaymentMethodType.debitCard,
    PaymentMethodType.sinpeMovil,
  };

  @override
  Set<Currency> get supportedCurrencies => {Currency.crc, Currency.usd};

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${_config.publicKey}',
    'Accept': 'application/json',
  };

  @override
  Future<void> initialize(PaymentGatewayConfiguration config) async {
    if (config.publicKey == null) {
      throw PaymentException(
        'ONVO Pay requires a publicKey',
        code: 'missing_public_key',
      );
    }
  }

  @override
  Future<CardToken> tokenizeCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/tokens'),
        headers: _headers,
        body: jsonEncode({
          'card': {
            'number': cardNumber.replaceAll(' ', ''),
            'exp_month': expiryMonth,
            'exp_year': expiryYear,
            'cvc': cvv,
            'name': cardHolderName,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final cardData = data['card'] as Map<String, dynamic>;

        return CardToken(
          id: data['id'] as String,
          last4: cardData['last4'] as String,
          brand: cardData['brand'] as String,
          expiryMonth: cardData['exp_month'].toString(),
          expiryYear: cardData['exp_year'].toString(),
          cardHolderName: cardHolderName,
        );
      } else {
        throw PaymentException(
          'Error tokenizing card: ${response.body}',
          code: 'tokenization_failed',
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException(
        'Exception during tokenization: $e',
        code: 'tokenization_exception',
        originalError: e,
      );
    }
  }

  @override
  Future<PaymentResult> processPayment({
    required int amount,
    required Currency currency,
    required PaymentMethodType method,
    required String description,
    String? orderId,
    Map<String, dynamic>? customer,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      String endpoint;
      Map<String, dynamic> body;

      if (method == PaymentMethodType.sinpeMovil) {
        // SINPE payment
        if (customer == null || customer['phone'] == null) {
          throw PaymentException(
            'SINPE payment requires customer phone number',
            code: 'missing_phone',
          );
        }

        endpoint = 'v1/mobile-transfers';
        body = {
          'amount': amount,
          'phone_number': (customer['phone'] as String).replaceAll(
            RegExp(r'\D'),
            '',
          ),
          'description': description,
          'order_id': orderId,
        };
      } else {
        // Card payment
        if (metadata == null || metadata['card_token'] == null) {
          throw PaymentException(
            'Card payment requires card_token in metadata',
            code: 'missing_card_token',
          );
        }

        endpoint = 'v1/charges';
        body = {
          'amount': amount,
          'currency': currency.code.toLowerCase(),
          'source': metadata['card_token'],
          'description': description,
          'order_id': orderId,
          'metadata': metadata..remove('card_token'),
        };
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentResult.success(
          transactionId: data['id'] as String,
          status: _mapStatus(data['status'] as String),
          amount: Money(amount, currency),
          receiptUrl: data['receipt_url'] as String?,
          createdAt: DateTime.now(),
          rawResponse: data,
        );
      } else {
        final error = data['error'] as Map<String, dynamic>?;
        return PaymentResult.failure(
          message: error?['message'] as String? ?? 'Payment failed',
          code: error?['code'] as String?,
          status: PaymentStatus.error,
          rawResponse: data,
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      return PaymentResult.failure(
        message: 'Exception during payment: $e',
        code: 'payment_exception',
      );
    }
  }

  @override
  Future<PaymentResult> getTransaction(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/charges/$transactionId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final currency = Currency.values.firstWhere(
          (c) =>
              c.code.toLowerCase() ==
              (data['currency'] as String).toLowerCase(),
          orElse: () => Currency.crc,
        );

        return PaymentResult.success(
          transactionId: data['id'] as String,
          status: _mapStatus(data['status'] as String),
          amount: Money(data['amount'] as int, currency),
          receiptUrl: data['receipt_url'] as String?,
          rawResponse: data,
        );
      } else {
        return PaymentResult.failure(
          message: 'Failed to get transaction',
          code: 'get_transaction_failed',
        );
      }
    } catch (e) {
      return PaymentResult.failure(
        message: 'Exception: $e',
        code: 'get_transaction_exception',
      );
    }
  }

  @override
  Future<RefundResult> refund({
    required String transactionId,
    int? amount,
    String? reason,
  }) async {
    try {
      final body = <String, dynamic>{'amount': ?amount, 'reason': ?reason};

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/charges/$transactionId/refund'),
        headers: _headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RefundResult.success(
          refundId: data['id'] as String,
          originalTransactionId: transactionId,
          amount: Money(data['amount'] as int, Currency.crc), // Will be updated
          reason: reason,
        );
      } else {
        final error = data['error'] as Map<String, dynamic>?;
        return RefundResult.failure(
          message: error?['message'] as String? ?? 'Refund failed',
          code: error?['code'] as String?,
          originalTransactionId: transactionId,
        );
      }
    } catch (e) {
      return RefundResult.failure(
        message: 'Exception: $e',
        code: 'refund_exception',
        originalTransactionId: transactionId,
      );
    }
  }

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    // Cleanup if needed
  }

  /// Map ONVO Pay status to PaymentStatus
  PaymentStatus _mapStatus(String status) {
    return switch (status.toLowerCase()) {
      'pending' => PaymentStatus.pending,
      'processing' => PaymentStatus.processing,
      'approved' || 'succeeded' => PaymentStatus.approved,
      'completed' => PaymentStatus.completed,
      'failed' || 'rejected' => PaymentStatus.rejected,
      'cancelled' => PaymentStatus.cancelled,
      'refunded' => PaymentStatus.refunded,
      'expired' => PaymentStatus.expired,
      _ => PaymentStatus.pending,
    };
  }
}
