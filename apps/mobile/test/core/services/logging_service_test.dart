import 'package:flutter_test/flutter_test.dart';
import 'package:altrupets/core/services/logging_service.dart';

void main() {
  group('LogLevel', () {
    test('should have correct order', () {
      expect(LogLevel.debug.index, 0);
      expect(LogLevel.info.index, 1);
      expect(LogLevel.warning.index, 2);
      expect(LogLevel.error.index, 3);
      expect(LogLevel.critical.index, 4);
    });
  });

  group('LogEntry', () {
    test('should create with required fields', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test message',
        timestamp: DateTime.now(),
      );

      expect(entry.level, LogLevel.info);
      expect(entry.message, 'Test message');
      expect(entry.timestamp, isNotNull);
      expect(entry.tag, isNull);
      expect(entry.context, isNull);
      expect(entry.exception, isNull);
    });

    test('should create with all fields', () {
      final timestamp = DateTime.now();
      final stackTrace = StackTrace.current;
      final entry = LogEntry(
        level: LogLevel.error,
        message: 'Error message',
        timestamp: timestamp,
        tag: 'TEST_TAG',
        context: {'key': 'value'},
        stackTrace: stackTrace,
        exception: Exception('Test exception'),
      );

      expect(entry.level, LogLevel.error);
      expect(entry.message, 'Error message');
      expect(entry.timestamp, timestamp);
      expect(entry.tag, 'TEST_TAG');
      expect(entry.context, {'key': 'value'});
      expect(entry.stackTrace, stackTrace);
      expect(entry.exception, isNotNull);
    });

    test('toString should return formatted string', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test message',
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final str = entry.toString();

      expect(str, contains('LogEntry'));
      expect(str, contains('LogLevel.info'));
      expect(str, contains('Test message'));
    });
  });

  group('LoggingService', () {
    late LoggingService loggingService;

    setUp(() {
      loggingService = LoggingService();
      loggingService.setMinLogLevel(LogLevel.debug);
    });

    group('Singleton', () {
      test('should return same instance', () {
        final instance1 = LoggingService();
        final instance2 = LoggingService();

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Log Level Configuration', () {
      test('should set minimum log level', () {
        loggingService.setMinLogLevel(LogLevel.warning);

        expect(LogLevel.warning.index, greaterThan(LogLevel.debug.index));
      });
    });

    group('Observers', () {
      test('should add observer', () {
        final observer = TestLogObserver();
        loggingService.addObserver(observer);

        loggingService.info('Test message');

        expect(observer.receivedLogs.length, 1);
        expect(observer.receivedLogs.first.message, 'Test message');
      });

      test('should remove observer', () {
        final observer = TestLogObserver();
        loggingService.addObserver(observer);
        loggingService.removeObserver(observer);

        loggingService.info('Test message');

        expect(observer.receivedLogs.length, 0);
      });

      test('should notify multiple observers', () {
        final observer1 = TestLogObserver();
        final observer2 = TestLogObserver();
        loggingService.addObserver(observer1);
        loggingService.addObserver(observer2);

        loggingService.info('Test message');

        expect(observer1.receivedLogs.length, 1);
        expect(observer2.receivedLogs.length, 1);
      });
    });

    group('Logging Methods', () {
      test('should log debug message', () {
        final observer = TestLogObserver();
        loggingService.addObserver(observer);

        loggingService.debug('Debug message');

        expect(observer.receivedLogs.length, 1);
        expect(observer.receivedLogs.first.level, LogLevel.debug);
        expect(observer.receivedLogs.first.message, 'Debug message');
      });

      test('should log info message', () {
        final observer = TestLogObserver();
        loggingService.addObserver(observer);

        loggingService.info('Info message');

        expect(observer.receivedLogs.length, 1);
        expect(observer.receivedLogs.first.level, LogLevel.info);
        expect(observer.receivedLogs.first.message, 'Info message');
      });

      test('should log warning message', () {
        final observer = TestLogObserver();
        loggingService.addObserver(observer);

        loggingService.warning('Warning message');

        expect(observer.receivedLogs.length, 1);
        expect(observer.receivedLogs.first.level, LogLevel.warning);
        expect(observer.receivedLogs.first.message, 'Warning message');
      });

      test('should log error message', () {
        final observer = TestLogObserver();
        loggingService.addObserver(observer);

        loggingService.error('Error message');

        expect(observer.receivedLogs.length, 1);
        expect(observer.receivedLogs.first.level, LogLevel.error);
        expect(observer.receivedLogs.first.message, 'Error message');
      });

      test('should log critical message', () {
        final observer = TestLogObserver();
        loggingService.addObserver(observer);

        loggingService.critical('Critical message');

        expect(observer.receivedLogs.length, 1);
        expect(observer.receivedLogs.first.level, LogLevel.critical);
        expect(observer.receivedLogs.first.message, 'Critical message');
      });

      test('should include tag in log', () {
        final observer = TestLogObserver();
        loggingService.addObserver(observer);

        loggingService.info('Tagged message', tag: 'MY_TAG');

        expect(observer.receivedLogs.first.tag, 'MY_TAG');
      });

      test('should include context in log', () {
        final observer = TestLogObserver();
        loggingService.addObserver(observer);

        loggingService.info('Context message', context: {'userId': '123'});

        expect(observer.receivedLogs.first.context, {'userId': '123'});
      });

      test('should include exception in log', () {
        final observer = TestLogObserver();
        loggingService.addObserver(observer);

        loggingService.error('Exception message', exception: Exception('Test'));

        expect(observer.receivedLogs.first.exception, isNotNull);
      });
    });

    group('Log Level Filtering', () {
      test('should filter logs below minimum level', () {
        loggingService.setMinLogLevel(LogLevel.error);
        final observer = TestLogObserver();
        loggingService.addObserver(observer);

        loggingService.debug('Debug');
        loggingService.info('Info');
        loggingService.warning('Warning');

        expect(observer.receivedLogs.length, 0);
      });

      test('should log at or above minimum level', () {
        loggingService.setMinLogLevel(LogLevel.warning);
        final observer = TestLogObserver();
        loggingService.addObserver(observer);

        loggingService.warning('Warning');
        loggingService.error('Error');
        loggingService.critical('Critical');

        expect(observer.receivedLogs.length, 3);
      });
    });
  });

  group('FileLogObserver', () {
    test('should store logs', () {
      final observer = FileLogObserver();
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test',
        timestamp: DateTime.now(),
      );

      observer.onLog(entry);

      expect(observer.logs.length, 1);
      expect(observer.logs.first.message, 'Test');
    });

    test('should clear logs', () {
      final observer = FileLogObserver();
      observer.onLog(
        LogEntry(
          level: LogLevel.info,
          message: 'Test',
          timestamp: DateTime.now(),
        ),
      );

      observer.clear();

      expect(observer.logs.length, 0);
    });

    test('should limit to 1000 entries', () {
      final observer = FileLogObserver();

      for (int i = 0; i < 1005; i++) {
        observer.onLog(
          LogEntry(
            level: LogLevel.info,
            message: 'Test $i',
            timestamp: DateTime.now(),
          ),
        );
      }

      expect(observer.logs.length, 1000);
    });

    test('should export as JSON', () {
      final observer = FileLogObserver();
      observer.onLog(
        LogEntry(
          level: LogLevel.info,
          message: 'Test',
          timestamp: DateTime(2024, 1, 1),
        ),
      );

      final json = observer.exportAsJson();

      expect(json, contains('Test'));
      expect(json, contains('info'));
    });
  });
}

class TestLogObserver implements LogObserver {
  final List<LogEntry> receivedLogs = [];

  @override
  void onLog(LogEntry entry) {
    receivedLogs.add(entry);
  }
}
