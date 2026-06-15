import 'package:backlog_vault/app/backlog_vault_app.dart';
import 'package:backlog_vault/app/router.dart';
import 'package:backlog_vault/app/theme.dart';
import 'package:backlog_vault/core/design_system/bv_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('app follows system theme and exposes OLED dark theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWith(
            (ref) => GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
        child: const BacklogVaultApp(),
      ),
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(app.darkTheme, isNotNull);
  });

  test('dark theme uses black scaffold and very dark surfaces', () {
    final theme = buildBacklogVaultDarkTheme();

    expect(theme.scaffoldBackgroundColor, const Color(0xFF050606));
    expect(theme.colorScheme.surface, const Color(0xFF050606));
    expect(theme.extension<BvThemeExtension>(), isNotNull);
    expect(theme.cardTheme.elevation, 0);
  });

  test('light theme exposes the Backlog Vault design extension', () {
    final theme = buildBacklogVaultTheme();

    expect(theme.extension<BvThemeExtension>(), isNotNull);
    expect(theme.useMaterial3, isTrue);
  });
}
