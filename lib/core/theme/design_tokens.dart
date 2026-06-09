/// Design tokens for the PATH app - single source of truth for all design constants
///
/// This file contains all design system values:
/// - Spacing scale (11 levels)
/// - Border radius values
/// - Typography scales
/// - Shadows and elevations
/// - Opacity values
/// - Responsive breakpoints
///
/// Every UI element should reference these tokens instead of hardcoding values.
library;

import 'package:flutter/material.dart';

/// Spacing scale: 4px base unit, 11 levels
/// Use: Padding, margins, gaps, insets
class Spacing {
  static const double xs = 4.0; // Micro spacing
  static const double sm = 8.0; // Small
  static const double md = 12.0; // Medium (default)
  static const double lg = 16.0; // Large
  static const double xl = 20.0; // Extra large
  static const double xxl = 24.0; // Double extra large
  static const double xxxl = 32.0; // Triple extra large
  static const double huge = 40.0; // Huge
  static const double massive = 48.0; // Massive
  static const double colossal = 56.0; // Colossal (common touch target)
  static const double giant = 64.0; // Giant

  // Common combinations
  static const double horizontalPadding = lg; // 16px
  static const double verticalPadding = lg; // 16px
  static const double cardPadding = xl; // 20px
  static const double sectionSpacing = xl; // 20px between sections
  static const double itemSpacing = md; // 12px between list items
}

/// Border radius scale
class Radius {
  static const double xs = 4.0; // Minimal rounding
  static const double sm = 8.0; // Small
  static const double md = 12.0; // Medium (default)
  static const double lg = 16.0; // Large
  static const double xl = 20.0; // Extra large
  static const double full = 999.0; // Circular
}

/// Shadow system - elevation-based shadows for depth
class AppShadows {
  // Subtle shadows (1-3 elevation)
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 2.0),
  ];

  // Medium shadows (4-6 elevation)
  static const List<BoxShadow> medium = [
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 2), blurRadius: 4.0),
  ];

  // Strong shadows (8+ elevation)
  static const List<BoxShadow> strong = [
    BoxShadow(color: Color(0x2F000000), offset: Offset(0, 4), blurRadius: 8.0),
  ];

  // Extra strong for modals
  static const List<BoxShadow> extraStrong = [
    BoxShadow(color: Color(0x3F000000), offset: Offset(0, 8), blurRadius: 16.0),
  ];

  // Pressed state (inset shadow effect)
  static const List<BoxShadow> pressed = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 1),
      blurRadius: 1.0,
      spreadRadius: -1.0,
    ),
  ];
}

/// Typography scale - font sizes for consistent hierarchy
class TypographyScale {
  // Extra small (caption-like)
  static const double xs = 11.0;

  // Small
  static const double sm = 12.0;

  // Small-medium
  static const double smMd = 13.0;

  // Medium (body default)
  static const double md = 14.0;

  // Medium-large
  static const double mdLg = 15.0;

  // Large (body large)
  static const double lg = 16.0;

  // Large-extra (subtitle)
  static const double lgXl = 18.0;

  // Extra large (body heading)
  static const double xl = 20.0;

  // 2XL (subheading)
  static const double xxl = 24.0;

  // 3XL (heading)
  static const double xxxl = 28.0;

  // 4XL (large heading)
  static const double huge = 32.0;

  // 5XL (very large heading)
  static const double massive = 40.0;

  // Display (hero text)
  static const double display = 48.0;
}

/// Opacity scale for transparency effects
class Opacity {
  // Disabled state
  static const double disabled = 0.38;

  // Secondary text
  static const double secondary = 0.60;

  // Tertiary/hint text
  static const double tertiary = 0.75;

  // Hover state
  static const double hover = 0.92;

  // Loading skeleton
  static const double skeleton = 0.10;

  // Divider
  static const double divider = 0.12;
}

/// Animation duration scale (in milliseconds)
class AnimationDuration {
  // Instant feedback
  static const Duration fastest = Duration(milliseconds: 100);

  // Quick interactions (button press, toggle)
  static const Duration fast = Duration(milliseconds: 200);

  // Standard UI transition
  static const Duration standard = Duration(milliseconds: 300);

  // Page transition
  static const Duration page = Duration(milliseconds: 400);

  // Entrance animation
  static const Duration entrance = Duration(milliseconds: 500);

  // Long animation (progress, hero)
  static const Duration long = Duration(milliseconds: 800);

  // Very long (staggered lists)
  static const Duration veryLong = Duration(milliseconds: 1000);

  // Delay stagger per item (in ms)
  static const int staggerDelayMs = 50;
}

/// Curve scale for animations
class AppCurves {
  // Standard easing
  static const Curve standard = Curves.easeInOut;

  // Entrance (ease out)
  static const Curve entrance = Curves.easeOut;

  // Exit (ease in)
  static const Curve exit = Curves.easeIn;

  // Bounce/elastic
  static const Curve bounce = Curves.elasticOut;

  // Snappy
  static const Curve snappy = Curves.easeOutCubic;

  // Smooth
  static const Curve smooth = Curves.easeInOutCubic;

  // Decelerate
  static const Curve decelerate = Curves.decelerate;

  // Accelerate
  static const Curve accelerate = Curves.easeInCubic;
}

/// Responsive breakpoints for different screen sizes
class Breakpoints {
  // Mobile (small phones)
  static const double mobile = 0.0;
  static const double mobileMax = 599.0;

  // Tablet
  static const double tablet = 600.0;
  static const double tabletMax = 1023.0;

  // Desktop
  static const double desktop = 1024.0;

  /// Get breakpoint name for current width
  static String getBreakpoint(double width) {
    if (width < tablet) return 'mobile';
    if (width < desktop) return 'tablet';
    return 'desktop';
  }

  /// Check if screen is mobile
  static bool isMobile(double width) => width < tablet;

  /// Check if screen is tablet
  static bool isTablet(double width) => width >= tablet && width < desktop;

  /// Check if screen is desktop
  static bool isDesktop(double width) => width >= desktop;
}

/// Touch target sizes (Fitts's Law compliance)
class TouchTargets {
  // Minimum touch target (48px recommended)
  static const double minimum = 48.0;

  // Comfortable (56px)
  static const double comfortable = 56.0;

  // Extra comfortable (64px)
  static const double extraComfortable = 64.0;

  // Minimum icon size (24px)
  static const double minIconSize = 24.0;

  // Standard icon size (32px)
  static const double iconSize = 32.0;

  // Large icon size (48px)
  static const double largeIconSize = 48.0;
}

/// Z-index elevation scale (for stacking context)
class Elevation {
  static const int hidden = -1;
  static const int background = 0;
  static const int card = 1;
  static const int overlay = 10;
  static const int modal = 100;
  static const int tooltip = 1000;
}

/// Semantic spacings - commonly used combinations
class SemanticSpacing {
  // Page/screen level spacing
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(
    horizontal: Spacing.lg,
  );
  static const EdgeInsets pageVertical = EdgeInsets.symmetric(
    vertical: Spacing.lg,
  );
  static const EdgeInsets pagePadding = EdgeInsets.all(Spacing.lg);

  // Card level spacing
  static const EdgeInsets cardPadding = EdgeInsets.all(Spacing.xl);
  static const EdgeInsets cardHorizontal = EdgeInsets.symmetric(
    horizontal: Spacing.xl,
  );
  static const EdgeInsets cardVertical = EdgeInsets.symmetric(
    vertical: Spacing.xl,
  );

  // List item spacing
  static const EdgeInsets listItemHorizontal = EdgeInsets.symmetric(
    horizontal: Spacing.lg,
  );
  static const EdgeInsets listItemVertical = EdgeInsets.symmetric(
    vertical: Spacing.md,
  );
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: Spacing.lg,
    vertical: Spacing.md,
  );

  // Component spacing
  static const EdgeInsets componentSmall = EdgeInsets.all(Spacing.sm);
  static const EdgeInsets componentMedium = EdgeInsets.all(Spacing.md);
  static const EdgeInsets componentLarge = EdgeInsets.all(Spacing.lg);
}

/// Line height scale for typography
class LineHeight {
  static const double tight = 1.2; // Headings
  static const double normal = 1.4; // Body (default)
  static const double relaxed = 1.5; // Body large
  static const double loose = 1.6; // Captions
}

/// Common border decorations
class AppBorders {
  static const Border subtleBorder = Border(
    bottom: BorderSide(color: Color(0x1F000000), width: 0.5),
  );

  static const Border standardBorder = Border(
    bottom: BorderSide(color: Color(0x2F000000), width: 1.0),
  );
}

/// Gradient definitions
class AppGradients {
  // Subtle gradient overlay
  static final LinearGradient subtleOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
  );

  // Strong gradient overlay (for hero images)
  static final LinearGradient strongOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
  );

  // Fade gradient (left to right)
  static final LinearGradient fadeHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Colors.white, Colors.white.withValues(alpha: 0)],
  );
}
