import 'package:backlog_vault/features/bulk_metadata_import/presentation/bulk_metadata_import_page.dart';
import 'package:backlog_vault/features/bulk_metadata_import/domain/bulk_metadata_import_models.dart';
import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/media/application/media_providers.dart';
import 'package:backlog_vault/features/media/domain/media_asset_models.dart';
import 'package:backlog_vault/features/media/domain/media_provider.dart';
import 'package:backlog_vault/features/metadata/application/metadata_providers.dart';
import 'package:backlog_vault/features/metadata/domain/external_game_details.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_provider.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_search_candidate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bulk import options stay readable in a narrow viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryRowsProvider.overrideWith((ref) => Stream.value(_rows)),
          metadataProviderListProvider.overrideWith(
            (ref) => const [_FakeIgdbProvider()],
          ),
        ],
        child: MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark(useMaterial3: true),
          home: const BulkMetadataImportPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Solo metadata'), findsOneWidget);
    expect(find.text('Solo cover art'), findsOneWidget);
    expect(find.text('Metadata + cover art'), findsOneWidget);
    expect(find.text('Juegos a analizar'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Solo cover art'));
    await tester.pumpAndSettle();

    expect(find.text('Fuente de portada'), findsOneWidget);
    expect(find.text('Portadas existentes'), findsOneWidget);
    expect(find.text('Provider metadata'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cover only preview selects covers without metadata noise', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryRowsProvider.overrideWith((ref) => Stream.value(_rows)),
          metadataProviderListProvider.overrideWith(
            (ref) => const [_FakeIgdbProvider()],
          ),
          mediaProviderListProvider.overrideWith(
            (ref) => const [_FakeSteamGridDbProvider()],
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const BulkMetadataImportPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Solo cover art'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byType(DropdownButtonFormField<BulkCoverProviderMode>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('SteamGridDB').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generar preview'));
    await tester.pumpAndSettle();

    expect(find.text('Portada nueva seleccionada'), findsWidgets);
    expect(find.text('No hay campos de metadata para aplicar.'), findsNothing);
    expect(find.text('Con match'), findsNothing);

    await tester.drag(
      find.byType(ListView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aplicar cambios', skipOffstage: false), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final _rows = [
  LibraryGameRow(
    gameId: 'game-1',
    libraryEntryId: 'entry-1',
    title: 'Final Fantasy XIII-2 Collector Edition With A Long Title',
    status: GameStatus.backlog,
    type: 'game',
    platforms: const [LibraryCatalogItem(id: 'pc', name: 'PC')],
    genres: const [LibraryCatalogItem(id: 'jrpg', name: 'JRPG')],
    playthroughCount: 0,
    updatedAt: DateTime(2026, 6, 14),
  ),
];

class _FakeIgdbProvider implements MetadataProvider {
  const _FakeIgdbProvider();

  @override
  String get providerId => 'igdb';

  @override
  String get displayName => 'IGDB';

  @override
  bool get requiresApiKey => true;

  @override
  Future<List<MetadataSearchCandidate>> searchGames(String query) async {
    return const [];
  }

  @override
  Future<ExternalGameDetails> getGameDetails(String externalId) async {
    return const ExternalGameDetails(
      providerId: 'igdb',
      providerName: 'IGDB',
      externalId: '1',
      title: 'Hades',
    );
  }
}

class _FakeSteamGridDbProvider implements MediaProvider {
  const _FakeSteamGridDbProvider();

  @override
  String get providerId => 'steamgriddb';

  @override
  String get displayName => 'SteamGridDB';

  @override
  bool get requiresApiKey => true;

  @override
  MediaProviderCapabilities get capabilities =>
      const MediaProviderCapabilities(supportsCovers: true);

  @override
  Future<List<MediaSearchCandidate>> searchGames(String query) async {
    return [
      MediaSearchCandidate(
        providerId: providerId,
        providerName: displayName,
        externalId: 'sgdb-game',
        title: query,
      ),
    ];
  }

  @override
  Future<List<ExternalMediaAsset>> searchCoverAssets(
    String externalGameId,
  ) async {
    return [
      ExternalMediaAsset(
        providerId: providerId,
        providerName: displayName,
        externalId: 'grid-1',
        kind: MediaAssetKind.cover,
        remoteUrl: 'https://cdn.steamgriddb.com/grid/fixture.jpg',
        mimeType: 'image/jpeg',
      ),
      ExternalMediaAsset(
        providerId: providerId,
        providerName: displayName,
        externalId: 'grid-2',
        kind: MediaAssetKind.cover,
        remoteUrl: 'https://cdn.steamgriddb.com/grid/fixture-alt.jpg',
        mimeType: 'image/jpeg',
      ),
    ];
  }
}
