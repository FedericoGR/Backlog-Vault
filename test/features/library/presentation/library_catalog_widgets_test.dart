import 'package:backlog_vault/app/theme/app_theme.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/library/presentation/widgets/library_catalog_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('catalog grid renders long titles and missing covers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: SizedBox(
          width: 520,
          height: 520,
          child: LibraryCatalogGrid(rows: _rows),
        ),
      ),
    );

    expect(find.textContaining('A Very Long Game Title'), findsOneWidget);
    expect(find.byIcon(Icons.image_outlined), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog grid avoids bottom overflow with dense long metadata', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _TestApp(child: LibraryCatalogGrid(rows: [_denseRow])),
    );

    expect(find.textContaining('Extremely Long'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildBacklogVaultDarkTheme(),
      home: Scaffold(body: child),
    );
  }
}

final _rows = [
  LibraryGameRow(
    gameId: 'game-1',
    libraryEntryId: 'entry-1',
    title: 'Hades',
    isCompleted: true,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
    genres: const [LibraryCatalogItem(id: 'rpg', name: 'Roguelike')],
    personalRating: 5,
    hoursPlayed: 24,
    releaseDate: DateTime(2020, 9, 17),
    completedAt: DateTime(2026, 1, 1),

    updatedAt: DateTime(2026, 6, 13),
  ),
  LibraryGameRow(
    gameId: 'game-2',
    libraryEntryId: 'entry-2',
    title:
        'A Very Long Game Title That Should Wrap Cleanly Without Overflowing',
    isCompleted: false,
    type: 'game',
    platforms: const [],
    genres: const [],

    updatedAt: DateTime(2026, 6, 13),
  ),
];

final _denseRow = LibraryGameRow(
  gameId: 'game-dense',
  libraryEntryId: 'entry-dense',
  title:
      'Extremely Long Tactical Role Playing Game Definitive Remastered Edition',
  isCompleted: false,
  type: 'game',
  platforms: const [
    LibraryCatalogItem(id: 'pc', name: 'PC'),
    LibraryCatalogItem(id: 'switch', name: 'Nintendo Switch'),
    LibraryCatalogItem(id: 'ps5', name: 'PlayStation 5'),
    LibraryCatalogItem(id: 'deck', name: 'Steam Deck'),
  ],
  genres: const [
    LibraryCatalogItem(id: 'rpg', name: 'Rol'),
    LibraryCatalogItem(id: 'strategy', name: 'Estrategia'),
    LibraryCatalogItem(id: 'adventure', name: 'Aventura'),
    LibraryCatalogItem(id: 'story', name: 'Narrativo'),
  ],
  personalRating: 5,
  hoursPlayed: 123.5,
  releaseDate: DateTime(2021, 11, 11),
  completedAt: DateTime(2026, 5, 8),

  updatedAt: DateTime(2026, 6, 13),
);
