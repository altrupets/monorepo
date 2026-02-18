import 'money.dart';
import '../enums/payment_status.dart';

/// Result of a refund operation
class RefundResult {
  /// Whether the refund was successful
  final bool success;

  /// Refund transaction ID
  final String? refundId;

  /// Original transaction ID
  final String? originalTransactionId;

  /// Amount refunded
  final Money? amount;

  /// Current status of the refund
  final PaymentStatus? status;

  /// Timestamp of creation
  final DateTime? createdAt;

  /// Reason for refund
  final String? reason;

  /// Error message (if failed)
  final String? errorMessage;

  /// Error code (if failed)
  final String? errorCode;

  const RefundResult({
    required this.success,
    this.refundId,
    this.originalTransactionId,
    this.amount,
    this.status,
    this.createdAt,
    this.reason,
    this.errorMessage,
    this.errorCode,
  });

  /// Successful refund result
  factory RefundResult.success({
    required String refundId,
    required String originalTransactionId,
    required Money amount,
    PaymentStatus status = PaymentStatus.completed,
    DateTime? createdAt,
    String? reason,
  }) {
    return RefundResult(
      success: true,
      refundId: refundId,
      originalTransactionId: originalTransactionId,
      amount: amount,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      reason: reason,
    );
  }

  /// Failed refund result
  factory RefundResult.failure({
    required String message,
    String? code,
    String? originalTransactionId,
  }) {
    return RefundResult(
      success: false,
      originalTransactionId: originalTransactionId,
      errorMessage: message,
      errorCode: code,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'RefundResult.success(id: $refundId, amount: $amount)';
    } else {
      return 'RefundResult.failure(message: $errorMessage)';
    }
  }
}
