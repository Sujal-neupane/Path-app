import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/sos/domain/entities/sos_alert.dart';
import 'package:path_app/features/sos/presentation/viewmodels/sos_viewmodel.dart';

class SosHistoryScreen extends ConsumerWidget {
  const SosHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sosHistoryAsync = ref.watch(sosHistoryProvider);

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: LightColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Emergency Logs',
          style: AppTextStyles.h2.copyWith(color: LightColors.textPrimary),
        ),
      ),
      body: RefreshIndicator(
        color: LightColors.forestPrimary,
        onRefresh: () async {
          HapticFeedback.lightImpact();
          ref.invalidate(sosHistoryProvider);
        },
        child: sosHistoryAsync.when(
          loading: () => const _SosHistorySkeleton(),
          error: (err, stack) => _SosHistoryErrorView(
            message: err.toString(),
            onRetry: () => ref.invalidate(sosHistoryProvider),
          ),
          data: (alerts) {
            if (alerts.isEmpty) {
              return const _SosHistoryEmptyView();
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _SosAlertCard(alert: alert),
                );
              },
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'resolved':
        return LightColors.successGreen;
      case 'acknowledged':
        return LightColors.altitudeBlue;
      case 'pending':
      default:
        return LightColors.warningOrange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'resolved':
        return 'RESCUE RESOLVED';
      case 'acknowledged':
        return 'RESCUE DISPATCHED';
      case 'pending':
      default:
        return 'SIGNAL PENDING';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(alert.status);
    final statusText = _getStatusText(alert.status);
    final formattedDate = alert.createdAt.toLocal().toString().substring(0, 16);

    return ClayContainer(
      borderRadius: 20,
      depth: 6,
      spread: 3,
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                formattedDate,
                style: AppTextStyles.caption.copyWith(
                  color: LightColors.textTertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.message ?? 'No details provided.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: LightColors.dividerLight),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricBadge(
                  icon: Icons.my_location_rounded,
                  label: 'Coordinates',
                  value: '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}',
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
                    label: 'Device Battery',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: LightColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: LightColors.textTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _SosHistoryEmptyView extends StatelessWidget {
  const _SosHistoryEmptyView();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ClayContainer(
                  borderRadius: 24,
                  depth: 6,
                  spread: 3,
                  color: Colors.white,
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: LightColors.successLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: LightColors.successGreen,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Safe & Sound',
                        style: AppTextStyles.h2.copyWith(
                          color: LightColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No emergency SOS distress signals have been triggered. Enjoy your adventures safely!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: LightColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SosHistoryErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SosHistoryErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClayContainer(
          borderRadius: 22,
          depth: 4,
          color: const Color(0xFFFEECEB),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 40, color: LightColors.sosRed),
              const SizedBox(height: 12),
              Text(
                'Logs Offline',
                style: AppTextStyles.h3.copyWith(
                  color: LightColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message.replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: LightColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LightColors.sosRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SosHistorySkeleton extends StatelessWidget {
  const _SosHistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ClayContainer(
          borderRadius: 20,
          depth: 3,
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: const SizedBox(
            height: 90,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: LightColors.forestPrimary,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
