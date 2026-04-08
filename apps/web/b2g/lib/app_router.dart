import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shared/layout/app_shell.dart';
import 'features/disbursements/disbursements_page.dart';
import 'features/settings/approval_rules_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/disbursements',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        // Determine panel index from current route
        final loc = state.uri.path;
        int panelIndex = 1; // default: Desembolsos
        if (loc.startsWith('/approval-rules')) panelIndex = 9;

        return AppShell(
          selectedNavIndex: 0,
          selectedPanelIndex: panelIndex,
          onPanelChanged: (index) {
            switch (index) {
              case 1:
                context.go('/disbursements');
                break;
              case 9:
                context.go('/approval-rules');
                break;
            }
          },
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/disbursements',
          builder: (context, state) => const DisbursementsPage(),
        ),
        GoRoute(
          path: '/approval-rules',
          builder: (context, state) => const ApprovalRulesPage(),
        ),
      ],
    ),
  ],
);
