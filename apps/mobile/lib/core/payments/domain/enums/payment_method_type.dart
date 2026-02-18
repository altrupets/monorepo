/// Payment method types supported across LATAM
enum PaymentMethodType {
  // Universal methods
  creditCard,
  debitCard,

  // Costa Rica
  sinpeMovil, // SINPE Móvil - mobile transfers

  // Colombia
  pse, // Pagos Seguros en Línea - bank transfers
  nequi, // Billetera digital
  daviplata, // Davivienda wallet

  // México
  spei, // Sistema de Pagos Electrónicos Interbancarios
  oxxo, // Cash payments at OXXO stores

  // Brasil
  pix, // Sistema de Pagos Instantáneos
  boleto, // Boleto bancário

  // Perú
  yape, // BCP wallet
  plin, // Interbank wallet

  // Multi-country
  cash, // Cash payments (various)
  bankTransfer, // Generic bank transfer
  wallet; // Generic digital wallet

  /// Human-readable name
  String get displayName {
    return switch (this) {
      PaymentMethodType.creditCard => 'Credit Card',
      PaymentMethodType.debitCard => 'Debit Card',
      PaymentMethodType.sinpeMovil => 'SINPE Móvil',
      PaymentMethodType.pse => 'PSE',
      PaymentMethodType.nequi => 'Nequi',
      PaymentMethodType.daviplata => 'Daviplata',
      PaymentMethodType.spei => 'SPEI',
      PaymentMethodType.oxxo => 'OXXO',
      PaymentMethodType.pix => 'PIX',
      PaymentMethodType.boleto => 'Boleto',
      PaymentMethodType.yape => 'Yape',
      PaymentMethodType.plin => 'Plin',
      PaymentMethodType.cash => 'Cash',
      PaymentMethodType.bankTransfer => 'Bank Transfer',
      PaymentMethodType.wallet => 'Digital Wallet',
    };
  }

  /// Whether this method requires a card
  bool get requiresCard {
    return this == PaymentMethodType.creditCard ||
        this == PaymentMethodType.debitCard;
  }

  /// Whether this method is a digital wallet
  bool get isWallet {
    return this == PaymentMethodType.nequi ||
        this == PaymentMethodType.daviplata ||
        this == PaymentMethodType.yape ||
        this == PaymentMethodType.plin ||
        this == PaymentMethodType.wallet;
  }

  /// Whether this method is cash-based
  bool get isCash {
    return this == PaymentMethodType.oxxo ||
        this == PaymentMethodType.boleto ||
        this == PaymentMethodType.cash;
  }
}
