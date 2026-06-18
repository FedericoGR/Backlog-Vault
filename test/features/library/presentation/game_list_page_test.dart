import 'package:backlog_vault/app/theme.dart';
import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/catalogs/data/catalog_repository.dart';
import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:backlog_vault/features/library/data/saved_library_view_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/library/presentation/game_list_page.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late _MockCatalogRepository catalogRepository;

  setUp(() {
    catalogRepository = _MockCatalogRepository();
    when(() => catalogRepository.seedDefaultsIfEmpty()).thenAnswer((_) async {});
  });

  testWidgets('library table keeps sidebar visible on wide desktop', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildLibraryApp(catalogRepository));
    await tester.pumpAndSettle();

    expect(find.text('Backlog Vault'), findsOneWidget);
    expect(find.text('Filtros'), findsWidgets);
    expect(find.byType(DataTable2), findsOneWidget);
    expect(find.text('Columnas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('library switches between table gallery and list on medium desktop', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1366, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildLibraryApp(catalogRepository));
    await tester.pumpAndSettle();

    expect(find.byType(DataTable2), findsOneWidget);
    expect(find.text('Filtros'), findsNothing);

    await tester.tap(find.text('Galería'));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
    expect(find.textContaining('Collector Edition'), findsWidgets);

    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsWidgets);
    expect(find.text('Completado'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('library stays stable on android sized viewport and opens filters modal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildLibraryApp(catalogRepository));
    await tester.pumpAndSettle();

    expect(find.text('Backlog Vault'), findsOneWidget);
    expect(find.text('Crear juego'), findsOneWidget);
    expect(find.byType(DataTable2), findsNothing);
    expect(find.text('Filtros'), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Filtros (0)'));
    await tester.pumpAndSettle();

    expect(find.text('Filtros'), findsWidgets);
    expect(find.text('Aplicar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('library selection bar stays accessible with long titles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1366, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildLibraryApp(catalogRepository));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Seleccionar varios'));
    await tester.pumpAndSettle();

    expect(find.textContaining('seleccionados'), findsOneWidget);
    expect(find.textContaining('Seleccionar visibles'), findsOneWidget);
    expect(find.text('Eliminar'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

Widget _buildLibraryApp(_MockCatalogRepository catalogRepository) {
  return ProviderScope(
    overrides: [
      catalogRepositoryProvider.overrideWith((ref) => catalogRepository),
      libraryRowsProvider.overrideWith((ref) => Stream.value(_rows)),
      platformsProvider.overrideWith((ref) => Stream.value(_platforms)),
      genresProvider.overrideWith((ref) => Stream.value(_genres)),
      customLibraryViewsProvider.overrideWith(
        (ref) => Stream.value(const []),
      ),
    ],
    child: MaterialApp(
      theme: buildBacklogVaultDarkTheme(),
      home: const GameListPage(),
    ),
  );
}

final _now = DateTime(2026, 6, 18);

final _platforms = [
  Platform(
    id: 'pc',
    name: 'PC',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
  Platform(
    id: 'switch',
    name: 'Nintendo Switch',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
  Platform(
    id: 'ps5',
    name: 'PS5',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
];

final _genres = [
  Genre(
    id: 'jrpg',
    name: 'JRPG',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
  Genre(
    id: 'action',
    name: 'Acción',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
  Genre(
    id: 'adventure',
    name: 'Aventura',
    createdAt: _now,
    updatedAt: _now,
    deletedAt: null,
  ),
];

final _rows = [
  LibraryGameRow(
    gameId: 'g1',
    libraryEntryId: 'e1',
    title:
        'Final Fantasy XIII-2 Collector Edition With A Very Long Title For Responsive QA',
    status: GameStatus.completed,
    personalRating: 3,
    hoursPlayed: 18.2,
    releaseDate: DateTime(2011, 12, 15),
    completedAt: DateTime(2026, 5, 27),
    type: 'Un jugador',
    platforms: const [
      LibraryCatalogItem(id: 'pc', name: 'PC'),
      LibraryCatalogItem(id: 'ps3', name: 'PS3'),
      LibraryCatalogItem(id: 'xbox360', name: 'Xbox 360'),
    ],
    genres: const [
      LibraryCatalogItem(id: 'adventure', name: 'Aventura'),
      LibraryCatalogItem(id: 'fantasy', name: 'Fantasy'),
      LibraryCatalogItem(id: 'rpg', name: 'RPG'),
    ],
    playthroughCount: 1,
    updatedAt: _now,
  ),
  LibraryGameRow(
    gameId: 'g2',
    libraryEntryId: 'e2',
    title: 'Pragmata',
    status: GameStatus.completed,
    personalRating: 4,
    hoursPlayed: 16.4,
    releaseDate: DateTime(2026, 4, 17),
    completedAt: DateTime(2026, 5, 8),
    type: 'Un jugador',
    platforms: const [
      LibraryCatalogItem(id: 'switch2', name: 'Nintendo Switch 2'),
      LibraryCatalogItem(id: 'pc', name: 'PC'),
    ],
    genres: const [
      LibraryCatalogItem(id: 'action', name: 'Acción'),
      LibraryCatalogItem(id: 'scifi', name: 'Sci-Fi'),
    ],
    playthroughCount: 1,
    updatedAt: _now.subtract(const Duration(days: 2)),
  ),
];
