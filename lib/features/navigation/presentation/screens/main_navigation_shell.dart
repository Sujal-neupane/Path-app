import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/theme/light_colors.dart';

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            elevation: 0,
            backgroundColor: Colors.transparent,
            indicatorColor: LightColors.primaryLight,
            height: 72,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.terrain_outlined),
                selectedIcon: Icon(Icons.terrain_rounded),
                label: 'Treks',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map_rounded),
                label: 'Map+Weather',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
