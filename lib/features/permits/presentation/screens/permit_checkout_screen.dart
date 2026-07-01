import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/app_theme.dart';
import '../viewmodels/permit_viewmodel.dart';

class PermitCheckoutScreen extends ConsumerStatefulWidget {
  final String regionKey;

  const PermitCheckoutScreen({super.key, required this.regionKey});

  @override
  ConsumerState<PermitCheckoutScreen> createState() =>
      _PermitCheckoutScreenState();
}

class _PermitCheckoutScreenState extends ConsumerState<PermitCheckoutScreen> {
  int _trekkerCount = 1;

  void _incrementTrekker() {
    if (_trekkerCount < 20) {
      HapticFeedback.lightImpact();
      setState(() {
        _trekkerCount++;
      });
    }
  }

  void _decrementTrekker() {
    if (_trekkerCount > 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _trekkerCount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final colors = theme.colors;
    final permitAsync = ref.watch(regionPermitProvider(widget.regionKey));
    final checkoutState = ref.watch(permitCheckoutProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Confirm & Pay',
          style: AppTextStyles.h2.copyWith(color: colors.textPrimary),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        leading: BackButton(color: colors.textPrimary),
      ),
      body: SafeArea(
        child: checkoutState.isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Redirecting to secure Stripe payment...',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Do not close this screen.',
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : permitAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: colors.primary),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: colors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to retrieve region info',
                          style: AppTextStyles.h3.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(
                            regionPermitProvider(widget.regionKey),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (permit) {
                  // Pricing Math
                  final baseNpr = permit.permits
                      .where((p) => p.required)
                      .fold<double>(0, (sum, p) => sum + p.feeNpr);
                  final baseUsd = permit.permits
                      .where((p) => p.required)
                      .fold<double>(0, (sum, p) => sum + p.feeUsd);

                  final subtotalNpr = baseNpr * _trekkerCount;
                  final subtotalUsd = baseUsd * _trekkerCount;

                  // Admin processing fee: flat 250 NPR (~$2) per transaction
                  const processingFeeNpr = 250.0;
                  const processingFeeUsd = 1.90;

                  final totalNpr = subtotalNpr + processingFeeNpr;
                  final totalUsd = subtotalUsd + processingFeeUsd;

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Region Summary
                      ClayContainer(
                        borderRadius: 20,
                        depth: 4,
                        spread: 2,
                        color: colors.surface,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Destination Region',
                              style: AppTextStyles.caption.copyWith(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              permit.region,
                              style: AppTextStyles.h2.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Trekker Count Selector
                      ClayContainer(
                        borderRadius: 20,
                        depth: 4,
                        spread: 2,
                        color: colors.surface,
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Number of Trekkers',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Maximum 20 hikers per group',
                                  style: AppTextStyles.caption.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _CountButton(
                                  icon: Icons.remove_rounded,
                                  onPressed: _decrementTrekker,
                                  colors: colors,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                  ),
                                  child: Text(
                                    '$_trekkerCount',
                                    style: AppTextStyles.h3.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _CountButton(
                                  icon: Icons.add_rounded,
                                  onPressed: _incrementTrekker,
                                  colors: colors,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Itemized Fee Breakdown Table
                      Text(
                        'ITEMIZED COST BREAKDOWN',
                        style: AppTextStyles.caption.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClayContainer(
                        borderRadius: 20,
                        depth: 4,
                        spread: 2,
                        color: colors.surface,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ...permit.permits
                                .where((p) => p.required)
                                .map(
                                  (p) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${p.name} (x$_trekkerCount)',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: colors.textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          'NPR ${(p.feeNpr * _trekkerCount).toStringAsFixed(0)}',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: colors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            const Divider(height: 20),
                            // Subtotal row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Permits Subtotal',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'NPR ${subtotalNpr.toStringAsFixed(0)}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Processing Fee row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Stripe Processing Fee',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'NPR ${processingFeeNpr.toStringAsFixed(0)}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24, thickness: 1.5),
                            // Grand Total Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'GRAND TOTAL (NPR)',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'NPR ${totalNpr.toStringAsFixed(0)}',
                                  style: AppTextStyles.h3.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Estimated USD Equivalent',
                                  style: AppTextStyles.caption.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                                Text(
                                  'USD \$${totalUsd.toStringAsFixed(2)}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: colors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Terms and Checkout Button
                      if (checkoutState.errorMessage != null) ...[
                        Text(
                          checkoutState.errorMessage!,
                          style: TextStyle(
                            color: colors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],

                      GestureDetector(
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          final success = await ref
                              .read(permitCheckoutProvider.notifier)
                              .bookPermit(
                                regionKey: widget.regionKey,
                                trekkerCount: _trekkerCount,
                              );
                          if (success && context.mounted) {
                            // After Stripe browser opens, we route to a waiting/success confirmation landing screen
                            context.pushReplacement('/permits/success');
                          }
                        },
                        child: ClayContainer(
                          borderRadius: 18,
                          depth: 6,
                          spread: 2,
                          color: colors.primary,
                          isDark: true,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment_rounded, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'PAY SECURELY WITH STRIPE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Payments processed securely via Stripe. Refunds for municipality permits depend on regional rules.',
                        style: AppTextStyles.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _CountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final dynamic colors;

  const _CountButton({
    required this.icon,
    required this.onPressed,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClayContainer(
        borderRadius: 10,
        depth: 3,
        spread: 1.5,
        color: colors.surface,
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: colors.textPrimary),
      ),
    );
  }
}
