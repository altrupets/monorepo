import 'dart:convert';
import 'package:http/http.dart' as http;

/// Interfaz abstracta para pasarelas de pago de Costa Rica
/// Implementaciones: [OnvoPayGateway], [TilopayGateway]
abstract class CostaRicaPaymentGateway {
  /// Nombre de la pasarela
  String get name;

  /// Indica si soporta SINPE Móvil
  bool get supportsSinpe;

  /// Indica si soporta pagos con tarjeta
  bool get supportsCardPayments;

  /// Indica si soporta reembolsos
  bool get supportsRefunds;

  /// Tokeniza una tarjeta para almacenamiento seguro
  Future<CardTokenizationResult> tokenizeCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
  });

  /// Procesa un pago con tarjeta tokenizada
  Future<PaymentResult> processPayment({
    required int amount,
    required String currency,
    required String paymentToken,
    required String description,
    String? orderId,
    Map<String, dynamic>? metadata,
  });

  /// Inicia un pago con SINPE Móvil
  Future<SinpePaymentResult> processSinpePayment({
    required int amount,
    required String phoneNumber,
    required String description,
    String? orderId,
  });

  /// Verifica el estado de un pago SINPE
  Future<SinpePaymentResult> checkSinpeStatus(String transactionId);

  /// Procesa un reembolso
  Future<RefundResult> processRefund({
    required String transactionId,
    int? amount,
    String? reason,
  });
}

/// Implementación de ONVO Pay
class OnvoPayGateway implements CostaRicaPaymentGateway {
  final String apiKey;
  final bool sandbox;
  final String _baseUrl;

  OnvoPayGateway({required this.apiKey, this.sandbox = true})
    : _baseUrl = sandbox
          ? 'https://api-sandbox.onvopay.com'
          : 'https://api.onvopay.com';

  @override
  String get name => 'ONVO Pay';

  @override
  bool get supportsSinpe => true;

  @override
  bool get supportsCardPayments => true;

  @override
  bool get supportsRefunds => true;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
    'Accept': 'application/json',
  };

  @override
  Future<CardTokenizationResult> tokenizeCard({
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

        return CardTokenizationResult.success(
          token: data['id'] as String,
          last4: cardData['last4'] as String,
          brand: cardData['brand'] as String,
          expiryMonth: cardData['exp_month'].toString(),
          expiryYear: cardData['exp_year'].toString(),
          cardHolderName: cardHolderName,
        );
      } else {
        return CardTokenizationResult.error(
          message: 'Error tokenizing card: ${response.body}',
        );
      }
    } catch (e) {
      return CardTokenizationResult.error(message: 'Exception: $e');
    }
  }

  @override
  Future<PaymentResult> processPayment({
    required int amount,
    required String currency,
    required String paymentToken,
    required String description,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/charges'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'source': paymentToken,
          'description': description,
          'order_id': orderId,
          'metadata': metadata ?? {},
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentResult.success(
          transactionId: data['id'] as String,
          status: data['status'] as String,
          amount: amount,
          currency: currency,
          receiptUrl: data['receipt_url'] as String?,
        );
      } else {
        final error = data['error'] as Map<String, dynamic>?;
        return PaymentResult.error(
          message: error?['message'] as String? ?? 'Payment failed',
          code: error?['code'] as String?,
        );
      }
    } catch (e) {
      return PaymentResult.error(message: 'Exception: $e');
    }
  }

  @override
  Future<SinpePaymentResult> processSinpePayment({
    required int amount,
    required String phoneNumber,
    required String description,
    String? orderId,
  }) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/mobile-transfers'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount,
          'phone_number': cleanPhone,
          'description': description,
          'order_id': orderId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SinpePaymentResult.success(
          transactionId: data['id'] as String,
          status: data['status'] as String,
          phoneNumber: cleanPhone,
          amount: amount,
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        );
      } else {
        final error = data['error'] as Map<String, dynamic>?;
        return SinpePaymentResult.error(
          message: error?['message'] as String? ?? 'SINPE transfer failed',
        );
      }
    } catch (e) {
      return SinpePaymentResult.error(message: 'Exception: $e');
    }
  }

  @override
  Future<SinpePaymentResult> checkSinpeStatus(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/mobile-transfers/$transactionId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return SinpePaymentResult.success(
          transactionId: data['id'] as String,
          status: data['status'] as String,
          phoneNumber: data['phone_number'] as String,
          amount: data['amount'] as int,
          expiresAt: DateTime.tryParse(data['expires_at']?.toString() ?? ''),
        );
      } else {
        return SinpePaymentResult.error(message: 'Failed to check status');
      }
    } catch (e) {
      return SinpePaymentResult.error(message: 'Exception: $e');
    }
  }

  @override
  Future<RefundResult> processRefund({
    required String transactionId,
    int? amount,
    String? reason,
  }) async {
    try {
      final body = <String, dynamic>{
        if (amount != null) 'amount': amount,
        if (reason != null) 'reason': reason,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/charges/$transactionId/refund'),
        headers: _headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RefundResult.success(
          refundId: data['id'] as String,
          amount: data['amount'] as int,
          status: data['status'] as String,
        );
      } else {
        final error = data['error'] as Map<String, dynamic>?;
        return RefundResult.error(
          message: error?['message'] as String? ?? 'Refund failed',
        );
      }
    } catch (e) {
      return RefundResult.error(message: 'Exception: $e');
    }
  }
}

/// Implementación de Tilopay
class TilopayGateway implements CostaRicaPaymentGateway {
  final String apiKey;
  final String apiSecret;
  final bool sandbox;
  final String _baseUrl;

  TilopayGateway({
    required this.apiKey,
    required this.apiSecret,
    this.sandbox = true,
  }) : _baseUrl = sandbox
           ? 'https://app-tilopay.com/api/v2'
           : 'https://app.tilopay.com/api/v2';

  @override
  String get name => 'Tilopay';

  @override
  bool get supportsSinpe => true;

  @override
  bool get supportsCardPayments => true;

  @override
  bool get supportsRefunds => true;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
    'X-Api-Secret': apiSecret,
  };

  @override
  Future<CardTokenizationResult> tokenizeCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
  }) async {
    try {
      // Tilopay usa un enfoque diferente: genera un hash que se usa en el frontend
      // y luego se confirma en el backend
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/tokenize'),
        headers: _headers,
        body: jsonEncode({
          'card_number': cardNumber.replaceAll(' ', ''),
          'card_expiration': '$expiryMonth/$expiryYear',
          'card_cvv': cvv,
          'card_holder': cardHolderName,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return CardTokenizationResult.success(
          token: data['token'] as String,
          last4: data['last4'] as String,
          brand: data['brand'] as String,
          expiryMonth: expiryMonth,
          expiryYear: expiryYear,
          cardHolderName: cardHolderName,
        );
      } else {
        return CardTokenizationResult.error(
          message: data['message'] as String? ?? 'Tokenization failed',
        );
      }
    } catch (e) {
      return CardTokenizationResult.error(message: 'Exception: $e');
    }
  }

  @override
  Future<PaymentResult> processPayment({
    required int amount,
    required String currency,
    required String paymentToken,
    required String description,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/process'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'token': paymentToken,
          'description': description,
          'order_id': orderId,
          'metadata': metadata,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return PaymentResult.success(
          transactionId: data['transaction_id'] as String,
          status: data['status'] as String,
          amount: amount,
          currency: currency,
          receiptUrl: data['receipt_url'] as String?,
        );
      } else {
        return PaymentResult.error(
          message: data['message'] as String? ?? 'Payment failed',
          code: data['error_code'] as String?,
        );
      }
    } catch (e) {
      return PaymentResult.error(message: 'Exception: $e');
    }
  }

  @override
  Future<SinpePaymentResult> processSinpePayment({
    required int amount,
    required String phoneNumber,
    required String description,
    String? orderId,
  }) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final response = await http.post(
        Uri.parse('$_baseUrl/sinpe/process'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount,
          'phone': cleanPhone,
          'description': description,
          'order_id': orderId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return SinpePaymentResult.success(
          transactionId: data['transaction_id'] as String,
          status: data['status'] as String,
          phoneNumber: cleanPhone,
          amount: amount,
          expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        );
      } else {
        return SinpePaymentResult.error(
          message: data['message'] as String? ?? 'SINPE transfer failed',
        );
      }
    } catch (e) {
      return SinpePaymentResult.error(message: 'Exception: $e');
    }
  }

  @override
  Future<SinpePaymentResult> checkSinpeStatus(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sinpe/status/$transactionId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return SinpePaymentResult.success(
          transactionId: data['transaction_id'] as String,
          status: data['status'] as String,
          phoneNumber: data['phone'] as String,
          amount: data['amount'] as int,
          expiresAt: DateTime.tryParse(data['expires_at']?.toString() ?? ''),
        );
      } else {
        return SinpePaymentResult.error(message: 'Failed to check status');
      }
    } catch (e) {
      return SinpePaymentResult.error(message: 'Exception: $e');
    }
  }

  @override
  Future<RefundResult> processRefund({
    required String transactionId,
    int? amount,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/refund'),
        headers: _headers,
        body: jsonEncode({
          'transaction_id': transactionId,
          if (amount != null) 'amount': amount,
          if (reason != null) 'reason': reason,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return RefundResult.success(
          refundId: data['refund_id'] as String,
          amount: amount ?? data['amount'] as int,
          status: data['status'] as String,
        );
      } else {
        return RefundResult.error(
          message: data['message'] as String? ?? 'Refund failed',
        );
      }
    } catch (e) {
      return RefundResult.error(message: 'Exception: $e');
    }
  }
}

/// Factory para crear instancias de pasarelas
class CostaRicaPaymentGatewayFactory {
  static CostaRicaPaymentGateway create({
    required PaymentGatewayType type,
    required String apiKey,
    String? apiSecret,
    bool sandbox = true,
  }) {
    switch (type) {
      case PaymentGatewayType.onvoPay:
        return OnvoPayGateway(apiKey: apiKey, sandbox: sandbox);
      case PaymentGatewayType.tilopay:
        if (apiSecret == null) {
          throw ArgumentError('Tilopay requires apiSecret');
        }
        return TilopayGateway(
          apiKey: apiKey,
          apiSecret: apiSecret,
          sandbox: sandbox,
        );
    }
  }
}

enum PaymentGatewayType { onvoPay, tilopay }

/// Modelo de resultado de tokenización
class CardTokenizationResult {
  final bool success;
  final String? token;
  final String? last4;
  final String? brand;
  final String? expiryMonth;
  final String? expiryYear;
  final String? cardHolderName;
  final String? errorMessage;

  CardTokenizationResult._({
    required this.success,
    this.token,
    this.last4,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
    this.cardHolderName,
    this.errorMessage,
  });

  factory CardTokenizationResult.success({
    required String token,
    required String last4,
    required String brand,
    required String expiryMonth,
    required String expiryYear,
    required String cardHolderName,
  }) {
    return CardTokenizationResult._(
      success: true,
      token: token,
      last4: last4,
      brand: brand,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cardHolderName: cardHolderName,
    );
  }

  factory CardTokenizationResult.error({required String message}) {
    return CardTokenizationResult._(success: false, errorMessage: message);
  }
}

/// Modelo de resultado de pago
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? status;
  final int? amount;
  final String? currency;
  final String? receiptUrl;
  final String? errorMessage;
  final String? errorCode;

  PaymentResult._({
    required this.success,
    this.transactionId,
    this.status,
    this.amount,
    this.currency,
    this.receiptUrl,
    this.errorMessage,
    this.errorCode,
  });

  factory PaymentResult.success({
    required String transactionId,
    required String status,
    required int amount,
    required String currency,
    String? receiptUrl,
  }) {
    return PaymentResult._(
      success: true,
      transactionId: transactionId,
      status: status,
      amount: amount,
      currency: currency,
      receiptUrl: receiptUrl,
    );
  }

  factory PaymentResult.error({required String message, String? code}) {
    return PaymentResult._(
      success: false,
      errorMessage: message,
      errorCode: code,
    );
  }
}

/// Modelo de resultado de pago SINPE
class SinpePaymentResult {
  final bool success;
  final String? transactionId;
  final String? status;
  final String? phoneNumber;
  final int? amount;
  final DateTime? expiresAt;
  final String? errorMessage;

  SinpePaymentResult._({
    required this.success,
    this.transactionId,
    this.status,
    this.phoneNumber,
    this.amount,
    this.expiresAt,
    this.errorMessage,
  });

  factory SinpePaymentResult.success({
    required String transactionId,
    required String status,
    required String phoneNumber,
    required int amount,
    DateTime? expiresAt,
  }) {
    return SinpePaymentResult._(
      success: true,
      transactionId: transactionId,
      status: status,
      phoneNumber: phoneNumber,
      amount: amount,
      expiresAt: expiresAt,
    );
  }

  factory SinpePaymentResult.error({required String message}) {
    return SinpePaymentResult._(success: false, errorMessage: message);
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? false;
}

/// Modelo de resultado de reembolso
class RefundResult {
  final bool success;
  final String? refundId;
  final int? amount;
  final String? status;
  final String? errorMessage;

  RefundResult._({
    required this.success,
    this.refundId,
    this.amount,
    this.status,
    this.errorMessage,
  });

  factory RefundResult.success({
    required String refundId,
    required int amount,
    required String status,
  }) {
    return RefundResult._(
      success: true,
      refundId: refundId,
      amount: amount,
      status: status,
    );
  }

  factory RefundResult.error({required String message}) {
    return RefundResult._(success: false, errorMessage: message);
  }
}
