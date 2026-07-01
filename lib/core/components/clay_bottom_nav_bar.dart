import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_colors.dart';

class ClayBottomNavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const ClayBottomNavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Minimalist claymorphic bottom nav bar.
///
/// UX Laws:
/// - Fitts's Law: 56px min touch targets
/// - Hick's Law: Max 5 destinations
/// - Jakob's Law: Standard bottom tab pattern
/// - Von Restorff: Active item uses accent color + dot
class ClayBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<ClayBottomNavBarItem> items;
  final ValueChanged<int> onTap;

  const ClayBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appColors = AppColors(isDark);

    return Container(
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF020906).withValues(alpha: 0.5)
                : const Color(0xFFB8C0BA).withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.white.withValues(alpha: 0.6),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (index != currentIndex) {
                  HapticFeedback.selectionClick();
                  onTap(index);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 48,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        key: ValueKey('${item.label}_$isActive'),
                        color: isActive
                            ? appColors.primary
                            : (isDark ? Colors.white38 : LightColors.textTertiary),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Active dot indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isActive ? 4 : 0,
                      height: isActive ? 4 : 0,
                      decoration: BoxDecoration(
                        color: appColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
