import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                _buildWeatherSection(),
                _buildQuickActions(),
                _buildSectionHeader('YOUR JOURNEY'),
                _buildTrekProgress(),
                _buildSectionHeader('DISCOVER TRAILS'),
                _buildTrailCategories(),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'April 12, 2026',
                  style: AppTextStyles.caption.copyWith(
                    color: LightColors.summitDark.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Good Morning,',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: LightColors.summitDark.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  'Sujal Neupane',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: LightColors.summitDark,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: LightColors.summitDark.withValues(alpha: 0.08), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: LightColors.summitDark.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_none_rounded, color: LightColors.summitDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSection() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: LightColors.summitDark.withValues(alpha: 0.04)),
            boxShadow: [
              BoxShadow(
                color: LightColors.summitDark.withValues(alpha: 0.02),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: LightColors.summitDark),
                          const SizedBox(width: 4),
                          Text(
                            'EVEREST BASE CAMP',
                            style: AppTextStyles.caption.copyWith(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w800,
                              color: LightColors.summitDark.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cloudy • -2°C',
                        style: AppTextStyles.h3.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  const Icon(Icons.wb_cloudy_rounded, size: 48, color: LightColors.summitDark),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailedStat('Elevation', '5,364 m', Icons.terrain_rounded),
                  _buildDetailedStat('Wind', '12 km/h', Icons.air_rounded),
                  _buildDetailedStat('Humidity', '45%', Icons.water_drop_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedStat(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: LightColors.summitDark.withValues(alpha: 0.4)),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: LightColors.summitDark.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: LightColors.summitDark,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMinimalAction('Navigation', Icons.explore_outlined),
            _buildMinimalAction('Offline Maps', Icons.map_outlined),
            _buildMinimalAction('Permits', Icons.assignment_outlined),
            _buildMinimalAction('Safety', Icons.shield_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalAction(String label, IconData icon) {
    return Column(
      children: [
        Container(
          height: 68,
          width: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: LightColors.summitDark.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: LightColors.summitDark.withValues(alpha: 0.02),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: LightColors.summitDark, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: LightColors.summitDark.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
                color: LightColors.summitDark.withValues(alpha: 0.3),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: LightColors.summitDark.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrekProgress() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: LightColors.summitDark,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: LightColors.summitDark.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Annapurna Circuit',
                        style: AppTextStyles.h3.copyWith(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        'Day 4: Thorong La Pass',
                        style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Live',
                      style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PROGRESS', style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, letterSpacing: 1.5)),
                  Text('65%', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.65,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailCategories() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 180,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildTrailCard('Himalayas', '12 Trails', 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b'),
            _buildTrailCard('Alps', '8 Trails', 'https://images.unsplash.com/photo-1533559662493-4403960f6062'),
            _buildTrailCard('Andes', '15 Trails', 'https://images.unsplash.com/photo-1519681393784-d120267933ba'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailCard(String name, String count, String imageUrl) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: LightColors.summitDark.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: LightColors.summitDark.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Icon(Icons.terrain_rounded, color: LightColors.summitDark, size: 32)),
            ),
          ),
          const SizedBox(height: 12),
          Text(name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 14)),
          Text(count, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 30,
      left: 24,
      right: 24,
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: LightColors.summitDark.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: LightColors.summitDark.withValues(alpha: 0.05),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.grid_view_rounded),
            _buildNavItem(1, Icons.explore_rounded),
            _buildNavItem(2, Icons.notifications_none_rounded),
            _buildNavItem(3, Icons.person_outline_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? LightColors.summitDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : LightColors.summitDark.withValues(alpha: 0.3),
          size: 26,
        ),
      ),
    );
  }
}

