import 'package:flutter/foundation.dart';

/// Log levels for structured logging
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Structured logging service
/// 
/// Implements REQ-FLT-020: Logging estructurado
/// Provides centralized, structured logging following cloud-native principles
class LoggingService {
  /// Singleton instance
  static final LoggingService _instance = LoggingService._internal();

  /// Minimum log level to output
  LogLevel _minLogLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// List of log observers
  final List<LogObserver> _observers = [];

  LoggingService._internal();

  /// Get singleton instance
  factory LoggingService() {
    return _instance;
  }

  /// Set minimum log level
  void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
  }

  /// Add log observer
  void addObserver(LogObserver observer) {
    _observers.add(observer);
  }

  /// Remove log observer
  void removeObserver(LogObserver observer) {
    _observers.remove(observer);
  }

  /// Log debug message
  void debug(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      context: context,
      stackTrace: stackTrace,
    );
  }

  /// Log info message
  void info(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      context: context,
      stackTrace: stackTrace,
    );
  }

  /// Log warning message
  void warning(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      context: context,
      stackTrace: stackTrace,
    );
  }

  /// Log error message
  void error(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
    dynamic exception,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      context: context,
      stackTrace: stackTrace,
      exception: exception,
    );
  }

  /// Log critical message
  void critical(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
    dynamic exception,
  }) {
    _log(
      LogLevel.critical,
      message,
      tag: tag,
      context: context,
      stackTrace: stackTrace,
      exception: exception,
    );
  }

  /// Internal log method
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
    dynamic exception,
  }) {
    // Check if this log level should be output
    if (level.index < _minLogLevel.index) {
      return;
    }

    // Create log entry
    final logEntry = LogEntry(
      level: level,
      message: message,
      tag: tag,
      context: context,
      stackTrace: stackTrace,
      exception: exception,
      timestamp: DateTime.now(),
    );

    // Output to console
    _outputToConsole(logEntry);

    // Notify observers
    for (final observer in _observers) {
      observer.onLog(logEntry);
    }
  }

  /// Output log to console
  void _outputToConsole(LogEntry entry) {
    final emoji = _getEmoji(entry.level);
    final levelName = entry.level.toString().split('.').last.toUpperCase();
    final tag = entry.tag != null ? '[${entry.tag}] ' : '';
    final timestamp = entry.timestamp.toIso8601String();

    final buffer = StringBuffer();
    buffer.writeln('$emoji $levelName $tag$timestamp');
    buffer.write('   ${entry.message}');

    if (entry.context != null && entry.context!.isNotEmpty) {
      buffer.writeln();
      buffer.write('   Context: ${entry.context}');
    }

    if (entry.exception != null) {
      buffer.writeln();
      buffer.write('   Exception: ${entry.exception}');
    }

    if (entry.stackTrace != null) {
      buffer.writeln();
      buffer.write('   StackTrace: ${entry.stackTrace}');
    }

    debugPrint(buffer.toString());
  }

  /// Get emoji for log level
  String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔵';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🔴';
    }
  }
}

/// Log entry
class LogEntry {
  final LogLevel level;
  final String message;
  final String? tag;
  final Map<String, dynamic>? context;
  final StackTrace? stackTrace;
  final dynamic exception;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    this.tag,
    this.context,
    this.stackTrace,
    this.exception,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'LogEntry(level: $level, message: $message, tag: $tag, '
        'timestamp: $timestamp)';
  }
}

/// Observer for log entries
abstract class LogObserver {
  /// Called when a log entry is created
  void onLog(LogEntry entry);
}

/// Console log observer (for testing)
class ConsoleLogObserver implements LogObserver {
  @override
  void onLog(LogEntry entry) {
    // Already handled by LoggingService._outputToConsole
  }
}

/// File log observer (for production)
class FileLogObserver implements LogObserver {
  final List<LogEntry> _logs = [];

  /// Get all logged entries
  List<LogEntry> get logs => List.unmodifiable(_logs);

  @override
  void onLog(LogEntry entry) {
    _logs.add(entry);

    // Keep only last 1000 entries to avoid memory issues
    if (_logs.length > 1000) {
      _logs.removeRange(0, _logs.length - 1000);
    }
  }

  /// Clear all logs
  void clear() {
    _logs.clear();
  }

  /// Export logs as JSON
  String exportAsJson() {
    return _logs
        .map((entry) => {
              'level': entry.level.toString().split('.').last,
              'message': entry.message,
              'tag': entry.tag,
              'context': entry.context,
              'exception': entry.exception?.toString(),
              'timestamp': entry.timestamp.toIso8601String(),
            })
        .toList()
        .toString();
  }
}

/// Global logging service instance
final logger = LoggingService();
