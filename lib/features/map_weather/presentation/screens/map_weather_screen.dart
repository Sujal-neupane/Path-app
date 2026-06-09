import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/map_weather/domain/entities/weather_report.dart';
import 'package:path_app/features/map_weather/presentation/viewmodels/weather_viewmodel.dart';

class MapWeatherScreen extends ConsumerStatefulWidget {
  const MapWeatherScreen({super.key});

  @override
  ConsumerState<MapWeatherScreen> createState() => _MapWeatherScreenState();
}

class _MapWeatherScreenState extends ConsumerState<MapWeatherScreen> {
  String _selectedRegion = 'Everest';

  final List<String> _regions = ['Everest', 'Annapurna', 'Langtang', 'Poon Hill'];

  void _onRegionChanged(String region) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedRegion = region;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherStateProvider(_selectedRegion));

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 96), // Extra bottom padding for floating bottom nav
          children: [
            Text(
              'Map & Weather',
              style: AppTextStyles.h1.copyWith(
                color: LightColors.textPrimary,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Trail visibility, dynamic weather conditions, and microservice forecasts.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: LightColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),

            // Region Segmented Selector (Claymorphic Tabs)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _regions.map((region) {
                  final isSelected = _selectedRegion == region;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10, bottom: 8, top: 4),
                    child: GestureDetector(
                      onTap: () => _onRegionChanged(region),
                      child: ClayContainer(
                        borderRadius: 14,
                        depth: isSelected ? 3 : 6,
                        spread: isSelected ? 1 : 2,
                        isFlat: isSelected,
                        color: isSelected ? LightColors.meadowTint : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          region,
                          style: AppTextStyles.button.copyWith(
                            color: isSelected 
                                ? LightColors.primaryFocus 
                                : LightColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Live Trail Navigator Card
            _MapPreviewCard(region: _selectedRegion),
            const SizedBox(height: 20),

            // Weather details async handler
            weatherAsync.when(
              loading: () => const _WeatherSkeletonLoader(),
              error: (err, stack) => _WeatherErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(weatherStateProvider(_selectedRegion)),
              ),
              data: (report) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CurrentWeatherCard(report: report),
                  const SizedBox(height: 16),
                  _ForecastStrip(forecast: report.forecast),
                  const SizedBox(height: 16),
                  _AdvisoryCard(advisory: report.advisory, condition: report.condition),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  final String region;

  const _MapPreviewCard({required this.region});

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      borderRadius: 22,
      depth: 6,
      spread: 3,
      color: Colors.white,
      padding: EdgeInsets.zero,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFF1B3A2D), Color(0xFF2D6A4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Trail Map',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$region • GPS Simulator Ready',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              right: 24,
              bottom: 24,
              child: Icon(Icons.explore_rounded, color: Colors.white, size: 56),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/map-weather/navigator', extra: region);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: LightColors.summitDark,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                label: const Text('Open GPX Navigator'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  final WeatherReport report;

  const _CurrentWeatherCard({required this.report});

  IconData _getIcon(String condition) {
    switch (condition) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'cloudy':
        return Icons.cloud_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'wind':
        return Icons.air_rounded;
      case 'storm':
        return Icons.thunderstorm_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'clear':
        return LightColors.peakAmber;
      case 'cloudy':
        return LightColors.textSecondary;
      case 'snow':
        return LightColors.altitudeBlue;
      case 'wind':
        return LightColors.trailGreen;
      case 'storm':
        return LightColors.sosRed;
      default:
        return LightColors.forestPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final conditionColor = _getConditionColor(report.condition);

    return ClayContainer(
      borderRadius: 22,
      depth: 6,
      spread: 3,
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: conditionColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(report.condition),
                  color: conditionColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.region,
                      style: AppTextStyles.h3.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      report.description,
                      style: AppTextStyles.caption.copyWith(
                        color: LightColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    report.temperature,
                    style: AppTextStyles.h1.copyWith(
                      color: LightColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    report.tempMinMax,
                    style: AppTextStyles.caption.copyWith(
                      color: LightColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: LightColors.dividerLight),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _WeatherMetric(
                  icon: Icons.air_rounded,
                  label: 'Wind',
                  value: report.windSpeed,
                  color: LightColors.trailGreen,
                ),
              ),
              Expanded(
                child: _WeatherMetric(
                  icon: Icons.water_drop_rounded,
                  label: 'Humidity',
                  value: report.humidity,
                  color: LightColors.altitudeBlue,
                ),
              ),
              Expanded(
                child: _WeatherMetric(
                  icon: Icons.speed_rounded,
                  label: 'Pressure',
                  value: report.pressure,
                  color: LightColors.peakAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WeatherMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.85), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: LightColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: LightColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ForecastStrip extends StatelessWidget {
  final List<ForecastDay> forecast;

  const _ForecastStrip({required this.forecast});

  IconData _getIcon(String condition) {
    switch (condition) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'cloudy':
        return Icons.cloud_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'wind':
        return Icons.air_rounded;
      case 'storm':
        return Icons.thunderstorm_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'clear':
        return LightColors.peakAmber;
      case 'cloudy':
        return LightColors.textSecondary;
      case 'snow':
        return LightColors.altitudeBlue;
      case 'wind':
        return LightColors.trailGreen;
      case 'storm':
        return LightColors.sosRed;
      default:
        return LightColors.forestPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      borderRadius: 20,
      depth: 6,
      spread: 3,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '4-Day Forecast',
            style: AppTextStyles.h3.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: forecast.map((item) {
              final condColor = _getConditionColor(item.condition);
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      item.day,
                      style: AppTextStyles.caption.copyWith(
                        color: LightColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: condColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIcon(item.condition),
                        color: condColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.tempMinMax,
                      style: AppTextStyles.caption.copyWith(
                        color: LightColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AdvisoryCard extends StatelessWidget {
  final String advisory;
  final String condition;

  const _AdvisoryCard({required this.advisory, required this.condition});

  @override
  Widget build(BuildContext context) {
    final isCritical = condition == 'snow' || condition == 'storm';
    final cardColor = isCritical ? const Color(0xFFFEECEB) : const Color(0xFFFEF9EB);
    final accentColor = isCritical ? LightColors.sosRed : LightColors.peakAmber;

    return ClayContainer(
      borderRadius: 18,
      depth: 4,
      spread: 2,
      color: cardColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCritical ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: accentColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCritical ? 'SAFETY WARNING' : 'TREKKER ADVISORY',
                  style: AppTextStyles.caption.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advisory,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherSkeletonLoader extends StatelessWidget {
  const _WeatherSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ClayContainer(
            borderRadius: 20,
            depth: 3,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: const SizedBox(
              height: 80,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: LightColors.forestPrimary,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _WeatherErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _WeatherErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      borderRadius: 20,
      depth: 4,
      color: const Color(0xFFFEECEB),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 40, color: LightColors.sosRed),
          const SizedBox(height: 12),
          Text(
            'Weather Offline',
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
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
