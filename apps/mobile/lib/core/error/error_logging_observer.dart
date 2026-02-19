import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Observer que captura errores de todos los providers de Riverpod
final class ErrorLoggingObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    developer.log(
      '[Riverpod] Provider error in ${context.provider.name ?? context.provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
      name: 'RiverpodError',
    );

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
