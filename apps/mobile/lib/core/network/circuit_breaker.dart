import 'package:flutter/foundation.dart';

/// Circuit breaker states
enum CircuitBreakerState {
  /// Circuit is closed, requests are allowed
  closed,

  /// Circuit is open, requests are blocked
  open,

  /// Circuit is half-open, testing if service recovered
  halfOpen,
}

/// Circuit breaker implementation
///
/// Implements REQ-REL-002: Circuit Breaker ante fallas
/// Prevents cascading failures by stopping requests to failing services
class CircuitBreaker {
  CircuitBreaker({
    this.failureThreshold = 5,
    this.successThreshold = 2,
    this.timeout = const Duration(seconds: 30),
    this.onStateChange,
  });

  /// Current state of the circuit breaker
  CircuitBreakerState _state = CircuitBreakerState.closed;

  /// Number of consecutive failures
  int _failureCount = 0;

  /// Number of consecutive successes in half-open state
  int _successCount = 0;

  /// Timestamp of last state change
  DateTime? _lastStateChangeTime;

  /// Threshold for opening the circuit
  final int failureThreshold;

  /// Threshold for closing the circuit from half-open state
  final int successThreshold;

  /// Timeout before attempting to recover (half-open state)
  final Duration timeout;

  /// Callback when state changes
  final void Function(
    CircuitBreakerState oldState,
    CircuitBreakerState newState,
  )?
  onStateChange;

  /// Get current state
  CircuitBreakerState get state => _state;

  /// Check if requests are allowed
  bool get isOpen => _state == CircuitBreakerState.open;

  /// Check if circuit is half-open
  bool get isHalfOpen => _state == CircuitBreakerState.halfOpen;

  /// Check if circuit is closed
  bool get isClosed => _state == CircuitBreakerState.closed;

  /// Record a successful request
  void recordSuccess() {
    if (kDebugMode) {
      debugPrint('✅ Circuit breaker: Success recorded (state: $_state)');
    }

    switch (_state) {
      case CircuitBreakerState.closed:
        // Reset failure count on success
        _failureCount = 0;
        break;

      case CircuitBreakerState.halfOpen:
        // Increment success count
        _successCount++;

        // If we've had enough successes, close the circuit
        if (_successCount >= successThreshold) {
          _transitionTo(CircuitBreakerState.closed);
          _failureCount = 0;
          _successCount = 0;
        }
        break;

      case CircuitBreakerState.open:
        // Ignore successes while open
        break;
    }
  }

  /// Record a failed request
  void recordFailure() {
    if (kDebugMode) {
      debugPrint(
        '❌ Circuit breaker: Failure recorded '
        '($_failureCount/$failureThreshold, state: $_state)',
      );
    }

    switch (_state) {
      case CircuitBreakerState.closed:
        // Increment failure count
        _failureCount++;

        // If we've exceeded the threshold, open the circuit
        if (_failureCount >= failureThreshold) {
          _transitionTo(CircuitBreakerState.open);
        }
        break;

      case CircuitBreakerState.halfOpen:
        // Any failure while half-open reopens the circuit
        _transitionTo(CircuitBreakerState.open);
        _successCount = 0;
        break;

      case CircuitBreakerState.open:
        // Check if we should transition to half-open
        if (_shouldAttemptRecovery()) {
          _transitionTo(CircuitBreakerState.halfOpen);
          _successCount = 0;
        }
        break;
    }
  }

  /// Check if we should attempt recovery
  bool _shouldAttemptRecovery() {
    if (_lastStateChangeTime == null) {
      return false;
    }

    final timeSinceChange = DateTime.now().difference(_lastStateChangeTime!);
    return timeSinceChange >= timeout;
  }

  /// Transition to a new state
  void _transitionTo(CircuitBreakerState newState) {
    if (_state == newState) {
      return;
    }

    final oldState = _state;
    _state = newState;
    _lastStateChangeTime = DateTime.now();

    if (kDebugMode) {
      debugPrint(
        '🔄 Circuit breaker: Transitioning from $oldState to $newState',
      );
    }

    onStateChange?.call(oldState, newState);
  }

  /// Reset the circuit breaker
  void reset() {
    if (kDebugMode) {
      debugPrint('🔄 Circuit breaker: Reset');
    }

    _state = CircuitBreakerState.closed;
    _failureCount = 0;
    _successCount = 0;
    _lastStateChangeTime = null;
  }

  /// Get circuit breaker status
  String getStatus() {
    return 'CircuitBreaker(state: $_state, failures: $_failureCount/$failureThreshold, '
        'successes: $_successCount/$successThreshold)';
  }
}

/// Circuit breaker manager for multiple endpoints
class CircuitBreakerManager {
  CircuitBreakerManager({
    this.failureThreshold = 5,
    this.successThreshold = 2,
    this.timeout = const Duration(seconds: 30),
  });

  /// Map of endpoint to circuit breaker
  final Map<String, CircuitBreaker> _breakers = {};

  /// Default configuration for new circuit breakers
  final int failureThreshold;
  final int successThreshold;
  final Duration timeout;

  /// Get or create circuit breaker for endpoint
  CircuitBreaker getBreaker(String endpoint) {
    return _breakers.putIfAbsent(
      endpoint,
      () => CircuitBreaker(
        failureThreshold: failureThreshold,
        successThreshold: successThreshold,
        timeout: timeout,
      ),
    );
  }

  /// Record success for endpoint
  void recordSuccess(String endpoint) {
    getBreaker(endpoint).recordSuccess();
  }

  /// Record failure for endpoint
  void recordFailure(String endpoint) {
    getBreaker(endpoint).recordFailure();
  }

  /// Check if endpoint is available
  bool isAvailable(String endpoint) {
    return !getBreaker(endpoint).isOpen;
  }

  /// Reset all circuit breakers
  void resetAll() {
    for (final breaker in _breakers.values) {
      breaker.reset();
    }
  }

  /// Get status of all circuit breakers
  Map<String, String> getStatus() {
    return {
      for (final entry in _breakers.entries) entry.key: entry.value.getStatus(),
    };
  }
}
