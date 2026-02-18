import '../enums/payment_status.dart';
import 'money.dart';

/// Result of a payment operation
class PaymentResult {
  /// Whether the operation was successful
  final bool success;

  /// Transaction ID from the gateway
  final String? transactionId;

  /// Current status of the payment
  final PaymentStatus? status;

  /// Amount charged
  final Money? amount;

  /// Receipt URL (if available)
  final String? receiptUrl;

  /// Timestamp of creation
  final DateTime? createdAt;

  /// Error message (if failed)
  final String? errorMessage;

  /// Error code (if failed)
  final String? errorCode;

  /// Raw response from gateway (for debugging)
  final Map<String, dynamic>? rawResponse;

  const PaymentResult({
    required this.success,
    this.transactionId,
    this.status,
    this.amount,
    this.receiptUrl,
    this.createdAt,
    this.errorMessage,
    this.errorCode,
    this.rawResponse,
  });

  /// Successful payment result
  factory PaymentResult.success({
    required String transactionId,
    required PaymentStatus status,
    required Money amount,
    String? receiptUrl,
    DateTime? createdAt,
    Map<String, dynamic>? rawResponse,
  }) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      status: status,
      amount: amount,
      receiptUrl: receiptUrl,
      createdAt: createdAt ?? DateTime.now(),
      rawResponse: rawResponse,
    );
  }

  /// Failed payment result
  factory PaymentResult.failure({
    required String message,
    String? code,
    PaymentStatus? status,
    Map<String, dynamic>? rawResponse,
  }) {
    return PaymentResult(
      success: false,
      status: status ?? PaymentStatus.error,
      errorMessage: message,
      errorCode: code,
      rawResponse: rawResponse,
    );
  }

  /// Whether the payment requires additional user action
  bool get requiresAction =>
      status == PaymentStatus.pending || status == PaymentStatus.processing;

  /// Whether the payment is in a final state
  bool get isComplete => status?.isFinal ?? false;

  @override
  String toString() {
    if (success) {
      return 'PaymentResult.success(id: $transactionId, status: $status)';
    } else {
      return 'PaymentResult.failure(message: $errorMessage, code: $errorCode)';
    }
  }
}
