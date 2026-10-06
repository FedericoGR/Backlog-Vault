import 'package:flutter/material.dart';

/// Brand color constants consumed by the application themes.
class BvColors {
  const BvColors._();

  static const darkBackground = Color(0xFF0D0D0F);
  static const darkCanvas = Color(0xFF101012);
  static const darkSurface = Color(0xFF19191C);
  static const darkSurfaceRaised = Color(0xFF242428);
  static const darkSurfaceHighest = Color(0xFF2C2C31);
  static const darkBorder = Color(0xFF28282D);
  static const darkBorderStrong = Color(0xFF34343A);

  static const accent = Color(0xFFE98A2F);
  static const accentContainer = Color(0xFF3C2819);
  static const amber = Color(0xFFD89A4A);
  static const amberContainer = Color(0xFF3F2B13);
  static const danger = Color(0xFFE06C75);
  static const dangerContainer = Color(0xFF421C22);

  static const textPrimaryDark = Color(0xFFF2F2F4);
  static const textSecondaryDark = Color(0xFFAAAAB2);
  static const textMutedDark = Color(0xFF74747D);

  static const lightBackground = Color(0xFFF5F7F6);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceRaised = Color(0xFFEFF3F1);
  static const lightBorder = Color(0xFFD4DCDA);
  static const lightTextPrimary = Color(0xFF17211F);
  static const lightTextSecondary = Color(0xFF52615E);
  static const lightTextMuted = Color(0xFF77827F);
}

/// Shared corner radii for controls and surfaces.
class BvRadii {
  const BvRadii._();

  static const double xs = 4;
  static const double sm = 6;
  static const double md = 6;
  static const double lg = 8;
  static const double pill = 999;
}

/// Short durations reserved for standard visual state transitions.
class BvDurations {
  const BvDurations._();

  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 180);
}
