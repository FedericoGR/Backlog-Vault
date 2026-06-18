import 'package:backlog_vault/features/bulk_metadata_import/application/apply_bulk_metadata_plan_use_case.dart';
import 'package:backlog_vault/features/bulk_metadata_import/application/bulk_metadata_import_providers.dart';
import 'package:backlog_vault/features/bulk_metadata_import/presentation/bulk_metadata_import_page.dart';
import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_game_row.dart';
import 'package:backlog_vault/features/media/application/media_providers.dart';
import 'package:backlog_vault/features/media/domain/media_asset_models.dart';
import 'package:backlog_vault/features/media/domain/media_provider.dart';
import 'package:backlog_vault/features/metadata/application/metadata_providers.dart';
import 'package:backlog_vault/features/metadata/domain/apply_metadata_request.dart';
import 'package:backlog_vault/features/metadata/domain/external_game_details.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_provider.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_search_candidate.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  tearDownAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;
  });

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
    tester.view.physicalSize = const Size(1200, 1400);
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
          mediaProviderListProvider.overrideWith(
            (ref) => const [_FakeIgdbCoverProvider()],
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
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Generar preview'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Generar preview'));
    await tester.pumpAndSettle();

    expect(find.text('Portada nueva seleccionada'), findsWidgets);
    expect(find.text('No hay campos de metadata para aplicar.'), findsNothing);
    expect(find.text('Con match'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Aplicar cambios', skipOffstage: false), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('applied plan is replaced by a final result state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1400);
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
          mediaProviderListProvider.overrideWith(
            (ref) => const [_FakeIgdbCoverProvider()],
          ),
          applyBulkMetadataPlanUseCaseProvider.overrideWith(
            (ref) => const ApplyBulkMetadataPlanUseCase(
              applyMetadata: _noopApplyMetadata,
              saveCover: _noopSaveCover,
            ),
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
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Generar preview'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Generar preview'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Aplicar cambios'),
      360,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Aplicar cambios'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'APLICAR');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Aplicar'));
    await tester.pumpAndSettle();

    expect(find.text('Importación finalizada'), findsOneWidget);
    expect(find.text('Generar nuevo preview'), findsOneWidget);
    expect(find.text('Volver a biblioteca'), findsOneWidget);
    expect(find.text('Aplicar cambios'), findsNothing);
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

class _FakeIgdbCoverProvider implements MediaProvider {
  const _FakeIgdbCoverProvider();

  @override
  String get providerId => 'igdb';

  @override
  String get displayName => 'IGDB';

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
        externalId: 'igdb-game',
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
        externalId: 'igdb-cover-1',
        kind: MediaAssetKind.cover,
        remoteUrl: 'https://images.igdb.com/igdb/fixture-cover.jpg',
        mimeType: 'image/jpeg',
      ),
      ExternalMediaAsset(
        providerId: providerId,
        providerName: displayName,
        externalId: 'igdb-cover-2',
        kind: MediaAssetKind.cover,
        remoteUrl: 'https://images.igdb.com/igdb/fixture-cover-alt.jpg',
        mimeType: 'image/jpeg',
      ),
    ];
  }
}

Future<void> _noopApplyMetadata(ApplyMetadataRequest request) async {}

Future<void> _noopSaveCover({
  required String gameId,
  required ExternalMediaAsset asset,
}) async {}
