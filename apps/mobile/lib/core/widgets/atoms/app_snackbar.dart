import 'package:flutter/material.dart';

import '../../../core/utils/debug_helper.dart';

/// AppSnackbar - Helper para mostrar SnackBars consistentes en la app
///
/// Características:
/// - Borde redondeado (borderRadius: 15)
/// - Floating behavior
/// - Logging automático del mensaje
/// - DebugPrint automático del mensaje
class AppSnackbar {
  AppSnackbar._();

  static void show({
    required BuildContext context,
    required String message,
    String? title,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    bool showBackendCommand = false,
  }) {
    // Loggear el mensaje
    final logMessage = title != null ? '$title: $message' : message;
    debugPrint('[AppSnackbar] $logMessage');

    // Si es error de conexión, mostrar comando en logs
    if (showBackendCommand) {
      debugPrint(
        '[AppSnackbar] 💡 Para iniciar el backend, ejecuta en terminal:',
      );
      debugPrint('[AppSnackbar] 💡 $DebugHelper.backendStartCommand');
    }

    // Determinar color basado en tipo
    Color backgroundColor;
    Color textColor = Colors.white;

    if (isError) {
      backgroundColor = Colors.red.shade600;
    } else if (isSuccess) {
      backgroundColor = Colors.green.shade600;
    } else {
      backgroundColor = Theme.of(context).colorScheme.inverseSurface;
      textColor = Theme.of(context).colorScheme.onInverseSurface;
    }

    final snackBar = SnackBar(
      content: Text(message),
      duration: duration,
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: textColor,
              onPressed: onAction,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Mostrar SnackBar de error
  static void error({
    required BuildContext context,
    required String message,
    String title = 'Error',
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    bool showBackendCommand = false,
  }) {
    debugPrint('[AppSnackbar ERROR] $title: $message');
    show(
      context: context,
      message: message,
      title: title,
      isError: true,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      showBackendCommand: showBackendCommand,
    );
  }

  /// Mostrar SnackBar de éxito
  static void success({
    required BuildContext context,
    required String message,
    String title = 'Éxito',
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    debugPrint('[AppSnackbar SUCCESS] $title: $message');
    show(
      context: context,
      message: message,
      title: title,
      isSuccess: true,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Mostrar SnackBar de información
  static void info({
    required BuildContext context,
    required String message,
    String title = 'Información',
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    debugPrint('[AppSnackbar INFO] $title: $message');
    show(
      context: context,
      message: message,
      title: title,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Mostrar SnackBar de error de conexión con botón para iniciar backend
  static void connectionError({
    required BuildContext context,
    required String message,
    String title = 'Error de conexión',
  }) {
    debugPrint('[AppSnackbar ERROR] $title: $message');
    debugPrint(
      '[AppSnackbar] 💡 Para iniciar el backend, ejecuta en terminal:',
    );
    debugPrint('[AppSnackbar] 💡 $DebugHelper.backendStartCommand');

    show(
      context: context,
      message: message,
      title: title,
      isError: true,
      duration: const Duration(seconds: 6),
      actionLabel: 'Reiniciar Backend',
      onAction: () {
        DebugHelper.restartBackend();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Intentando reiniciar backend en modo local...'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      showBackendCommand: true,
    );
  }
}
