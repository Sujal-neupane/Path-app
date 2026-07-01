import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/app_colors.dart';
import 'package:path_app/core/theme/app_typography.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/sos/domain/entities/sos_alert.dart';
import 'package:path_app/features/sos/presentation/viewmodels/sos_viewmodel.dart';

class SosHistoryScreen extends ConsumerWidget {
  const SosHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final sosHistoryAsync = ref.watch(sosHistoryProvider);

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: AppBar(
        backgroundColor: c.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('SAFETY',
                style: AppType.eyebrow.copyWith(color: LightColors.sosRed)),
            const SizedBox(height: 2),
            Text('Emergency logs',
                style: AppType.titleSm.copyWith(color: c.textPrimary)),
          ],
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: c.primary,
        onRefresh: () async {
          HapticFeedback.lightImpact();
          ref.invalidate(sosHistoryProvider);
        },
        child: sosHistoryAsync.when(
          loading: () =>
              Center(child: CircularProgressIndicator(color: c.primary)),
          error: (err, stack) => _SosHistoryErrorView(
            message: err.toString(),
            onRetry: () => ref.invalidate(sosHistoryProvider),
          ),
          data: (alerts) {
            if (alerts.isEmpty) return const _SosHistoryEmptyView();
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              itemCount: alerts.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _SosAlertCard(alert: alerts[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SosAlertCard extends StatelessWidget {
  final SosAlert alert;
  const _SosAlertCard({required this.alert});

  (Color, String) _status(String status) => switch (status) {
        'resolved' => (LightColors.successGreen, 'RESCUE RESOLVED'),
        'acknowledged' => (LightColors.altitudeBlue, 'RESCUE DISPATCHED'),
        _ => (LightColors.warningOrange, 'SIGNAL PENDING'),
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final (statusColor, statusText) = _status(alert.status);
    final formattedDate = alert.createdAt.toLocal().toString().substring(0, 16);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(statusText,
                    style: AppType.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.6,
                    )),
              ),
              Text(formattedDate,
                  style: AppType.caption.copyWith(color: c.textTertiary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(alert.message ?? 'No details provided.',
              style: AppType.bodySm.copyWith(
                  color: c.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Divider(color: c.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricBadge(
                  icon: Icons.my_location_rounded,
                  label: 'Coordinates',
                  value:
                      '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}',
                ),
              ),
              if (alert.altitude != null)
                Expanded(
                  child: _MetricBadge(
                    icon: Icons.filter_hdr_rounded,
                    label: 'Elevation',
                    value: '${alert.altitude!.round()} m',
                  ),
                ),
              if (alert.batteryLevel != null)
                Expanded(
                  child: _MetricBadge(
                    icon: Icons.battery_charging_full_rounded,
                    label: 'Battery',
                    value: '${alert.batteryLevel!.round()}%',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: c.textTertiary),
            const SizedBox(width: 4),
            Text(label,
                style: AppType.caption.copyWith(color: c.textTertiary, fontSize: 9)),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(value,
              style: AppType.caption.copyWith(
                  color: c.textSecondary, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

class _SosHistoryEmptyView extends StatelessWidget {
  const _SosHistoryEmptyView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: LightColors.successGreen.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user_rounded,
                        color: LightColors.successGreen, size: 34),
                  ),
                  const SizedBox(height: 20),
                  Text('Safe & sound',
                      style: AppType.title.copyWith(color: c.textPrimary)),
                  const SizedBox(height: 8),
                  Text(
                    'No emergency signals have been triggered. Enjoy your adventures safely.',
                    textAlign: TextAlign.center,
                    style: AppType.body.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SosHistoryErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SosHistoryErrorView({required this.message, required this.onRetry});

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
            const Icon(Icons.error_outline_rounded,
                size: 44, color: LightColors.sosRed),
            const SizedBox(height: 14),
            Text('Logs offline',
                style: AppType.title.copyWith(color: c.textPrimary)),
            const SizedBox(height: 6),
            Text(
              message.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: AppType.caption.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: LightColors.sosRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Try again', style: AppType.button),
            ),
          ],
        ),
      ),
    );
  }
}
