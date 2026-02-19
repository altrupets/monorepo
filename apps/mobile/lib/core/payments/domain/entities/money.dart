import 'package:altrupets/core/payments/domain/enums/currency.dart';

/// Represents a monetary amount with currency
class Money {
  const Money(this.amount, this.currency);

  /// Create from decimal amount
  factory Money.fromDecimal(double decimal, Currency currency) {
    return Money(currency.fromDecimal(decimal), currency);
  }

  /// Amount in smallest currency unit (cents)
  final int amount;

  /// Currency of the amount
  final Currency currency;

  /// Convert to decimal representation
  double get decimal => currency.toDecimal(amount);

  /// Format for display
  String get display => '${currency.symbol}${decimal.toStringAsFixed(2)}';

  /// Zero amount
  static Money zero(Currency currency) => Money(0, currency);

  @override
  String toString() => display;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Money &&
        other.amount == amount &&
        other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(amount, currency);
}
