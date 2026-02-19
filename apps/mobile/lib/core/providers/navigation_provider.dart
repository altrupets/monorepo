import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/core/theme/app_motion.dart';

/// A custom PageRoute that respects Design System Motion tokens.
class AppPageRoute<T> extends MaterialPageRoute<T> {
  AppPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
    super.allowSnapshotting,
  });

  @override
  Duration get transitionDuration => AppMotion.medium;
}

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
    Navigator.push(context, AppPageRoute<void>(builder: (context) => page));
  }

  void navigateReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      AppPageRoute<void>(builder: (context) => page),
    );
  }

  void navigateAndRemoveAll(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      AppPageRoute<void>(builder: (context) => page),
      (route) => false,
    );
  }

  /// Specialized pop that doesn't require context
  void globalPop() {
    navigatorKey.currentState?.maybePop();
  }

  void navigateAndRemoveAllGlobal(Widget page) {
    final state = navigatorKey.currentState;
    if (state == null) {
      return;
    }
    state.pushAndRemoveUntil(
      AppPageRoute<void>(builder: (context) => page),
      (route) => false,
    );
  }
}

/// Provider for the NavigationService.
final navigationProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});
