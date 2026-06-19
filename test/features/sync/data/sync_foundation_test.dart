import 'dart:convert';
import 'dart:io' as io;

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/ids/id_generator.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/core/version/app_versions.dart';
import 'package:backlog_vault/features/backup_restore/data/export_repository.dart';
import 'package:backlog_vault/features/catalogs/data/catalog_repository.dart';
import 'package:backlog_vault/features/games/application/game_form_model.dart';
import 'package:backlog_vault/features/games/data/game_repository.dart';
import 'package:backlog_vault/features/import_export/notion_csv/data/notion_csv_import_repository.dart';
import 'package:backlog_vault/features/import_export/notion_csv/domain/import_preview.dart';
import 'package:backlog_vault/features/import_export/notion_csv/domain/normalized_import_row.dart';
import 'package:backlog_vault/features/library/data/saved_library_view_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/library/domain/library_column_config.dart';
import 'package:backlog_vault/features/library/domain/library_filter_state.dart';
import 'package:backlog_vault/features/library/domain/library_sort_state.dart';
import 'package:backlog_vault/features/media/data/media_file_storage.dart';
import 'package:backlog_vault/features/media/data/media_repository.dart';
import 'package:backlog_vault/features/metadata/data/metadata_repository.dart';
import 'package:backlog_vault/features/metadata/domain/apply_metadata_request.dart';
import 'package:backlog_vault/features/metadata/domain/external_game_details.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_field.dart';
import 'package:backlog_vault/features/sync/data/canonical_json.dart';
import 'package:backlog_vault/features/sync/data/sync_change_tracking.dart';
import 'package:backlog_vault/features/sync/data/sync_device_identity.dart';
import 'package:backlog_vault/features/sync/domain/sync_models.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

const _deviceId = '11111111-1111-4111-8111-111111111111';
const _secondDeviceId = '22222222-2222-4222-8222-222222222222';
final _now = DateTime.utc(2026, 6, 19, 12);

void main() {
  group('canonical sync JSON', () {
    test('sorts keys, keeps nulls and normalizes dates and numbers', () {
      final first = canonicalJson.encode({
        'z': null,
        'date': DateTime.parse('2026-06-19T09:00:00-03:00'),
        'nested': {'b': 1.0, 'a': -0.0},
      });
      final second = canonicalJson.encode({
        'nested': {'a': 0, 'b': 1},
        'date': DateTime.utc(2026, 6, 19, 12),
        'z': null,
      });

      expect(first, second);
      expect(
        canonicalJson.sha256Hex(jsonDecode(first)),
        canonicalJson.sha256Hex(jsonDecode(second)),
      );
      expect(first, contains('2026-06-19T12:00:00.000Z'));
    });

    test('rejects non-finite numbers and unsupported values', () {
      expect(() => canonicalJson.encode(double.nan), throwsFormatException);
      expect(() => canonicalJson.encode(Object()), throwsFormatException);
    });
  });

  group('device identity', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test(
      'is stable across service instances and provider-like rebuilds',
      () async {
        final store = _MemoryIdentityStore();
        final ids = _SequenceIds([_deviceId]);
        final firstService = _identityService(db, store: store, ids: ids);
        final first = await firstService.ensureIdentity();
        final second =
            await _identityService(db, store: store).ensureIdentity();

        expect(first.id, _deviceId);
        expect(second.id, _deviceId);
        expect(await store.readDeviceId(), _deviceId);
        expect(
          (await db.select(db.syncDevices).get()).where((row) => row.isLocal),
          hasLength(1),
        );
      },
    );

    test('does not silently trust a SQLite-only identity', () async {
      await db
          .into(db.syncDevices)
          .insert(
            SyncDevicesCompanion.insert(
              id: _deviceId,
              displayName: 'Old device',
              platform: 'windows',
              isLocal: const Value(true),
              status: SyncDeviceStatus.local.name,
              createdAt: _now,
            ),
          );
      await db
          .into(db.syncStates)
          .insert(
            SyncStatesCompanion.insert(
              id: 'local',
              localDeviceId: _deviceId,
              nextLocalCounter: const Value(9),
              baselineCreated: const Value(true),
              updatedAt: _now,
            ),
          );

      final replacement =
          await _identityService(
            db,
            store: _MemoryIdentityStore(),
            ids: _SequenceIds([_secondDeviceId]),
          ).ensureIdentity();
      final state = await SyncChangeRecorder(
        db,
        clock: _FixedClock(_now),
      ).ensureState(replacement);
      final old =
          await (db.select(db.syncDevices)
            ..where((row) => row.id.equals(_deviceId))).getSingle();

      expect(replacement.id, _secondDeviceId);
      expect(old.isLocal, isFalse);
      expect(old.status, SyncDeviceStatus.identityLost.name);
      expect(state.localDeviceId, _secondDeviceId);
      expect(state.nextLocalCounter, 1);
      expect(state.baselineCreated, isFalse);
      expect(state.requiresReconciliation, isTrue);
      expect(state.replicaEpoch, 2);
    });
  });

  test(
    'sync schema enforces one local device and unique origin counters',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db
          .into(db.syncDevices)
          .insert(
            SyncDevicesCompanion.insert(
              id: _deviceId,
              displayName: 'Device 1',
              platform: 'windows',
              isLocal: const Value(true),
              status: SyncDeviceStatus.local.name,
              createdAt: _now,
            ),
          );
      await expectLater(
        db
            .into(db.syncDevices)
            .insert(
              SyncDevicesCompanion.insert(
                id: _secondDeviceId,
                displayName: 'Device 2',
                platform: 'android',
                isLocal: const Value(true),
                status: SyncDeviceStatus.local.name,
                createdAt: _now,
              ),
            ),
        throwsA(anything),
      );

      SyncChangesCompanion change(String changeId) =>
          SyncChangesCompanion.insert(
            changeId: changeId,
            originDeviceId: _deviceId,
            originCounter: 1,
            mutationId: 'mutation',
            mutationSequence: 0,
            entityType: 'game',
            entityId: 'game-1',
            operation: 'created',
            changedFieldsJson: '[]',
            payloadJson: '{}',
            snapshotJson: '{}',
            causalContextJson: '{}',
            source: SyncChangeSource.manual.name,
            contentHash: 'hash',
            createdAt: _now,
          );

      await db.into(db.syncChanges).insert(change('change-1'));
      await expectLater(
        db.into(db.syncChanges).insert(change('change-2')),
        throwsA(anything),
      );
    },
  );

  group('deterministic change tracking', () {
    late _Harness harness;

    setUp(() async {
      harness = await _Harness.create();
    });

    tearDown(() => harness.db.close());

    test(
      'groups changes and advances deterministic counters atomically',
      () async {
        await harness.runner.run(
          source: SyncChangeSource.manual,
          action: (_) async {
            await harness.db
                .into(harness.db.games)
                .insert(
                  GamesCompanion.insert(
                    id: 'game-1',
                    title: 'Game',
                    createdAt: _now,
                    updatedAt: _now,
                  ),
                );
            await harness.db
                .into(harness.db.libraryEntries)
                .insert(
                  LibraryEntriesCompanion.insert(
                    id: 'entry-1',
                    gameId: 'game-1',
                    status: 'backlog',
                    createdAt: _now,
                    updatedAt: _now,
                  ),
                );
          },
        );

        final changes =
            await (harness.db.select(harness.db.syncChanges)
              ..orderBy([(row) => OrderingTerm.asc(row.originCounter)])).get();
        final state = await harness.localState();
        expect(changes, hasLength(2));
        expect(changes.map((row) => row.changeId), [
          '$_deviceId:1',
          '$_deviceId:2',
        ]);
        expect(changes.map((row) => row.mutationId).toSet(), {'mutation-1'});
        expect(changes.map((row) => row.mutationSequence), [0, 1]);
        expect(state.nextLocalCounter, 3);
        expect(jsonDecode(state.seenVectorJson), {_deviceId: 2});
      },
    );

    test(
      'rollback leaves business rows, counter and oplog unchanged',
      () async {
        await expectLater(
          harness.runner.run<void>(
            source: SyncChangeSource.manual,
            action: (_) async {
              await harness.db
                  .into(harness.db.games)
                  .insert(
                    GamesCompanion.insert(
                      id: 'rolled-back',
                      title: 'Rollback',
                      createdAt: _now,
                      updatedAt: _now,
                    ),
                  );
              throw StateError('expected test rollback');
            },
          ),
          throwsStateError,
        );

        expect(await harness.db.select(harness.db.games).get(), isEmpty);
        expect(await harness.db.select(harness.db.syncChanges).get(), isEmpty);
        expect((await harness.localState()).nextLocalCounter, 1);
      },
    );

    test('suppressed and remote modes do not echo changes', () async {
      for (final mode in [
        SyncMutationMode.suppressed,
        SyncMutationMode.remote,
      ]) {
        await harness.runner.run(
          source: SyncChangeSource.remote,
          mode: mode,
          action: (_) async {
            await harness.db
                .into(harness.db.games)
                .insert(
                  GamesCompanion.insert(
                    id: 'game-${mode.name}',
                    title: mode.name,
                    createdAt: _now,
                    updatedAt: _now,
                  ),
                );
          },
        );
      }

      expect(await harness.db.select(harness.db.games).get(), hasLength(2));
      expect(await harness.db.select(harness.db.syncChanges).get(), isEmpty);
      expect((await harness.localState()).nextLocalCounter, 1);
    });

    test(
      'touch-only updates are ignored and soft deletes create tombstones',
      () async {
        await harness.runner.run(
          source: SyncChangeSource.manual,
          action:
              (_) => harness.db
                  .into(harness.db.games)
                  .insert(
                    GamesCompanion.insert(
                      id: 'game-1',
                      title: 'Game',
                      createdAt: _now,
                      updatedAt: _now,
                    ),
                  ),
        );
        await harness.runner.run(
          source: SyncChangeSource.manual,
          action:
              (_) =>
                  (harness.db.update(harness.db.games)
                    ..where((row) => row.id.equals('game-1'))).write(
                    GamesCompanion(
                      updatedAt: Value(_now.add(const Duration(minutes: 1))),
                    ),
                  ),
        );
        expect(
          await harness.db.select(harness.db.syncChanges).get(),
          hasLength(1),
        );

        await harness.runner.run(
          source: SyncChangeSource.manual,
          action:
              (_) =>
                  (harness.db.update(harness.db.games)
                    ..where((row) => row.id.equals('game-1'))).write(
                    GamesCompanion(
                      updatedAt: Value(_now.add(const Duration(minutes: 2))),
                      deletedAt: Value(_now.add(const Duration(minutes: 2))),
                    ),
                  ),
        );

        final changes =
            await (harness.db.select(harness.db.syncChanges)
              ..orderBy([(row) => OrderingTerm.asc(row.originCounter)])).get();
        expect(changes, hasLength(2));
        expect(changes.last.operation, 'deleted');
        expect(
          await harness.db.select(harness.db.syncTombstones).get(),
          hasLength(1),
        );
        expect(
          (await harness.db.select(harness.db.games).getSingle()).deletedAt,
          isNotNull,
        );
      },
    );

    test(
      'a shared bulk scope keeps one mutation id across transactions',
      () async {
        await SyncMutationScope.run(
          mutationId: 'bulk-1',
          source: SyncChangeSource.bulk,
          action: () async {
            await harness.runner.run(
              source: SyncChangeSource.metadata,
              action:
                  (_) => harness.db
                      .into(harness.db.games)
                      .insert(
                        GamesCompanion.insert(
                          id: 'game-1',
                          title: 'Game',
                          createdAt: _now,
                          updatedAt: _now,
                        ),
                      ),
            );
            await harness.runner.run(
              source: SyncChangeSource.manual,
              action:
                  (_) => (harness.db.update(harness.db.games)..where(
                    (row) => row.id.equals('game-1'),
                  )).write(const GamesCompanion(title: Value('Updated'))),
            );
          },
        );

        final changes =
            await (harness.db.select(harness.db.syncChanges)
              ..orderBy([(row) => OrderingTerm.asc(row.originCounter)])).get();
        expect(changes.map((row) => row.mutationId).toSet(), {'bulk-1'});
        expect(changes.map((row) => row.mutationSequence), [0, 1]);
        expect(changes.map((row) => row.source).toSet(), {
          SyncChangeSource.bulk.name,
        });
      },
    );

    test('soft-unlink records an event and relation tombstone', () async {
      await harness.runner.run(
        source: SyncChangeSource.manual,
        action: (_) async {
          await harness.db
              .into(harness.db.games)
              .insert(
                GamesCompanion.insert(
                  id: 'game-1',
                  title: 'Game',
                  createdAt: _now,
                  updatedAt: _now,
                ),
              );
          await harness.db
              .into(harness.db.libraryEntries)
              .insert(
                LibraryEntriesCompanion.insert(
                  id: 'entry-1',
                  gameId: 'game-1',
                  status: 'backlog',
                  createdAt: _now,
                  updatedAt: _now,
                ),
              );
          await harness.db
              .into(harness.db.platforms)
              .insert(
                PlatformsCompanion.insert(
                  id: 'platform-1',
                  name: 'PC',
                  createdAt: _now,
                  updatedAt: _now,
                ),
              );
          await harness.db
              .into(harness.db.libraryEntryPlatforms)
              .insert(
                LibraryEntryPlatformsCompanion.insert(
                  id: 'relation-1',
                  libraryEntryId: 'entry-1',
                  platformId: 'platform-1',
                  createdAt: _now,
                  updatedAt: _now,
                ),
              );
        },
      );
      await harness.runner.run(
        source: SyncChangeSource.manual,
        action:
            (_) =>
                (harness.db.update(harness.db.libraryEntryPlatforms)
                  ..where((row) => row.id.equals('relation-1'))).write(
                  LibraryEntryPlatformsCompanion(
                    updatedAt: Value(_now.add(const Duration(minutes: 1))),
                    deletedAt: Value(_now.add(const Duration(minutes: 1))),
                  ),
                ),
      );

      final unlink =
          await (harness.db.select(harness.db.syncChanges)
                ..where((row) => row.entityId.equals('relation-1'))
                ..where((row) => row.operation.equals('unlinked')))
              .getSingle();
      expect(unlink.entityType, 'library_entry_platform');
      expect(
        await (harness.db.select(
          harness.db.syncTombstones,
        )..where((row) => row.entityId.equals('relation-1'))).getSingleOrNull(),
        isNotNull,
      );
    });
  });

  test('all mutable repositories feed the shared oplog boundary', () async {
    final harness = await _Harness.create();
    addTearDown(harness.db.close);
    final clock = _FixedClock(_now);

    final catalogs = CatalogRepository(
      harness.db,
      ids: _SequenceIds(['platform-1', 'genre-1']),
      clock: clock,
      sync: harness.runner,
    );
    await catalogs.createPlatform('PC');
    await catalogs.createGenre('RPG');

    final games = GameRepository(
      harness.db,
      ids: _SequenceIds([
        'game-1',
        'entry-1',
        'platform-link-1',
        'genre-link-1',
      ]),
      clock: clock,
      sync: harness.runner,
    );
    await games.save(
      const GameFormModel(
        title: 'Tracked game',
        status: GameStatus.backlog,
        platformIds: ['platform-1'],
        genreIds: ['genre-1'],
      ),
    );

    final metadata = MetadataRepository(
      harness.db,
      ids: _SequenceIds(['external-1']),
      clock: clock,
      sync: harness.runner,
    );
    await metadata.applyMetadata(
      const ApplyMetadataRequest(
        gameId: 'game-1',
        libraryEntryId: 'entry-1',
        details: ExternalGameDetails(
          providerId: 'rawg',
          providerName: 'RAWG',
          externalId: 'rawg-1',
          title: 'Tracked game updated',
        ),
        selectedFields: {MetadataField.title},
      ),
    );

    final views = SavedLibraryViewRepository(
      harness.db,
      ids: _SequenceIds(['view-1']),
      clock: clock,
      sync: harness.runner,
    );
    await views.create(
      name: 'Tracked view',
      filter: const LibraryFilterState(),
      sort: const LibrarySortState(),
      columnConfig: LibraryColumnConfig(),
    );

    final notion = NotionCsvImportRepository(
      harness.db,
      ids: _SequenceIds(['game-2', 'entry-2']),
      clock: clock,
      sync: harness.runner,
    );
    await notion.importPreview(
      const ImportPreview(
        rows: [
          NormalizedImportRow(
            rowNumber: 1,
            title: 'Imported game',
            releaseDate: null,
            completedAt: null,
            hoursPlayed: null,
            personalRating: null,
            genres: [],
            platforms: [],
            status: GameStatus.backlog,
            type: 'game',
            personalNotes: null,
            issues: [],
            duplicates: [],
            include: true,
            forceCreateDuplicate: false,
          ),
        ],
      ),
    );

    final tempDir = await io.Directory.systemTemp.createTemp(
      'bv_sync_repo_test_',
    );
    addTearDown(() => tempDir.delete(recursive: true));
    final source = io.File(
      '${tempDir.path}${io.Platform.pathSeparator}source.png',
    );
    await source.writeAsBytes([
      0x89,
      0x50,
      0x4e,
      0x47,
      0x0d,
      0x0a,
      0x1a,
      0x0a,
      0,
    ]);
    final client = http.Client();
    addTearDown(client.close);
    final media = MediaRepository(
      harness.db,
      storage: MediaFileStorage(baseDirectoryLoader: () async => tempDir),
      httpClient: client,
      ids: _SequenceIds(['media-1']),
      clock: clock,
      sync: harness.runner,
    );
    await media.saveLocalCover(gameId: 'game-1', sourcePath: source.path);
    await media.softDelete('media-1');

    final changes = await harness.db.select(harness.db.syncChanges).get();
    final entityTypes = changes.map((row) => row.entityType).toSet();
    final sources = changes.map((row) => row.source).toSet();
    expect(
      entityTypes,
      containsAll({
        'platform',
        'genre',
        'game',
        'library_entry',
        'library_entry_platform',
        'game_genre',
        'external_game_id',
        'saved_view',
        'media_asset',
      }),
    );
    expect(
      sources,
      containsAll({
        SyncChangeSource.manual.name,
        SyncChangeSource.metadata.name,
        SyncChangeSource.import.name,
      }),
    );
    expect(
      await (harness.db.select(harness.db.syncTombstones)..where(
        (row) => row.entityType.equals('media_asset'),
      )).getSingleOrNull(),
      isNotNull,
    );
  });

  test(
    'baseline is deterministic, idempotent and excludes local media paths',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db
          .into(db.games)
          .insert(
            GamesCompanion.insert(
              id: 'game-b',
              title: 'B',
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      await db
          .into(db.games)
          .insert(
            GamesCompanion.insert(
              id: 'game-a',
              title: 'A',
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      await db
          .into(db.mediaAssets)
          .insert(
            MediaAssetsCompanion.insert(
              id: 'media-1',
              gameId: 'game-a',
              kind: 'cover',
              source: 'local',
              remoteUrl: const Value(
                'https://example.invalid/image?access_token=test_access_token',
              ),
              localPath: r'C:\private\cover.png',
              fileName: 'cover.png',
              createdAt: _now,
              updatedAt: _now,
            ),
          );
      final harness = await _Harness.create(database: db, initialize: false);
      final device = await harness.identity.ensureIdentity();
      await harness.initializer.initialize(device);
      final firstCount = await db
          .select(db.syncChanges)
          .get()
          .then((rows) => rows.length);
      await harness.initializer.initialize(device);

      final changes =
          await (db.select(db.syncChanges)
            ..orderBy([(row) => OrderingTerm.asc(row.originCounter)])).get();
      final snapshots = changes.map((row) => row.snapshotJson).join('\n');
      expect(changes.map((row) => '${row.entityType}:${row.entityId}'), [
        'game:game-a',
        'game:game-b',
        'media_asset:media-1',
      ]);
      expect(
        await db.select(db.syncChanges).get().then((rows) => rows.length),
        firstCount,
      );
      expect(snapshots, isNot(contains(r'C:\private')));
      expect(snapshots, isNot(contains('access_token')));
      expect(snapshots, isNot(contains('sync.local.device_id')));
    },
  );

  test(
    'logical backup stays at schema 4 and excludes sync internals',
    () async {
      final harness = await _Harness.create();
      addTearDown(harness.db.close);
      await harness.runner.run(
        source: SyncChangeSource.manual,
        action:
            (_) => harness.db
                .into(harness.db.games)
                .insert(
                  GamesCompanion.insert(
                    id: 'game-1',
                    title: 'Game',
                    createdAt: _now,
                    updatedAt: _now,
                  ),
                ),
      );

      final export = await ExportRepository(harness.db).exportLogical();
      final json = export.toJsonString();
      expect(export.schemaVersion, logicalLibrarySchemaVersion);
      expect(logicalLibrarySchemaVersion, 4);
      expect(json, isNot(contains('sync_devices')));
      expect(json, isNot(contains(_deviceId)));
      expect(json, isNot(contains('sync_changes')));
    },
  );

  test('restore preserves identity/state and marks reconciliation', () async {
    final harness = await _Harness.create();
    addTearDown(harness.db.close);
    final repository = ExportRepository(harness.db, sync: harness.runner);
    final export = await repository.exportLogical();
    final before = await harness.localState();

    await repository.restoreLogical(export);

    final after = await harness.localState();
    expect(after.localDeviceId, before.localDeviceId);
    expect(after.nextLocalCounter, before.nextLocalCounter);
    expect(after.requiresReconciliation, isTrue);
    expect(
      (await harness.db.select(harness.db.syncDevices).getSingle()).id,
      _deviceId,
    );
  });
}

class _MemoryIdentityStore implements SyncIdentityStore {
  _MemoryIdentityStore([this.value]);

  String? value;

  @override
  Future<String?> readDeviceId() async => value;

  @override
  Future<void> writeDeviceId(String deviceId) async {
    value = deviceId;
  }
}

class _SequenceIds extends IdGenerator {
  _SequenceIds(this.values);

  final List<String> values;
  var _index = 0;

  @override
  String newId() {
    if (_index >= values.length) throw StateError('No test ID available.');
    return values[_index++];
  }
}

class _FixedClock extends Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

SyncDeviceIdentityService _identityService(
  AppDatabase db, {
  required _MemoryIdentityStore store,
  IdGenerator? ids,
}) {
  return SyncDeviceIdentityService(
    store: store,
    repository: SyncDeviceRepository(db),
    ids: ids,
    clock: _FixedClock(_now),
    platformLoader: () => 'windows',
  );
}

class _Harness {
  _Harness({
    required this.db,
    required this.identity,
    required this.initializer,
    required this.runner,
  });

  final AppDatabase db;
  final SyncDeviceIdentityService identity;
  final SyncFoundationInitializer initializer;
  final SyncAwareTransaction runner;

  static Future<_Harness> create({
    AppDatabase? database,
    bool initialize = true,
  }) async {
    final db = database ?? AppDatabase(NativeDatabase.memory());
    final identity = _identityService(
      db,
      store: _MemoryIdentityStore(_deviceId),
    );
    final reader = LogicalLibrarySnapshotReader(db);
    const differ = SyncSnapshotDiffer();
    final recorder = SyncChangeRecorder(db, clock: _FixedClock(_now));
    final initializer = SyncFoundationInitializer(
      database: db,
      snapshotReader: reader,
      differ: differ,
      recorder: recorder,
      clock: _FixedClock(_now),
    );
    final runner = SyncAwareTransaction(
      database: db,
      identityService: identity,
      initializer: initializer,
      snapshotReader: reader,
      differ: differ,
      recorder: recorder,
      ids: _SequenceIds([
        'mutation-1',
        'mutation-2',
        'mutation-3',
        'mutation-4',
        'mutation-5',
        'mutation-6',
        'mutation-7',
        'mutation-8',
        'mutation-9',
        'mutation-10',
        'mutation-11',
        'mutation-12',
      ]),
    );
    final harness = _Harness(
      db: db,
      identity: identity,
      initializer: initializer,
      runner: runner,
    );
    if (initialize) {
      await initializer.initialize(await identity.ensureIdentity());
    }
    return harness;
  }

  Future<SyncState> localState() =>
      (db.select(db.syncStates)
        ..where((row) => row.id.equals('local'))).getSingle();
}
