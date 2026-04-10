import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/timer/nap_preset.dart';
import '../../ui/screens/home_screen.dart';
import '../../ui/screens/nap_stack_screen.dart';
import '../../ui/screens/paywall_screen.dart';
import '../../ui/screens/stats_screen.dart';
import '../../ui/screens/timer_screen.dart';
import '../../ui/shell/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/nap-stack',
              builder: (_, __) => const NapStackScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              builder: (_, __) => const StatsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Timer — poza shellem, bez bottom nav
    GoRoute(
      path: '/timer/:presetType',
      pageBuilder: (context, state) {
        final typeName = state.pathParameters['presetType']!;
        final preset = presetByType(NapTypeName.fromName(typeName));
        return _slideUpPage(TimerScreen(preset: preset));
      },
    ),

    // Paywall — modal
    GoRoute(
      path: '/paywall',
      pageBuilder: (context, state) => _slideUpPage(
        const PaywallScreen(),
        fullscreenDialog: true,
      ),
    ),
  ],
);

CustomTransitionPage<void> _slideUpPage(
  Widget child, {
  bool fullscreenDialog = false,
}) =>
    CustomTransitionPage(
      fullscreenDialog: fullscreenDialog,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
