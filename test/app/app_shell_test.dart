import 'package:backlog_vault/app/routing/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  for (final width in [1440.0, 900.0, 390.0]) {
    testWidgets('top navigation preserves destinations at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        routes: [
          ShellRoute(
            builder: (context, state, child) => AppShell(child: child),
            routes: [
              for (final path in ['/', '/statistics', '/settings'])
                GoRoute(
                  path: path,
                  builder: (_, _) => const Scaffold(body: Text('Content')),
                ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Inicio'), findsNothing);
      for (final destination
          in {
            'nav-statistics': '/statistics',
            'nav-settings': '/settings',
            'nav-games': '/',
          }.entries) {
        await tester.tap(find.byKey(ValueKey(destination.key)));
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          destination.value,
        );
      }
      expect(tester.getTopLeft(find.text('Content')).dy, 56);
      expect(tester.takeException(), isNull);
    });
  }
}
