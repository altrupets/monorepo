/// Currencies supported by LATAM payment gateways
enum Currency {
  crc('CRC', 'Costa Rican Colón', '₡', 100), // 100 centavos = 1 colón
  pab('PAB', 'Panamanian Balboa', 'B/.', 100),
  cop('COP', 'Colombian Peso', r'$', 100),
  mxn('MXN', 'Mexican Peso', r'$', 100),
  brl('BRL', 'Brazilian Real', r'R$', 100),
  usd('USD', 'US Dollar', r'$', 100);

  final String code;
  final String name;
  final String symbol;
  final int decimalPlaces;

  const Currency(this.code, this.name, this.symbol, this.decimalPlaces);

  /// Convert amount from decimal to smallest unit (cents)
  int fromDecimal(double amount) {
    return (amount * decimalPlaces).round();
  }

  /// Convert amount from smallest unit to decimal
  double toDecimal(int amount) {
    return amount / decimalPlaces;
  }

  @override
  String toString() => symbol;
}
