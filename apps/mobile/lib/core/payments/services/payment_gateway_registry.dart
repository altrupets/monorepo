import 'package:altrupets/core/payments/domain/enums/country.dart';
import 'package:altrupets/core/payments/services/payment_gateway_factory.dart';

/// Registry of available payment gateways by country
///
/// This class maintains a mapping of which payment gateways
/// are available in each supported country.
class PaymentGatewayRegistry {
  /// Map of countries to their available gateway types
  static const Map<Country, List<PaymentGatewayType>> gatewaysByCountry = {
    Country.costaRica: [PaymentGatewayType.onvoPay, PaymentGatewayType.tilopay],
    Country.panama: [
      // To be defined
    ],
    Country.colombia: [
      PaymentGatewayType.wompi,
      PaymentGatewayType.mercadoPago,
      PaymentGatewayType.ebanx,
    ],
    Country.mexico: [
      PaymentGatewayType.openpay,
      PaymentGatewayType.conekta,
      PaymentGatewayType.mercadoPago,
    ],
    Country.brazil: [PaymentGatewayType.mercadoPago, PaymentGatewayType.ebanx],
    Country.argentina: [
      PaymentGatewayType.mercadoPago,
      PaymentGatewayType.ebanx,
    ],
    Country.chile: [PaymentGatewayType.mercadoPago, PaymentGatewayType.ebanx],
    Country.peru: [PaymentGatewayType.mercadoPago, PaymentGatewayType.ebanx],
  };

  /// Check if a country is supported
  static bool isSupported(Country country) {
    return gatewaysByCountry.containsKey(country);
  }

  /// Get all supported countries
  static Set<Country> get supportedCountries {
    return gatewaysByCountry.keys.toSet();
  }

  /// Get number of available gateways for a country
  static int gatewayCountFor(Country country) {
    return gatewaysByCountry[country]?.length ?? 0;
  }
}
