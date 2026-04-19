import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import '../viewmodels/trekking_providers.dart';
import '../widgets/trek_card.dart';

/// Browse all available treks (Treks tab)
///
/// Features:
/// - Search by name/location
/// - Filter by difficulty, season, days
/// - Offline indicator
/// - Tap card → TrekDetailsScreen
/// - Long press → Download offline
///
/// Grid layout, responsive (Fitts's Law: large touch targets)
/// Uses offline-first caching (trekListProvider)
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover Treks',
                    style: AppTextStyles.h2.copyWith(
                      color: LightColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find your next adventure',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: LightColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _difficultyFilter == null,
                    onTap: () {
                      setState(() => _difficultyFilter = null);
                      ref.read(trekListProvider.notifier).fetchTreks();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
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
                  _FilterChip(
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
                  _FilterChip(
                    label: 'Expert',
                    isSelected: _difficultyFilter == 'expert',
                    color: LightColors.sosRed,
                    onTap: () {
                      setState(() => _difficultyFilter = 'expert');
                      ref.read(trekListProvider.notifier).fetchTreks(
                            difficultyFilter: 'extreme',
                          );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Trek list
            Expanded(
              child: trekListState.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: LightColors.forestPrimary,
                      ),
                    )
                  : trekListState.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: LightColors.sosRed,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Failed to load treks',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: LightColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () {
                                  ref
                                      .read(trekListProvider.notifier)
                                      .fetchTreks();
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: LightColors.forestPrimary,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          itemCount: trekListState.treks.length + 1,
                          itemBuilder: (context, index) {
                            if (index == trekListState.treks.length) {
                              return const SizedBox(height: 80);
                            }

                            final trek = trekListState.treks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: TrekCard(
                                trek: trek,
                                onTap: () {
                                  // TODO: Navigate to TrekDetailsScreen
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Selected: ${trek.name}'),
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

/// Filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
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
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (color ?? LightColors.forestPrimary)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: isSelected ? Colors.white : LightColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
