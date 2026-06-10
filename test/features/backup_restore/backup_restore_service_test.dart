import 'dart:convert';
import 'dart:io' as io;

import 'package:archive/archive.dart';
import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/ids/id_generator.dart';
import 'package:backlog_vault/core/time/clock.dart';
import 'package:backlog_vault/features/backup_restore/data/backup_service.dart';
import 'package:backlog_vault/features/backup_restore/data/export_repository.dart';
import 'package:backlog_vault/features/backup_restore/domain/backup_models.dart';
import 'package:backlog_vault/features/library/data/library_query_repository.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/playthroughs/domain/playthrough_status.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late io.Directory tempDir;
  late ExportRepository exportRepository;
  late BackupService backupService;
  late bool dbClosed;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dbClosed = false;
    tempDir = await io.Directory.systemTemp.createTemp('backlog_vault_backup_');
    exportRepository = ExportRepository(db, clock: _FixedClock());
    backupService = BackupService(
      exportRepository: exportRepository,
      baseDirectoryLoader: () async => tempDir,
      ids: _FixedIds(),
      clock: _FixedClock(),
    );
  });

  tearDown(() async {
    if (!dbClosed) {
      await db.close();
    }
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('export JSON includes all entities and soft-deleted rows', () async {
    await _insertCompleteLibrary(db, mediaBase: tempDir);
    await _insertDeletedGame(db);

    final bytes = await exportRepository.exportLogicalJsonBytes();
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
    final entities = json['entities'] as Map<String, Object?>;

    expect((entities['games'] as List), hasLength(2));
    expect((entities['library_entries'] as List), hasLength(2));
    expect((entities['media_assets'] as List), hasLength(1));
    expect((entities['external_game_ids'] as List), hasLength(1));
    expect(utf8.decode(bytes), isNot(contains('rawg-secret')));
    expect(utf8.decode(bytes), isNot(contains('steamgriddb-secret')));
  });

  test('CSV exports active library rows with BOM and visible dates', () async {
    await _insertCompleteLibrary(db, mediaBase: tempDir);
    await _insertDeletedGame(db);

    final bytes = await exportRepository.exportActiveLibraryCsvBytes();
    final csv = utf8.decode(bytes);

    expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
    expect(csv, startsWith('Titulo,Estado'));
    expect(csv, contains('Hades'));
    expect(csv, contains('Completado'));
    expect(csv, contains('17-09-2020'));
    expect(csv, contains('02-01-2026'));
    expect(csv, isNot(contains('Deleted')));
  });

  test('backup ZIP contains manifest, logical data and media files', () async {
    await _insertCompleteLibrary(db, mediaBase: tempDir);

    final result = await backupService.createBackup();
    final archive = ZipDecoder().decodeBytes(result.bytes);

    expect(archive.findFile('manifest.json'), isNotNull);
    expect(archive.findFile('data/library.json'), isNotNull);
    expect(archive.findFile('media/games/game-1/cover-1.png'), isNotNull);

    final manifest = BackupManifest.fromJson(
      jsonDecode(utf8.decode(archive.findFile('manifest.json')!.content))
          as Map<String, Object?>,
    );
    expect(manifest.appName, backupAppName);
    expect(manifest.counts.games, 1);
    expect(manifest.counts.mediaFiles, 1);
    expect(manifest.warnings, isEmpty);
  });

  test(
    'encrypted backup roundtrips and does not expose clear ZIP entries',
    () async {
      await _insertCompleteLibrary(db, mediaBase: tempDir);

      final result = await backupService.createEncryptedBackup(
        password: 'correct horse battery staple',
      );
      final encryptedText = String.fromCharCodes(result.bytes);

      expect(result.fileName, endsWith('.vaultbackup.enc'));
      expect(result.bytes.take(4), [0x42, 0x56, 0x45, 0x31]);
      expect(encryptedText, isNot(contains('manifest.json')));
      expect(encryptedText, isNot(contains('data/library.json')));
      expect(encryptedText, isNot(contains('Nota privada')));

      final preview = await backupService.previewEncryptedBackup(
        result.bytes,
        password: 'correct horse battery staple',
      );
      expect(preview.manifest.appName, backupAppName);
      expect(preview.manifest.counts.games, 1);
    },
  );

  test(
    'encrypted backup rejects wrong passwords and corrupt payloads',
    () async {
      await _insertCompleteLibrary(db, mediaBase: tempDir);
      final result = await backupService.createEncryptedBackup(
        password: 'correct horse battery staple',
      );

      await expectLater(
        backupService.previewEncryptedBackup(result.bytes, password: 'wrong'),
        throwsA(isA<BackupException>()),
      );

      final corrupt = [...result.bytes]..[result.bytes.length - 1] ^= 0xFF;
      await expectLater(
        backupService.previewEncryptedBackup(
          corrupt,
          password: 'correct horse battery staple',
        ),
        throwsA(isA<BackupException>()),
      );
    },
  );

  test('backup with missing media keeps JSON and emits warning', () async {
    await _insertCompleteLibrary(
      db,
      mediaBase: tempDir,
      createMediaFile: false,
    );

    final result = await backupService.createBackup();
    final archive = ZipDecoder().decodeBytes(result.bytes);

    expect(archive.findFile('data/library.json'), isNotNull);
    expect(archive.findFile('media/games/game-1/cover-1.png'), isNull);
    expect(result.warnings, hasLength(1));
    expect(result.warnings.single.code, 'missing_media_file');
  });

  test('backup warns and omits media paths outside media folder', () async {
    await _insertCompleteLibrary(db, mediaBase: tempDir);
    await db
        .into(db.mediaAssets)
        .insert(
          MediaAssetsCompanion.insert(
            id: 'unsafe-cover',
            gameId: 'game-1',
            kind: 'cover',
            source: 'local',
            localPath: 'covers/game-1/unsafe-cover.png',
            fileName: 'unsafe-cover.png',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );

    final result = await backupService.createBackup();
    final archive = ZipDecoder().decodeBytes(result.bytes);

    expect(archive.findFile('covers/game-1/unsafe-cover.png'), isNull);
    expect(
      result.warnings.map((warning) => warning.code),
      contains('unsafe_media_path'),
    );
  });

  test('reader rejects incompatible schema and unsafe paths', () async {
    final validLibrary =
        LogicalLibraryExport(
          formatVersion: 1,
          schemaVersion: 4,
          exportedAt: DateTime(2026),
          games: const [],
          libraryEntries: const [],
          platforms: const [],
          libraryEntryPlatforms: const [],
          genres: const [],
          gameGenres: const [],
          playthroughs: const [],
          savedViews: const [],
          externalGameIds: const [],
          mediaAssets: const [],
        ).toJsonString();

    expect(
      () => BackupPackageReader().read(
        _backupBytes(libraryJson: validLibrary, appSchemaVersion: 99),
      ),
      throwsA(isA<BackupException>()),
    );

    expect(
      () => BackupPackageReader().read(
        _backupBytes(libraryJson: validLibrary, backupFormatVersionValue: 99),
      ),
      throwsA(isA<BackupException>()),
    );

    expect(
      () => BackupPackageReader().read(
        _backupBytes(
          libraryJson: validLibrary,
          extraPath: 'media/../secret.png',
        ),
      ),
      throwsA(isA<BackupException>()),
    );
  });

  test('reader rejects missing data, bad checksum and corrupt package', () {
    final validLibrary =
        LogicalLibraryExport(
          formatVersion: 1,
          schemaVersion: 4,
          exportedAt: DateTime(2026),
          games: const [],
          libraryEntries: const [],
          platforms: const [],
          libraryEntryPlatforms: const [],
          genres: const [],
          gameGenres: const [],
          playthroughs: const [],
          savedViews: const [],
          externalGameIds: const [],
          mediaAssets: const [],
        ).toJsonString();

    expect(
      () => BackupPackageReader().read(
        _backupBytes(libraryJson: validLibrary, includeLibrary: false),
      ),
      throwsA(isA<BackupException>()),
    );
    expect(
      () => BackupPackageReader().read(
        _backupBytes(
          libraryJson: validLibrary,
          libraryJsonSha256: 'not-the-real-checksum',
        ),
      ),
      throwsA(isA<BackupException>()),
    );
    expect(
      () => BackupPackageReader().read([1, 2, 3, 4]),
      throwsA(isA<BackupException>()),
    );
  });

  test('reader rejects unsafe media paths inside logical export', () {
    final invalidLibrary =
        LogicalLibraryExport(
          formatVersion: 1,
          schemaVersion: 4,
          exportedAt: DateTime(2026),
          games: const [],
          libraryEntries: const [],
          platforms: const [],
          libraryEntryPlatforms: const [],
          genres: const [],
          gameGenres: const [],
          playthroughs: const [],
          savedViews: const [],
          externalGameIds: const [],
          mediaAssets: const [
            {
              'id': 'media-1',
              'gameId': 'game-1',
              'localPath': '../outside.png',
            },
          ],
        ).toJsonString();

    expect(
      () =>
          BackupPackageReader().read(_backupBytes(libraryJson: invalidLibrary)),
      throwsA(isA<BackupException>()),
    );
  });

  test(
    'restore rebuilds data and media without hard-deleting current rows',
    () async {
      await _insertCompleteLibrary(db, mediaBase: tempDir);
      await _insertDeletedGame(db);
      final backup = await backupService.createBackup();
      await db.close();
      dbClosed = true;

      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetTempDir = await io.Directory.systemTemp.createTemp(
        'backlog_vault_restore_',
      );
      try {
        await _insertDeletedCandidateAsActive(
          targetDb,
          mediaBase: targetTempDir,
        );
        await _insertOverlappingGameAsActive(targetDb);
        final targetService = BackupService(
          exportRepository: ExportRepository(targetDb, clock: _FixedClock()),
          baseDirectoryLoader: () async => targetTempDir,
          ids: _FixedIds(),
          clock: _FixedClock(),
        );

        final result = await targetService.restoreBackup(
          backup.bytes,
          confirmation: 'RESTAURAR',
        );

        final restoredGame =
            await (targetDb.select(targetDb.games)
              ..where((table) => table.id.equals('game-1'))).getSingle();
        final absentGame =
            await (targetDb.select(targetDb.games)
              ..where((table) => table.id.equals('old-game'))).getSingle();
        final softDeletedFromBackup =
            await (targetDb.select(targetDb.games)
              ..where((table) => table.id.equals('deleted-game'))).getSingle();
        final restoredMedia = io.File(
          '${targetTempDir.path}${io.Platform.pathSeparator}media${io.Platform.pathSeparator}games${io.Platform.pathSeparator}game-1${io.Platform.pathSeparator}cover-1.png',
        );
        final oldMedia = io.File(
          '${targetTempDir.path}${io.Platform.pathSeparator}media${io.Platform.pathSeparator}games${io.Platform.pathSeparator}old-game${io.Platform.pathSeparator}old-cover.png',
        );

        expect(restoredGame.deletedAt, isNull);
        expect(restoredGame.title, 'Hades');
        expect(absentGame.deletedAt, isNotNull);
        expect(softDeletedFromBackup.deletedAt, isNotNull);
        expect(await restoredMedia.exists(), isTrue);
        expect(await oldMedia.exists(), isTrue);
        expect(await io.File(result.preRestoreBackupPath).exists(), isTrue);
        expect(
          () => BackupPackageReader().read(
            io.File(result.preRestoreBackupPath).readAsBytesSync(),
          ),
          returnsNormally,
        );
        expect(result.restoredCounts.games, 2);

        final visibleRows =
            await LibraryQueryRepository(targetDb).watchRows().first;
        expect(visibleRows.map((row) => row.title), ['Hades']);
      } finally {
        await targetDb.close();
        if (await targetTempDir.exists()) {
          await targetTempDir.delete(recursive: true);
        }
      }
    },
  );

  test(
    'encrypted restore rebuilds data and writes encrypted pre-restore backup',
    () async {
      await _insertCompleteLibrary(db, mediaBase: tempDir);
      final backup = await backupService.createEncryptedBackup(
        password: 'correct horse battery staple',
      );
      await db.close();
      dbClosed = true;

      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetTempDir = await io.Directory.systemTemp.createTemp(
        'backlog_vault_encrypted_restore_',
      );
      try {
        await _insertDeletedCandidateAsActive(
          targetDb,
          mediaBase: targetTempDir,
        );
        final targetService = BackupService(
          exportRepository: ExportRepository(targetDb, clock: _FixedClock()),
          baseDirectoryLoader: () async => targetTempDir,
          ids: _FixedIds(),
          clock: _FixedClock(),
        );

        final result = await targetService.restoreEncryptedBackup(
          backup.bytes,
          password: 'correct horse battery staple',
          confirmation: 'RESTAURAR',
        );

        final visibleRows =
            await LibraryQueryRepository(targetDb).watchRows().first;
        final oldGame =
            await (targetDb.select(targetDb.games)
              ..where((table) => table.id.equals('old-game'))).getSingle();
        final preRestoreFile = io.File(result.preRestoreBackupPath);
        final preRestoreBytes = await preRestoreFile.readAsBytes();

        expect(visibleRows.map((row) => row.title), ['Hades']);
        expect(oldGame.deletedAt, isNotNull);
        expect(result.preRestoreBackupPath, endsWith('.vaultbackup.enc'));
        expect(preRestoreBytes.take(4), [0x42, 0x56, 0x45, 0x31]);
        expect(
          String.fromCharCodes(preRestoreBytes),
          isNot(contains('manifest.json')),
        );
      } finally {
        await targetDb.close();
        if (await targetTempDir.exists()) {
          await targetTempDir.delete(recursive: true);
        }
      }
    },
  );

  test(
    'encrypted restore with wrong password does not modify DB or media',
    () async {
      await _insertCompleteLibrary(db, mediaBase: tempDir);
      final backup = await backupService.createEncryptedBackup(
        password: 'correct horse battery staple',
      );
      await db.close();
      dbClosed = true;

      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetTempDir = await io.Directory.systemTemp.createTemp(
        'backlog_vault_encrypted_restore_wrong_password_',
      );
      try {
        await _insertDeletedCandidateAsActive(
          targetDb,
          mediaBase: targetTempDir,
        );
        final targetService = BackupService(
          exportRepository: ExportRepository(targetDb, clock: _FixedClock()),
          baseDirectoryLoader: () async => targetTempDir,
          ids: _FixedIds(),
          clock: _FixedClock(),
        );

        await expectLater(
          targetService.restoreEncryptedBackup(
            backup.bytes,
            password: 'wrong',
            confirmation: 'RESTAURAR',
          ),
          throwsA(isA<BackupException>()),
        );

        final oldGame =
            await (targetDb.select(targetDb.games)
              ..where((table) => table.id.equals('old-game'))).getSingle();
        final oldMedia = io.File(
          '${targetTempDir.path}${io.Platform.pathSeparator}media${io.Platform.pathSeparator}games${io.Platform.pathSeparator}old-game${io.Platform.pathSeparator}old-cover.png',
        );
        final preRestoreDirectory = io.Directory(
          '${targetTempDir.path}${io.Platform.pathSeparator}backups${io.Platform.pathSeparator}pre-restore',
        );

        expect(oldGame.deletedAt, isNull);
        expect(await oldMedia.exists(), isTrue);
        expect(await preRestoreDirectory.exists(), isFalse);
      } finally {
        await targetDb.close();
        if (await targetTempDir.exists()) {
          await targetTempDir.delete(recursive: true);
        }
      }
    },
  );

  test('restore requires explicit confirmation', () async {
    await _insertCompleteLibrary(db, mediaBase: tempDir);
    final backup = await backupService.createBackup();

    await expectLater(
      backupService.restoreBackup(backup.bytes, confirmation: 'SI'),
      throwsA(isA<BackupException>()),
    );
  });

  test(
    'restore does not continue if pre-restore backup cannot be created',
    () async {
      await _insertCompleteLibrary(db, mediaBase: tempDir);
      final backup = await backupService.createBackup();
      await db.close();
      dbClosed = true;

      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetTempDir = await io.Directory.systemTemp.createTemp(
        'backlog_vault_restore_prebackup_failure_',
      );
      try {
        await _insertDeletedCandidateAsActive(
          targetDb,
          mediaBase: targetTempDir,
        );
        final service = BackupService(
          exportRepository: _FailingExportRepository(targetDb),
          baseDirectoryLoader: () async => targetTempDir,
          ids: _FixedIds(),
          clock: _FixedClock(),
        );

        await expectLater(
          service.restoreBackup(backup.bytes, confirmation: 'RESTAURAR'),
          throwsA(isA<StateError>()),
        );

        final oldGame =
            await (targetDb.select(targetDb.games)
              ..where((table) => table.id.equals('old-game'))).getSingle();
        expect(oldGame.deletedAt, isNull);
      } finally {
        await targetDb.close();
        if (await targetTempDir.exists()) {
          await targetTempDir.delete(recursive: true);
        }
      }
    },
  );

  test(
    'encrypted restore does not continue if encrypted pre-restore backup fails',
    () async {
      await _insertCompleteLibrary(db, mediaBase: tempDir);
      final backup = await backupService.createEncryptedBackup(
        password: 'correct horse battery staple',
      );
      await db.close();
      dbClosed = true;

      final targetDb = AppDatabase(NativeDatabase.memory());
      final targetTempDir = await io.Directory.systemTemp.createTemp(
        'backlog_vault_encrypted_restore_prebackup_failure_',
      );
      try {
        await _insertDeletedCandidateAsActive(
          targetDb,
          mediaBase: targetTempDir,
        );
        final service = BackupService(
          exportRepository: _FailingExportRepository(targetDb),
          baseDirectoryLoader: () async => targetTempDir,
          ids: _FixedIds(),
          clock: _FixedClock(),
        );

        await expectLater(
          service.restoreEncryptedBackup(
            backup.bytes,
            password: 'correct horse battery staple',
            confirmation: 'RESTAURAR',
          ),
          throwsA(isA<StateError>()),
        );

        final oldGame =
            await (targetDb.select(targetDb.games)
              ..where((table) => table.id.equals('old-game'))).getSingle();
        final preRestoreDirectory = io.Directory(
          '${targetTempDir.path}${io.Platform.pathSeparator}backups${io.Platform.pathSeparator}pre-restore',
        );
        expect(oldGame.deletedAt, isNull);
        expect(await preRestoreDirectory.exists(), isFalse);
      } finally {
        await targetDb.close();
        if (await targetTempDir.exists()) {
          await targetTempDir.delete(recursive: true);
        }
      }
    },
  );
}

Future<void> _insertCompleteLibrary(
  AppDatabase db, {
  required io.Directory mediaBase,
  bool createMediaFile = true,
}) async {
  final now = DateTime(2026, 1, 1);
  await db
      .into(db.games)
      .insert(
        GamesCompanion.insert(
          id: 'game-1',
          title: 'Hades',
          releaseDate: Value(DateTime(2020, 9, 17)),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.libraryEntries)
      .insert(
        LibraryEntriesCompanion.insert(
          id: 'entry-1',
          gameId: 'game-1',
          status: GameStatus.completed.name,
          personalRating: const Value(5),
          personalNotes: const Value('Nota privada'),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.platforms)
      .insert(
        PlatformsCompanion.insert(
          id: 'pc',
          name: 'PC',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.libraryEntryPlatforms)
      .insert(
        LibraryEntryPlatformsCompanion.insert(
          id: 'lep-1',
          libraryEntryId: 'entry-1',
          platformId: 'pc',
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
          id: 'gg-1',
          gameId: 'game-1',
          genreId: 'genre-1',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.playthroughs)
      .insert(
        PlaythroughsCompanion.insert(
          id: 'pt-1',
          libraryEntryId: 'entry-1',
          platformId: const Value('pc'),
          status: PlaythroughStatus.completed.name,
          completedAt: Value(DateTime(2026, 1, 2)),
          hoursPlayed: const Value(21.5),
          rating: const Value(5),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.savedViews)
      .insert(
        SavedViewsCompanion.insert(
          id: 'view-1',
          name: 'Favoritos',
          filterJson: '{}',
          sortJson: '{}',
          columnConfigJson: '{}',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.externalGameIds)
      .insert(
        ExternalGameIdsCompanion.insert(
          id: 'external-1',
          gameId: 'game-1',
          provider: 'rawg',
          externalId: '3498',
          matchedTitle: const Value('Hades'),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.mediaAssets)
      .insert(
        MediaAssetsCompanion.insert(
          id: 'cover-1',
          gameId: 'game-1',
          kind: 'cover',
          source: 'local',
          localPath: 'media/games/game-1/cover-1.png',
          fileName: 'cover-1.png',
          mimeType: const Value('image/png'),
          hash: const Value('hash-1'),
          isSelected: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );

  if (createMediaFile) {
    final file = io.File(
      '${mediaBase.path}${io.Platform.pathSeparator}media${io.Platform.pathSeparator}games${io.Platform.pathSeparator}game-1${io.Platform.pathSeparator}cover-1.png',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(_pngBytes(), flush: true);
  }
}

Future<void> _insertDeletedGame(AppDatabase db) async {
  final now = DateTime(2026, 1, 1);
  await db
      .into(db.games)
      .insert(
        GamesCompanion.insert(
          id: 'deleted-game',
          title: 'Deleted',
          createdAt: now,
          updatedAt: now,
          deletedAt: Value(now),
        ),
      );
  await db
      .into(db.libraryEntries)
      .insert(
        LibraryEntriesCompanion.insert(
          id: 'deleted-entry',
          gameId: 'deleted-game',
          status: GameStatus.backlog.name,
          createdAt: now,
          updatedAt: now,
          deletedAt: Value(now),
        ),
      );
}

Future<void> _insertDeletedCandidateAsActive(
  AppDatabase db, {
  required io.Directory mediaBase,
}) async {
  final now = DateTime(2026, 1, 1);
  await db
      .into(db.games)
      .insert(
        GamesCompanion.insert(
          id: 'old-game',
          title: 'Old Game',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.libraryEntries)
      .insert(
        LibraryEntriesCompanion.insert(
          id: 'old-entry',
          gameId: 'old-game',
          status: GameStatus.backlog.name,
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.mediaAssets)
      .insert(
        MediaAssetsCompanion.insert(
          id: 'old-cover',
          gameId: 'old-game',
          kind: 'cover',
          source: 'local',
          localPath: 'media/games/old-game/old-cover.png',
          fileName: 'old-cover.png',
          createdAt: now,
          updatedAt: now,
        ),
      );
  final file = io.File(
    '${mediaBase.path}${io.Platform.pathSeparator}media${io.Platform.pathSeparator}games${io.Platform.pathSeparator}old-game${io.Platform.pathSeparator}old-cover.png',
  );
  await file.parent.create(recursive: true);
  await file.writeAsBytes(_pngBytes(), flush: true);
}

Future<void> _insertOverlappingGameAsActive(AppDatabase db) async {
  final now = DateTime(2026, 1, 1);
  await db
      .into(db.games)
      .insert(
        GamesCompanion.insert(
          id: 'game-1',
          title: 'Wrong Title',
          createdAt: now,
          updatedAt: now,
        ),
      );
}

List<int> _backupBytes({
  required String libraryJson,
  int appSchemaVersion = 4,
  int backupFormatVersionValue = backupFormatVersion,
  bool includeLibrary = true,
  String? libraryJsonSha256,
  String? extraPath,
}) {
  final manifest = BackupManifest(
    appName: backupAppName,
    backupFormatVersion: backupFormatVersionValue,
    backupId: 'backup-1',
    createdAt: DateTime(2026),
    appSchemaVersion: appSchemaVersion,
    sourcePlatform: 'test',
    mediaIncluded: false,
    counts: const BackupCounts(
      games: 0,
      libraryEntries: 0,
      platforms: 0,
      genres: 0,
      playthroughs: 0,
      savedViews: 0,
      externalGameIds: 0,
      mediaAssets: 0,
      mediaFiles: 0,
    ),
    libraryJsonSha256:
        libraryJsonSha256 ??
        sha256.convert(utf8.encode(libraryJson)).toString(),
    warnings: const [],
  );
  final archive =
      Archive()..addFile(
        ArchiveFile.string(
          'manifest.json',
          const JsonEncoder.withIndent('  ').convert(manifest.toJson()),
        ),
      );
  if (includeLibrary) {
    archive.addFile(ArchiveFile.string('data/library.json', libraryJson));
  }
  if (extraPath != null) {
    archive.addFile(ArchiveFile.bytes(extraPath, _pngBytes()));
  }
  return ZipEncoder().encodeBytes(archive);
}

List<int> _pngBytes() {
  return [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1];
}

class _FixedClock extends Clock {
  @override
  DateTime now() => DateTime(2026, 6, 10, 12);
}

class _FixedIds extends IdGenerator {
  _FixedIds() : super();

  @override
  String newId() => 'backup-id';
}

class _FailingExportRepository extends ExportRepository {
  const _FailingExportRepository(super.db);

  @override
  Future<LogicalLibraryExport> exportLogical({bool includeSoftDeleted = true}) {
    throw StateError('pre-restore backup failed');
  }
}
