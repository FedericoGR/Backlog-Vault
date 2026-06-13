import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/library/domain/game_status.dart';
import 'package:backlog_vault/features/metadata/data/metadata_repository.dart';
import 'package:backlog_vault/features/metadata/domain/apply_metadata_request.dart';
import 'package:backlog_vault/features/metadata/domain/external_game_details.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_exception.dart';
import 'package:backlog_vault/features/metadata/domain/metadata_field.dart';
import 'package:backlog_vault/features/playthroughs/domain/playthrough_status.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late MetadataRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = MetadataRepository(db);
    await _seedGame(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'apply creates catalogs, relations and external id without touching personal data',
    () async {
      await repository.applyMetadata(
        ApplyMetadataRequest(
          gameId: 'game-1',
          libraryEntryId: 'entry-1',
          details: _details(),
          selectedFields: const {
            MetadataField.releaseDate,
            MetadataField.genres,
            MetadataField.platforms,
          },
        ),
      );

      final game = await db.select(db.games).getSingle();
      final entry = await db.select(db.libraryEntries).getSingle();
      final playthrough = await db.select(db.playthroughs).getSingle();
      final externalIds = await db.select(db.externalGameIds).get();
      final platforms = await db.select(db.platforms).get();
      final genres = await db.select(db.genres).get();
      final platformLinks = await db.select(db.libraryEntryPlatforms).get();
      final genreLinks = await db.select(db.gameGenres).get();

      expect(game.title, 'Local Title');
      expect(game.releaseDate, DateTime(2013, 9, 17));
      expect(entry.status, GameStatus.playing.name);
      expect(entry.personalRating, 4);
      expect(entry.personalNotes, 'Manual note');
      expect(playthrough.status, PlaythroughStatus.active.name);
      expect(externalIds.single.provider, 'rawg');
      expect(externalIds.single.externalId, '3498');
      expect(
        platforms.map((platform) => platform.name),
        containsAll(['PC', 'Nintendo Switch']),
      );
      expect(genres.map((genre) => genre.name), containsAll(['RPG', 'Action']));
      expect(platformLinks, hasLength(2));
      expect(genreLinks, hasLength(2));
    },
  );

  test('apply does not duplicate existing catalogs or external id', () async {
    final request = ApplyMetadataRequest(
      gameId: 'game-1',
      libraryEntryId: 'entry-1',
      details: _details(),
      selectedFields: const {MetadataField.genres, MetadataField.platforms},
    );

    await repository.applyMetadata(request);
    await repository.applyMetadata(request);

    expect(await db.select(db.externalGameIds).get(), hasLength(1));
    expect(await db.select(db.platforms).get(), hasLength(2));
    expect(await db.select(db.genres).get(), hasLength(2));
    expect(await db.select(db.libraryEntryPlatforms).get(), hasLength(2));
    expect(await db.select(db.gameGenres).get(), hasLength(2));
  });

  test(
    'apply deduplicates repeated RAWG catalog names case-insensitively',
    () async {
      await repository.applyMetadata(
        ApplyMetadataRequest(
          gameId: 'game-1',
          libraryEntryId: 'entry-1',
          details: const ExternalGameDetails(
            providerId: 'rawg',
            providerName: 'RAWG',
            externalId: '3498',
            title: 'Grand Theft Auto V',
            genres: ['RPG', 'rpg', 'Action', ' action '],
            platforms: ['PC', 'pc', 'Nintendo Switch', ' nintendo switch '],
          ),
          selectedFields: const {MetadataField.genres, MetadataField.platforms},
        ),
      );

      expect(await db.select(db.platforms).get(), hasLength(2));
      expect(await db.select(db.genres).get(), hasLength(2));
      expect(await db.select(db.libraryEntryPlatforms).get(), hasLength(2));
      expect(await db.select(db.gameGenres).get(), hasLength(2));
    },
  );

  test(
    'different external id for same provider requires explicit replacement',
    () async {
      await repository.applyMetadata(
        ApplyMetadataRequest(
          gameId: 'game-1',
          libraryEntryId: 'entry-1',
          details: _details(),
          selectedFields: const {},
        ),
      );

      await expectLater(
        repository.applyMetadata(
          ApplyMetadataRequest(
            gameId: 'game-1',
            libraryEntryId: 'entry-1',
            details: _details(externalId: '9999'),
            selectedFields: const {},
          ),
        ),
        throwsA(
          isA<MetadataException>().having(
            (error) => error.type,
            'type',
            MetadataErrorType.conflict,
          ),
        ),
      );

      await repository.applyMetadata(
        ApplyMetadataRequest(
          gameId: 'game-1',
          libraryEntryId: 'entry-1',
          details: _details(externalId: '9999'),
          selectedFields: const {},
          replaceExistingExternalId: true,
        ),
      );

      final externalIds = await db.select(db.externalGameIds).get();
      expect(externalIds.single.externalId, '9999');
    },
  );

  test(
    'apply can store IGDB external id without touching personal data',
    () async {
      await repository.applyMetadata(
        ApplyMetadataRequest(
          gameId: 'game-1',
          libraryEntryId: 'entry-1',
          details: const ExternalGameDetails(
            providerId: 'igdb',
            providerName: 'IGDB',
            externalId: '123',
            externalSlug: 'hades',
            externalUrl: 'https://www.igdb.com/games/hades',
            title: 'Hades',
            genres: ['Role-playing (RPG)'],
            platforms: ['PC (Microsoft Windows)'],
          ),
          selectedFields: const {MetadataField.genres, MetadataField.platforms},
        ),
      );

      final entry = await db.select(db.libraryEntries).getSingle();
      final playthrough = await db.select(db.playthroughs).getSingle();
      final externalIds = await db.select(db.externalGameIds).get();

      expect(externalIds.single.provider, 'igdb');
      expect(externalIds.single.externalId, '123');
      expect(externalIds.single.externalSlug, 'hades');
      expect(entry.status, GameStatus.playing.name);
      expect(entry.personalRating, 4);
      expect(entry.personalNotes, 'Manual note');
      expect(playthrough.status, PlaythroughStatus.active.name);
    },
  );
}

final _now = DateTime(2026, 6, 10);

ExternalGameDetails _details({String externalId = '3498'}) {
  return ExternalGameDetails(
    providerId: 'rawg',
    providerName: 'RAWG',
    externalId: externalId,
    externalSlug: 'grand-theft-auto-v',
    externalUrl: 'https://rawg.io/games/grand-theft-auto-v',
    title: 'Grand Theft Auto V',
    releaseDate: DateTime(2013, 9, 17),
    genres: const ['Action', 'RPG'],
    platforms: const ['Nintendo Switch', 'PC'],
  );
}

Future<void> _seedGame(AppDatabase db) async {
  await db
      .into(db.games)
      .insert(
        GamesCompanion.insert(
          id: 'game-1',
          title: 'Local Title',
          createdAt: _now,
          updatedAt: _now,
        ),
      );
  await db
      .into(db.libraryEntries)
      .insert(
        LibraryEntriesCompanion.insert(
          id: 'entry-1',
          gameId: 'game-1',
          status: GameStatus.playing.name,
          personalRating: const Value(4),
          personalNotes: const Value('Manual note'),
          createdAt: _now,
          updatedAt: _now,
        ),
      );
  await db
      .into(db.platforms)
      .insert(
        PlatformsCompanion.insert(
          id: 'platform-pc',
          name: 'PC',
          createdAt: _now,
          updatedAt: _now,
        ),
      );
  await db
      .into(db.genres)
      .insert(
        GenresCompanion.insert(
          id: 'genre-rpg',
          name: 'RPG',
          createdAt: _now,
          updatedAt: _now,
        ),
      );
  await db
      .into(db.libraryEntryPlatforms)
      .insert(
        LibraryEntryPlatformsCompanion.insert(
          id: 'entry-platform-pc',
          libraryEntryId: 'entry-1',
          platformId: 'platform-pc',
          isPrimary: const Value(true),
          createdAt: _now,
          updatedAt: _now,
        ),
      );
  await db
      .into(db.gameGenres)
      .insert(
        GameGenresCompanion.insert(
          id: 'game-genre-rpg',
          gameId: 'game-1',
          genreId: 'genre-rpg',
          createdAt: _now,
          updatedAt: _now,
        ),
      );
  await db
      .into(db.playthroughs)
      .insert(
        PlaythroughsCompanion.insert(
          id: 'playthrough-1',
          libraryEntryId: 'entry-1',
          platformId: const Value('platform-pc'),
          status: PlaythroughStatus.active.name,
          startedAt: Value(DateTime(2026, 6, 1)),
          createdAt: _now,
          updatedAt: _now,
        ),
      );
}
