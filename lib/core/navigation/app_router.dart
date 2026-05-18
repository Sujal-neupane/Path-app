import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/features/auth/presentation/screens/login_screen.dart';
import 'package:path_app/features/auth/presentation/screens/register_screen.dart';
import 'package:path_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:path_app/features/map_weather/presentation/screens/map_weather_screen.dart';
import 'package:path_app/features/navigation/presentation/screens/main_navigation_shell.dart';
import 'package:path_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:path_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:path_app/features/splash/presentation/pages/splash_page.dart';
import 'package:path_app/features/treks/presentation/screens/trek_details_screen.dart';
import 'package:path_app/features/treks/presentation/screens/treks_screen.dart';

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
