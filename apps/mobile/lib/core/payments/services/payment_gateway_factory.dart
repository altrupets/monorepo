import '../domain/enums/country.dart';
import '../domain/enums/payment_method_type.dart';
import '../domain/entities/payment_gateway_configuration.dart';
import '../domain/interfaces/latin_american_payment_gateway.dart';
import '../data/gateways/costa_rica/onvo_pay_payment_gateway.dart';
import '../data/gateways/costa_rica/tilopay_payment_gateway.dart';
import '../data/gateways/colombia/wompi_payment_gateway.dart';
import '../data/gateways/mexico/openpay_payment_gateway.dart';
import '../data/gateways/mexico/conekta_payment_gateway.dart';
import '../data/gateways/brazil/mercado_pago_payment_gateway.dart';
import 'payment_gateway_registry.dart';

/// Types of supported payment gateways
enum PaymentGatewayType {
  onvoPay,
  tilopay,
  wompi,
  openpay,
  conekta,
  mercadoPago,
  ebanx,
}

/// Factory for creating payment gateway instances
class PaymentGatewayFactory {
  /// Create a gateway instance
  ///
  /// Example:
  /// ```dart
  /// final gateway = PaymentGatewayFactory.create(
  ///   type: PaymentGatewayType.onvoPay,
  ///   config: PaymentGatewayConfiguration(
  ///     publicKey: 'pk_test_...',
  ///     sandbox: true,
  ///   ),
  /// );
  /// ```
  static LatinAmericanPaymentGateway create({
    required PaymentGatewayType type,
    required PaymentGatewayConfiguration config,
  }) {
    config.validate();

    switch (type) {
      case PaymentGatewayType.onvoPay:
        return OnvoPayPaymentGateway(config);
      case PaymentGatewayType.tilopay:
        return TilopayPaymentGateway(config);
      case PaymentGatewayType.wompi:
        return WompiPaymentGateway(config);
      case PaymentGatewayType.openpay:
        return OpenpayPaymentGateway(config);
      case PaymentGatewayType.conekta:
        return ConektaPaymentGateway(config);
      case PaymentGatewayType.mercadoPago:
        return MercadoPagoPaymentGateway(config);
      case PaymentGatewayType.ebanx:
        throw UnimplementedError(
          'Gateway $type not yet implemented. '
          'Available: onvoPay, tilopay (Costa Rica), wompi (Colombia), '
          'openpay, conekta (Mexico), mercadoPago (Brazil)',
        );
    }
  }

  /// Get available gateway types for a specific country
  static List<PaymentGatewayType> availableFor(Country country) {
    return PaymentGatewayRegistry.gatewaysByCountry[country] ?? [];
  }

  /// Get native payment methods for a country
  ///
  /// These are payment methods specific to that country's
  /// financial ecosystem (e.g., SINPE for Costa Rica, PIX for Brazil)
  static Set<PaymentMethodType> nativeMethodsFor(Country country) {
    return switch (country) {
      Country.costaRica => {PaymentMethodType.sinpeMovil},
      Country.colombia => {PaymentMethodType.pse, PaymentMethodType.nequi},
      Country.mexico => {PaymentMethodType.spei, PaymentMethodType.oxxo},
      Country.brazil => {PaymentMethodType.pix, PaymentMethodType.boleto},
      _ => {},
    };
  }

  /// Get all supported payment methods for a country
  ///
  /// Includes native methods plus universal methods (cards)
  static Set<PaymentMethodType> supportedMethodsFor(Country country) {
    final methods = nativeMethodsFor(country);
    return {
      ...methods,
      PaymentMethodType.creditCard,
      PaymentMethodType.debitCard,
    };
  }
}
