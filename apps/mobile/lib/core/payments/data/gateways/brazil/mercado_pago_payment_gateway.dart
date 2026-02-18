import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../domain/entities/card_token.dart';
import '../../../domain/entities/payment_gateway_configuration.dart';
import '../../../domain/entities/payment_result.dart';
import '../../../domain/entities/refund_result.dart';
import '../../../domain/entities/money.dart';
import '../../../domain/enums/country.dart';
import '../../../domain/enums/currency.dart';
import '../../../domain/enums/payment_method_type.dart';
import '../../../domain/enums/payment_status.dart';
import '../../../domain/interfaces/latin_american_payment_gateway.dart';

/// Mercado Pago Brazil Payment Gateway Implementation
///
/// Supports:
/// - Brazil: Cards, PIX, Boleto
///
/// API Documentation: https://www.mercadopago.com.br/developers/
///
/// ## Key Features:
/// - Order-based payment flow
/// - PIX instant payments (QR code, copy-paste)
/// - Boleto bancário (bank slip)
/// - Card payments
/// - Webhook support
class MercadoPagoPaymentGateway implements LatinAmericanPaymentGateway {
  final PaymentGatewayConfiguration _config;
  late final String _baseUrl;

  MercadoPagoPaymentGateway(this._config) {
    _baseUrl = _config.sandbox
        ? 'https://api.mercadopago.com'
        : 'https://api.mercadopago.com';
  }

  @override
  String get id => 'mercadopago';

  @override
  String get name => 'Mercado Pago';

  @override
  Country get primaryCountry => Country.brazil;

  @override
  Set<Country> get supportedCountries => {Country.brazil};

  @override
  Set<PaymentMethodType> get supportedMethods => {
    PaymentMethodType.creditCard,
    PaymentMethodType.debitCard,
    PaymentMethodType.pix,
    PaymentMethodType.boleto,
  };

  @override
  Set<Currency> get supportedCurrencies => {Currency.brl, Currency.usd};

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${_config.privateKey}',
  };

  @override
  Future<void> initialize(PaymentGatewayConfiguration config) async {
    if (config.privateKey == null) {
      throw PaymentException(
        'Mercado Pago requires a privateKey (access token)',
        code: 'missing_access_token',
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
        Uri.parse('$_baseUrl/v1/card_tokens'),
        headers: _headers,
        body: jsonEncode({
          'card_number': cardNumber.replaceAll(' ', ''),
          'expiration_month': int.tryParse(expiryMonth) ?? 1,
          'expiration_year': int.tryParse(expiryYear) ?? 2025,
          'cvv': cvv,
          'cardholder': {
            'identification': {'type': 'CPF', 'number': ''},
            'name': cardHolderName,
          },
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        return CardToken(
          id: data['id'] as String,
          last4: data['last_four_digits'] as String? ?? '',
          brand: data['card_brand'] as String? ?? 'unknown',
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

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/orders'),
        headers: {..._headers, 'X-Idempotency-Key': orderIdValue},
        body: jsonEncode(orderData),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        String? paymentUrl;
        String? receiptUrl;

        if (method == PaymentMethodType.pix) {
          final transaction = data['transactions'] as List<dynamic>?;
          final payment = transaction?.isNotEmpty == true
              ? transaction!.first
              : null;
          final paymentMethod =
              payment?['payment_method'] as Map<String, dynamic>?;
          paymentUrl = paymentMethod?['ticket_url'] as String?;
          receiptUrl = paymentMethod?['qr_code'] as String?;
        } else if (method == PaymentMethodType.boleto) {
          final transaction = data['transactions'] as List<dynamic>?;
          final payment = transaction?.isNotEmpty == true
              ? transaction!.first
              : null;
          final paymentMethod =
              payment?['payment_method'] as Map<String, dynamic>?;
          paymentUrl = paymentMethod?['ticket_url'] as String?;
          receiptUrl = paymentMethod?['barcode'] as String?;
        }

        return PaymentResult.success(
          transactionId: data['id'] as String? ?? orderIdValue,
          status: _mapStatus(data['status'] as String? ?? ''),
          amount: Money(amount, currency),
          receiptUrl: paymentUrl ?? receiptUrl,
          createdAt: DateTime.now(),
          rawResponse: data,
        );
      } else {
        return PaymentResult.failure(
          message: data['message'] as String? ?? 'Payment failed',
          code: data['error'] as String?,
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

  Map<String, dynamic> _buildOrderRequest({
    required int amount,
    required Currency currency,
    required PaymentMethodType method,
    required String description,
    required String orderId,
    Map<String, dynamic>? customer,
    Map<String, dynamic>? metadata,
  }) {
    final amountDecimal = (amount / 100).toStringAsFixed(2);

    final baseRequest = {
      'type': 'online',
      'external_reference': orderId,
      'total_amount': amountDecimal,
      'country_code': 'BR',
      'currency': currency.code.toUpperCase(),
    };

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
          ...baseRequest,
          'payer': {'email': customer?['email'] ?? 'test@example.com'},
          'transactions': [
            {
              'payments': [
                {
                  'payment_method_id': method == PaymentMethodType.creditCard
                      ? 'credit_card'
                      : 'debit_card',
                  'token': metadata['card_token'],
                  'transaction_amount': double.tryParse(amountDecimal) ?? 0,
                  'installments': metadata['installments'] ?? 1,
                },
              ],
            },
          ],
        };

      case PaymentMethodType.pix:
        return {
          ...baseRequest,
          'payer': {'email': customer?['email'] ?? 'test@example.com'},
          'transactions': [
            {
              'payments': [
                {
                  'payment_method_id': 'pix',
                  'transaction_amount': double.tryParse(amountDecimal) ?? 0,
                },
              ],
            },
          ],
        };

      case PaymentMethodType.boleto:
        return {
          ...baseRequest,
          'payer': {'email': customer?['email'] ?? 'test@example.com'},
          'transactions': [
            {
              'payments': [
                {
                  'payment_method_id': 'bolbradesco',
                  'transaction_amount': double.tryParse(amountDecimal) ?? 0,
                },
              ],
            },
          ],
        };

      default:
        throw PaymentException(
          'Payment method $method not supported by Mercado Pago',
          code: 'unsupported_payment_method',
        );
    }
  }

  @override
  Future<PaymentResult> getTransaction(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/orders/$transactionId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final currencyCode = data['currency'] as String? ?? 'BRL';
        final currency = Currency.values.firstWhere(
          (c) => c.code.toUpperCase() == currencyCode.toUpperCase(),
          orElse: () => Currency.brl,
        );

        final amount =
            (double.tryParse(data['total_amount']?.toString() ?? '0') ?? 0);

        return PaymentResult.success(
          transactionId: data['id'] as String,
          status: _mapStatus(data['status'] as String? ?? ''),
          amount: Money((amount * 100).toInt(), currency),
          createdAt: DateTime.tryParse(data['created_date'] as String? ?? ''),
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
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/orders/$transactionId/refunds'),
        headers: {..._headers, 'X-Idempotency-Key': 'refund_$transactionId'},
        body: jsonEncode({
          'amount': amount != null ? (amount / 100).toStringAsFixed(2) : null,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final refundAmount =
            (double.tryParse(data['amount']?.toString() ?? '0') ?? 0);
        return RefundResult.success(
          refundId: data['id'] as String,
          originalTransactionId: transactionId,
          amount: Money((refundAmount * 100).toInt(), Currency.brl),
          reason: reason,
        );
      } else {
        return RefundResult.failure(
          message: data['message'] as String? ?? 'Refund failed',
          code: data['error'] as String?,
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

  Future<Map<String, dynamic>?> getPixQrCode(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/orders/$orderId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final transactions = data['transactions'] as List<dynamic>?;
        final transaction = transactions?.isNotEmpty == true
            ? transactions!.first
            : null;
        final payment = transaction?['payments'] as List<dynamic>?;
        final paymentData = payment?.isNotEmpty == true ? payment!.first : null;
        final paymentMethod =
            paymentData?['payment_method'] as Map<String, dynamic>?;

        return {
          'qr_code': paymentMethod?['qr_code'] as String?,
          'qr_code_content': paymentMethod?['qr_code_content'] as String?,
          'ticket_url': paymentMethod?['ticket_url'] as String?,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/orders'),
        headers: _headers,
      );
      return response.statusCode != 503 && response.statusCode != 502;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {}

  PaymentStatus _mapStatus(String status) {
    return switch (status.toLowerCase()) {
      'approved' || 'paid' => PaymentStatus.approved,
      'pending' || 'in_progress' => PaymentStatus.pending,
      'rejected' || 'failed' => PaymentStatus.rejected,
      'cancelled' => PaymentStatus.cancelled,
      'refunded' => PaymentStatus.refunded,
      _ => PaymentStatus.pending,
    };
  }
}
