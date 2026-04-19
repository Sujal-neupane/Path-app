import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import '../viewmodels/trekking_providers.dart';
import '../widgets/trek_card.dart';
import 'trek_details_screen.dart';

/// World-class trek discovery: Minimalist, aesthetic, zero visual clutter
class TrekListScreen extends ConsumerStatefulWidget {
  const TrekListScreen({super.key});

  @override
  ConsumerState<TrekListScreen> createState() => _TrekListScreenState();
}

class _TrekListScreenState extends ConsumerState<TrekListScreen> {
  late TextEditingController _searchController;
  String? _difficultyFilter;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Fetch treks on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trekListProvider.notifier).fetchTreks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trekListState = ref.watch(trekListProvider);

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Minimal header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover Treks',
                    style: AppTextStyles.h2.copyWith(
                      color: LightColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find your next adventure',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: LightColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar (Fitts's Law: large, accessible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  if (query.isEmpty) {
                    ref.read(trekListProvider.notifier).fetchTreks();
                  } else {
                    ref.read(trekListProvider.notifier).searchTreks(query);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search treks...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: LightColors.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            ref.read(trekListProvider.notifier).fetchTreks();
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: LightColors.textSecondary,
                            size: 20,
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.black.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.black.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: LightColors.forestPrimary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Difficulty filters (Hick's Law: reduced choices)
            SizedBox(
              height: 36,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _DifficultyChip(
                      label: 'All',
                      isSelected: _difficultyFilter == null,
                      onTap: () {
                        setState(() => _difficultyFilter = null);
                        ref.read(trekListProvider.notifier).fetchTreks();
                      },
                    ),
                    const SizedBox(width: 8),
                    _DifficultyChip(
                      label: 'Easy',
                      isSelected: _difficultyFilter == 'easy',
                      color: Colors.green,
                      onTap: () {
                        setState(() => _difficultyFilter = 'easy');
                        ref.read(trekListProvider.notifier).fetchTreks(
                          difficultyFilter: 'easy',
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _DifficultyChip(
                      label: 'Moderate',
                      isSelected: _difficultyFilter == 'moderate',
                      color: LightColors.peakAmber,
                      onTap: () {
                        setState(() => _difficultyFilter = 'moderate');
                        ref.read(trekListProvider.notifier).fetchTreks(
                          difficultyFilter: 'moderate',
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _DifficultyChip(
                      label: 'Expert',
                      isSelected: _difficultyFilter == 'extreme',
                      color: LightColors.sosRed,
                      onTap: () {
                        setState(() => _difficultyFilter = 'extreme');
                        ref.read(trekListProvider.notifier).fetchTreks(
                          difficultyFilter: 'extreme',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Trek list
            Expanded(
              child: trekListState.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: LightColors.forestPrimary,
                      ),
                    )
                  : trekListState.error != null
                      ? _ErrorState(
                          onRetry: () {
                            ref.read(trekListProvider.notifier).fetchTreks();
                          },
                        )
                      : trekListState.treks.isEmpty
                          ? _EmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              itemCount: trekListState.treks.length + 1,
                              itemBuilder: (context, index) {
                                if (index == trekListState.treks.length) {
                                  return const SizedBox(height: 80);
                                }

                                final trek = trekListState.treks[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: TrekCard(
                                    trek: trek,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TrekDetailsScreen(trek: trek),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Difficulty filter chip
class _DifficultyChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? LightColors.forestPrimary)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected
                ? (color == LightColors.peakAmber || color == LightColors.sosRed
                    ? Colors.black
                    : Colors.white)
                : LightColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Error state
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: LightColors.sosRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load treks',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: LightColors.forestPrimary,
            ),
            child: Text(
              'Retry',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_rounded,
            size: 56,
            color: LightColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No treks found',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
