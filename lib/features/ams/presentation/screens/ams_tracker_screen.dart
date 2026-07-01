import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/theme/app_colors.dart';
import 'package:path_app/core/theme/app_typography.dart';
import 'package:path_app/core/theme/light_colors.dart';

/// Smart AMS (Acute Mountain Sickness) Tracker.
///
/// Implements the clinically-recognised **Lake Louise Score**: four symptoms
/// rated 0–3, summed into a risk band with clear, actionable guidance.
/// This is the "Smart AMS Tracker" from the Safety-First product proposal.
class AmsTrackerScreen extends ConsumerStatefulWidget {
  const AmsTrackerScreen({super.key});

  @override
  ConsumerState<AmsTrackerScreen> createState() => _AmsTrackerScreenState();
}

class _AmsTrackerScreenState extends ConsumerState<AmsTrackerScreen> {
  static const _symptoms = <_Symptom>[
    _Symptom('Headache', Icons.sick_rounded, [
      'None',
      'Mild',
      'Moderate',
      'Severe / incapacitating',
    ]),
    _Symptom('Nausea / appetite', Icons.restaurant_rounded, [
      'Good appetite',
      'Poor appetite or nausea',
      'Moderate nausea / vomiting',
      'Severe, incapacitating',
    ]),
    _Symptom('Fatigue / weakness', Icons.battery_2_bar_rounded, [
      'Not tired',
      'Mild fatigue',
      'Moderate fatigue',
      'Severe, incapacitating',
    ]),
    _Symptom('Dizziness', Icons.blur_on_rounded, [
      'None',
      'Mild',
      'Moderate',
      'Severe, incapacitating',
    ]),
  ];

  final List<int> _scores = List<int>.filled(_symptoms.length, 0);

  int get _total => _scores.fold(0, (a, b) => a + b);

  /// (band, color, headline, guidance)
  (_Band, Color, String, String) get _result {
    final hasSevere = _scores.any((s) => s == 3);
    if (_total >= 6 || hasSevere) {
      return (
        _Band.severe,
        LightColors.sosRed,
        'High risk — descend now',
        'This points to severe AMS, which can progress to life-threatening HACE/HAPE. Descend at least 500–1,000 m immediately, do not ascend further, and seek help. Trigger SOS if symptoms worsen.',
      );
    }
    if (_total >= 3) {
      return (
        _Band.moderate,
        LightColors.peakAmber,
        'Moderate AMS — stop ascending',
        'Rest at the current altitude. Hydrate, avoid alcohol and sleeping pills. Do NOT go higher until symptoms fully resolve. Re-check in a few hours.',
      );
    }
    return (
      _Band.none,
      LightColors.successGreen,
      'Low risk — you are clear',
      'No significant AMS right now. Keep ascending gradually (≤500 m sleeping altitude/day above 3,000 m), stay hydrated, and re-check if you feel unwell.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final result = _result;

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: AppBar(
        backgroundColor: c.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          children: [
            Text('SAFETY',
                style: AppType.eyebrow.copyWith(color: LightColors.sosRed)),
            const SizedBox(height: 2),
            Text('AMS Tracker',
                style: AppType.titleSm.copyWith(color: c.textPrimary)),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // Why-now context card (answers the backlog "why does this appear?")
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.accentSoft,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(
                  color: LightColors.peakAmber.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: LightColors.peakAmber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Altitude sickness can strike above 2,500 m. Rate how you feel now — be honest, it could save your life.',
                    style: AppType.bodySm.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < _symptoms.length; i++) ...[
            _SymptomCard(
              symptom: _symptoms[i],
              value: _scores[i],
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _scores[i] = v);
              },
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 8),
          _ResultCard(
            band: result.$1,
            color: result.$2,
            headline: result.$3,
            guidance: result.$4,
            score: _total,
          ),
          if (result.$1 == _Band.severe) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: LightColors.sosRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  context.go('/dashboard');
                },
                icon: const Icon(Icons.sos_rounded),
                label: Text('Go to SOS',
                    style: AppType.button.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _Band { none, moderate, severe }

class _Symptom {
  final String name;
  final IconData icon;
  final List<String> levels;
  const _Symptom(this.name, this.icon, this.levels);
}

class _SymptomCard extends StatelessWidget {
  final _Symptom symptom;
  final int value;
  final ValueChanged<int> onChanged;

  const _SymptomCard({
    required this.symptom,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

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
            children: [
              Icon(symptom.icon, size: 18, color: c.primary),
              const SizedBox(width: 8),
              Text(symptom.name,
                  style: AppType.titleSm.copyWith(color: c.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: value == i ? c.primary : c.canvas,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: value == i ? c.primary : c.border,
                        ),
                      ),
                      child: Text(
                        '$i',
                        style: AppType.titleSm.copyWith(
                          color: value == i ? Colors.white : c.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(symptom.levels[value],
              style: AppType.caption.copyWith(color: c.textSecondary)),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _Band band;
  final Color color;
  final String headline;
  final String guidance;
  final int score;

  const _ResultCard({
    required this.band,
    required this.color,
    required this.headline,
    required this.guidance,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text('SCORE $score',
                    style: AppType.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    )),
              ),
              const Spacer(),
              Icon(
                band == _Band.severe
                    ? Icons.warning_rounded
                    : band == _Band.moderate
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_rounded,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(headline,
              style: AppType.title.copyWith(color: color, fontSize: 20)),
          const SizedBox(height: 8),
          Text(guidance, style: AppType.body),
        ],
      ),
    );
  }
}
