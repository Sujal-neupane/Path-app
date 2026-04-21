import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/trekking/presentation/screens/trek_list_screen.dart';
import '../../features/trekking/presentation/screens/trek_details_screen.dart';

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
        path: '/dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return DashboardScreen(
            onExploreTreks: () {
              context.push('/treks');
            },
          );
        },
      ),
      GoRoute(
        path: '/treks',
        builder: (BuildContext context, GoRouterState state) {
          return TrekListScreen(
            onTrekSelected: () {
              // Will be overridden by tap handler
            },
          );
        },
      ),
      GoRoute(
        path: '/trek-details/:id',
        builder: (BuildContext context, GoRouterState state) {
          final trekId = state.pathParameters['id'] ?? '';
          return TrekDetailsScreen(
            trekId: trekId,
            onCreateItinerary: () {
              // Navigate to create itinerary
              context.push('/create-itinerary/$trekId');
            },
          );
        },
      ),
      GoRoute(
        path: '/create-itinerary/:id',
        builder: (BuildContext context, GoRouterState state) {
          final trekId = state.pathParameters['id'] ?? '';
          return Scaffold(
            appBar: AppBar(title: const Text('Create Itinerary')),
            body: Center(
              child: Text('Creating itinerary for trek: $trekId'),
            ),
          );
        },
      ),
    ],
  );
}
