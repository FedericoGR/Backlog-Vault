import 'dart:convert';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/import_export/library_export/data/library_export_repository.dart';
import 'package:backlog_vault/features/import_export/library_export/domain/library_export_document.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test(
    'obsolete saved-view settings export verbatim without runtime filter models',
    () async {
      const filter =
          '{"version":1,"statuses":["playing","paused","wishlist"],"minHours":18,"missingGenre":true,"futureField":{"keep":true}}';
      const sort = '{"field":"releaseDate","direction":"descending"}';
      const columns =
          '{"visibleColumns":["title","status","hours"],"unknownOption":42}';
      final date = DateTime(2020);
      await db
          .into(db.savedViews)
          .insert(
            SavedViewsCompanion.insert(
              id: 'old-view',
              name: 'Old custom view',
              filterJson: filter,
              sortJson: sort,
              columnConfigJson: columns,
              createdAt: date,
              updatedAt: date,
            ),
          );
      final before = await db.select(db.savedViews).getSingle();
      final exported =
          await LibraryExportRepository(
            db,
            sourcePlatform: 'windows',
          ).createDocument();
      expect(exported.savedViews.single['filterJson'], filter);
      expect(exported.savedViews.single['sortJson'], sort);
      expect(exported.savedViews.single['columnConfigJson'], columns);
      expect(await db.select(db.savedViews).getSingle(), before);
    },
  );

  LibraryExportRepository repository({DateTime? now}) {
    return LibraryExportRepository(
      db,
      sourcePlatform: 'windows',
      clock: _FixedClock(now ?? DateTime.utc(2026, 7, 17, 18, 30, 45)),
    );
  }

  test('empty export has the versioned contract and zero summary', () async {
    final document = await repository().createDocument();
    final json = document.toJson();

    expect(json['format'], libraryExportFormat);
    expect(json['formatVersion'], 2);
    expect(json['exportedAt'], '2026-07-17T18:30:45.000Z');
    expect(json['appVersion'], '1.0.0-rc2');
    expect(json['sourcePlatform'], 'windows');
    final summary = json['summary']! as Map<String, Object?>;
    for (final value in summary.values) {
      expect(value, 0);
    }
    for (final key in _collectionKeys) {
      expect(json[key], isEmpty, reason: key);
    }
  });

  test('a game can be exported without a library entry', () async {
    final now = DateTime.utc(2026, 1, 1);
    await db
        .into(db.games)
        .insert(
          GamesCompanion.insert(
            id: 'game-only',
            title: 'Standalone',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final document = await repository().createDocument();

    expect(document.games.single['id'], 'game-only');
    expect(document.libraryEntries, isEmpty);
    expect(document.summary.games, 1);
    expect(document.summary.libraryEntries, 0);
  });

  test(
    'complex export preserves entities, relations and optional values',
    () async {
      await _insertComplexLibrary(db);

      final document = await repository().createDocument();

      expect(document.games.map((row) => row['id']), ['game-a', 'game-z']);
      expect(document.libraryEntries.single['gameId'], 'game-z');
      expect(document.libraryEntries.single['personalRating'], 5);
      expect(
        document.libraryEntries.single['personalNotes'],
        'Línea uno\nLínea dos — 你好',
      );
      expect(document.libraryEntries.single['isCompleted'], isTrue);
      expect(document.libraryEntries.single['playedYear'], 2026);
      expect(
        document.libraryEntries.single['completedAt'],
        '2026-02-03T00:00:00.000Z',
      );
      expect(document.libraryEntries.single['hoursPlayed'], 42);
      expect(document.libraryEntries.single['playedPlatformId'], 'platform-1');
      expect(document.libraryEntries.single['status'], 'completed');
      expect(document.playthroughs.single['hoursPlayed'], 21.5);
      expect(document.playthroughs.single['rating'], 4);
      expect(document.playthroughs.single['startedAt'], isNotNull);
      expect(document.playthroughs.single['completedAt'], isNotNull);
      expect(document.platforms.single['shortName'], isNull);
      expect(document.libraryEntryPlatforms.single['isPrimary'], isTrue);
      expect(document.gameGenres.single['gameId'], 'game-z');
      expect(document.savedViews.single['filterJson'], contains('completed'));
      expect(document.metadata.single['provider'], 'rawg');
      expect(
        document.metadata.single['externalUrl'],
        'https://example.invalid/games/hades',
      );
      expect(document.media.single['hash'], 'sha256-cover');
      expect(document.media.single['hasLocalFile'], isTrue);
      expect(document.media.single, isNot(contains('localPath')));
      expect(document.media.single, isNot(contains('fileName')));
      expect(document.games.first['deletedAt'], isNotNull);
      expect(document.summary.toJson(), {
        'games': 2,
        'libraryEntries': 1,
        'playthroughs': 1,
        'platforms': 1,
        'genres': 1,
        'libraryEntryPlatforms': 1,
        'gameGenres': 1,
        'savedViews': 1,
        'metadata': 1,
        'media': 1,
      });
    },
  );

  test('ordering and content are deterministic except exportedAt', () async {
    await _insertComplexLibrary(db);
    final first =
        (await repository(now: DateTime.utc(2026, 7, 17, 18)).createDocument())
            .toJson();
    final second =
        (await repository(now: DateTime.utc(2026, 7, 17, 19)).createDocument())
            .toJson();

    expect(first.remove('exportedAt'), isNot(second.remove('exportedAt')));
    expect(first, second);
    expect(
      (first['games'] as List<Map<String, Object?>>).map((row) => row['id']),
      orderedEquals(['game-a', 'game-z']),
    );
  });

  test('JSON is pretty printed, parseable UTF-8 and keeps Unicode', () async {
    await _insertComplexLibrary(db);
    final document = await repository().createDocument();
    final text = utf8.decode(document.toUtf8Bytes());
    final parsed = jsonDecode(text) as Map<String, Object?>;

    expect(text, contains('\n  "format":'));
    expect(text, contains('Línea dos — 你好'));
    expect(parsed['formatVersion'], 2);
    expect(
      libraryExportFileName(document.exportedAt),
      'backlog-vault-library-20260717-183045.json',
    );
  });

  test(
    'export excludes secrets, private paths, binary media and Sync data',
    () async {
      await _insertComplexLibrary(db);
      final text = utf8.decode(
        (await repository().createDocument()).toUtf8Bytes(),
      );
      final lower = text.toLowerCase();

      for (final forbidden in [
        'client_secret',
        'access_token',
        'bearer',
        'password',
        'apikey',
        'api_key',
        'group_key',
        'sync',
        '.vaultsync',
        '.vaultpair',
        r'c:\users\',
        '/data/user/',
        '/users/',
        'secure storage',
        'base64',
        'cover-raw-bytes',
        'hidden',
      ]) {
        expect(lower, isNot(contains(forbidden)), reason: forbidden);
      }
    },
  );
}

const _collectionKeys = [
  'games',
  'libraryEntries',
  'playthroughs',
  'platforms',
  'genres',
  'libraryEntryPlatforms',
  'gameGenres',
  'savedViews',
  'metadata',
  'media',
];

Future<void> _insertComplexLibrary(AppDatabase db) async {
  final now = DateTime.utc(2026, 1, 1);
  await db
      .into(db.games)
      .insert(
        GamesCompanion.insert(
          id: 'game-z',
          title: 'Hades — 你好',
          sortTitle: const Value('Hades'),
          releaseDate: Value(DateTime.utc(2020, 9, 17)),
          type: const Value('game'),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.games)
      .insert(
        GamesCompanion.insert(
          id: 'game-a',
          title: 'Archived game',
          createdAt: now,
          updatedAt: now,
          deletedAt: Value(now),
        ),
      );
  await db
      .into(db.libraryEntries)
      .insert(
        LibraryEntriesCompanion.insert(
          id: 'entry-1',
          gameId: 'game-z',
          status: 'completed',
          personalRating: const Value(5),
          personalNotes: const Value('Línea uno\nLínea dos — 你好'),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.platforms)
      .insert(
        PlatformsCompanion.insert(
          id: 'platform-1',
          name: 'PC',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .update(db.libraryEntries)
      .write(
        LibraryEntriesCompanion(
          isCompleted: const Value(true),
          playedYear: const Value(2026),
          completedAt: Value(DateTime.utc(2026, 2, 3)),
          hoursPlayed: const Value(42),
          playedPlatformId: const Value('platform-1'),
        ),
      );
  await db
      .into(db.libraryEntryPlatforms)
      .insert(
        LibraryEntryPlatformsCompanion.insert(
          id: 'entry-platform-1',
          libraryEntryId: 'entry-1',
          platformId: 'platform-1',
          isPrimary: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.genres)
      .insert(
        GenresCompanion.insert(
          id: 'genre-1',
          name: 'Roguelite',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.gameGenres)
      .insert(
        GameGenresCompanion.insert(
          id: 'game-genre-1',
          gameId: 'game-z',
          genreId: 'genre-1',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.playthroughs)
      .insert(
        PlaythroughsCompanion.insert(
          id: 'playthrough-1',
          libraryEntryId: 'entry-1',
          platformId: const Value('platform-1'),
          status: 'completed',
          startedAt: Value(DateTime.utc(2025, 12, 1)),
          completedAt: Value(DateTime.utc(2026, 1, 2)),
          hoursPlayed: const Value(21.5),
          rating: const Value(4),
          notes: const Value('Run final'),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.savedViews)
      .insert(
        SavedViewsCompanion.insert(
          id: 'view-1',
          name: 'Terminados',
          filterJson: '{"status":"completed"}',
          sortJson: '{"field":"title"}',
          columnConfigJson: '{"title":true}',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.externalGameIds)
      .insert(
        ExternalGameIdsCompanion.insert(
          id: 'metadata-1',
          gameId: 'game-z',
          provider: 'rawg',
          externalId: '3498',
          externalSlug: const Value('hades'),
          externalUrl: const Value(
            'https://user:secret@example.invalid/games/hades?api_key=hidden#part',
          ),
          matchedTitle: const Value('Hades'),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.mediaAssets)
      .insert(
        MediaAssetsCompanion.insert(
          id: 'media-1',
          gameId: 'game-z',
          kind: 'cover',
          source: 'local',
          provider: const Value('igdb'),
          externalId: const Value('cover-1'),
          remoteUrl: const Value(
            'https://example.invalid/cover.png?access_token=hidden',
          ),
          localPath: r'C:\Users\Private\covers\cover.png',
          fileName: 'cover.png',
          mimeType: const Value('image/png'),
          width: const Value(600),
          height: const Value(900),
          hash: const Value('sha256-cover'),
          isSelected: const Value(true),
          attribution: const Value('IGDB'),
          createdAt: now,
          updatedAt: now,
        ),
      );
}

class _FixedClock extends Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
