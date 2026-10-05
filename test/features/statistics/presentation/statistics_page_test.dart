import 'package:backlog_vault/app/theme/app_theme.dart';
import 'package:backlog_vault/core/design_system/bv_stat_card.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/library/application/annual_game_log.dart';
import 'package:backlog_vault/features/library/application/library_providers.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/statistics/presentation/statistics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Clock extends Clock {
  const _Clock();
  @override
  DateTime now() => DateTime(2026, 10, 5);
}

void main() {
  Future<void> open(
    WidgetTester tester,
    List<LibraryGameRow> rows, {
    double width = 900,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          annualLogClockProvider.overrideWithValue(const _Clock()),
          libraryRowsProvider.overrideWith((ref) => Stream.value(rows)),
        ],
        child: MaterialApp(
          theme: buildBacklogVaultDarkTheme(),
          home: const StatisticsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String kpi(WidgetTester tester, String key) =>
      tester.widget<BvStatCard>(find.byKey(ValueKey('statistics-$key'))).value;

  testWidgets(
    'defaults to calendar year and exposes exactly four yearly KPIs with restrained sections',
    (tester) async {
      await open(tester, _rows);
      expect(
        tester
            .widget<DropdownButton<int>>(
              find.byKey(const ValueKey('statistics-year')),
            )
            .value,
        2026,
      );
      expect(find.byType(BvStatCard), findsNWidgets(4));
      expect(kpi(tester, 'games'), '2');
      expect(kpi(tester, 'completed'), '1');
      expect(kpi(tester, 'hours'), '18.0');
      expect(kpi(tester, 'rating'), '5.0');
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.text('Dónde jugué'), findsOneWidget);
      expect(find.text('Current favorite'), findsOneWidget);
      expect(find.text('Unrated'), findsNothing);
      expect(find.text('PS5'), findsOneWidget);
      expect(find.text('Catalog PC'), findsNothing);
      for (final old in [
        'Calidad de datos',
        'Biblioteca por estado',
        'Progreso anual',
        'Últimos completados',
        'Sin portada',
        'Sin metadata',
        'Sin puntaje',
        'Sin género',
        'Sin fecha de completado',
        'Ratings',
        'Backlog',
        'Jugando',
        'Pausado',
        'Abandonado',
        'Retirado',
        'Partidas',
      ]) {
        expect(find.textContaining(old), findsNothing, reason: old);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('year arrows and dropdown change the scope of every section', (
    tester,
  ) async {
    await open(tester, _rows);
    await tester.tap(find.byKey(const ValueKey('statistics-previous-year')));
    await tester.pumpAndSettle();
    expect(kpi(tester, 'games'), '1');
    expect(kpi(tester, 'completed'), '0');
    expect(kpi(tester, 'hours'), '4.0');
    expect(kpi(tester, 'rating'), '3.0');
    expect(find.text('Old favorite'), findsOneWidget);
    expect(find.text('Current favorite'), findsNothing);
    expect(find.text('Switch'), findsOneWidget);
    expect(find.text('PS5'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('statistics-year')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2026').last);
    await tester.pumpAndSettle();
    expect(kpi(tester, 'games'), '2');
    await tester.tap(find.byKey(const ValueKey('statistics-next-year')));
    await tester.pumpAndSettle();
    expect(kpi(tester, 'games'), '0');
    expect(find.text('Sin juegos en este año'), findsOneWidget);
  });

  testWidgets(
    'no current-year games does not silently select another year or assign unknown records',
    (tester) async {
      await open(tester, [_rows[2], _rows[3]]);
      expect(kpi(tester, 'games'), '0');
      expect(kpi(tester, 'hours'), 'Sin datos');
      expect(kpi(tester, 'rating'), 'Sin datos');
      expect(find.text('Sin juegos en este año'), findsOneWidget);
      expect(find.textContaining('Juegos → Sin año'), findsOneWidget);
    },
  );

  testWidgets(
    'partial records and completed games without dates show honest unavailable values',
    (tester) async {
      await open(tester, [row('No measurements', completed: true)]);
      expect(kpi(tester, 'games'), '1');
      expect(kpi(tester, 'completed'), '1');
      expect(kpi(tester, 'hours'), 'Sin datos');
      expect(kpi(tester, 'rating'), 'Sin datos');
      expect(
        find.text('Todavía no hay juegos con puntaje en este año.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Todavía no hay plataformas jugadas registradas en este año.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty library keeps year navigation and clear empty state', (
    tester,
  ) async {
    await open(tester, [], width: 390);
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('Sin juegos en este año'), findsOneWidget);
    expect(kpi(tester, 'games'), '0');
    expect(kpi(tester, 'hours'), 'Sin datos');
    expect(tester.takeException(), isNull);
  });

  testWidgets('long personal titles and platforms fit a narrow window', (
    tester,
  ) async {
    await open(tester, [
      row(
        'An extremely long personal favorite game title that should remain readable',
        rating: 5,
        platform: 'A very long personally played platform name',
      ),
    ], width: 360);
    await tester.scrollUntilVisible(
      find.text('Dónde jugué'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Dónde jugué'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

LibraryGameRow row(
  String title, {
  int? year = 2026,
  bool completed = false,
  double? hours,
  int? rating,
  String? platform,
}) => LibraryGameRow(
  gameId: title,
  libraryEntryId: title,
  title: title,
  playedYear: year,
  isCompleted: completed,
  hoursPlayed: hours,
  personalRating: rating,
  playedPlatformId: platform,
  playedPlatformName: platform,
  releaseDate: DateTime(2026),
  updatedAt: DateTime(2026),
  type: 'game',
  platforms: const [LibraryCatalogItem(id: 'catalog-pc', name: 'Catalog PC')],
  genres: const [],
);
final _rows = [
  row(
    'Current favorite',
    completed: true,
    hours: 18,
    rating: 5,
    platform: 'PS5',
  ),
  row('Unrated'),
  row('Old favorite', year: 2025, hours: 4, rating: 3, platform: 'Switch'),
  row('Unknown', year: null, hours: 99, rating: 1),
];
