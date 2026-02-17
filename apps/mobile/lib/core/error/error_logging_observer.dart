import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Observer que captura errores de todos los providers de Riverpod
class ErrorLoggingObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    developer.log(
      '[Riverpod] Provider error in ${provider.name ?? provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
      name: 'RiverpodError',
    );

    // Log adicional para errores de red
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection refused') ||
        error.toString().contains('Connection timed out')) {
      developer.log(
        '[Riverpod] 🔌 Network error detected in provider',
        name: 'RiverpodNetworkError',
      );
    }
  }
}
