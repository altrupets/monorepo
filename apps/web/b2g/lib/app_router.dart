import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shared/layout/app_shell.dart';
import 'features/campaigns/campaigns_page.dart';
import 'features/complaints/complaints_page.dart';
import 'features/complaints/public/public_complaint_form.dart';
import 'features/complaints/public/public_tracking_page.dart';
import 'features/disbursements/disbursements_page.dart';
import 'features/emergencies/emergencies_page.dart';
import 'features/settings/approval_rules_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/campaigns',
  routes: [
    // ─── Public routes (OUTSIDE ShellRoute — no sidebar, no auth) ──
    GoRoute(
      path: '/denuncias',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PublicComplaintForm(),
    ),
    GoRoute(
      path: '/denuncias/rastreo/:code',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final code = state.pathParameters['code'] ?? '';
        return PublicTrackingPage(trackingCode: code);
      },
    ),

    // ─── Dashboard routes (inside ShellRoute — sidebar + auth) ─────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        final loc = state.uri.path;
        int panelIndex = 0;
        if (loc.startsWith('/campaigns')) panelIndex = 0;
        if (loc.startsWith('/disbursements')) panelIndex = 1;
        if (loc.startsWith('/complaints')) panelIndex = 2;
        if (loc.startsWith('/emergencies')) panelIndex = 3;
        if (loc.startsWith('/approval-rules')) panelIndex = 9;

        return AppShell(
          selectedNavIndex: 0,
          selectedPanelIndex: panelIndex,
          onPanelChanged: (index) {
            switch (index) {
              case 0:
                context.go('/campaigns');
                break;
              case 1:
                context.go('/disbursements');
                break;
              case 2:
                context.go('/complaints');
                break;
              case 3:
                context.go('/emergencies');
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
          path: '/campaigns',
          builder: (context, state) => const CampaignsPage(),
        ),
        GoRoute(
          path: '/disbursements',
          builder: (context, state) => const DisbursementsPage(),
        ),
        GoRoute(
          path: '/complaints',
          builder: (context, state) => const ComplaintsPage(),
        ),
        GoRoute(
          path: '/emergencies',
          builder: (context, state) => const EmergenciesPage(),
        ),
        GoRoute(
          path: '/approval-rules',
          builder: (context, state) => const ApprovalRulesPage(),
        ),
      ],
    ),
  ],
);
