import 'package:flutter/material.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:path_app/features/trekking/presentation/screens/trek_list_screen.dart';
import 'package:path_app/features/trekking/presentation/screens/route_screen.dart';

/// Main shell screen with 4-tab bottom navigation
///
/// Tabs:
/// 1. Home (Dashboard)
/// 2. Treks (Browse/discover)
/// 3. Route (Active trek navigation - map)
/// 4. Profile (User settings)
///
/// Uses IndexedStack for efficient tab switching
/// Maintains state across tab changes using StatefulWidget
class MainNavigationShell extends StatefulWidget {
  final int initialTabIndex;

  const MainNavigationShell({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _selectedIndex;

  /// Tab destinations
  static const List<NavTab> _tabs = [
    NavTab(icon: Icons.home_rounded, label: 'Home', index: 0),
    NavTab(icon: Icons.hiking_rounded, label: 'Treks', index: 1),
    NavTab(icon: Icons.map_rounded, label: 'Route', index: 2),
    NavTab(icon: Icons.person_rounded, label: 'Profile', index: 3),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Home tab - Dashboard with navigation callback
          DashboardScreen(
            onExploreTreks: () {
              setState(() => _selectedIndex = 1); // Navigate to Treks tab
            },
          ),
          const TrekListScreen(),
          const RouteScreen(),
          // ProfileScreen(),
          const Placeholder(), // Profile tab placeholder
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: LightColors.forestPrimary,
        unselectedItemColor: LightColors.textSecondary.withValues(alpha: 0.5),
        selectedLabelStyle: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w900,
          color: LightColors.forestPrimary,
        ),
        unselectedLabelStyle: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: LightColors.textSecondary.withValues(alpha: 0.5),
          fontSize: 10,
        ),
        elevation: 8,
        items: _tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon, size: 24),
                activeIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: LightColors.forestPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(tab.icon, size: 24),
                ),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Navigation tab model
class NavTab {
  final IconData icon;
  final String label;
  final int index;

  const NavTab({
    required this.icon,
    required this.label,
    required this.index,
  });
}
