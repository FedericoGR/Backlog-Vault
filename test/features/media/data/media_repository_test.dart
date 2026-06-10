import 'dart:io';
import 'dart:typed_data';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/ids/id_generator.dart';
import 'package:backlog_vault/features/media/data/media_file_storage.dart';
import 'package:backlog_vault/features/media/data/media_repository.dart';
import 'package:backlog_vault/features/media/domain/media_asset_models.dart';
import 'package:backlog_vault/features/media/domain/media_exception.dart';
import 'package:drift/native.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late MediaRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp(
      'backlog_vault_media_repo_',
    );
    repository = MediaRepository(
      db,
      storage: MediaFileStorage(baseDirectoryLoader: () async => tempDir),
      httpClient: MockClient((request) async {
        final seed = request.url.toString().contains('second') ? 2 : 1;
        return http.Response.bytes(_pngBytes(seed), 200);
      }),
      ids: _SequenceIds(),
    );
    await _insertGame(db);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('saves a remote cover and marks it selected', () async {
    final saved = await repository.saveRemoteCover(
      gameId: 'game-1',
      asset: _asset('external-1', 'https://cdn.example.test/cover.png'),
    );

    expect(saved.gameId, 'game-1');
    expect(saved.isSelected, isTrue);
    expect(saved.source, MediaAssetSource.steamgriddb.name);
    expect(saved.externalId, 'external-1');
    expect(saved.localPath, 'media/games/game-1/id-1.png');

    final file = await repository.resolveLocalFile(saved.localPath);
    expect(await file.exists(), isTrue);
    expect(await repository.selectedCoverForGame('game-1'), isNotNull);
  });

  test('replacing a cover deselects the previous cover', () async {
    final first = await repository.saveRemoteCover(
      gameId: 'game-1',
      asset: _asset('external-1', 'https://cdn.example.test/cover.png'),
    );
    final second = await repository.saveRemoteCover(
      gameId: 'game-1',
      asset: _asset('external-2', 'https://cdn.example.test/second.png'),
    );

    final covers = await repository.coversForGame('game-1');
    final firstReloaded = covers.singleWhere((cover) => cover.id == first.id);
    final selectedCount = covers.where((cover) => cover.isSelected).length;

    expect(second.id, isNot(first.id));
    expect(firstReloaded.isSelected, isFalse);
    expect(selectedCount, 1);
    expect((await repository.selectedCoverForGame('game-1'))!.id, second.id);
  });

  test('same provider external id is reused for the same game', () async {
    final first = await repository.saveRemoteCover(
      gameId: 'game-1',
      asset: _asset('external-1', 'https://cdn.example.test/cover.png'),
    );
    final second = await repository.saveRemoteCover(
      gameId: 'game-1',
      asset: _asset('external-1', 'https://cdn.example.test/cover.png'),
    );

    expect(second.id, first.id);
    expect(await repository.coversForGame('game-1'), hasLength(1));
  });

  test('same hash is reused even with a different external id', () async {
    final first = await repository.saveRemoteCover(
      gameId: 'game-1',
      asset: _asset('external-1', 'https://cdn.example.test/cover.png'),
    );
    final second = await repository.saveRemoteCover(
      gameId: 'game-1',
      asset: _asset('external-2', 'https://cdn.example.test/cover-copy.png'),
    );

    expect(second.id, first.id);
    expect(await repository.coversForGame('game-1'), hasLength(1));
  });

  test('same provider external id for another game fails safely', () async {
    await _insertGame(db, id: 'game-2');
    await repository.saveRemoteCover(
      gameId: 'game-1',
      asset: _asset('external-1', 'https://cdn.example.test/cover.png'),
    );

    await expectLater(
      repository.saveRemoteCover(
        gameId: 'game-2',
        asset: _asset('external-1', 'https://cdn.example.test/cover.png'),
      ),
      throwsA(
        isA<MediaException>().having(
          (error) => error.type,
          'type',
          MediaErrorType.conflict,
        ),
      ),
    );
  });

  test('soft-delete hides selected cover without deleting the row', () async {
    final saved = await repository.saveRemoteCover(
      gameId: 'game-1',
      asset: _asset('external-1', 'https://cdn.example.test/cover.png'),
    );

    await repository.softDelete(saved.id);

    expect(await repository.selectedCoverForGame('game-1'), isNull);
    final rows = await db.select(db.mediaAssets).get();
    expect(rows, hasLength(1));
    expect(rows.single.deletedAt, isNotNull);
  });
}

ExternalMediaAsset _asset(String externalId, String url) {
  return ExternalMediaAsset(
    providerId: 'steamgriddb',
    providerName: 'SteamGridDB',
    externalId: externalId,
    kind: MediaAssetKind.cover,
    remoteUrl: url,
    mimeType: 'image/png',
    width: 600,
    height: 900,
  );
}

Future<void> _insertGame(AppDatabase db, {String id = 'game-1'}) async {
  await db
      .into(db.games)
      .insert(
        GamesCompanion.insert(
          id: id,
          title: 'Hades',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      );
}

Uint8List _pngBytes(int seed) {
  return Uint8List.fromList([
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    seed,
  ]);
}

class _SequenceIds extends IdGenerator {
  _SequenceIds() : super();

  var _next = 1;

  @override
  String newId() => 'id-${_next++}';
}
