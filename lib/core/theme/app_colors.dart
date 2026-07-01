import 'package:flutter/material.dart';
import 'dark_colors.dart';
import 'light_colors.dart';


class AppColors {
  final bool isDark;
  AppColors(this.isDark);

  // Background
  Color get background =>
      isDark ? DarkColors.voidForest : LightColors.stoneWhite;

  Color get surface =>
      isDark ? DarkColors.deepCanopy : Colors.white;

  Color get card =>
      isDark ? DarkColors.undergrowth : Colors.white;

  // Brand
  Color get primary =>
      isDark ? DarkColors.forestPrimary : LightColors.forestPrimary;

  Color get primaryLight =>
      isDark ? DarkColors.trailGreen : LightColors.trailGreen;

  // Accent
  Color get accent => isDark ? DarkColors.peakAmber : LightColors.peakAmber;

  // Info / Weather
  Color get info => isDark ? DarkColors.altitudeBlue : LightColors.altitudeBlue;

  // Emergency
  Color get error => isDark ? DarkColors.sosRed : LightColors.sosRed;

  // Text
  Color get textPrimary =>
      isDark ? const Color(0xFFEAF2EC) : LightColors.summitDark;

  Color get textSecondary =>
      isDark ? Colors.white70 : const Color(0xFF5C6660);

  Color get textTertiary =>
      isDark ? Colors.white38 : const Color(0xFF9AA39D);

  // ── Editorial neutral roles ──────────────────────────────────────
  /// Warm off-white / near-black page canvas.
  Color get canvas =>
      isDark ? DarkColors.voidForest : const Color(0xFFF6F5F1);

  /// Slightly raised neutral surface (cards on the canvas).
  Color get surfaceElevated =>
      isDark ? DarkColors.undergrowth : Colors.white;

  /// Hairline border for neutral cards.
  Color get border =>
      isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFE7E5DE);

  /// Soft tint of the brand colour for filled accents.
  Color get primarySoft => isDark
      ? DarkColors.forestPrimary.withValues(alpha: 0.18)
      : LightColors.primaryLight;

  /// Accent (amber) soft tint.
  Color get accentSoft => isDark
      ? DarkColors.peakAmber.withValues(alpha: 0.16)
      : LightColors.amberLight;
}
