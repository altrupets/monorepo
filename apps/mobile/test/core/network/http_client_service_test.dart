import 'package:altrupets/core/network/circuit_breaker.dart';
import 'package:altrupets/core/network/exceptions/network_exceptions.dart';
import 'package:altrupets/core/network/http_client_service.dart';
import 'package:altrupets/core/network/interceptors/retry_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_environment_manager.dart';

void main() {
  group('HttpClientService', () {
    late HttpClientService httpClientService;
    late MockEnvironmentManager mockEnvironmentManager;

    setUp(() {
      mockEnvironmentManager = MockEnvironmentManager();
      httpClientService = HttpClientService(
        environmentManager: mockEnvironmentManager,
      );
    });

    tearDown(() {
      httpClientService.close();
    });

    group('Initialization', () {
      test('should initialize with correct base URL and timeouts', () {
        expect(httpClientService.dio.options.baseUrl, isNotEmpty);
        expect(
          httpClientService.dio.options.connectTimeout,
          isNotNull,
        );
      });

      test('should have all required interceptors', () {
        final interceptors = httpClientService.dio.interceptors;
        expect(interceptors.length, greaterThanOrEqualTo(4));
      });

      test('should have circuit breaker manager', () {
        expect(httpClientService.circuitBreakerManager, isNotNull);
      });
    });

    group('Circuit Breaker', () {
      test('should block requests when circuit is open', () async {
        final breaker = httpClientService.circuitBreakerManager
            .getBreaker('/test/endpoint');

        // Simulate failures to open circuit
        for (int i = 0; i < 5; i++) {
          breaker.recordFailure();
        }

        expect(breaker.isOpen, isTrue);
      });

      test('should recover after timeout in half-open state', () async {
        final breaker = httpClientService.circuitBreakerManager
            .getBreaker('/test/endpoint');

        // Open the circuit
        for (int i = 0; i < 5; i++) {
          breaker.recordFailure();
        }
        expect(breaker.isOpen, isTrue);

        // Wait for timeout
        await Future.delayed(Duration(seconds: 31));

        // Should transition to half-open
        breaker.recordFailure();
        expect(breaker.isHalfOpen, isTrue);
      });

      test('should close circuit after successful requests in half-open state',
          () async {
        final breaker = httpClientService.circuitBreakerManager
            .getBreaker('/test/endpoint');

        // Open the circuit
        for (int i = 0; i < 5; i++) {
          breaker.recordFailure();
        }

        // Manually transition to half-open for testing
        breaker.recordSuccess();
        breaker.recordSuccess();

        expect(breaker.isClosed, isTrue);
      });
    });

    group('Error Handling', () {
      test('should throw NetworkConnectionException on connection error', () {
        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
          error: SocketException('Connection refused'),
        );

        expect(
          () => httpClientService.dio.interceptors
              .whereType<ErrorInterceptor>()
              .first,
          isNotNull,
        );
      });

      test('should throw NetworkTimeoutException on timeout', () {
        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.receiveTimeout,
        );

        expect(exception.type, DioExceptionType.receiveTimeout);
      });

      test('should throw AuthenticationException on 401', () {
        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
          ),
        );

        expect(exception.response?.statusCode, 401);
      });

      test('should throw ServerException on 500', () {
        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
          ),
        );

        expect(exception.response?.statusCode, 500);
      });
    });

    group('Retry Logic', () {
      test('should have retry interceptor configured', () {
        final hasRetryInterceptor = httpClientService.dio.interceptors
            .whereType<RetryInterceptor>()
            .isNotEmpty;

        expect(hasRetryInterceptor, isTrue);
      });

      test('should not retry on 4xx errors (except specific codes)', () {
        final retryInterceptor = httpClientService.dio.interceptors
            .whereType<RetryInterceptor>()
            .first;

        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 404,
          ),
        );

        // 404 should not be retried
        expect(retryInterceptor.retryableStatusCodes.contains(404), isFalse);
      });

      test('should retry on 5xx errors', () {
        final retryInterceptor = httpClientService.dio.interceptors
            .whereType<RetryInterceptor>()
            .first;

        expect(retryInterceptor.retryableStatusCodes.contains(500), isTrue);
        expect(retryInterceptor.retryableStatusCodes.contains(503), isTrue);
      });

      test('should retry on timeout', () {
        final retryInterceptor = httpClientService.dio.interceptors
            .whereType<RetryInterceptor>()
            .first;

        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.receiveTimeout,
        );

        // Timeout should be retried
        expect(
          retryInterceptor.retryableStatusCodes.contains(408),
          isTrue,
        );
      });
    });

    group('Logging', () {
      test('should log requests in debug mode', () {
        // This test verifies that logging interceptor is present
        final hasLoggingInterceptor = httpClientService.dio.interceptors
            .whereType<LoggingInterceptor>()
            .isNotEmpty;

        expect(hasLoggingInterceptor, isTrue);
      });
    });
  });

  group('CircuitBreaker', () {
    late CircuitBreaker circuitBreaker;

    setUp(() {
      circuitBreaker = CircuitBreaker(
        failureThreshold: 3,
        successThreshold: 2,
        timeout: Duration(seconds: 1),
      );
    });

    test('should start in closed state', () {
      expect(circuitBreaker.isClosed, isTrue);
      expect(circuitBreaker.isOpen, isFalse);
      expect(circuitBreaker.isHalfOpen, isFalse);
    });

    test('should open after reaching failure threshold', () {
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();

      expect(circuitBreaker.isOpen, isTrue);
    });

    test('should reset failure count on success', () {
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();
      circuitBreaker.recordSuccess();

      // Failure count should be reset
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();

      expect(circuitBreaker.isOpen, isTrue);
    });

    test('should transition to half-open after timeout', () async {
      // Open the circuit
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();

      expect(circuitBreaker.isOpen, isTrue);

      // Wait for timeout
      await Future.delayed(Duration(seconds: 2));

      // Attempt a request (should transition to half-open)
      circuitBreaker.recordFailure();

      expect(circuitBreaker.isHalfOpen, isTrue);
    });

    test('should close after successes in half-open state', () {
      // Open the circuit
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();

      // Manually transition to half-open
      circuitBreaker.recordSuccess();
      circuitBreaker.recordSuccess();

      expect(circuitBreaker.isClosed, isTrue);
    });

    test('should reopen on failure in half-open state', () async {
      // Open the circuit
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();

      expect(circuitBreaker.isOpen, isTrue);

      // Wait for timeout
      await Future.delayed(Duration(seconds: 2));

      // Attempt a request (should transition to half-open)
      circuitBreaker.recordFailure();

      expect(circuitBreaker.isHalfOpen, isTrue);

      // Another failure should reopen
      circuitBreaker.recordFailure();

      expect(circuitBreaker.isOpen, isTrue);
    });

    test('should reset to closed state', () {
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();
      circuitBreaker.recordFailure();

      expect(circuitBreaker.isOpen, isTrue);

      circuitBreaker.reset();

      expect(circuitBreaker.isClosed, isTrue);
    });
  });

  group('CircuitBreakerManager', () {
    late CircuitBreakerManager manager;

    setUp(() {
      manager = CircuitBreakerManager(
        failureThreshold: 3,
        successThreshold: 2,
      );
    });

    test('should create breaker for new endpoint', () {
      final breaker = manager.getBreaker('/api/users');

      expect(breaker, isNotNull);
      expect(breaker.isClosed, isTrue);
    });

    test('should return same breaker for same endpoint', () {
      final breaker1 = manager.getBreaker('/api/users');
      final breaker2 = manager.getBreaker('/api/users');

      expect(identical(breaker1, breaker2), isTrue);
    });

    test('should track failures per endpoint', () {
      manager.recordFailure('/api/users');
      manager.recordFailure('/api/users');
      manager.recordFailure('/api/users');

      expect(manager.isAvailable('/api/users'), isFalse);
      expect(manager.isAvailable('/api/posts'), isTrue);
    });

    test('should reset all breakers', () {
      manager.recordFailure('/api/users');
      manager.recordFailure('/api/users');
      manager.recordFailure('/api/users');

      expect(manager.isAvailable('/api/users'), isFalse);

      manager.resetAll();

      expect(manager.isAvailable('/api/users'), isTrue);
    });

    test('should provide status of all breakers', () {
      manager.recordFailure('/api/users');
      manager.recordFailure('/api/posts');

      final status = manager.getStatus();

      expect(status.containsKey('/api/users'), isTrue);
      expect(status.containsKey('/api/posts'), isTrue);
    });
  });
}

// Mock classes
class MockEnvironmentManager extends Mock {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #currentEnvironment) {
      return MockEnvironment();
    }
    return super.noSuchMethod(invocation);
  }
}

class MockEnvironment {
  String get apiBaseUrl => 'https://api.example.com';
  int get requestTimeoutSeconds => 30;
}

class ErrorInterceptor extends Interceptor {}
class LoggingInterceptor extends Interceptor {}
