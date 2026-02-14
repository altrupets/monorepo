import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A service that handles navigation actions.
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void pop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // Fallback to global navigator if context pop isn't possible but state exists
      navigatorKey.currentState?.maybePop();
    }
  }

  void push(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => page),
    );
  }

  /// Specialized pop that doesn't require context
  void globalPop() {
    navigatorKey.currentState?.maybePop();
  }
}

/// Provider for the NavigationService.
final navigationProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});
