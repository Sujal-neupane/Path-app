import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/components/clay_bottom_nav_bar.dart';

/// Premium bottom navigation shell with frosted glass effect,
/// animated icons, and fluid transitions.
///
/// UX Laws applied:
/// - Fitts's Law: 48px minimum touch targets, generous hit areas
/// - Hick's Law: 4 destinations only (minimal cognitive load)
/// - Jakob's Law: Standard bottom tab pattern users already know
class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            bottomPadding > 0 ? bottomPadding : 12,
          ),
          child: ClayBottomNavBar(
            currentIndex: navigationShell.currentIndex,
            items: const [
              ClayBottomNavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              ClayBottomNavBarItem(
                icon: Icons.terrain_outlined,
                activeIcon: Icons.terrain_rounded,
                label: 'Treks',
              ),
              ClayBottomNavBarItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map_rounded,
                label: 'Map',
              ),
              ClayBottomNavBarItem(
                icon: Icons.forum_outlined,
                activeIcon: Icons.forum_rounded,
                label: 'Community',
              ),
              ClayBottomNavBarItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
              ),
            ],
            onTap: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        ),
      ),
    );
  }
}
