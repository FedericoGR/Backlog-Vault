import 'package:backlog_vault/app/routing/app_router.dart';
import 'package:backlog_vault/app/theme/app_theme.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/catalogs/application/catalog_controller.dart';
import 'package:backlog_vault/features/library/application/annual_game_log.dart';
import 'package:backlog_vault/features/library/application/library_providers.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/library/presentation/annual_game_log_page.dart';
import 'package:backlog_vault/features/library/presentation/widgets/library_catalog_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Catalog extends Mock implements CatalogController {}

class _Clock extends Clock {
  const _Clock();
  @override
  DateTime now() => DateTime(2026, 10, 5);
}

void main() {
  late ProviderContainer container;
  late _Catalog catalog;

  setUp(() {
    catalog = _Catalog();
    when(() => catalog.seedDefaultsIfEmpty()).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [
        catalogControllerProvider.overrideWith((ref) => catalog),
        annualLogClockProvider.overrideWithValue(const _Clock()),
        libraryRowsProvider.overrideWith((ref) => Stream.value(_rows)),
      ],
    );
  });
  tearDown(() => container.dispose());

  Future<void> pump(
    WidgetTester tester, {
    bool router = false,
    double width = 1000,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final config = router ? container.read(appRouterProvider) : null;
    if (config != null) addTearDown(config.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child:
            config == null
                ? MaterialApp(
                  theme: buildBacklogVaultDarkTheme(),
                  home: const GameListPage(),
                )
                : MaterialApp.router(
                  theme: buildBacklogVaultDarkTheme(),
                  routerConfig: config,
                ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'app opens Games directly, with only Games Statistics Settings navigation',
    (tester) async {
      await pump(tester, router: true);
      expect(
        container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        '/',
      );
      expect(find.byType(GameListPage), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-games')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-statistics')), findsOneWidget);
      expect(find.byTooltip('Ajustes'), findsOneWidget);
      expect(find.text('Inicio'), findsNothing);
      container.read(appRouterProvider).go('/home');
      await tester.pumpAndSettle();
      expect(
        container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        '/',
      );
    },
  );

  testWidgets(
    'gallery defaults to current year without configuration controls',
    (tester) async {
      await pump(tester);
      expect(container.read(annualGameLogProvider).year, 2026);
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Current finished'), findsOneWidget);
      expect(find.text('Current unfinished'), findsOneWidget);
      expect(find.text('Previous finished'), findsNothing);
      expect(find.text('Unknown old game'), findsNothing);
      for (final label in [
        'Tabla',
        'Lista',
        'Galería',
        'Guardar vista',
        'Columnas',
        'Filtros',
        'Partidas',
        'Nueva partida',
        'Jugando',
        'Pausar',
        'Retirado',
      ]) {
        expect(find.textContaining(label), findsNothing, reason: label);
      }
      expect(find.byTooltip('Seleccionar varios'), findsNothing);
      expect(find.byType(Checkbox), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'year navigation and search intersect; unknown release-dated records stay accessible',
    (tester) async {
      await pump(tester);
      await tester.enterText(
        find.byKey(const ValueKey('annual-search')),
        'finished',
      );
      await tester.tap(find.byKey(const ValueKey('previous-year')));
      await tester.pumpAndSettle();
      expect(find.text('Previous finished'), findsOneWidget);
      expect(find.text('Current finished'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('next-year')));
      await tester.pumpAndSettle();
      expect(find.text('Current finished'), findsOneWidget);
      expect(find.text('Previous finished'), findsNothing);
      await tester.enterText(find.byKey(const ValueKey('annual-search')), '');
      await tester.tap(find.byKey(const ValueKey('selected-year')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sin año').last);
      await tester.pumpAndSettle();
      expect(container.read(annualGameLogProvider).year, isNull);
      expect(find.text('Unknown old game'), findsOneWidget);
      expect(find.text('Current finished'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cards prioritize rating hours completion and personally played platform',
    (tester) async {
      await pump(tester);
      final card = find.byWidgetPredicate(
        (w) => w is LibraryCatalogCard && w.row.libraryEntryId == 'current',
      );
      Finder textInCard(String text) =>
          find.descendant(of: card, matching: find.text(text));
      expect(textInCard('18,0 h'), findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.byIcon(Icons.star)),
        findsNWidgets(4),
      );
      expect(
        find.descendant(of: card, matching: find.byTooltip('Terminado')),
        findsOneWidget,
      );
      expect(textInCard('Played Switch'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('Catalog PC'), findsNothing);
      expect(find.text('Catalog RPG'), findsNothing);
      expect(find.text('01-01-1999'), findsNothing);
    },
  );

  testWidgets(
    'mobile retains gallery and three destinations without overflow',
    (tester) async {
      await pump(tester, router: true, width: 390);
      expect(find.byKey(const ValueKey('nav-games')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-statistics')), findsOneWidget);
      expect(find.byTooltip('Ajustes'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Agregar juego'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('add carries selected year and card opens game', (tester) async {
    when(() => catalog.watchPlatforms()).thenAnswer((_) => Stream.value([]));
    when(() => catalog.watchGenres()).thenAnswer((_) => Stream.value([]));
    await pump(tester, router: true);
    await tester.tap(find.byKey(const ValueKey('previous-year')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-game')));
    await tester.pumpAndSettle();
    expect(
      container
          .read(appRouterProvider)
          .routeInformationProvider
          .value
          .uri
          .queryParameters['year'],
      '2025',
    );
    final field = tester.widget<TextFormField>(
      find.byKey(const ValueKey('played-year-field')),
    );
    expect(field.controller!.text, '2025');
    container.read(appRouterProvider).go('/');
    await tester.pumpAndSettle();
    // Do not build Detail here: routing to it is sufficient, its own tests cover rendering.
    await tester.tap(find.text('Previous finished'));
    expect(
      container.read(appRouterProvider).routeInformationProvider.value.uri.path,
      '/games/previous',
    );
  });
}

LibraryGameRow _row(
  String id,
  String title,
  int? year, {
  bool completed = false,
}) => LibraryGameRow(
  gameId: id,
  libraryEntryId: id,
  title: title,
  playedYear: year,
  isCompleted: completed,
  completedAt: completed ? DateTime(2026, 5, 1) : null,
  hoursPlayed: 18,
  personalRating: 4,
  playedPlatformId: 'switch',
  playedPlatformName: 'Played Switch',
  releaseDate: DateTime(1999),
  type: 'game',
  updatedAt: DateTime(2026),
  platforms: const [LibraryCatalogItem(id: 'pc', name: 'Catalog PC')],
  genres: const [LibraryCatalogItem(id: 'rpg', name: 'Catalog RPG')],
);
final _rows = [
  _row('current', 'Current finished', 2026, completed: true),
  _row('unfinished', 'Current unfinished', 2026),
  _row('previous', 'Previous finished', 2025, completed: true),
  _row('unknown', 'Unknown old game', null),
];
