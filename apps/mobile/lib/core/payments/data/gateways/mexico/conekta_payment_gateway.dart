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

/// Conekta Payment Gateway Implementation (Mexico)
///
/// Supports:
/// - Mexico: Cards, SPEI (bank transfer), OXXO (cash)
///
/// API Documentation: https://developers.conekta.com/
///
/// ## Key Features:
/// - Order-based payment flow
/// - Card tokenization for PCI compliance
/// - SPEI bank transfers (CLABE)
/// - OXXO cash payments
/// - Webhook support
/// - 3D Secure support
class ConektaPaymentGateway implements LatinAmericanPaymentGateway {
  ConektaPaymentGateway(this._config) {
    _baseUrl = _config.sandbox
        ? 'https://api.conekta.io'
        : 'https://api.conekta.io';
  }
  final PaymentGatewayConfiguration _config;
  late final String _baseUrl;

  @override
  String get id => 'conekta';

  @override
  String get name => 'Conekta';

  @override
  Country get primaryCountry => Country.mexico;

  @override
  Set<Country> get supportedCountries => {Country.mexico};

  @override
  Set<PaymentMethodType> get supportedMethods => {
    PaymentMethodType.creditCard,
    PaymentMethodType.debitCard,
    PaymentMethodType.spei,
    PaymentMethodType.oxxo,
  };

  @override
  Set<Currency> get supportedCurrencies => {Currency.mxn, Currency.usd};

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/vnd.conekta-v2.1.0+json',
    'Authorization': 'Bearer ${_config.privateKey}',
  };

  @override
  Future<void> initialize(PaymentGatewayConfiguration config) async {
    if (config.privateKey == null) {
      throw PaymentException(
        'Conekta requires a privateKey',
        code: 'missing_private_key',
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
        Uri.parse('$_baseUrl/tokens'),
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

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final tokenData = data;
        return CardToken(
          id: tokenData['id'] as String,
          last4: tokenData['card']?['last4'] as String? ?? '',
          brand: tokenData['card']?['brand'] as String? ?? 'unknown',
          expiryMonth: expiryMonth,
          expiryYear: expiryYear,
          cardHolderName: cardHolderName,
        );
      } else {
        throw PaymentException(
          data['message'] as String? ?? 'Tokenization failed',
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
      final orderIdValue =
          orderId ?? 'order_${DateTime.now().millisecondsSinceEpoch}';

      final orderData = _buildOrderRequest(
        amount: amount,
        currency: currency,
        method: method,
        description: description,
        orderId: orderIdValue,
        customer: customer,
        metadata: metadata,
      );

      final orderResponse = await http.post(
        Uri.parse('$_baseUrl/orders'),
        headers: _headers,
        body: jsonEncode(orderData),
      );

      final orderResult =
          jsonDecode(orderResponse.body) as Map<String, dynamic>;

      if (orderResponse.statusCode == 201 || orderResponse.statusCode == 200) {
        String? paymentUrl;
        String? receiptUrl;

        if (method == PaymentMethodType.oxxo) {
          final checkout = orderResult['checkout'] as Map<String, dynamic>?;
          paymentUrl = checkout?['url'] as String?;
        } else if (method == PaymentMethodType.spei) {
          final checkout = orderResult['checkout'] as Map<String, dynamic>?;
          paymentUrl = checkout?['url'] as String?;
        }

        return PaymentResult.success(
          transactionId: orderIdValue,
          status: PaymentStatus.pending,
          amount: Money(amount, currency),
          receiptUrl: paymentUrl ?? receiptUrl,
          createdAt: DateTime.now(),
          rawResponse: orderResult,
        );
      } else {
        return PaymentResult.failure(
          message: orderResult['message'] as String? ?? 'Payment failed',
          code: orderResult['code'] as String?,
          status: PaymentStatus.error,
          rawResponse: orderResult,
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

  Map<String, dynamic> _buildOrderRequest({
    required int amount,
    required Currency currency,
    required PaymentMethodType method,
    required String description,
    required String orderId,
    Map<String, dynamic>? customer,
    Map<String, dynamic>? metadata,
  }) {
    final lineItem = {'name': description, 'unit_price': amount, 'quantity': 1};

    switch (method) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        if (metadata == null || metadata['card_token'] == null) {
          throw PaymentException(
            'Card payment requires card_token in metadata',
            code: 'missing_card_token',
          );
        }
        return {
          'currency': currency.code.toUpperCase(),
          'customer_info': customer ?? {},
          'line_items': [lineItem],
          'metadata': metadata,
          'charges': [
            {
              'payment_method': {
                'type': 'card',
                'token_id': metadata['card_token'],
                'installments': metadata['installments'] ?? 1,
              },
            },
          ],
        };

      case PaymentMethodType.oxxo:
        return {
          'currency': currency.code.toUpperCase(),
          'customer_info': customer ?? {},
          'line_items': [lineItem],
          'metadata': metadata,
          'checkout': {
            'type': 'HostedPayment',
            'allowed_payment_methods': ['cash'],
            'expires_at':
                DateTime.now()
                    .add(const Duration(days: 3))
                    .millisecondsSinceEpoch ~/
                1000,
            'success_url':
                metadata?['success_url'] ?? 'https://example.com/success',
            'failure_url':
                metadata?['failure_url'] ?? 'https://example.com/failure',
          },
        };

      case PaymentMethodType.spei:
        return {
          'currency': currency.code.toUpperCase(),
          'customer_info': customer ?? {},
          'line_items': [lineItem],
          'metadata': metadata,
          'checkout': {
            'type': 'HostedPayment',
            'allowed_payment_methods': ['bank_transfer'],
            'expires_at':
                DateTime.now()
                    .add(const Duration(days: 3))
                    .millisecondsSinceEpoch ~/
                1000,
            'success_url':
                metadata?['success_url'] ?? 'https://example.com/success',
            'failure_url':
                metadata?['failure_url'] ?? 'https://example.com/failure',
          },
        };

      default:
        throw PaymentException(
          'Payment method $method not supported by Conekta',
          code: 'unsupported_payment_method',
        );
    }
  }

  @override
  Future<PaymentResult> getTransaction(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$transactionId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final orderData = data;
        final currencyCode = orderData['currency'] as String? ?? 'MXN';
        final currency = Currency.values.firstWhere(
          (c) => c.code.toUpperCase() == currencyCode.toUpperCase(),
          orElse: () => Currency.mxn,
        );

        final charges = orderData['charges'] as List<dynamic>?;
        final charge = charges?.isNotEmpty == true ? charges!.first : null;
        final chargeData = charge as Map<String, dynamic>?;

        return PaymentResult.success(
          transactionId: transactionId,
          status: _mapChargeStatus(chargeData?['status'] as String? ?? ''),
          amount: Money((orderData['amount'] as num?)?.toInt() ?? 0, currency),
          createdAt: DateTime.tryParse(
            orderData['created_at'] as String? ?? '',
          ),
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
      final chargeResponse = await http.get(
        Uri.parse('$_baseUrl/orders/$transactionId/charges'),
        headers: _headers,
      );

      final chargeData =
          jsonDecode(chargeResponse.body) as Map<String, dynamic>;
      final charges = chargeData['data'] as List<dynamic>?;
      final charge = charges?.isNotEmpty == true ? charges!.first : null;
      final chargeId = charge?['id'] as String?;

      if (chargeId == null) {
        return RefundResult.failure(
          message: 'No charge found for order',
          code: 'no_charge_found',
          originalTransactionId: transactionId,
        );
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/charges/$chargeId/refunds'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount,
          'reason': reason ?? 'Refund requested by customer',
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final refundData = data;
        return RefundResult.success(
          refundId: refundData['id'] as String,
          originalTransactionId: transactionId,
          amount: Money(
            (refundData['amount'] as num?)?.toInt() ?? 0,
            Currency.mxn,
          ),
          reason: reason,
        );
      } else {
        return RefundResult.failure(
          message: data['message'] as String? ?? 'Refund failed',
          code: data['code'] as String?,
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
        Uri.parse('$_baseUrl/orders'),
        headers: _headers,
      );
      return response.statusCode != 503 && response.statusCode != 502;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {}

  PaymentStatus _mapChargeStatus(String status) {
    return switch (status.toLowerCase()) {
      'paid' => PaymentStatus.approved,
      'pending' => PaymentStatus.pending,
      'failed' => PaymentStatus.rejected,
      'refunded' => PaymentStatus.refunded,
      _ => PaymentStatus.pending,
    };
  }
}
