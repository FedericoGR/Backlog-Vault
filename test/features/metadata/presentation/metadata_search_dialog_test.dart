import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/games/application/library_game_details.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/metadata/application/metadata_providers.dart';
import 'package:backlog_vault/features/metadata/domain/external_game_details.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_provider.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_search_candidate.dart';
import 'package:backlog_vault/features/metadata/presentation/metadata_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('allows choosing RAWG or IGDB as metadata provider', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: MetadataSearchDialog(item: _details())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Proveedor'), findsOneWidget);
    expect(find.text('RAWG'), findsOneWidget);

    await tester.tap(find.text('RAWG'));
    await tester.pumpAndSettle();

    expect(find.text('IGDB'), findsOneWidget);
    await tester.tap(find.text('IGDB').last);
    await tester.pumpAndSettle();

    expect(find.text('Sin candidatos todavía'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an explicit option to save included IGDB cover', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metadataProviderListProvider.overrideWith(
            (ref) => const [_FakeIgdbProvider()],
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MetadataSearchDialog(item: _details())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hades').last);
    await tester.pumpAndSettle();

    expect(find.text('Guardar portada incluida'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stays stable on small viewport with diff preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metadataProviderListProvider.overrideWith(
            (ref) => const [_FakeIgdbProvider()],
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MetadataSearchDialog(item: _details())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hades').last);
    await tester.pumpAndSettle();

    expect(find.text('Guardar portada incluida'), findsOneWidget);
    expect(find.textContaining('Aplicar metadata'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps actions accessible with dense diff content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metadataProviderListProvider.overrideWith(
            (ref) => const [_FakeIgdbProvider(denseDetails: true)],
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: MetadataSearchDialog(item: _details())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hades').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.textContaining('Aplicar metadata'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Guardar portada incluida'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final _now = DateTime(2026, 6, 13);

LibraryGameDetails _details() {
  return LibraryGameDetails(
    game: Game(
      id: 'game-1',
      title: 'Hades',
      sortTitle: null,
      releaseDate: null,
      type: 'game',
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    entry: LibraryEntry(
      id: 'entry-1',
      gameId: 'game-1',
      status: GameStatus.backlog.name,
      personalRating: null,
      personalNotes: null,
      createdAt: _now,
      updatedAt: _now,
      deletedAt: null,
    ),
    platforms: const [],
    genres: const [],
    playthroughs: const [],
  );
}

class _FakeIgdbProvider implements MetadataProvider {
  const _FakeIgdbProvider({this.denseDetails = false});

  final bool denseDetails;

  @override
  String get providerId => 'igdb';

  @override
  String get displayName => 'IGDB';

  @override
  bool get requiresApiKey => true;

  @override
  Future<List<MetadataSearchCandidate>> searchGames(String query) async {
    return const [
      MetadataSearchCandidate(
        providerId: 'igdb',
        providerName: 'IGDB',
        externalId: '1',
        title: 'Hades',
      ),
    ];
  }

  @override
  Future<ExternalGameDetails> getGameDetails(String externalId) async {
    return ExternalGameDetails(
      providerId: 'igdb',
      providerName: 'IGDB',
      externalId: externalId,
      title: 'Hades',
      releaseDate: DateTime(2020, 9, 17),
      genres:
          denseDetails
              ? List.generate(10, (index) => 'Genre $index With Long Name')
              : const ['Roguelite'],
      platforms:
          denseDetails
              ? List.generate(10, (index) => 'Platform $index With Long Name')
              : const ['PC'],
      cover: const ExternalGameCover(
        externalId: 'cover-1',
        remoteUrl:
            'https://images.igdb.com/igdb/image/upload/t_cover_big/cofixture.jpg',
      ),
    );
  }
}
