import 'dart:io';
import 'dart:ui' as ui;

import 'package:backlog_vault/app/bootstrap/backlog_vault_app.dart';
import 'package:backlog_vault/app/routing/app_router.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/catalogs/application/catalog_controller.dart';
import 'package:backlog_vault/features/catalogs/domain/catalog_item.dart';
import 'package:backlog_vault/features/games/application/game_view_models.dart';
import 'package:backlog_vault/features/games/application/library_game_details.dart';
import 'package:backlog_vault/features/library/application/annual_game_log.dart';
import 'package:backlog_vault/features/library/application/library_providers.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/media/application/media_providers.dart';
import 'package:backlog_vault/features/settings/application/app_language.dart';
import 'package:backlog_vault/features/settings/application/external_credentials_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _Catalog extends Mock implements CatalogController {}

class _Clock extends Clock {
  const _Clock();
  @override
  DateTime now() => DateTime(2026, 10, 5);
}

class _Language extends AppLanguageController {
  @override
  Future<AppLanguagePreference> build() async => AppLanguagePreference.spanish;
}

class _Credentials extends ExternalCredentialsViewModel {
  @override
  Future<ExternalCredentialsState> build() async =>
      const ExternalCredentialsState();
}

const visualPlatforms = [
  CatalogItem(id: 'pc', name: 'PC'),
  CatalogItem(id: 'ps5', name: 'PlayStation 5'),
  CatalogItem(id: 'switch', name: 'Nintendo Switch'),
];
final visualRows = [
  for (var i = 0; i < _titles.length; i++)
    LibraryGameRow(
      gameId: '$i',
      libraryEntryId: '$i',
      title: _titles[i],
      isCompleted: i.isEven,
      playedYear:
          i < 10
              ? 2026
              : i < 14
              ? 2025
              : null,
      completedAt: i.isEven ? DateTime(i < 10 ? 2026 : 2025, 7, 14) : null,
      hoursPlayed: i == 7 ? null : [38.0, 12.5, 24.0, 62.5][i % 4],
      personalRating: i == 7 ? null : [5, 4, 3, 4][i % 4],
      personalNotes:
          i < 2
              ? 'Un mundo al que siempre quiero volver.\nLa música y la exploración hicieron que cada hora valiera la pena.'
              : null,
      playedPlatformId: visualPlatforms[i % 3].id,
      playedPlatformName: visualPlatforms[i % 3].name,
      selectedCoverLocalPath: 'synthetic/$i',
      releaseDate: DateTime(2020, 9, 17),
      type: 'Un jugador',
      platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
      genres: const [LibraryCatalogItem(id: 'adventure', name: 'Aventura')],
      updatedAt: DateTime(2026),
    ),
];
const _titles = [
  'Hades II',
  'Hollow Knight: Silksong',
  'Sea of Stars',
  'Balatro',
  'Celeste',
  'Tunic',
  'Hollow Knight',
  'Animal Well',
  'Chants of Sennaar',
  'Dave the Diver',
  'Outer Wilds',
  'Disco Elysium',
  'Gris',
  'Journey',
  'The Witness',
  'Fez',
];

LibraryGameDetails visualDetails(LibraryGameRow row) => LibraryGameDetails(
  game: GameDetails(
    id: row.gameId,
    title: row.title,
    type: row.type,
    releaseDate: row.releaseDate,
    createdAt: DateTime(2020),
    updatedAt: row.updatedAt,
  ),
  entry: LibraryEntryDetails(
    id: row.libraryEntryId,
    gameId: row.gameId,
    createdAt: DateTime(2020),
    updatedAt: row.updatedAt,
    isCompleted: row.isCompleted,
    completedAt: row.completedAt,
    playedYear: row.playedYear,
    hoursPlayed: row.hoursPlayed,
    personalRating: row.personalRating,
    personalNotes: row.personalNotes,
    playedPlatformId: row.playedPlatformId,
  ),
  platforms: const [CatalogItem(id: 'pc', name: 'PC')],
  genres: const [CatalogItem(id: 'adventure', name: 'Aventura')],
  playedPlatform: visualPlatforms.firstWhere(
    (p) => p.id == row.playedPlatformId,
  ),
  selectedCover: GameCoverDetails(
    id: row.gameId,
    localPath: row.selectedCoverLocalPath!,
  ),
);

/// Isolated production UI: no database, credentials, network or user files.
class VisualFixture {
  late ProviderContainer container;
  late GoRouter router;
  final covers = <String, Uint8List>{};
  static const boundary = ValueKey('visual-app');

  Future<void> open(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.runAsync(() async {
      await (FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      // Pin the font for portable goldens; the production theme is unchanged.
      final bytes =
          File('test/visual/fixtures/Roboto-Regular.ttf').readAsBytesSync();
      for (final family in ['Segoe UI', 'Roboto']) {
        await (FontLoader(family)
          ..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      }
      for (var i = 0; i < visualRows.length; i++) {
        covers['synthetic/$i'] = await _cover(i);
      }
    });
    final catalog = _Catalog();
    when(() => catalog.seedDefaultsIfEmpty()).thenAnswer((_) async {});
    when(
      () => catalog.watchPlatforms(),
    ).thenAnswer((_) => Stream.value(visualPlatforms));
    when(() => catalog.watchGenres()).thenAnswer(
      (_) =>
          Stream.value(const [CatalogItem(id: 'adventure', name: 'Aventura')]),
    );
    container = ProviderContainer(
      overrides: [
        catalogControllerProvider.overrideWithValue(catalog),
        annualLogClockProvider.overrideWithValue(const _Clock()),
        libraryRowsProvider.overrideWith((ref) => Stream.value(visualRows)),
        libraryGameProvider.overrideWith(
          (ref, id) async => visualDetails(
            visualRows.firstWhere((row) => row.libraryEntryId == id),
          ),
        ),
        localMediaBytesProvider.overrideWith((ref, path) async => covers[path]),
        appLanguageProvider.overrideWith(_Language.new),
        externalCredentialsProvider.overrideWith(_Credentials.new),
      ],
    );
    addTearDown(container.dispose);
    router = container.read(appRouterProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RepaintBoundary(key: boundary, child: BacklogVaultApp()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      for (final bytes in covers.values) {
        await precacheImage(
          MemoryImage(bytes),
          tester.element(find.byKey(boundary)),
        );
      }
    });
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(boundary),
      matchesGoldenFile('goldens/$name.png'),
    );
  }
}

Future<Uint8List> _cover(int index) async {
  const colors = [
    Color(0xFF742B35),
    Color(0xFF244B67),
    Color(0xFF4C6060),
    Color(0xFF705026),
    Color(0xFF484278),
    Color(0xFF416346),
  ];
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 240, 360),
    Paint()..color = colors[index % colors.length],
  );
  canvas.drawCircle(
    Offset(160, 120 + (index % 3) * 20),
    95,
    Paint()..color = Colors.white.withValues(alpha: 0.12),
  );
  canvas.drawPath(
    Path()
      ..moveTo(0, 240)
      ..lineTo(130, 100)
      ..lineTo(240, 270)
      ..lineTo(240, 360)
      ..lineTo(0, 360)
      ..close(),
    Paint()..color = Colors.black.withValues(alpha: 0.3),
  );
  final text = TextPainter(
    text: TextSpan(
      text: _titles[index].toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Roboto',
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w600,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: 208);
  text.paint(canvas, Offset(16, 330 - text.height));
  final picture = recorder.endRecording();
  final image = await picture.toImage(240, 360);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return bytes!.buffer.asUint8List();
}
