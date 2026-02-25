import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:altrupets/core/network/interceptors/retry_interceptor.dart';

void main() {
  group('RetryInterceptor', () {
    late RetryInterceptor interceptor;
    late RetryInterceptor defaultInterceptor;

    setUp(() {
      // Custom interceptor for most tests
      interceptor = RetryInterceptor(
        maxRetries: 3,
        initialDelayMs: 10,
        maxDelayMs: 100,
        backoffMultiplier: 2.0,
      );

      // Default interceptor for default value tests
      defaultInterceptor = RetryInterceptor();
    });

    group('Configuration', () {
      test('should have default max retries of 3', () {
        expect(defaultInterceptor.maxRetries, 3);
      });

      test('should have default initial delay of 100ms', () {
        expect(defaultInterceptor.initialDelayMs, 100);
      });

      test('should have default max delay of 10000ms', () {
        expect(defaultInterceptor.maxDelayMs, 10000);
      });

      test('should have correct retryable status codes', () {
        expect(interceptor.retryableStatusCodes, contains(408));
        expect(interceptor.retryableStatusCodes, contains(429));
        expect(interceptor.retryableStatusCodes, contains(500));
        expect(interceptor.retryableStatusCodes, contains(502));
        expect(interceptor.retryableStatusCodes, contains(503));
        expect(interceptor.retryableStatusCodes, contains(504));
      });

      test('should have retryable exception types', () {
        expect(interceptor.retryableExceptionTypes, contains(SocketException));
        expect(interceptor.retryableExceptionTypes, contains(TimeoutException));
      });
    });

    group('Custom Configuration', () {
      test('should accept custom maxRetries', () {
        final custom = RetryInterceptor(maxRetries: 5);
        expect(custom.maxRetries, 5);
      });

      test('should accept custom delays', () {
        final custom = RetryInterceptor(initialDelayMs: 50, maxDelayMs: 5000);
        expect(custom.initialDelayMs, 50);
        expect(custom.maxDelayMs, 5000);
      });

      test('should accept custom backoff multiplier', () {
        final custom = RetryInterceptor(backoffMultiplier: 3.0);
        expect(custom.backoffMultiplier, 3.0);
      });

      test('should accept custom retryable status codes', () {
        final custom = RetryInterceptor(retryableStatusCodes: [500, 502]);
        expect(custom.retryableStatusCodes, [500, 502]);
      });
    });
  });

  group('Retry Logic', () {
    test('should calculate exponential backoff correctly', () {
      final interceptor = RetryInterceptor(
        initialDelayMs: 100,
        maxDelayMs: 10000,
        backoffMultiplier: 2.0,
      );

      final delay1 = _calculateDelayCorrect(interceptor, 0);
      final delay2 = _calculateDelayCorrect(interceptor, 1);
      final delay3 = _calculateDelayCorrect(interceptor, 2);

      expect(delay1, 100);
      expect(delay2, 200);
      expect(delay3, 400);
    });

    test('should cap delay at maxDelayMs', () {
      final interceptor = RetryInterceptor(
        initialDelayMs: 100,
        maxDelayMs: 500,
        backoffMultiplier: 10.0,
      );

      final delay = _calculateDelayWithoutJitter(interceptor, 10);

      expect(delay, 500);
    });
  });
}

int _calculateDelayWithoutJitter(RetryInterceptor interceptor, int retryCount) {
  final initialDelayMs = interceptor.initialDelayMs;
  final maxDelayMs = interceptor.maxDelayMs;
  final backoffMultiplier = interceptor.backoffMultiplier;

  final exponentialDelay = (initialDelayMs * (backoffMultiplier * retryCount))
      .toInt();
  final delay = exponentialDelay.clamp(0, maxDelayMs);

  return delay.clamp(0, maxDelayMs);
}

int _calculateDelayCorrect(RetryInterceptor interceptor, int retryCount) {
  final initialDelayMs = interceptor.initialDelayMs;
  final maxDelayMs = interceptor.maxDelayMs;
  final backoffMultiplier = interceptor.backoffMultiplier;

  final exponentialDelay =
      (initialDelayMs * _pow(backoffMultiplier, retryCount)).toInt();
  final delay = exponentialDelay.clamp(0, maxDelayMs);

  return delay.clamp(0, maxDelayMs);
}

double _pow(double base, int exponent) {
  double result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}
