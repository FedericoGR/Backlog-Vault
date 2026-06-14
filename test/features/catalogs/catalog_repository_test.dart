import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/features/catalogs/data/catalog_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CatalogRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = CatalogRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('platform aliases reuse canonical catalog value', () async {
    final first = await repository.createPlatform('PlayStation 2');
    final second = await repository.createPlatform('PS2');

    final platforms = await db.select(db.platforms).get();

    expect(second, first);
    expect(platforms, hasLength(1));
    expect(platforms.single.name, 'PS2');
  });

  test('genre aliases reuse canonical Spanish catalog value', () async {
    final first = await repository.createGenre('Adventure');
    final second = await repository.createGenre('Aventura');

    final genres = await db.select(db.genres).get();

    expect(second, first);
    expect(genres, hasLength(1));
    expect(genres.single.name, 'Aventura');
  });

  test('normalization reassigns existing duplicate platform links', () async {
    final now = DateTime(2026, 6, 14);
    await db
        .into(db.games)
        .insert(
          GamesCompanion.insert(
            id: 'game-1',
            title: 'Silent Hill 2',
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
            status: 'backlog',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.platforms)
        .insert(
          PlatformsCompanion.insert(
            id: 'platform-alias',
            name: 'PlayStation 2',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.platforms)
        .insert(
          PlatformsCompanion.insert(
            id: 'platform-canonical',
            name: 'PS2',
            createdAt: now,
            updatedAt: now,
          ),
        );
    for (final id in ['platform-alias', 'platform-canonical']) {
      await db
          .into(db.libraryEntryPlatforms)
          .insert(
            LibraryEntryPlatformsCompanion.insert(
              id: 'link-$id',
              libraryEntryId: 'entry-1',
              platformId: id,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    await repository.normalizeCatalogs();

    final activePlatforms =
        await (db.select(db.platforms)
          ..where((row) => row.deletedAt.isNull())).get();
    final activeLinks =
        await (db.select(db.libraryEntryPlatforms)
          ..where((row) => row.deletedAt.isNull())).get();

    expect(activePlatforms.map((platform) => platform.name), ['PS2']);
    expect(activeLinks, hasLength(1));
    expect(activeLinks.single.platformId, 'platform-canonical');
  });
}
