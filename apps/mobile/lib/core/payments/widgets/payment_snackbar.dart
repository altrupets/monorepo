import 'package:flutter/material.dart';

class PaymentSnackbar {
  PaymentSnackbar._();

  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    if (isError) {
      backgroundColor = Colors.red.shade600;
    } else if (isSuccess) {
      backgroundColor = Colors.green.shade600;
    } else {
      backgroundColor = Theme.of(context).colorScheme.inverseSurface;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  static void error({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(context: context, message: message, isError: true, duration: duration);
  }

  static void success({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      isSuccess: true,
      duration: duration,
    );
  }
}
