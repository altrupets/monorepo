import 'package:flutter_test/flutter_test.dart';
import 'package:altrupets/core/payments/services/payment_gateway_factory.dart';
import 'package:altrupets/core/payments/domain/enums/country.dart';
import 'package:altrupets/core/payments/domain/enums/payment_method_type.dart';
import 'package:altrupets/core/payments/domain/entities/payment_gateway_configuration.dart';

void main() {
  group('PaymentGatewayFactory', () {
    group('create', () {
      test('should create OnvoPay gateway', () {
        final gateway = PaymentGatewayFactory.create(
          type: PaymentGatewayType.onvoPay,
          config: const PaymentGatewayConfiguration(publicKey: 'pk_test_123'),
        );

        expect(gateway.id, 'onvo_pay');
        expect(gateway.name, 'ONVO Pay');
        expect(gateway.primaryCountry, Country.costaRica);
      });

      test('should create Tilopay gateway', () {
        final gateway = PaymentGatewayFactory.create(
          type: PaymentGatewayType.tilopay,
          config: const PaymentGatewayConfiguration(publicKey: 'pk_test_123'),
        );

        expect(gateway.id, 'tilopay');
        expect(gateway.name, 'Tilopay');
        expect(gateway.primaryCountry, Country.costaRica);
      });

      test('should create Wompi gateway', () {
        final gateway = PaymentGatewayFactory.create(
          type: PaymentGatewayType.wompi,
          config: const PaymentGatewayConfiguration(publicKey: 'pub_test_123'),
        );

        expect(gateway.id, 'wompi');
        expect(gateway.name, 'Wompi');
        expect(gateway.primaryCountry, Country.colombia);
      });

      test('should create OpenPay gateway', () {
        final gateway = PaymentGatewayFactory.create(
          type: PaymentGatewayType.openpay,
          config: const PaymentGatewayConfiguration(
            privateKey: 'sk_test_123',
            extraConfig: {'merchantId': 'merchant_123'},
          ),
        );

        expect(gateway.id, 'openpay');
        expect(gateway.name, 'OpenPay');
        expect(gateway.primaryCountry, Country.mexico);
      });

      test('should create Conekta gateway', () {
        final gateway = PaymentGatewayFactory.create(
          type: PaymentGatewayType.conekta,
          config: const PaymentGatewayConfiguration(privateKey: 'sk_test_123'),
        );

        expect(gateway.id, 'conekta');
        expect(gateway.name, 'Conekta');
        expect(gateway.primaryCountry, Country.mexico);
      });

      test('should create Mercado Pago gateway', () {
        final gateway = PaymentGatewayFactory.create(
          type: PaymentGatewayType.mercadoPago,
          config: const PaymentGatewayConfiguration(
            privateKey: 'access_token_123',
          ),
        );

        expect(gateway.id, 'mercadopago');
        expect(gateway.name, 'Mercado Pago');
        expect(gateway.primaryCountry, Country.brazil);
      });

      test('should throw for unimplemented gateways', () {
        expect(
          () => PaymentGatewayFactory.create(
            type: PaymentGatewayType.ebanx,
            config: const PaymentGatewayConfiguration(
              privateKey: 'sk_test_123',
            ),
          ),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('should throw when no keys provided', () {
        expect(
          () => PaymentGatewayFactory.create(
            type: PaymentGatewayType.onvoPay,
            config: const PaymentGatewayConfiguration(),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('availableFor', () {
      test('should return gateways for Costa Rica', () {
        final gateways = PaymentGatewayFactory.availableFor(Country.costaRica);

        expect(gateways, contains(PaymentGatewayType.onvoPay));
        expect(gateways, contains(PaymentGatewayType.tilopay));
      });

      test('should return gateways for Colombia', () {
        final gateways = PaymentGatewayFactory.availableFor(Country.colombia);

        expect(gateways, contains(PaymentGatewayType.wompi));
      });

      test('should return gateways for Mexico', () {
        final gateways = PaymentGatewayFactory.availableFor(Country.mexico);

        expect(gateways, contains(PaymentGatewayType.openpay));
        expect(gateways, contains(PaymentGatewayType.conekta));
      });

      test('should return gateways for Brazil', () {
        final gateways = PaymentGatewayFactory.availableFor(Country.brazil);

        expect(gateways, contains(PaymentGatewayType.mercadoPago));
      });

      test('should return gateways for Argentina', () {
        final gateways = PaymentGatewayFactory.availableFor(Country.argentina);

        expect(gateways, contains(PaymentGatewayType.mercadoPago));
      });

      test('should return gateways for Peru', () {
        final gateways = PaymentGatewayFactory.availableFor(Country.peru);

        expect(gateways, contains(PaymentGatewayType.mercadoPago));
      });

      test('should return gateways for Chile', () {
        final gateways = PaymentGatewayFactory.availableFor(Country.chile);

        expect(gateways, contains(PaymentGatewayType.mercadoPago));
      });

      test('should return empty list for Panama (not yet implemented)', () {
        final gateways = PaymentGatewayFactory.availableFor(Country.panama);

        expect(gateways, isEmpty);
      });
    });

    group('nativeMethodsFor', () {
      test('should return SINPE for Costa Rica', () {
        final methods = PaymentGatewayFactory.nativeMethodsFor(
          Country.costaRica,
        );

        expect(methods, contains(PaymentMethodType.sinpeMovil));
      });

      test('should return PSE and Nequi for Colombia', () {
        final methods = PaymentGatewayFactory.nativeMethodsFor(
          Country.colombia,
        );

        expect(methods, contains(PaymentMethodType.pse));
        expect(methods, contains(PaymentMethodType.nequi));
      });

      test('should return SPEI and OXXO for Mexico', () {
        final methods = PaymentGatewayFactory.nativeMethodsFor(Country.mexico);

        expect(methods, contains(PaymentMethodType.spei));
        expect(methods, contains(PaymentMethodType.oxxo));
      });

      test('should return PIX and Boleto for Brazil', () {
        final methods = PaymentGatewayFactory.nativeMethodsFor(Country.brazil);

        expect(methods, contains(PaymentMethodType.pix));
        expect(methods, contains(PaymentMethodType.boleto));
      });

      test('should return empty for unsupported country', () {
        final methods = PaymentGatewayFactory.nativeMethodsFor(Country.peru);

        expect(methods, isEmpty);
      });
    });

    group('supportedMethodsFor', () {
      test('should include cards plus native methods for Costa Rica', () {
        final methods = PaymentGatewayFactory.supportedMethodsFor(
          Country.costaRica,
        );

        expect(methods, contains(PaymentMethodType.creditCard));
        expect(methods, contains(PaymentMethodType.debitCard));
        expect(methods, contains(PaymentMethodType.sinpeMovil));
      });

      test('should include cards plus native methods for Brazil', () {
        final methods = PaymentGatewayFactory.supportedMethodsFor(
          Country.brazil,
        );

        expect(methods, contains(PaymentMethodType.creditCard));
        expect(methods, contains(PaymentMethodType.pix));
        expect(methods, contains(PaymentMethodType.boleto));
      });
    });
  });

  group('PaymentGatewayType Enum', () {
    test('should have all expected values', () {
      expect(PaymentGatewayType.values, contains(PaymentGatewayType.onvoPay));
      expect(PaymentGatewayType.values, contains(PaymentGatewayType.tilopay));
      expect(PaymentGatewayType.values, contains(PaymentGatewayType.wompi));
      expect(PaymentGatewayType.values, contains(PaymentGatewayType.openpay));
      expect(PaymentGatewayType.values, contains(PaymentGatewayType.conekta));
      expect(
        PaymentGatewayType.values,
        contains(PaymentGatewayType.mercadoPago),
      );
      expect(PaymentGatewayType.values, contains(PaymentGatewayType.ebanx));
    });
  });
}
