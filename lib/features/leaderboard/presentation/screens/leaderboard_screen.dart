import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/components/editorial_atoms.dart';
import 'package:path_app/core/theme/app_colors.dart';
import 'package:path_app/core/theme/app_typography.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/leaderboard/presentation/viewmodels/leaderboard_viewmodel.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final state = ref.watch(leaderboardViewModelProvider);

    return Scaffold(
      backgroundColor: c.canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: c.primary,
          onRefresh: () =>
              ref.read(leaderboardViewModelProvider.notifier).load(state.type),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(Icons.arrow_back_rounded,
                                color: c.textPrimary),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(width: 8),
                          EyebrowLabel('Global rankings',
                              color: LightColors.peakAmber),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Leaderboard',
                          style:
                              AppType.displayXL.copyWith(color: c.textPrimary)),
                      const SizedBox(height: 6),
                      Text(
                        'See how you stack up against trekkers worldwide.',
                        style: AppType.body.copyWith(color: c.textSecondary),
                      ),
                      const SizedBox(height: 18),
                      _TypeSelector(
                        selected: state.type,
                        onSelect: (t) => ref
                            .read(leaderboardViewModelProvider.notifier)
                            .load(t),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              if (state.isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: c.primary, strokeWidth: 3),
                  ),
                )
              else if (state.error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _Message(text: state.error!, icon: Icons.cloud_off_rounded),
                )
              else if (state.entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _Message(
                    text: 'No rankings yet. Be the first to summit!',
                    icon: Icons.emoji_events_outlined,
                  ),
                )
              else ...[
                if (state.entries.length >= 3)
                  SliverToBoxAdapter(
                    child: _Podium(top: state.entries.take(3).toList()),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  sliver: SliverList.separated(
                    itemCount: state.entries.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _RankRow(entry: state.entries[index]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final LeaderboardType selected;
  final ValueChanged<LeaderboardType> onSelect;

  const _TypeSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: LeaderboardType.values.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = LeaderboardType.values[index];
          final active = type == selected;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? LightColors.forestPrimary : c.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: active ? LightColors.forestPrimary : c.border,
                ),
              ),
              child: Text(
                type.label,
                style: AppType.caption.copyWith(
                  color: active ? Colors.white : c.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> top;
  const _Podium({required this.top});

  @override
  Widget build(BuildContext context) {
    // order visually: 2nd, 1st, 3rd
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _PodiumPillar(entry: top[1], height: 96, place: 2)),
          const SizedBox(width: 10),
          Expanded(child: _PodiumPillar(entry: top[0], height: 124, place: 1)),
          const SizedBox(width: 10),
          Expanded(child: _PodiumPillar(entry: top[2], height: 78, place: 3)),
        ],
      ),
    );
  }
}

class _PodiumPillar extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  final int place;

  const _PodiumPillar({
    required this.entry,
    required this.height,
    required this.place,
  });

  Color get _medal => switch (place) {
    1 => const Color(0xFFE8B84B),
    2 => const Color(0xFFB8C0C8),
    _ => const Color(0xFFCD8B5A),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return Column(
      children: [
        _Avatar(name: entry.fullName, size: place == 1 ? 60 : 50, ring: _medal),
        const SizedBox(height: 8),
        Text(
          entry.fullName.split(' ').first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppType.caption.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          entry.formattedValue,
          style: AppType.caption.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_medal.withValues(alpha: 0.9), _medal.withValues(alpha: 0.5)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            '$place',
            style: AppType.display.copyWith(color: Colors.white, fontSize: 26),
          ),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  final LeaderboardEntry entry;
  const _RankRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${entry.rank}',
              style: AppType.titleSm.copyWith(color: c.textTertiary),
            ),
          ),
          const SizedBox(width: 6),
          _Avatar(name: entry.fullName, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.bodySm.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  entry.level.replaceAll('_', ' '),
                  style: AppType.caption.copyWith(color: c.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            entry.formattedValue,
            style: AppType.stat.copyWith(color: c.primary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? ring;

  const _Avatar({required this.name, required this.size, this.ring});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [LightColors.forestPrimary, LightColors.trailGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: ring != null ? Border.all(color: ring!, width: 3) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppType.titleSm.copyWith(
          color: Colors.white,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Message({required this.text, required this.icon});

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
            Icon(icon, size: 48, color: c.textTertiary),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppType.body.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
