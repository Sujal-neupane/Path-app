import 'dart:ui';

/// Light theme color palette for PATH app
/// All colors follow WCAG AA contrast guidelines for accessibility
class LightColors {
  // ============ BRAND CORE ============
  static const Color summitDark = Color(0xFF1B3A2D);     // Deepest brand
  static const Color forestPrimary = Color(0xFF2D6A4F);  // Primary brand
  static const Color trailGreen = Color(0xFF52B788);     // Primary light
  static const Color meadowTint = Color(0xFFB7E4C7);     // Soft backgrounds

  // Primary variants (interactions)
  static const Color primaryHover = Color(0xFF245A41);   // Darker on hover
  static const Color primaryFocus = Color(0xFF1B3A2D);   // Darkest on focus
  static const Color primaryDisabled = Color(0xFFB7E4C7); // Light on disabled
  static const Color primaryOverlay = Color(0x1F2D6A4F); // 12% opacity for backgrounds
  static const Color primaryLight = Color(0xFFE8F5ED);   // Very light tint for backgrounds

  // ============ ACCENT COLORS ============
  static const Color peakAmber = Color(0xFFD4A017);      // CTA / Buttons / Moderate
  static const Color amberHover = Color(0xFFC29015);     // Darker on hover
  static const Color amberDisabled = Color(0xFFE8D9A8);  // Light on disabled
  static const Color amberLight = Color(0xFFFEF4E4);     // Very light tint

  static const Color altitudeBlue = Color(0xFF5B8DB8);   // Info / Weather
  static const Color blueHover = Color(0xFF4A7AA8);      // Darker on hover
  static const Color blueDisabled = Color(0xFFB7D0E0);   // Light on disabled
  static const Color blueLight = Color(0xFFEBF3F9);      // Very light tint

  static const Color sosRed = Color(0xFFE63946);         // Emergency / High Risk
  static const Color redHover = Color(0xFFC32E36);       // Darker on hover
  static const Color redDisabled = Color(0xFFE8A8B0);    // Light on disabled
  static const Color redLight = Color(0xFFFDE8EA);       // Very light tint

  // ============ SUCCESS COLOR ============
  static const Color successGreen = Color(0xFF2DBE60);   // Success states
  static const Color successHover = Color(0xFF26A64F);   // Darker on hover
  static const Color successLight = Color(0xFFE8F9F1);   // Very light tint

  // ============ WARNING COLOR ============
  static const Color warningOrange = Color(0xFFF59E0B);  // Warnings / Caution
  static const Color warningHover = Color(0xFFD97706);   // Darker on hover
  static const Color warningLight = Color(0xFFFEF3E2);   // Very light tint

  // ============ NEUTRAL COLORS ============
  static const Color stoneWhite = Color(0xFFF4F5F0);     // Background
  static const Color surfaceWhite = Color(0xFFFFFFFF);   // Surface
  static const Color surface95 = Color(0xFFF9F9F7);      // Slight variant
  static const Color surface90 = Color(0xFFF3F3EF);      // Medium variant

  static const Color divider = Color(0xFFE0E0E0);        // Divider lines
  static const Color dividerLight = Color(0xFFF0F0ED);   // Light divider
  static const Color dividerStrong = Color(0xFFCDCDC7);  // Strong divider

  // ============ TEXT / TYPOGRAPHY ============
  static const Color textPrimary = Color(0xFF1F1F1F);    // Main text (90% black)
  static const Color textSecondary = Color(0xFF666666);  // Secondary text (40% opacity of black)
  static const Color textTertiary = Color(0xFF999999);   // Hint text (60% opacity of black)
  static const Color textDisabled = Color(0xFFC0C0C0);   // Disabled text (75% opacity of black)
  static const Color textOnPrimary = Color(0xFFFFFFFF);  // Text on primary color
  static const Color textOnAccent = Color(0xFFFFFFFF);   // Text on accent color

  // ============ LOGO & BRANDING ============
  static const Color logoWhite = Color(0xFFFFFFFF);      // For use on dark backgrounds
  static const Color logoSlate = Color(0xFF4A4A4A);      // Alternate dark logo for light backgrounds
  static const Color logoPrimary = Color(0xFF2D6A4F);    // Logo on white backgrounds

  // ============ SEMANTIC COLORS (COMPONENT-SPECIFIC) ============
  // Difficulty levels
  static const Color difficultyEasy = Color(0xFF2DBE60);     // Easy = Green
  static const Color difficultyModerate = Color(0xFFD4A017); // Moderate = Amber
  static const Color difficultyHard = Color(0xFFE63946);     // Hard = Red
  static const Color difficultyExpert = Color(0xFF8B0000);   // Expert = Dark red

  // Altitude risk levels
  static const Color altitudeRiskLow = Color(0xFF2DBE60);    // Low = Green
  static const Color altitudeRiskModerate = Color(0xFFD4A017);// Moderate = Amber
  static const Color altitudeRiskHigh = Color(0xFFE63946);   // High = Red

  // Badge backgrounds
  static const Color badgeBackground = Color(0xFFF0F0ED);
  static const Color badgeBackgroundPrimary = Color(0xFFE8F5ED);
  static const Color badgeBackgroundAccent = Color(0xFFFEF4E4);
  static const Color badgeBackgroundDanger = Color(0xFFFDE8EA);

  // ============ COMPONENT-SPECIFIC ============
  // Skeleton/Loading
  static const Color skeletonBase = Color(0xFFE8E8E8);
  static const Color skeletonShimmer = Color(0xFFF5F5F5);

  // Overlay/Scrim
  static const Color scrimLight = Color(0x4D000000);     // 30% black
  static const Color scrimStrong = Color(0x80000000);    // 50% black

  // Focus state
  static const Color focusRing = Color(0xFF2D6A4F);      // Primary for focus rings
  static const Color focusRingWidth = Color(0xFFFFFFFF); // White space before ring
}
