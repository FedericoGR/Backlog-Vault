import 'package:flutter/material.dart';

import '../../core/design_system/bv_theme_extension.dart';
import '../../core/design_system/bv_tokens.dart';

ThemeData buildBacklogVaultTheme() {
  return _buildBacklogVaultTheme(Brightness.light);
}

ThemeData buildBacklogVaultDarkTheme() {
  return _buildBacklogVaultTheme(Brightness.dark);
}

ThemeData _buildBacklogVaultTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final bv = isDark ? BvThemeExtension.dark : BvThemeExtension.light;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: BvColors.accent,
    brightness: brightness,
  ).copyWith(
    primary: isDark ? BvColors.accent : const Color(0xFF9B4B08),
    onPrimary: isDark ? const Color(0xFF241306) : Colors.white,
    primaryContainer:
        isDark ? BvColors.accentContainer : const Color(0xFFFFDCC0),
    onPrimaryContainer:
        isDark ? const Color(0xFFFFDCC0) : const Color(0xFF351B08),
    secondary: isDark ? const Color(0xFFAAAAB2) : const Color(0xFF5C5C64),
    onSecondary: isDark ? const Color(0xFF242428) : Colors.white,
    secondaryContainer:
        isDark ? const Color(0xFF242428) : const Color(0xFFE6E6EA),
    onSecondaryContainer:
        isDark ? const Color(0xFFE6E6EA) : const Color(0xFF242428),
    tertiary: isDark ? BvColors.amber : const Color(0xFF8A5B13),
    onTertiary: isDark ? const Color(0xFF322000) : Colors.white,
    tertiaryContainer:
        isDark ? BvColors.amberContainer : const Color(0xFFFFDEAA),
    onTertiaryContainer:
        isDark ? const Color(0xFFFFDDA7) : const Color(0xFF2D1A00),
    error: isDark ? BvColors.danger : const Color(0xFFB3261E),
    onError: Colors.white,
    errorContainer: isDark ? BvColors.dangerContainer : const Color(0xFFFFDAD6),
    onErrorContainer:
        isDark ? const Color(0xFFFFDADD) : const Color(0xFF410002),
    surface: isDark ? BvColors.darkBackground : BvColors.lightSurface,
    onSurface: isDark ? BvColors.textPrimaryDark : BvColors.lightTextPrimary,
    onSurfaceVariant:
        isDark ? BvColors.textSecondaryDark : BvColors.lightTextSecondary,
    outline: isDark ? BvColors.darkBorderStrong : BvColors.lightBorder,
    outlineVariant: isDark ? BvColors.darkBorder : const Color(0xFFE0E7E4),
    surfaceContainerLowest: isDark ? Colors.black : const Color(0xFFFFFFFF),
    surfaceContainerLow: isDark ? BvColors.darkCanvas : const Color(0xFFF8FAF9),
    surfaceContainer: isDark ? BvColors.darkSurface : const Color(0xFFF1F5F3),
    surfaceContainerHigh:
        isDark ? BvColors.darkSurfaceRaised : const Color(0xFFEAF0EE),
    surfaceContainerHighest:
        isDark ? BvColors.darkSurfaceHighest : const Color(0xFFE1E9E6),
  );
  final textTheme = Typography.material2021(
    platform: TargetPlatform.windows,
    colorScheme: colorScheme,
  ).black.apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  );
  final border = _outlineBorder(bv.border);
  final focusedBorder = _outlineBorder(bv.focus, width: 1.4);

  return ThemeData(
    colorScheme: colorScheme,
    brightness: brightness,
    useMaterial3: true,
    extensions: [bv],
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    scaffoldBackgroundColor:
        isDark ? BvColors.darkBackground : BvColors.lightBackground,
    canvasColor: bv.canvas,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: bv.surfaceRaised,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BvRadii.md),
        side: BorderSide(color: bv.border),
      ),
      margin: const EdgeInsets.all(4),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: bv.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BvRadii.lg),
        side: BorderSide(color: bv.border),
      ),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    ),
    dividerTheme: DividerThemeData(color: bv.border, thickness: 1, space: 1),
    dividerColor: bv.border,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? BvColors.darkCanvas : colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      errorBorder: _outlineBorder(colorScheme.error),
      focusedErrorBorder: _outlineBorder(colorScheme.error, width: 1.4),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      helperStyle: TextStyle(color: bv.textMuted),
      hintStyle: TextStyle(color: bv.textMuted),
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(40, 40)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        shape: WidgetStatePropertyAll(_buttonShape()),
        textStyle: WidgetStatePropertyAll(
          textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(40, 40)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        foregroundColor: _stateColor(
          normal: colorScheme.primary,
          disabled: bv.textMuted,
        ),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: bv.border.withValues(alpha: 0.55));
          }
          if (states.contains(WidgetState.focused) ||
              states.contains(WidgetState.hovered)) {
            return BorderSide(color: bv.focus);
          }
          return BorderSide(color: bv.borderStrong);
        }),
        shape: WidgetStatePropertyAll(_buttonShape()),
        overlayColor: _overlayColor(colorScheme.primary),
        textStyle: WidgetStatePropertyAll(
          textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(40, 40)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        foregroundColor: _stateColor(
          normal: colorScheme.primary,
          disabled: bv.textMuted,
        ),
        shape: WidgetStatePropertyAll(_buttonShape()),
        overlayColor: _overlayColor(colorScheme.primary),
        textStyle: WidgetStatePropertyAll(
          textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(40, 40)),
        foregroundColor: _stateColor(
          normal: colorScheme.onSurfaceVariant,
          disabled: bv.textMuted,
        ),
        overlayColor: _overlayColor(colorScheme.primary),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer.withValues(alpha: 0.72);
          }
          return isDark ? BvColors.darkCanvas : colorScheme.surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimaryContainer;
          }
          return colorScheme.onSurface;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BorderSide(color: bv.focus);
          }
          return BorderSide(color: bv.borderStrong);
        }),
        shape: WidgetStatePropertyAll(_buttonShape()),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: bv.surfaceHighest,
      selectedColor: colorScheme.primaryContainer,
      disabledColor: bv.surface.withValues(alpha: 0.68),
      deleteIconColor: colorScheme.onSurfaceVariant,
      labelStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: bv.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BvRadii.sm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: bv.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BvRadii.md),
        side: BorderSide(color: bv.border),
      ),
      textStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: isDark ? BvColors.darkSurfaceHighest : const Color(0xFF22302C),
        borderRadius: BorderRadius.circular(BvRadii.sm),
        border: Border.all(color: bv.borderStrong),
      ),
      textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
      waitDuration: const Duration(milliseconds: 450),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: bv.surfaceHighest,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      actionTextColor: colorScheme.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BvRadii.md),
        side: BorderSide(color: bv.border),
      ),
    ),
  );
}

OutlineInputBorder _outlineBorder(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(BvRadii.md),
    borderSide: BorderSide(color: color, width: width),
  );
}

RoundedRectangleBorder _buttonShape() {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(BvRadii.md),
  );
}

WidgetStateProperty<Color?> _overlayColor(Color color) {
  return WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) {
      return color.withValues(alpha: 0.14);
    }
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused)) {
      return color.withValues(alpha: 0.08);
    }
    return null;
  });
}

WidgetStateProperty<Color?> _stateColor({
  required Color normal,
  required Color disabled,
}) {
  return WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return disabled;
    return normal;
  });
}
