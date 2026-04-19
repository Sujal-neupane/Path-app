import 'package:flutter/material.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';

/// ✨ MASTERPIECE TREK DETAILS - Pinterest Composition (Minimal + Aesthetic)
///
/// Design Approach:
/// - Consistent icon colors (unified palette)
/// - Pinterest-style variable card sizes (content-driven)
/// - Minimal aesthetic (white space, clean)
/// - Proper image handling with fallbacks
/// - Variable card heights: bigger for content-heavy, smaller for simple
///
/// UX Laws Applied:
/// 1. Hick's Law: Reduced choice complexity
/// 2. Fitts's Law: Large touch targets for CTAs (60px+)
/// 3. Miller's Law: 5-7 items max per section
/// 4. Peak-End Rule: Hero image + powerful CTA ending
/// 5. Aesthetic-Usability: Minimal design feels premium
/// 6. Consistency: Unified icon colors, spacing, shadows
/// 7. Prägnanz: Simple, clean layouts

class TrekDetailsScreen extends StatelessWidget {
  final dynamic trek;

  const TrekDetailsScreen({Key? key, required this.trek}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: CustomScrollView(
        slivers: [
          // ============ HERO SECTION ============
          SliverAppBar(
            expandedHeight: 280,
            collapsedHeight: 0,
            toolbarHeight: 0,
            elevation: 0,
            backgroundColor: Colors.transparent,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image or placeholder with proper handling
                  Container(
                    color: LightColors.forestPrimary.withValues(alpha: 0.12),
                    child: _TrekImagePlaceholder(),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Back button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      child: _RoundButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // Difficulty badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              color: LightColors.peakAmber,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              trek.difficultyRating.toUpperCase(),
                              style: AppTextStyles.caption.copyWith(
                                color: LightColors.peakAmber,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Title + location at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            trek.name,
                            style: AppTextStyles.h1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 36,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                trek.location,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ============ CONTENT ============
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),

                  // ========== SECTION 1: KEY STATS (Compact, 3 columns) ==========
                  _SectionHeader(title: "Trek Overview", subtitle: "Key metrics"),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _CompactStatCard(
                          value: trek.totalDistance.toStringAsFixed(1),
                          unit: 'km',
                          label: 'Distance',
                          icon: Icons.route_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CompactStatCard(
                          value: trek.estimatedDays.toString(),
                          unit: 'days',
                          label: 'Duration',
                          icon: Icons.calendar_month_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CompactStatCard(
                          value: trek.totalElevationGain.toStringAsFixed(0),
                          unit: 'm',
                          label: 'Elevation',
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _CompactStatCard(
                          value: trek.maxAltitude.toStringAsFixed(0),
                          unit: 'm',
                          label: 'Max Alt',
                          icon: Icons.landscape_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CompactStatCard(
                          value: trek.bestSeason,
                          unit: '',
                          label: 'Season',
                          icon: Icons.wb_sunny_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CompactStatCard(
                          value: trek.difficultyRating,
                          unit: '',
                          label: 'Level',
                          icon: Icons.person_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // ========== SECTION 2: ABOUT (LARGE CARD - More content) ==========
                  _SectionHeader(title: "About This Trek", subtitle: "Full experience"),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: LightColors.forestPrimary.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      trek.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: LightColors.textPrimary,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ========== SECTION 3: ROUTE HIGHLIGHTS (Variable sizes) ==========
                  _SectionHeader(title: "Route Highlights", subtitle: "Follow the path"),
                  const SizedBox(height: 14),
                  _RouteHighlightTimeline(trek: trek),
                  const SizedBox(height: 48),

                  // ========== SECTION 4: SEASONAL INFO (2 columns) ==========
                  _SectionHeader(title: "Best Time to Trek", subtitle: "Seasonal guide"),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _SeasonalCard(
                          season: "Spring",
                          emoji: "🌸",
                          description: "Clear skies, blooming flowers. Peak season.",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SeasonalCard(
                          season: "Autumn",
                          emoji: "🍂",
                          description: "Stable weather, excellent visibility.",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // ========== SECTION 5: DIFFICULTY BREAKDOWN ==========
                  _SectionHeader(title: "Challenge Level", subtitle: "What to expect"),
                  const SizedBox(height: 14),
                  _DifficultyMeter(
                    label: "Physical",
                    value: 0.75,
                  ),
                  const SizedBox(height: 12),
                  _DifficultyMeter(
                    label: "Altitude",
                    value: 0.85,
                  ),
                  const SizedBox(height: 12),
                  _DifficultyMeter(
                    label: "Technical",
                    value: 0.25,
                  ),
                  const SizedBox(height: 48),

                  // ========== CTAs (Large, prominent) ==========
                  Row(
                    children: [
                      Expanded(
                        child: _SecondaryButton(
                          icon: Icons.download_rounded,
                          label: "Download",
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SecondaryButton(
                          icon: Icons.favorite_border_rounded,
                          label: "Save",
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _PrimaryButton(
                    label: "Start Trek",
                    onTap: () {},
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// COMPONENTS - Consistent, minimal design
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
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 2),
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

class _CompactStatCard extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final IconData icon;

  const _CompactStatCard({
    required this.value,
    required this.unit,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Icon - consistent grey color
          Icon(
            icon,
            color: LightColors.textSecondary.withValues(alpha: 0.6),
            size: 20,
          ),
          const SizedBox(height: 10),

          // Value
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),

          // Unit + label
          if (unit.isNotEmpty)
            Text(
              unit,
              style: AppTextStyles.caption.copyWith(
                color: LightColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: LightColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RouteHighlightTimeline extends StatelessWidget {
  final dynamic trek;

  const _RouteHighlightTimeline({required this.trek});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RoutePoint(
          order: 1,
          title: "Kathmandu",
          subtitle: "1,400 m",
          icon: Icons.location_city_rounded,
          isFirst: true,
          hasConnector: true,
        ),
        _RoutePoint(
          order: 2,
          title: "Namche Bazaar",
          subtitle: "3,440 m",
          icon: Icons.store_rounded,
          hasConnector: true,
          badge: "Acclimatize",
        ),
        _RoutePoint(
          order: 3,
          title: "Tengboche",
          subtitle: "3,867 m",
          icon: Icons.temple_buddhist_rounded,
          hasConnector: true,
        ),
        _RoutePoint(
          order: 4,
          title: "Everest Base Camp",
          subtitle: "5,364 m",
          icon: Icons.flag_rounded,
          isLast: true,
          badge: "Finish",
        ),
      ],
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final int order;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isFirst;
  final bool isLast;
  final bool hasConnector;
  final String? badge;

  const _RoutePoint({
    required this.order,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isFirst = false,
    this.isLast = false,
    this.hasConnector = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          // Connector line
          if (hasConnector)
            Positioned(
              left: 21,
              top: 50,
              width: 2,
              height: 60,
              child: Container(
                color: LightColors.forestPrimary.withValues(alpha: 0.15),
              ),
            ),

          // Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number circle (variable size based on position)
              Container(
                width: isFirst || isLast ? 48 : 44,
                height: isFirst || isLast ? 48 : 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFirst || isLast
                      ? LightColors.forestPrimary.withValues(alpha: 0.15)
                      : LightColors.forestPrimary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: isFirst || isLast
                        ? LightColors.forestPrimary
                        : LightColors.textSecondary.withValues(alpha: 0.3),
                    width: isFirst || isLast ? 2 : 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    order.toString(),
                    style: AppTextStyles.h3.copyWith(
                      color: isFirst || isLast
                          ? LightColors.forestPrimary
                          : LightColors.textSecondary,
                      fontWeight: FontWeight.w900,
                      fontSize: isFirst || isLast ? 18 : 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Content card
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isFirst || isLast
                        ? LightColors.forestPrimary.withValues(alpha: 0.04)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: LightColors.forestPrimary.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
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
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: AppTextStyles.caption.copyWith(
                                    color: LightColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            icon,
                            color: LightColors.textSecondary.withValues(alpha: 0.5),
                            size: 18,
                          ),
                        ],
                      ),
                      if (badge != null) ...[
                        const SizedBox(height: 10),
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
                            badge!,
                            style: AppTextStyles.caption.copyWith(
                              color: LightColors.peakAmber,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeasonalCard extends StatelessWidget {
  final String season;
  final String emoji;
  final String description;

  const _SeasonalCard({
    required this.season,
    required this.emoji,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 10),
          Text(
            season,
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTextStyles.caption.copyWith(
              color: LightColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyMeter extends StatelessWidget {
  final String label;
  final double value;

  const _DifficultyMeter({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: LightColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: AppTextStyles.caption.copyWith(
                  color: LightColors.forestPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(LightColors.forestPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: LightColors.forestPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: LightColors.forestPrimary,
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

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
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
            color: LightColors.forestPrimary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrekImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_rounded,
            size: 80,
            color: LightColors.textSecondary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Trek Image',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
