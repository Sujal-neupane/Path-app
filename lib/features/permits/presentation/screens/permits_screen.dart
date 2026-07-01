import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/app_theme.dart';
import '../viewmodels/permit_viewmodel.dart';
import '../../data/models/permit_info_model.dart';

class PermitsScreen extends ConsumerWidget {
  const PermitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final colors = theme.colors;
    final permitsAsync = ref.watch(allPermitsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Trek Permits & Fees',
          style: AppTextStyles.h2.copyWith(color: colors.textPrimary),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        leading: BackButton(color: colors.textPrimary),
      ),
      body: SafeArea(
        child: permitsAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: colors.primary),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: colors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load permit directories',
                    style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    err.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(allPermitsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (permits) {
            if (permits.isEmpty) {
              return Center(
                child: Text(
                  'No permits found.',
                  style: AppTextStyles.bodyLarge.copyWith(color: colors.textSecondary),
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: permits.length,
              itemBuilder: (context, index) {
                final permit = permits[index];
                return _PermitRegionCard(permit: permit, colors: colors);
              },
            );
          },
        ),
      ),
    );
  }
}

class _PermitRegionCard extends StatelessWidget {
  final PermitInfoModel permit;
  final dynamic colors;

  const _PermitRegionCard({required this.permit, required this.colors});

  @override
  Widget build(BuildContext context) {
    // Calculate total cost for visual glance
    final totalNpr = permit.permits
        .where((p) => p.required)
        .fold<double>(0, (sum, p) => sum + p.feeNpr);
    final totalUsd = permit.permits
        .where((p) => p.required)
        .fold<double>(0, (sum, p) => sum + p.feeUsd);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ClayContainer(
        borderRadius: 24,
        depth: 6,
        spread: 3,
        color: colors.surface,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Region Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    permit.region,
                    style: AppTextStyles.h2.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'NPR ${totalNpr.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Approx. USD \$${totalUsd.toStringAsFixed(0)} per hiker',
              style: AppTextStyles.caption.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24, thickness: 1),

            // Permits list
            Text(
              'REQUIRED DOCS & FEES:',
              style: AppTextStyles.caption.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),
            ...permit.permits.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${p.description} (${p.validity})',
                              style: AppTextStyles.caption.copyWith(
                                color: colors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NPR ${p.feeNpr.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 16),
            // Call to action
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/permits/checkout', extra: permit.regionKey);
                },
                child: ClayContainer(
                  borderRadius: 16,
                  depth: 4,
                  spread: 2,
                  color: colors.primary,
                  isDark: true,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: const Center(
                    child: Text(
                      'BOOK NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
