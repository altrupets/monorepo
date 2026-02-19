import 'package:flutter_test/flutter_test.dart';
import 'package:altrupets/core/payments/domain/enums/country.dart';
import 'package:altrupets/core/payments/domain/enums/currency.dart';
import 'package:altrupets/core/payments/domain/enums/payment_method_type.dart';
import 'package:altrupets/core/payments/domain/enums/payment_status.dart';
import 'package:altrupets/core/payments/domain/entities/money.dart';
import 'package:altrupets/core/payments/domain/entities/card_token.dart';
import 'package:altrupets/core/payments/domain/entities/payment_result.dart';
import 'package:altrupets/core/payments/domain/entities/payment_gateway_configuration.dart';

void main() {
  group('Country Enum', () {
    test('should have correct codes', () {
      expect(Country.costaRica.code, 'CR');
      expect(Country.colombia.code, 'CO');
      expect(Country.mexico.code, 'MX');
      expect(Country.brazil.code, 'BR');
      expect(Country.panama.code, 'PA');
    });

    test('should have correct display names', () {
      expect(Country.costaRica.displayName, 'Costa Rica');
      expect(Country.colombia.displayName, 'Colombia');
      expect(Country.mexico.displayName, 'México');
      expect(Country.brazil.displayName, 'Brasil');
    });
  });

  group('Currency Enum', () {
    test('should have correct codes', () {
      expect(Currency.crc.code, 'CRC');
      expect(Currency.cop.code, 'COP');
      expect(Currency.mxn.code, 'MXN');
      expect(Currency.brl.code, 'BRL');
    });

    test('should have correct symbols', () {
      expect(Currency.crc.symbol, '₡');
      expect(Currency.cop.symbol, r'$');
      expect(Currency.mxn.symbol, r'$');
      expect(Currency.brl.symbol, r'R$');
    });

    test('should convert decimal to smallest unit correctly', () {
      expect(Currency.usd.fromDecimal(10.00), 1000);
      expect(Currency.cop.fromDecimal(50000.00), 5000000);
      expect(Currency.mxn.fromDecimal(150.50), 15050);
    });

    test('should convert smallest unit to decimal correctly', () {
      expect(Currency.usd.toDecimal(1000), 10.00);
      expect(Currency.cop.toDecimal(5000000), 50000.00);
    });
  });

  group('PaymentMethodType Enum', () {
    test('should have correct display names', () {
      expect(PaymentMethodType.creditCard.displayName, 'Credit Card');
      expect(PaymentMethodType.sinpeMovil.displayName, 'SINPE Móvil');
      expect(PaymentMethodType.pse.displayName, 'PSE');
      expect(PaymentMethodType.nequi.displayName, 'Nequi');
      expect(PaymentMethodType.pix.displayName, 'PIX');
      expect(PaymentMethodType.oxxo.displayName, 'OXXO');
    });

    test('should identify card methods correctly', () {
      expect(PaymentMethodType.creditCard.requiresCard, true);
      expect(PaymentMethodType.debitCard.requiresCard, true);
      expect(PaymentMethodType.pix.requiresCard, false);
      expect(PaymentMethodType.oxxo.requiresCard, false);
    });

    test('should identify wallet methods correctly', () {
      expect(PaymentMethodType.nequi.isWallet, true);
      expect(PaymentMethodType.pix.isWallet, false);
      expect(PaymentMethodType.creditCard.isWallet, false);
    });

    test('should identify cash methods correctly', () {
      expect(PaymentMethodType.oxxo.isCash, true);
      expect(PaymentMethodType.boleto.isCash, true);
      expect(PaymentMethodType.creditCard.isCash, false);
    });
  });

  group('PaymentStatus Enum', () {
    test('should correctly identify final statuses', () {
      expect(PaymentStatus.completed.isFinal, true);
      expect(PaymentStatus.rejected.isFinal, true);
      expect(PaymentStatus.cancelled.isFinal, true);
      expect(PaymentStatus.refunded.isFinal, true);
      expect(PaymentStatus.expired.isFinal, true);
      expect(PaymentStatus.error.isFinal, true);
      expect(PaymentStatus.pending.isFinal, false);
      expect(PaymentStatus.processing.isFinal, false);
      expect(PaymentStatus.approved.isFinal, false);
    });
  });

  group('Money Entity', () {
    test('should create with correct values', () {
      const money = Money(10050, Currency.mxn);
      expect(money.amount, 10050);
      expect(money.currency, Currency.mxn);
    });

    test('should format correctly', () {
      const money = Money(10050, Currency.mxn);
      expect(money.display, '\$100.50');
    });

    test('should convert to decimal correctly', () {
      const money = Money(10050, Currency.mxn);
      expect(money.decimal, 100.50);
    });

    test('should create zero amount', () {
      final money = Money.zero(Currency.usd);
      expect(money.amount, 0);
    });
  });

  group('CardToken Entity', () {
    test('should create with correct values', () {
      const token = CardToken(
        id: 'tok_test_123',
        last4: '4242',
        brand: 'visa',
        expiryMonth: '12',
        expiryYear: '2025',
        cardHolderName: 'John Doe',
      );

      expect(token.id, 'tok_test_123');
      expect(token.last4, '4242');
      expect(token.brand, 'visa');
      expect(token.expiryMonth, '12');
      expect(token.expiryYear, '2025');
      expect(token.cardHolderName, 'John Doe');
    });

    test('should format masked number correctly', () {
      const token = CardToken(
        id: 'tok_1',
        last4: '4242',
        brand: 'visa',
        expiryMonth: '12',
        expiryYear: '2025',
        cardHolderName: 'Test',
      );

      expect(token.maskedNumber, '**** **** **** 4242');
    });

    test('should format display correctly', () {
      const token = CardToken(
        id: 'tok_1',
        last4: '4242',
        brand: 'visa',
        expiryMonth: '12',
        expiryYear: '2025',
        cardHolderName: 'Test',
      );

      expect(token.display, 'visa ending in 4242');
    });

    test('should serialize to JSON correctly', () {
      const token = CardToken(
        id: 'tok_1',
        last4: '4242',
        brand: 'visa',
        expiryMonth: '12',
        expiryYear: '2025',
        cardHolderName: 'Test',
      );

      final json = token.toJson();
      expect(json['id'], 'tok_1');
      expect(json['last4'], '4242');
      expect(json['brand'], 'visa');
    });
  });

  group('PaymentResult Entity', () {
    test('should create success result correctly', () {
      final result = PaymentResult.success(
        transactionId: 'txn_123',
        status: PaymentStatus.approved,
        amount: const Money(10000, Currency.mxn),
      );

      expect(result.success, true);
      expect(result.transactionId, 'txn_123');
      expect(result.status, PaymentStatus.approved);
      expect(result.requiresAction, false);
    });

    test('should create failure result correctly', () {
      final result = PaymentResult.failure(
        message: 'Payment declined',
        code: 'declined',
      );

      expect(result.success, false);
      expect(result.errorMessage, 'Payment declined');
      expect(result.errorCode, 'declined');
      expect(result.requiresAction, false);
    });

    test('should identify pending status as requiring action', () {
      final result = PaymentResult.success(
        transactionId: 'txn_123',
        status: PaymentStatus.pending,
        amount: const Money(10000, Currency.mxn),
      );

      expect(result.requiresAction, true);
    });

    test('should identify complete status correctly', () {
      final completedResult = PaymentResult.success(
        transactionId: 'txn_123',
        status: PaymentStatus.completed,
        amount: const Money(10000, Currency.mxn),
      );

      expect(completedResult.isComplete, true);

      final rejectedResult = PaymentResult.success(
        transactionId: 'txn_123',
        status: PaymentStatus.rejected,
        amount: const Money(10000, Currency.mxn),
      );

      expect(rejectedResult.isComplete, true);

      final pendingResult = PaymentResult.success(
        transactionId: 'txn_123',
        status: PaymentStatus.pending,
        amount: const Money(10000, Currency.mxn),
      );

      expect(pendingResult.isComplete, false);
    });
  });

  group('PaymentGatewayConfiguration', () {
    test('should create with default values', () {
      const config = PaymentGatewayConfiguration(publicKey: 'pk_test_123');

      expect(config.publicKey, 'pk_test_123');
      expect(config.sandbox, true);
      expect(config.timeout, const Duration(seconds: 30));
    });

    test('should validate and throw on empty config', () {
      const config = PaymentGatewayConfiguration();

      expect(() => config.validate(), throwsA(isA<ArgumentError>()));
    });

    test('should create minimal config', () {
      final config = PaymentGatewayConfiguration.minimal(
        publicKey: 'pk_test_123',
      );

      expect(config.publicKey, 'pk_test_123');
      expect(config.sandbox, true);
    });

    test('should extract extra config', () {
      const config = PaymentGatewayConfiguration(
        publicKey: 'pk_test',
        extraConfig: {'merchantId': 'merchant_123', 'businessPrefix': 'TEST-'},
      );

      expect(config.extraConfig?['merchantId'], 'merchant_123');
      expect(config.extraConfig?['businessPrefix'], 'TEST-');
    });

    test('should copy with new values', () {
      const original = PaymentGatewayConfiguration(
        publicKey: 'pk_test',
        sandbox: true,
      );

      final copied = original.copyWith(sandbox: false, privateKey: 'sk_test');

      expect(copied.publicKey, 'pk_test');
      expect(copied.sandbox, false);
      expect(copied.privateKey, 'sk_test');
    });
  });
}
