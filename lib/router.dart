import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/active_session_screen.dart';
import 'screens/calibration_screen.dart';
import 'screens/create_grip_screen.dart';
import 'screens/grips_screen.dart';
import 'screens/home_screen.dart';
import 'screens/measurement_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/protocol_setup_screen.dart';
import 'screens/session_detail_screen.dart';
import 'screens/session_history_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/common/app_shell.dart';

CustomTransitionPage<void> _slidePage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
      return SlideTransition(position: slide, child: child);
    },
  );
}

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final onboarded = await isOnboardingComplete();
    final isOnboardingRoute = state.matchedLocation == '/onboarding';
    if (!onboarded && !isOnboardingRoute) return '/onboarding';
    if (onboarded && isOnboardingRoute) return '/';
    return null;
  },
  routes: [
    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Shell route — pages with bottom nav
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/grips',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: GripsScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SessionHistoryScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),

    // Top-level routes — no bottom nav (immersive)
    GoRoute(
      path: '/grips/create',
      pageBuilder: (context, state) =>
          _slidePage(child: const CreateGripScreen(), state: state),
    ),
    GoRoute(
      path: '/measurements',
      pageBuilder: (context, state) =>
          _slidePage(child: const MeasurementScreen(), state: state),
    ),
    GoRoute(
      path: '/session/setup',
      pageBuilder: (context, state) {
        final mode = state.uri.queryParameters['mode'] == 'manage'
            ? SetupMode.manage
            : SetupMode.train;
        return _slidePage(
          child: ProtocolSetupScreen(mode: mode),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/session/active',
      pageBuilder: (context, state) =>
          _slidePage(child: const ActiveSessionScreen(), state: state),
    ),
    GoRoute(
      path: '/history/:id',
      pageBuilder: (context, state) => _slidePage(
        child: SessionDetailScreen(sessionId: state.pathParameters['id']!),
        state: state,
      ),
    ),
    GoRoute(
      path: '/settings/calibration',
      pageBuilder: (context, state) =>
          _slidePage(child: const CalibrationScreen(), state: state),
    ),
  ],
);
