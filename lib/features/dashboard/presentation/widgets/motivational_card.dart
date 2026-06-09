import 'package:flutter/material.dart';
import 'package:path_app/core/theme/design_tokens.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';

/// Motivational message widget that changes based on activity and time
class MotivationalCard extends StatelessWidget {
  final String message;
  final String subMessage;
  final IconData icon;
  final Color accentColor;

  const MotivationalCard({
    super.key,
    required this.message,
    required this.subMessage,
    this.icon = Icons.favorite_rounded,
    this.accentColor = LightColors.sosRed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.08),
            accentColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: accentColor.withOpacity(0.15),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(Radius.lg),
      ),
      child: Row(
        children: [
          // Icon with glow
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(Radius.md),
            ),
            child: Center(
              child: Icon(
                icon,
                color: accentColor,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: Spacing.lg),
          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: Spacing.xs),
                Text(
                  subMessage,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: LightColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Factory method to create motivational card based on context
  static MotivationalCard forStreak(int streakDays) {
    final messages = [
      ('🔥 $streakDays day streak!', 'Keep the momentum going'),
      ('You\'re on fire!', 'Don\'t break the chain'),
      ('Unstoppable!', 'Keep crushing it'),
    ];
    final msg = messages[streakDays % messages.length];
    return MotivationalCard(
      message: msg.$1,
      subMessage: msg.$2,
      icon: Icons.local_fire_department_rounded,
      accentColor: LightColors.peakAmber,
    );
  }

  static MotivationalCard forFirstTrek() {
    return const MotivationalCard(
      message: 'Start Your Adventure',
      subMessage: 'Choose your first trek and begin exploring',
      icon: Icons.flag_rounded,
      accentColor: LightColors.forestPrimary,
    );
  }

  static MotivationalCard forMorning() {
    return const MotivationalCard(
      message: 'Good Morning!',
      subMessage: 'Time to explore the mountains',
      icon: Icons.wb_sunny_rounded,
      accentColor: LightColors.peakAmber,
    );
  }

  static MotivationalCard forEvening() {
    return const MotivationalCard(
      message: 'Good Evening!',
      subMessage: 'Plan your next trek before bed',
      icon: Icons.nights_stay_rounded,
      accentColor: LightColors.altitudeBlue,
    );
  }

  static MotivationalCard forMilestone(String milestone) {
    return MotivationalCard(
      message: 'Milestone Reached!',
      subMessage: 'You\'ve reached $milestone. Celebrate your progress!',
      icon: Icons.emoji_events_rounded,
      accentColor: LightColors.peakAmber,
    );
  }
}
