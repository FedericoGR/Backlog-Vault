import 'package:backlog_vault/app/bootstrap/backlog_vault_app.dart';
import 'package:backlog_vault/app/routing/app_router.dart';
import 'package:backlog_vault/app/theme/app_theme.dart';
import 'package:backlog_vault/core/design_system/bv_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('app follows system theme and exposes neutral dark theme', (
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

  test('dark theme uses neutral scaffold and restrained orange accent', () {
    final theme = buildBacklogVaultDarkTheme();

    expect(theme.scaffoldBackgroundColor, const Color(0xFF0D0D0F));
    expect(theme.colorScheme.surface, const Color(0xFF0D0D0F));
    expect(theme.extension<BvThemeExtension>(), isNotNull);
    expect(theme.cardTheme.elevation, 0);
    expect(theme.colorScheme.primary, const Color(0xFFE98A2F));
  });

  test('light theme exposes the Backlog Vault design extension', () {
    final theme = buildBacklogVaultTheme();

    expect(theme.extension<BvThemeExtension>(), isNotNull);
    expect(theme.useMaterial3, isTrue);
  });
}
