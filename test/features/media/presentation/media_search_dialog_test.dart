import 'package:backlog_vault/app/theme.dart';
import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/games/application/library_game_details.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/media/application/media_providers.dart';
import 'package:backlog_vault/features/media/domain/media_asset_models.dart';
import 'package:backlog_vault/features/media/domain/media_provider.dart';
import 'package:backlog_vault/features/media/presentation/media_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MediaSearchDialog shows empty state before searching', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaProviderListProvider.overrideWith(
            (ref) => const [_FakeMediaProvider(withAssets: false)],
          ),
        ],
        child: MaterialApp(
          theme: buildBacklogVaultDarkTheme(),
          home: Scaffold(body: MediaSearchDialog(item: _details())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin portadas todavia'), findsNothing);
    expect(find.textContaining('Sin portadas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MediaSearchDialog renders cover grid', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaProviderListProvider.overrideWith(
            (ref) => const [_FakeMediaProvider(withAssets: true)],
          ),
        ],
        child: MaterialApp(
          theme: buildBacklogVaultDarkTheme(),
          home: Scaffold(body: MediaSearchDialog(item: _details())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hades').last);
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MediaSearchDialog stays stable on small viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaProviderListProvider.overrideWith(
            (ref) => const [_FakeMediaProvider(withAssets: true)],
          ),
        ],
        child: MaterialApp(
          theme: buildBacklogVaultDarkTheme(),
          home: Scaffold(body: MediaSearchDialog(item: _details())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hades').last);
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final _now = DateTime(2026, 6, 16);

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

class _FakeMediaProvider implements MediaProvider {
  const _FakeMediaProvider({required this.withAssets});

  final bool withAssets;

  @override
  MediaProviderCapabilities get capabilities =>
      const MediaProviderCapabilities(supportsCovers: true);

  @override
  String get displayName => 'SteamGridDB';

  @override
  String get providerId => 'steamgriddb';

  @override
  bool get requiresApiKey => true;

  @override
  Future<List<ExternalMediaAsset>> searchCoverAssets(
    String externalGameId,
  ) async {
    if (!withAssets) return const [];
    return const [
      ExternalMediaAsset(
        providerId: 'steamgriddb',
        providerName: 'SteamGridDB',
        externalId: 'asset-1',
        kind: MediaAssetKind.cover,
        remoteUrl: 'https://example.com/cover-1.jpg',
        thumbnailUrl: 'https://example.com/cover-1.jpg',
      ),
      ExternalMediaAsset(
        providerId: 'steamgriddb',
        providerName: 'SteamGridDB',
        externalId: 'asset-2',
        kind: MediaAssetKind.cover,
        remoteUrl: 'https://example.com/cover-2.jpg',
        thumbnailUrl: 'https://example.com/cover-2.jpg',
      ),
    ];
  }

  @override
  Future<List<MediaSearchCandidate>> searchGames(String query) async {
    return const [
      MediaSearchCandidate(
        providerId: 'steamgriddb',
        providerName: 'SteamGridDB',
        externalId: 'game-1',
        title: 'Hades',
      ),
    ];
  }
}
