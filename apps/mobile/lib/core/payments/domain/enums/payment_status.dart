/// Payment transaction status
enum PaymentStatus {
  pending('pending'),
  processing('processing'),
  approved('approved'),
  completed('completed'),
  rejected('rejected'),
  cancelled('cancelled'),
  refunded('refunded'),
  partiallyRefunded('partially_refunded'),
  expired('expired'),
  error('error');

  final String value;

  const PaymentStatus(this.value);

  /// Whether the payment is in a final state
  bool get isFinal {
    return this == PaymentStatus.completed ||
        this == PaymentStatus.rejected ||
        this == PaymentStatus.cancelled ||
        this == PaymentStatus.refunded ||
        this == PaymentStatus.expired ||
        this == PaymentStatus.error;
  }

  /// Whether the payment was successful
  bool get isSuccessful {
    return this == PaymentStatus.completed || this == PaymentStatus.approved;
  }

  /// Whether the payment requires user action
  bool get requiresAction {
    return this == PaymentStatus.pending || this == PaymentStatus.processing;
  }

  @override
  String toString() => value;
}
