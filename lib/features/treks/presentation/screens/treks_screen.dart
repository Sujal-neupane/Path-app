import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/components/editorial_atoms.dart';
import 'package:path_app/core/theme/app_colors.dart';
import 'package:path_app/core/theme/app_typography.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';
import 'package:path_app/features/treks/presentation/viewmodels/trek_viewmodel.dart';

class TreksScreen extends ConsumerWidget {
  const TreksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final treksAsync = ref.watch(trekListProvider);

    return Scaffold(
      backgroundColor: c.canvas,
      body: SafeArea(
        child: treksAsync.when(
          loading: () =>
              Center(child: CircularProgressIndicator(color: c.primary)),
          error: (error, stack) => _ErrorView(
            onRetry: () => ref.invalidate(trekListProvider),
          ),
          data: (treks) => _TreksListView(treks: treks),
        ),
      ),
    );
  }
}

class _TreksListView extends StatefulWidget {
  final List<TrekSummary> treks;
  const _TreksListView({required this.treks});

  @override
  State<_TreksListView> createState() => _TreksListViewState();
}

class _TreksListViewState extends State<_TreksListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDifficulty = 'All';

  static const _difficulties = ['All', 'Easy', 'Moderate', 'Challenging', 'Extreme'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TrekSummary> get _filtered {
    final query = _searchQuery.toLowerCase().trim();
    return widget.treks.where((trek) {
      final matchesSearch = query.isEmpty ||
          trek.name.toLowerCase().contains(query) ||
          trek.region.toLowerCase().contains(query) ||
          trek.shortDescription.toLowerCase().contains(query);
      final matchesDifficulty = _selectedDifficulty == 'All' ||
          trek.difficulty.toLowerCase() == _selectedDifficulty.toLowerCase();
      return matchesSearch && matchesDifficulty;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedDifficulty = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final filtered = _filtered;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EyebrowLabel('Discover', color: c.primary),
                const SizedBox(height: 8),
                Text('Available treks',
                    style: AppType.displayXL.copyWith(color: c.textPrimary)),
                const SizedBox(height: 6),
                Text('Handpicked routes for your next mountain story.',
                    style: AppType.body.copyWith(color: c.textSecondary)),
                const SizedBox(height: 18),
                // Search
                Container(
                  decoration: BoxDecoration(
                    color: c.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(color: c.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: c.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: AppType.body.copyWith(color: c.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search name or region…',
                            hintStyle:
                                AppType.body.copyWith(color: c.textTertiary),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          }),
                          child: Icon(Icons.close_rounded,
                              color: c.textSecondary, size: 18),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Difficulty filter
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _difficulties.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final diff = _difficulties[i];
                      final active = _selectedDifficulty == diff;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedDifficulty = diff);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active ? c.primary : c.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                                color: active ? c.primary : c.border),
                          ),
                          child: Text(
                            diff,
                            style: AppType.caption.copyWith(
                              color: active ? Colors.white : c.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.treks.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.hiking_rounded,
              title: 'No treks available yet',
              subtitle: 'Official treks will appear here once published.',
            ),
          )
        else if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              icon: Icons.filter_list_off_rounded,
              title: 'No matching trails',
              subtitle: 'Try a different search or difficulty.',
              actionLabel: 'Reset filters',
              onAction: _resetFilters,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final trek = filtered[index];
                return _TrekListCard(
                  trek: trek,
                  onTap: () => context.push('/treks/${trek.id}'),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _TrekListCard extends StatelessWidget {
  final TrekSummary trek;
  final VoidCallback onTap;

  const _TrekListCard({required this.trek, required this.onTap});

  Color get _difficultyColor => switch (trek.difficulty) {
        'Easy' => LightColors.successGreen,
        'Moderate' => LightColors.peakAmber,
        'Challenging' => LightColors.sosRed,
        _ => LightColors.difficultyExpert,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final radius = BorderRadius.circular(AppRadii.card);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: radius,
          border: Border.all(color: c.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo header
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      trek.coverImageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          Container(color: const Color(0xFF1B3A2D)),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.45, 1.0],
                          colors: [Color(0x00000000), Color(0xCC000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: GlassChip(
                        label: trek.difficulty,
                        dotColor: _difficultyColor,
                      ),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: GlassChip(
                        label: trek.rating.toStringAsFixed(1),
                        icon: Icons.star_rounded,
                        foreground: Colors.white,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trek.name,
                              style: AppType.title.copyWith(
                                  color: Colors.white, fontSize: 21),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 13, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text('${trek.region} Region',
                                  style: AppType.caption
                                      .copyWith(color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trek.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.bodySm.copyWith(color: c.textSecondary)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Metric(Icons.calendar_today_rounded,
                          '${trek.durationDays}d', 'Duration'),
                      _Metric(Icons.route_rounded, '${trek.distanceKm}km',
                          'Distance'),
                      _Metric(Icons.terrain_rounded, '${trek.maxAltitudeM}m',
                          'Altitude'),
                      const Spacer(),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: c.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 18, color: c.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Metric(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: c.primary),
              const SizedBox(width: 5),
              Text(value,
                  style: AppType.caption.copyWith(
                      color: c.textPrimary, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              style: AppType.caption.copyWith(color: c.textTertiary, fontSize: 10)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: c.textTertiary),
            const SizedBox(height: 16),
            Text(title, style: AppType.title.copyWith(color: c.textPrimary)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: AppType.body.copyWith(color: c.textSecondary)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: c.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onAction,
                child: Text(actionLabel!, style: AppType.button),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: c.textTertiary),
            const SizedBox(height: 14),
            Text('Failed to load treks',
                style: AppType.title.copyWith(color: c.textPrimary)),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onRetry,
              child: Text('Try again', style: AppType.button),
            ),
          ],
        ),
      ),
    );
  }
}
