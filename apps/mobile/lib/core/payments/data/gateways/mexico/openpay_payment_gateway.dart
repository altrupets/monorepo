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

/// OpenPay Payment Gateway Implementation (Mexico)
///
/// Supports:
/// - Mexico: Cards, SPEI (bank transfer), OXXO (cash)
///
/// API Documentation: https://documents.openpay.mx/en/api/
///
/// ## Key Features:
/// - Merchant ID required (from OpenPay dashboard)
/// - Card tokenization for PCI compliance
/// - SPEI bank transfers (CLABE)
/// - OXXO cash payments (barcode generation)
/// - Webhook support
class OpenpayPaymentGateway implements LatinAmericanPaymentGateway {
  final PaymentGatewayConfiguration _config;
  late final String _baseUrl;
  late final String _merchantId;

  OpenpayPaymentGateway(this._config) {
    _merchantId =
        (_config.extraConfig?['merchantId'] as String?) ??
        (_config.extraConfig?['merchant_id'] as String?) ??
        '';
    _baseUrl = _config.sandbox
        ? 'https://sandbox-api.openpay.mx/v1'
        : 'https://api.openpay.mx/v1';
  }

  @override
  String get id => 'openpay';

  @override
  String get name => 'OpenPay';

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
    'Authorization':
        'Basic ${base64Encode(utf8.encode('${_config.privateKey}:'))}',
  };

  String get _merchantUrl => '$_baseUrl/$_merchantId';

  @override
  Future<void> initialize(PaymentGatewayConfiguration config) async {
    if (config.privateKey == null) {
      throw PaymentException(
        'OpenPay requires a privateKey',
        code: 'missing_private_key',
      );
    }
    if (_merchantId.isEmpty) {
      throw PaymentException(
        'OpenPay requires merchantId in extraConfig',
        code: 'missing_merchant_id',
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
        Uri.parse('$_merchantUrl/tokens'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('${_config.publicKey}:'))}',
        },
        body: jsonEncode({
          'card_number': cardNumber.replaceAll(' ', ''),
          'expiration_month': expiryMonth,
          'expiration_year': expiryYear,
          'cvv2': cvv,
          'cardholder_name': cardHolderName,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        return CardToken(
          id: data['id'] as String,
          last4: data['card_number'] as String? ?? '',
          brand: _detectCardBrand(data['card_number'] as String? ?? ''),
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

  String _detectCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'visa';
    if (cardNumber.startsWith('5')) return 'mastercard';
    if (cardNumber.startsWith('34') || cardNumber.startsWith('37')) {
      return 'amex';
    }
    if (cardNumber.startsWith('6011')) return 'discover';
    return 'unknown';
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
      final chargeData = _buildChargeRequest(
        amount: amount,
        currency: currency,
        method: method,
        description: description,
        orderId: orderId,
        customer: customer,
        metadata: metadata,
      );

      final response = await http.post(
        Uri.parse('$_merchantUrl/charges'),
        headers: _headers,
        body: jsonEncode(chargeData),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final txnData = data;

        String? paymentUrl;
        String? receiptUrl;

        if (method == PaymentMethodType.oxxo) {
          paymentUrl = txnData['payment_method']?['barcode_url'] as String?;
          receiptUrl = txnData['payment_method']?['receipt_url'] as String?;
        } else if (method == PaymentMethodType.spei) {
          paymentUrl = txnData['payment_method']?['redirect_url'] as String?;
          receiptUrl = txnData['payment_method']?['receipt_url'] as String?;
        }

        return PaymentResult.success(
          transactionId: txnData['id'] as String,
          status: _mapStatus(txnData['status'] as String? ?? ''),
          amount: Money(amount, currency),
          receiptUrl: receiptUrl,
          createdAt: DateTime.tryParse(txnData['created_at'] as String? ?? ''),
          rawResponse: data,
        );
      } else {
        return PaymentResult.failure(
          message: data['message'] as String? ?? 'Payment failed',
          code: data['error_code'] as String?,
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

  Map<String, dynamic> _buildChargeRequest({
    required int amount,
    required Currency currency,
    required PaymentMethodType method,
    required String description,
    String? orderId,
    Map<String, dynamic>? customer,
    Map<String, dynamic>? metadata,
  }) {
    final baseRequest = {
      'amount': (amount / 100).toStringAsFixed(2),
      'currency': currency.code.toUpperCase(),
      'description': description,
      'order_id': orderId ?? 'order_${DateTime.now().millisecondsSinceEpoch}',
      if (customer != null) 'customer': customer,
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
          'payment_method': {
            'type': 'card',
            'token_id': metadata['card_token'],
          },
          if (metadata['installments'] != null)
            'installments': metadata['installments'],
        };

      case PaymentMethodType.oxxo:
        return {
          ...baseRequest,
          'payment_method': {
            'type': 'store',
            'reference':
                orderId ?? 'ref_${DateTime.now().millisecondsSinceEpoch}',
          },
        };

      case PaymentMethodType.spei:
        return {
          ...baseRequest,
          'payment_method': {'type': 'bank_account'},
        };

      default:
        throw PaymentException(
          'Payment method $method not supported by OpenPay',
          code: 'unsupported_payment_method',
        );
    }
  }

  @override
  Future<PaymentResult> getTransaction(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_merchantUrl/charges/$transactionId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final txnData = data;
        final currencyCode = txnData['currency'] as String? ?? 'MXN';
        final currency = Currency.values.firstWhere(
          (c) => c.code.toUpperCase() == currencyCode.toUpperCase(),
          orElse: () => Currency.mxn,
        );

        return PaymentResult.success(
          transactionId: txnData['id'] as String,
          status: _mapStatus(txnData['status'] as String? ?? ''),
          amount: Money(
            ((txnData['amount'] as num?)?.toInt() ?? 0) * 100,
            currency,
          ),
          createdAt: DateTime.tryParse(txnData['created_at'] as String? ?? ''),
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
      final requestBody = <String, dynamic>{
        'description': reason ?? 'Customer request',
      };
      if (amount != null) {
        requestBody['amount'] = (amount / 100).toStringAsFixed(2);
      }

      final response = await http.post(
        Uri.parse('$_merchantUrl/charges/$transactionId/refunds'),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final refundData = data;
        final amountValue = (refundData['amount'] as num?)?.toInt() ?? 0;
        return RefundResult.success(
          refundId: refundData['id'] as String,
          originalTransactionId: transactionId,
          amount: Money(amountValue * 100, Currency.mxn),
          reason: reason,
        );
      } else {
        return RefundResult.failure(
          message: data['message'] as String? ?? 'Refund failed',
          code: data['error_code'] as String?,
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

  Future<List<Map<String, dynamic>>> getSpeiBanks() async {
    try {
      final response = await http.get(
        Uri.parse('$_merchantUrl/bankaccounts'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final banksData = data['banks'] as List<dynamic>?;
        return banksData?.cast<Map<String, dynamic>>() ?? [];
      } else {
        throw PaymentException(
          'Failed to get banks list',
          code: 'banks_fetch_failed',
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException(
        'Exception getting banks: $e',
        code: 'banks_fetch_exception',
      );
    }
  }

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_merchantUrl'),
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
      'completed' => PaymentStatus.approved,
      'in_progress' => PaymentStatus.pending,
      'failed' => PaymentStatus.rejected,
      'cancelled' => PaymentStatus.cancelled,
      _ => PaymentStatus.pending,
    };
  }
}
