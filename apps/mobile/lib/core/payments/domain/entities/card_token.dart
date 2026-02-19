/// Represents a tokenized card (PCI compliant)
class CardToken {
  const CardToken({
    required this.id,
    required this.last4,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardHolderName,
  });

  factory CardToken.fromJson(Map<String, dynamic> json) {
    return CardToken(
      id: json['id'] as String,
      last4: json['last4'] as String,
      brand: json['brand'] as String,
      expiryMonth: json['expiryMonth'] as String,
      expiryYear: json['expiryYear'] as String,
      cardHolderName: json['cardHolderName'] as String,
    );
  }

  /// Token ID from the gateway
  final String id;

  /// Last 4 digits of the card
  final String last4;

  /// Card brand (visa, mastercard, amex, etc.)
  final String brand;

  /// Expiry month (MM)
  final String expiryMonth;

  /// Expiry year (YYYY)
  final String expiryYear;

  /// Cardholder name
  final String cardHolderName;

  /// Masked card number for display
  String get maskedNumber => '**** **** **** $last4';

  /// Short display (e.g., "Visa ending in 4242")
  String get display => '$brand ending in $last4';

  Map<String, dynamic> toJson() => {
    'id': id,
    'last4': last4,
    'brand': brand,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
    'cardHolderName': cardHolderName,
  };

  @override
  String toString() => 'CardToken($display)';
}
