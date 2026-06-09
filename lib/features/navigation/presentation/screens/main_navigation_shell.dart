import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/design_tokens.dart';

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: LightColors.stoneWhite,
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: _PremiumBottomNav(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            HapticFeedback.lightImpact();
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}

class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.terrain_outlined,
      activeIcon: Icons.terrain_rounded,
      label: 'Treks',
    ),
    _NavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: 'Map',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding > 0 ? bottomPadding : 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: LightColors.dividerLight.withValues(alpha: 0.5),
                width: 0.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                return _NavItemWidget(
                  item: _items[index],
                  isActive: currentIndex == index,
                  onTap: () => onTap(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: TouchTargets.comfortable,
        height: TouchTargets.comfortable,
        child: AnimatedContainer(
          duration: AnimationDuration.fast,
          curve: AppCurves.snappy,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Active indicator pill + icon
              AnimatedContainer(
                duration: AnimationDuration.fast,
                curve: AppCurves.snappy,
                padding: EdgeInsets.symmetric(
                  horizontal: isActive ? 16 : 0,
                  vertical: isActive ? 6 : 0,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? LightColors.forestPrimary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AnimatedSwitcher(
                  duration: AnimationDuration.fast,
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    key: ValueKey(isActive),
                    size: 22,
                    color: isActive
                        ? LightColors.forestPrimary
                        : LightColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Label
              AnimatedDefaultTextStyle(
                duration: AnimationDuration.fast,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? LightColors.forestPrimary
                      : LightColors.textTertiary,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
