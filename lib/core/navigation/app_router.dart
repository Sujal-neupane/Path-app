import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/features/auth/presentation/screens/login_screen.dart';
import 'package:path_app/features/auth/presentation/screens/register_screen.dart';
import 'package:path_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:path_app/features/sos/presentation/screens/sos_history_screen.dart';
import 'package:path_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:path_app/features/map_weather/presentation/screens/map_weather_screen.dart';
import 'package:path_app/features/map_weather/presentation/screens/trail_navigator_screen.dart';
import 'package:path_app/features/navigation/presentation/screens/main_navigation_shell.dart';
import 'package:path_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:path_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:path_app/features/community/presentation/screens/community_screen.dart';
import 'package:path_app/features/splash/presentation/pages/splash_page.dart';
import 'package:path_app/features/treks/presentation/screens/trek_details_screen.dart';
import 'package:path_app/features/treks/presentation/screens/treks_screen.dart';
import 'package:path_app/features/ai_guide/presentation/screens/ai_guide_screen.dart';
import 'package:path_app/features/ams/presentation/screens/ams_tracker_screen.dart';
import 'package:path_app/features/gear/presentation/screens/gear_screen.dart';
import 'package:path_app/features/journal/presentation/screens/journal_screen.dart';
import 'package:path_app/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:path_app/features/permits/presentation/screens/permits_screen.dart';
import 'package:path_app/features/permits/presentation/screens/permit_checkout_screen.dart';
import 'package:path_app/features/permits/presentation/screens/permit_success_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashPage();
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingPage();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: '/sos-history',
        builder: (BuildContext context, GoRouterState state) {
          return const SosHistoryScreen();
        },
      ),
      GoRoute(
        path: '/ai-guide',
        builder: (BuildContext context, GoRouterState state) {
          return const AiGuideScreen();
        },
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (BuildContext context, GoRouterState state) {
          return const LeaderboardScreen();
        },
      ),
      GoRoute(
        path: '/ams-tracker',
        builder: (BuildContext context, GoRouterState state) {
          return const AmsTrackerScreen();
        },
      ),
      GoRoute(
        path: '/gear/:trekId',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['trekId'] ?? '';
          final name = state.extra as String? ?? 'Trek';
          return GearScreen(trekId: id, trekName: name);
        },
      ),
      GoRoute(
        path: '/journal/:trekId',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['trekId'] ?? '';
          final name = state.extra as String? ?? 'Trek';
          return JournalScreen(trekId: id, trekName: name);
        },
      ),
      GoRoute(
        path: '/permits',
        builder: (BuildContext context, GoRouterState state) {
          return const PermitsScreen();
        },
      ),
      GoRoute(
        path: '/permits/checkout',
        builder: (BuildContext context, GoRouterState state) {
          final regionKey = state.extra as String? ?? 'Everest';
          return PermitCheckoutScreen(regionKey: regionKey);
        },
      ),
      GoRoute(
        path: '/permits/success',
        builder: (BuildContext context, GoRouterState state) {
          return const PermitSuccessScreen();
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (BuildContext context, GoRouterState state) {
                  return const DashboardScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/treks',
                builder: (BuildContext context, GoRouterState state) {
                  return const TreksScreen();
                },
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (BuildContext context, GoRouterState state) {
                      final id = state.pathParameters['id'] ?? '';
                      return TrekDetailsScreen(trekId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map-weather',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapWeatherScreen();
                },
                routes: [
                  GoRoute(
                    path: 'navigator',
                    builder: (BuildContext context, GoRouterState state) {
                      final trekId = state.extra as String? ?? '';
                      return TrailNavigatorScreen(trekId: trekId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                builder: (BuildContext context, GoRouterState state) {
                  return const CommunityScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (BuildContext context, GoRouterState state) {
                  return const ProfileScreen();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
