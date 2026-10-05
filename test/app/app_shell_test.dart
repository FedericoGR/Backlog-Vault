import 'package:backlog_vault/app/routing/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('app shell uses navigation rail on desktop widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1366, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: _router(initialLocation: '/statistics')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      1,
    );
    expect(find.text('Inicio'), findsNothing);
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      2,
    );
    await tester.tap(find.text('Juegos'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      0,
    );
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Shell body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('app shell uses bottom navigation on mobile widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: _router(initialLocation: '/')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
    expect(find.text('Inicio'), findsNothing);
    await tester.tap(find.text('Estadísticas'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Shell body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

GoRouter _router({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder:
            (context, state) => const AppShell(
              child: Scaffold(body: Center(child: Text('Shell body'))),
            ),
      ),
      GoRoute(
        path: '/home',
        builder:
            (context, state) => const AppShell(
              child: Scaffold(body: Center(child: Text('Shell body'))),
            ),
      ),
      GoRoute(
        path: '/statistics',
        builder:
            (context, state) => const AppShell(
              child: Scaffold(body: Center(child: Text('Shell body'))),
            ),
      ),
      GoRoute(
        path: '/settings',
        builder:
            (context, state) => const AppShell(
              child: Scaffold(body: Center(child: Text('Shell body'))),
            ),
      ),
    ],
  );
}
