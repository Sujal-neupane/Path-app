import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';

class MapWeatherScreen extends StatelessWidget {
  const MapWeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            Text(
              'Map & Weather',
              style: AppTextStyles.h1.copyWith(
                color: LightColors.textPrimary,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Trail visibility, weather status, and quick outdoor readiness in one place.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: LightColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _MapPreviewCard(),
            const SizedBox(height: 14),
            _CurrentWeatherCard(),
            const SizedBox(height: 14),
            _ForecastStrip(),
          ],
        ),
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF203A2C), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -26,
            top: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: Text(
              'Live Trail Map',
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 46,
            child: Text(
              'Khumbu Region • Offline Ready',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
          const Positioned(
            right: 20,
            bottom: 20,
            child: Icon(Icons.map_rounded, color: Colors.white, size: 64),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: LightColors.summitDark,
              ),
              icon: const Icon(Icons.navigation_rounded, size: 18),
              label: const Text('Open Trail Navigator'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LightColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.ac_unit_rounded,
                color: LightColors.altitudeBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Conditions',
                style: AppTextStyles.h3.copyWith(
                  color: LightColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _WeatherStat(label: 'Temp', value: '4°C'),
              ),
              Expanded(
                child: _WeatherStat(label: 'Wind', value: '18 km/h'),
              ),
              Expanded(
                child: _WeatherStat(label: 'Humidity', value: '64%'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Light snow expected after 6 PM. Recommended: thermal layer + windproof shell.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const days = [
      ('Tue', '3° / -2°', Icons.ac_unit_rounded),
      ('Wed', '5° / -1°', Icons.cloud_rounded),
      ('Thu', '6° / 0°', Icons.wb_sunny_rounded),
      ('Fri', '4° / -2°', Icons.ac_unit_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LightColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '4-Day Forecast',
            style: AppTextStyles.h3.copyWith(
              color: LightColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: days
                .map(
                  (item) => Expanded(
                    child: Column(
                      children: [
                        Text(
                          item.$1,
                          style: AppTextStyles.caption.copyWith(
                            color: LightColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Icon(item.$3, color: LightColors.altitudeBlue),
                        const SizedBox(height: 6),
                        Text(
                          item.$2,
                          style: AppTextStyles.caption.copyWith(
                            color: LightColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final String label;
  final String value;

  const _WeatherStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: LightColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: LightColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
