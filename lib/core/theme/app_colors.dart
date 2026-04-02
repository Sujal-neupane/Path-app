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
      isDark ? DarkColors.bioluminescent : LightColors.summitDark;

  Color get textSecondary =>
      isDark ? Colors.white70 : Colors.black54;
}
