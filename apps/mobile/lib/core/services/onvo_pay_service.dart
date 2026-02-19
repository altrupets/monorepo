import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio de integración con ONVO Pay
/// Pasarela de pagos de Costa Rica con soporte para:
/// - Tokenización de tarjetas (PCI compliant)
/// - SINPE Móvil (transferencias bancarias)
/// - Pagos con tarjeta
/// - Reembolsos
class OnvoPayService {
  OnvoPayService({required this.apiKey, this.sandbox = true})
    : baseUrl = sandbox
          ? 'https://api-sandbox.onvopay.com'
          : 'https://api.onvopay.com';
  final String apiKey;
  final String baseUrl;
  final bool sandbox;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
    'Accept': 'application/json',
  };

  /// Tokeniza una tarjeta para almacenamiento seguro
  /// Retorna un token que puede usarse para pagos futuros
  Future<OnvoCardToken> tokenizeCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/tokens'),
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
        return OnvoCardToken(
          id: data['id'] as String,
          last4: cardData['last4'] as String,
          brand: cardData['brand'] as String,
          expiryMonth: cardData['exp_month'].toString(),
          expiryYear: cardData['exp_year'].toString(),
          cardHolderName: cardHolderName,
        );
      } else {
        throw OnvoPayException(
          'Error tokenizing card: ${response.body}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw OnvoPayException('Failed to tokenize card: $e');
    }
  }

  /// Crea un pago con tarjeta tokenizada
  Future<OnvoPaymentResult> createPayment({
    required int amount, // En colones (CRC) o dólares (USD)
    required String currency, // 'CRC' o 'USD'
    required String cardToken,
    required String description,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/charges'),
        headers: _headers,
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'source': cardToken,
          'description': description,
          'order_id': orderId,
          'metadata': metadata ?? {},
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OnvoPaymentResult(
          success: true,
          paymentId: data['id'] as String,
          status: data['status'] as String,
          amount: amount,
          currency: currency,
          receiptUrl: data['receipt_url'] as String?,
          createdAt: DateTime.now(),
        );
      } else {
        final error = data['error'] as Map<String, dynamic>?;
        return OnvoPaymentResult(
          success: false,
          errorMessage: error?['message'] as String? ?? 'Payment failed',
          errorCode: error?['code'] as String?,
        );
      }
    } catch (e) {
      return OnvoPaymentResult(
        success: false,
        errorMessage: 'Payment error: $e',
      );
    }
  }

  /// Inicia un pago con SINPE Móvil
  /// El usuario recibe una notificación en su banco para aprobar
  Future<OnvoSinpeResult> createSinpePayment({
    required int amount, // En colones
    required String phoneNumber, // Número SINPE (ej: 8888-8888)
    required String description,
    String? orderId,
  }) async {
    try {
      // Limpiar número de teléfono
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      final response = await http.post(
        Uri.parse('$baseUrl/v1/mobile-transfers'),
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
        return OnvoSinpeResult(
          success: true,
          transferId: data['id'] as String,
          status: data['status'] as String,
          phoneNumber: cleanPhone,
          amount: amount,
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        );
      } else {
        final error = data['error'] as Map<String, dynamic>?;
        return OnvoSinpeResult(
          success: false,
          errorMessage: error?['message'] as String? ?? 'SINPE transfer failed',
        );
      }
    } catch (e) {
      return OnvoSinpeResult(success: false, errorMessage: 'SINPE error: $e');
    }
  }

  /// Verifica el estado de una transferencia SINPE
  Future<OnvoSinpeResult> checkSinpeStatus(String transferId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/mobile-transfers/$transferId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return OnvoSinpeResult(
          success: data['status'] == 'completed',
          transferId: data['id'] as String,
          status: data['status'] as String,
          phoneNumber: data['phone_number'] as String,
          amount: data['amount'] as int,
          expiresAt: DateTime.tryParse(data['expires_at']?.toString() ?? ''),
        );
      } else {
        throw OnvoPayException('Failed to check SINPE status');
      }
    } catch (e) {
      throw OnvoPayException('Error checking status: $e');
    }
  }

  /// Lista las transferencias SINPE recientes
  Future<List<OnvoSinpeResult>> listSinpeTransfers({
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'status': ?status,
      };

      final uri = Uri.parse(
        '$baseUrl/v1/mobile-transfers',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final transfers = data['data'] as List<dynamic>;

        return transfers
            .map(
              (t) => OnvoSinpeResult(
                success: t['status'] == 'completed',
                transferId: t['id'] as String,
                status: t['status'] as String,
                phoneNumber: t['phone_number'] as String,
                amount: t['amount'] as int,
                expiresAt: DateTime.tryParse(t['expires_at']?.toString() ?? ''),
              ),
            )
            .toList();
      } else {
        throw OnvoPayException('Failed to list transfers');
      }
    } catch (e) {
      throw OnvoPayException('Error listing transfers: $e');
    }
  }

  /// Reembolsa un pago
  Future<OnvoRefundResult> refundPayment({
    required String paymentId,
    int? amount, // Si es null, reembolsa el monto total
    String? reason,
  }) async {
    try {
      final body = <String, dynamic>{'amount': ?amount, 'reason': ?reason};

      final response = await http.post(
        Uri.parse('$baseUrl/v1/charges/$paymentId/refund'),
        headers: _headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OnvoRefundResult(
          success: true,
          refundId: data['id'] as String,
          amount: data['amount'] as int,
          status: data['status'] as String,
          createdAt: DateTime.now(),
        );
      } else {
        final error = data['error'] as Map<String, dynamic>?;
        return OnvoRefundResult(
          success: false,
          errorMessage: error?['message'] as String? ?? 'Refund failed',
        );
      }
    } catch (e) {
      return OnvoRefundResult(success: false, errorMessage: 'Refund error: $e');
    }
  }
}

/// Modelo de token de tarjeta ONVO
class OnvoCardToken {
  OnvoCardToken({
    required this.id,
    required this.last4,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardHolderName,
  });
  final String id;
  final String last4;
  final String brand;
  final String expiryMonth;
  final String expiryYear;
  final String cardHolderName;

  Map<String, dynamic> toJson() => {
    'id': id,
    'last4': last4,
    'brand': brand,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
    'cardHolderName': cardHolderName,
  };
}

/// Resultado de pago ONVO
class OnvoPaymentResult {
  OnvoPaymentResult({
    required this.success,
    this.paymentId,
    this.status,
    this.amount,
    this.currency,
    this.receiptUrl,
    this.createdAt,
    this.errorMessage,
    this.errorCode,
  });
  final bool success;
  final String? paymentId;
  final String? status;
  final int? amount;
  final String? currency;
  final String? receiptUrl;
  final DateTime? createdAt;
  final String? errorMessage;
  final String? errorCode;
}

/// Resultado de transferencia SINPE
class OnvoSinpeResult {
  OnvoSinpeResult({
    required this.success,
    this.transferId,
    this.status,
    this.phoneNumber,
    this.amount,
    this.expiresAt,
    this.errorMessage,
  });
  final bool success;
  final String? transferId;
  final String? status;
  final String? phoneNumber;
  final int? amount;
  final DateTime? expiresAt;
  final String? errorMessage;

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isExpired =>
      status == 'expired' || (expiresAt?.isBefore(DateTime.now()) ?? false);
}

/// Resultado de reembolso
class OnvoRefundResult {
  OnvoRefundResult({
    required this.success,
    this.refundId,
    this.amount,
    this.status,
    this.createdAt,
    this.errorMessage,
  });
  final bool success;
  final String? refundId;
  final int? amount;
  final String? status;
  final DateTime? createdAt;
  final String? errorMessage;
}

/// Excepción específica de ONVO Pay
class OnvoPayException implements Exception {
  OnvoPayException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() =>
      'OnvoPayException: $message${code != null ? ' (Code: $code)' : ''}';
}
