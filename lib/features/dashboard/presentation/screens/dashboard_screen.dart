import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/features/trekking/presentation/viewmodels/itinerary_providers.dart';

//
/// 
/// Design Philosophy (15 UX Laws Applied):
/// 1. Hick's Law: Reduced choices to core CTAs (Explore, Browse, Profile)
/// 2. Fitts's Law: Large touch targets for critical actions (Explore button = 56px height)
/// 3. Jakob's Law: Familiar patterns (bottom nav, card layouts)
/// 4. Aesthetic-Usability: Visually premium = more trustworthy
/// 5. Miller's Law: 3-5 items per section (not overwhelming)
/// 6. Tesler's Law: Hide complexity (show only next action needed)
/// 7. Peak-End Rule: Strong hero section + memorable CTA
/// 8. Goal Gradient: Progress bar for active trek (visual motivation)
/// 9. Doherty Threshold: Smooth animations (300-500ms) for perceived speed
/// 10. Zeigarnik: Incomplete tasks highlighted (progress bar, "Continue Trek")
/// 11. Von Restorff: Emergency SOS in distinctive red
/// 12. Serial Position: Key actions at top/bottom (hero + CTA)
/// 13. Postel's: Flexible input (search, filters) → strict structure
/// 14. Consistency: Same spacing rhythm, typography scale, color usage
/// 15. Prägnanz: Simple, memorable layouts
///
/// Composition Details:
/// - Depth layering: Multiple z-planes (background shapes → cards → overlays)
/// - Micro-spacing: 4px for small gaps, 12px for section spacing, 24px for major sections
/// - Typography hierarchy: H1 (40px) hero → H2 (28px) section titles → body (16px)
/// - Color psychology: Forest green = trust/nature, white = clarity, amber = energy
class DashboardScreen extends ConsumerWidget {
  final VoidCallback? onExploreTreks;

  const DashboardScreen({super.key, this.onExploreTreks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeItinerary = ref.watch(activeItineraryProvider);

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: activeItinerary.when(
        loading: () => const _DashboardLoadingState(),
        error: (error, _) => _DashboardErrorState(error: error.toString()),
        data: (itinerary) {
          if (itinerary == null) {
            return _NoPlanDashboard(onExploreTreks: onExploreTreks);
          }
          return _ActivePlanDashboard(itinerary: itinerary);
        },
      ),
    );
  }
}

// ============================================================================
// NO ACTIVE PLAN STATE - Discovery Incentive Surface
// ============================================================================

class _NoPlanDashboard extends StatefulWidget {
  final VoidCallback? onExploreTreks;
  const _NoPlanDashboard({this.onExploreTreks});

  @override
  State<_NoPlanDashboard> createState() => _NoPlanDashboardState();
}

class _NoPlanDashboardState extends State<_NoPlanDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ====== HERO SECTION ======
        SliverAppBar(
          expandedHeight: 280,
          collapsedHeight: 0,
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                // Background gradient + decorative shape
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        LightColors.forestPrimary.withValues(alpha: 0.85),
                        LightColors.forestPrimary,
                      ],
                    ),
                  ),
                ),

                // Subtle animated background shape (depth)
                Positioned(
                  right: -40,
                  top: -60,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
                    ),
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),

                // Hero content
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated icon badge
                        FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.5)),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.public_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Ready to Trek',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Main headline - staggered animation
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(parent: _animController, curve: const Interval(0.1, 0.6)),
                          ),
                          child: Text(
                            "Adventures\nAwait You",
                            style: AppTextStyles.h1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              fontSize: 42,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Supporting text - fade in
                        FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(parent: _animController, curve: const Interval(0.3, 0.8)),
                          ),
                          child: Text(
                            "Personalized treks matched to your spirit, fitness, and dreams.",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ====== CONTENT SECTIONS ======
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: Why PATH Value Props
                _SectionHeader(title: "Why Choose PATH?", subtitle: "3 reasons to start here"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ValuePropCard(
                        icon: Icons.tune_rounded,
                        iconColor: const Color(0xFF4A90E2),
                        title: "Curated",
                        description: "Matched to your level",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ValuePropCard(
                        icon: Icons.verified_rounded,
                        iconColor: const Color(0xFF2ECC71),
                        title: "Safe",
                        description: "Real-time alerts",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ValuePropCard(
                        icon: Icons.trending_up_rounded,
                        iconColor: LightColors.peakAmber,
                        title: "Track Progress",
                        description: "Every step counts",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // SECTION 2: Featured Trek (Smart Personalization)
                _SectionHeader(
                  title: "Trending This Week",
                  subtitle: "Most booked treks right now",
                ),
                const SizedBox(height: 16),
                _FeaturedTrekCard(
                  imagePlaceholder: "🏔️",
                  title: "Everest Base Camp Trek",
                  difficulty: "Hard",
                  stats: "64 km • 12 days • 5,540m elevation",
                  badge: "Popular",
                ),
                const SizedBox(height: 40),

                // SECTION 3: Quick Stats
                _SectionHeader(
                  title: "Your Journey So Far",
                  subtitle: "See your growth",
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _QuickStatCard(
                        icon: Icons.flag_rounded,
                        value: "2",
                        label: "Treks",
                        accentColor: const Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickStatCard(
                        icon: Icons.height_rounded,
                        value: "12.3K",
                        label: "Meters",
                        accentColor: const Color(0xFF8B6F47),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // CTA BUTTON - Large, Prominent, Clear Action
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LightColors.forestPrimary,
                        LightColors.forestPrimary.withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: LightColors.forestPrimary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onExploreTreks,
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.explore_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Explore All Treks",
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ACTIVE PLAN STATE - Day-by-Day Progress Tracker
// ============================================================================

class _ActivePlanDashboard extends StatelessWidget {
  final dynamic itinerary;

  const _ActivePlanDashboard({required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ====== PROGRESS HERO SECTION ======
        SliverAppBar(
          expandedHeight: 220,
          collapsedHeight: 0,
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    LightColors.forestPrimary.withValues(alpha: 0.85),
                    LightColors.forestPrimary,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Day counter (large, prominent)
                  Positioned(
                    left: 24,
                    top: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Day 3 of 12",
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Keep Going! 🎯",
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress bar at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 3 / 12,
                              minHeight: 6,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation(
                                Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ====== TODAY'S ROUTE CARD ======
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: "Today's Route", subtitle: "Day 3: Namche → Tyangboche"),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: LightColors.forestPrimary.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.route_rounded,
                              color: Color(0xFF4A90E2),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Namche Bazaar → Tyangboche",
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: LightColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "11.5 km • 5-6 hours • Moderate",
                                  style: AppTextStyles.caption.copyWith(
                                    color: LightColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        color: LightColors.forestPrimary.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _TodaysRouteStatItem(
                            icon: Icons.thermostat_rounded,
                            value: "-5°C to 8°C",
                            label: "Temperature",
                          ),
                          _TodaysRouteStatItem(
                            icon: Icons.wb_sunny_rounded,
                            value: "Clear",
                            label: "Weather",
                          ),
                          _TodaysRouteStatItem(
                            icon: Icons.favorite_rounded,
                            value: "Moderate",
                            label: "Effort",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // ====== QUICK ACTIONS ======
                _SectionHeader(title: "Quick Actions", subtitle: "What do you need?"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.map_rounded,
                        label: "Route",
                        color: const Color(0xFF4A90E2),
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.list_rounded,
                        label: "Itinerary",
                        color: const Color(0xFF8B6F47),
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.sos_rounded,
                        label: "SOS",
                        color: LightColors.peakAmber,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// HELPER WIDGETS - Composed with care for micro-interactions
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h2.copyWith(
            color: LightColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: LightColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ValuePropCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _ValuePropCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.caption.copyWith(
              color: LightColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedTrekCard extends StatelessWidget {
  final String imagePlaceholder;
  final String title;
  final String difficulty;
  final String stats;
  final String badge;

  const _FeaturedTrekCard({
    required this.imagePlaceholder,
    required this.title,
    required this.difficulty,
    required this.stats,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            child: Column(
              children: [
                // Image placeholder
                Container(
                  height: 180,
                  color: LightColors.forestPrimary.withValues(alpha: 0.1),
                  child: Center(
                    child: Text(
                      imagePlaceholder,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: LightColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  stats,
                                  style: AppTextStyles.caption.copyWith(
                                    color: LightColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE85D75).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Text(
                              difficulty,
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFFE85D75),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: LightColors.peakAmber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          badge,
                          style: AppTextStyles.caption.copyWith(
                            color: LightColors.peakAmber,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;

  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaysRouteStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _TodaysRouteStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: LightColors.forestPrimary, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: LightColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: LightColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: LightColors.forestPrimary.withValues(alpha: 0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: LightColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOADING & ERROR STATES - Polished Feedback
// ============================================================================

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: LightColors.forestPrimary,
          ),
          const SizedBox(height: 16),
          Text(
            "Loading your journey...",
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  final String error;

  const _DashboardErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: LightColors.peakAmber,
            ),
            const SizedBox(height: 16),
            Text(
              "Something went wrong",
              style: AppTextStyles.h3.copyWith(
                color: LightColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: LightColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
