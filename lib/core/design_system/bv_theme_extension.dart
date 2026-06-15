import 'package:flutter/material.dart';

import 'bv_tokens.dart';

@immutable
class BvThemeExtension extends ThemeExtension<BvThemeExtension> {
  const BvThemeExtension({
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceHighest,
    required this.border,
    required this.borderStrong,
    required this.focus,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.textMuted,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceHighest;
  final Color border;
  final Color borderStrong;
  final Color focus;
  final Color warning;
  final Color warningContainer;
  final Color danger;
  final Color dangerContainer;
  final Color textMuted;

  static const dark = BvThemeExtension(
    canvas: BvColors.darkCanvas,
    surface: BvColors.darkSurface,
    surfaceRaised: BvColors.darkSurfaceRaised,
    surfaceHighest: BvColors.darkSurfaceHighest,
    border: BvColors.darkBorder,
    borderStrong: BvColors.darkBorderStrong,
    focus: BvColors.mint,
    warning: BvColors.amber,
    warningContainer: BvColors.amberContainer,
    danger: BvColors.danger,
    dangerContainer: BvColors.dangerContainer,
    textMuted: BvColors.textMutedDark,
  );

  static const light = BvThemeExtension(
    canvas: BvColors.lightBackground,
    surface: BvColors.lightSurface,
    surfaceRaised: BvColors.lightSurfaceRaised,
    surfaceHighest: Color(0xFFE5ECE9),
    border: BvColors.lightBorder,
    borderStrong: Color(0xFFB6C4C0),
    focus: Color(0xFF2E7D6F),
    warning: Color(0xFF9B650F),
    warningContainer: Color(0xFFFFE6BE),
    danger: Color(0xFFB3261E),
    dangerContainer: Color(0xFFFFDAD6),
    textMuted: BvColors.lightTextMuted,
  );

  static BvThemeExtension of(BuildContext context) {
    final extension = Theme.of(context).extension<BvThemeExtension>();
    if (extension != null) return extension;
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  @override
  BvThemeExtension copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceHighest,
    Color? border,
    Color? borderStrong,
    Color? focus,
    Color? warning,
    Color? warningContainer,
    Color? danger,
    Color? dangerContainer,
    Color? textMuted,
  }) {
    return BvThemeExtension(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceHighest: surfaceHighest ?? this.surfaceHighest,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      focus: focus ?? this.focus,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  BvThemeExtension lerp(ThemeExtension<BvThemeExtension>? other, double t) {
    if (other is! BvThemeExtension) return this;
    return BvThemeExtension(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceHighest: Color.lerp(surfaceHighest, other.surfaceHighest, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}
