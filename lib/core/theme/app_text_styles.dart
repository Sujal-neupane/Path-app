import 'package:flutter/material.dart';

class AppTextStyles {
  //  Headings (Plus Jakarta Sans)
  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  //  Body (Inter)
  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  //  Stats / Numbers (Space Grotesk)
  static const TextStyle stats = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // ── Auth-Specific Styles ──

  /// Hero title on auth screens ("Resume Expedition", "Join the Expedition")
  static const TextStyle authTitle = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 30,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    height: 1.15,
  );

  /// Tagline / subtitle under the auth hero
  static const TextStyle authSubtitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Trail input field label ("EXPEDITION ID", "TRAIL PASS")
  static const TextStyle fieldLabel = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
  );

  /// CTA button text
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 2.0,
  );

  /// Small caption / policy text
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}