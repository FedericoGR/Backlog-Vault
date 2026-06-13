import 'package:flutter/material.dart';

ThemeData buildBacklogVaultTheme() {
  return _buildBacklogVaultTheme(Brightness.light);
}

ThemeData buildBacklogVaultDarkTheme() {
  return _buildBacklogVaultTheme(Brightness.dark);
}

ThemeData _buildBacklogVaultTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2E7D6F),
    brightness: brightness,
  ).copyWith(
    surface: isDark ? const Color(0xFF050505) : null,
    surfaceContainerLowest: isDark ? Colors.black : null,
    surfaceContainerLow: isDark ? const Color(0xFF080808) : null,
    surfaceContainer: isDark ? const Color(0xFF0D0D0D) : null,
    surfaceContainerHigh: isDark ? const Color(0xFF141414) : null,
    surfaceContainerHighest: isDark ? const Color(0xFF1A1A1A) : null,
  );

  return ThemeData(
    colorScheme: colorScheme,
    brightness: brightness,
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    scaffoldBackgroundColor: isDark ? Colors.black : null,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF080808) : null,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? const Color(0xFF252525) : Colors.transparent,
        ),
      ),
    ),
    dividerColor: isDark ? const Color(0xFF262626) : null,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
