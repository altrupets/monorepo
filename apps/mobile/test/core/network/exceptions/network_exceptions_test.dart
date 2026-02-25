import 'package:flutter_test/flutter_test.dart';
import 'package:altrupets/core/network/exceptions/network_exceptions.dart';

void main() {
  group('NetworkConnectionException', () {
    test('should have default message', () {
      final exception = NetworkConnectionException();

      expect(exception.message, 'No internet connection');
    });

    test('should accept custom message', () {
      final exception = NetworkConnectionException(
        message: 'Custom connection error',
      );

      expect(exception.message, 'Custom connection error');
    });
  });

  group('NetworkTimeoutException', () {
    test('should have default message', () {
      final exception = NetworkTimeoutException(
        timeout: const Duration(seconds: 30),
      );

      expect(exception.message, 'Request timeout');
      expect(exception.timeout, const Duration(seconds: 30));
    });

    test('should accept custom message', () {
      final exception = NetworkTimeoutException(
        timeout: const Duration(seconds: 60),
        message: 'Custom timeout',
      );

      expect(exception.message, 'Custom timeout');
    });
  });

  group('ServerException', () {
    test('should have correct statusCode and message', () {
      final exception = ServerException(
        statusCode: 500,
        message: 'Server error',
      );

      expect(exception.statusCode, 500);
      expect(exception.message, 'Server error');
    });

    test('should include statusCode in default message', () {
      final exception = ServerException(statusCode: 503);

      expect(exception.message, 'Server error: 503');
    });

    test('should store responseBody', () {
      final responseBody = {'error': 'Something went wrong'};
      final exception = ServerException(
        statusCode: 500,
        responseBody: responseBody,
      );

      expect(exception.responseBody, responseBody);
    });
  });

  group('AuthenticationException', () {
    test('should have default message', () {
      final exception = AuthenticationException();

      expect(exception.message, 'Authentication failed');
    });

    test('should accept custom message', () {
      final exception = AuthenticationException(message: 'Invalid token');

      expect(exception.message, 'Invalid token');
    });
  });

  group('AuthorizationException', () {
    test('should have default message', () {
      final exception = AuthorizationException();

      expect(exception.message, 'Access denied');
    });

    test('should accept custom message', () {
      final exception = AuthorizationException(
        message: 'Insufficient permissions',
      );

      expect(exception.message, 'Insufficient permissions');
    });
  });

  group('NotFoundException', () {
    test('should have default message', () {
      final exception = NotFoundException();

      expect(exception.message, 'Resource not found');
    });

    test('should accept custom message', () {
      final exception = NotFoundException(message: 'User not found');

      expect(exception.message, 'User not found');
    });
  });

  group('CancelledException', () {
    test('should have default message', () {
      final exception = CancelledException();

      expect(exception.message, 'Request cancelled');
    });

    test('should accept custom message', () {
      final exception = CancelledException(message: 'User cancelled request');

      expect(exception.message, 'User cancelled request');
    });
  });

  group('UnknownException', () {
    test('should have default message', () {
      final exception = UnknownException();

      expect(exception.message, 'Unknown error occurred');
    });

    test('should accept custom message', () {
      final exception = UnknownException(message: 'Unexpected error');

      expect(exception.message, 'Unexpected error');
    });
  });

  group('GraphQLException', () {
    test('should have correct errors and message', () {
      final errors = ['Error 1', 'Error 2'];
      final exception = GraphQLException(errors: errors);

      expect(exception.errors, errors);
      expect(exception.message, 'GraphQL error: 2 error(s)');
    });

    test('should accept custom message', () {
      final exception = GraphQLException(
        errors: ['Error'],
        message: 'Custom GraphQL error',
      );

      expect(exception.message, 'Custom GraphQL error');
    });
  });

  group('ValidationException', () {
    test('should have default message', () {
      final exception = ValidationException();

      expect(exception.message, 'Validation error');
    });

    test('should store validation errors', () {
      final validationErrors = {
        'email': 'Invalid email format',
        'password': 'Password too short',
      };
      final exception = ValidationException(validationErrors: validationErrors);

      expect(exception.validationErrors, validationErrors);
    });
  });

  group('ParseException', () {
    test('should have default message', () {
      final exception = ParseException();

      expect(exception.message, 'Failed to parse response');
    });

    test('should accept custom message', () {
      final exception = ParseException(message: 'Invalid JSON');

      expect(exception.message, 'Invalid JSON');
    });
  });
}
