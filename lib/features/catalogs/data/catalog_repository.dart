import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../domain/catalog_normalizer.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(appDatabaseProvider));
});

final platformsProvider = StreamProvider.autoDispose<List<Platform>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchPlatforms();
});

final genresProvider = StreamProvider.autoDispose<List<Genre>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchGenres();
});

class CatalogRepository {
  CatalogRepository(this._db, {IdGenerator? ids, Clock clock = systemClock})
    : _ids = ids ?? defaultIdGenerator,
      _clock = clock;

  final AppDatabase _db;
  final IdGenerator _ids;
  final Clock _clock;

  Stream<List<Platform>> watchPlatforms() {
    return (_db.select(_db.platforms)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .watch();
  }

  Stream<List<Genre>> watchGenres() {
    return (_db.select(_db.genres)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .watch();
  }

  Future<String> createPlatform(String name, {String? shortName}) async {
    final normalized = canonicalPlatformName(name);
    if (normalized.isEmpty) {
      throw ArgumentError('El nombre de la plataforma es obligatorio.');
    }

    final existing = _firstOrNull(
      (await ((_db.select(_db.platforms)
            ..where((table) => table.deletedAt.isNull())).get()))
          .where(
            (platform) =>
                catalogComparisonKey(platform.name) ==
                catalogComparisonKey(normalized),
          ),
    );
    if (existing != null) return existing.id;

    final now = _clock.now();
    final id = _ids.newId();
    await _db
        .into(_db.platforms)
        .insert(
          PlatformsCompanion.insert(
            id: id,
            name: normalized,
            shortName: Value(
              shortName?.trim().isEmpty ?? true ? null : shortName!.trim(),
            ),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<String> createGenre(String name) async {
    final normalized = canonicalGenreName(name);
    if (normalized.isEmpty) {
      throw ArgumentError('El nombre del género es obligatorio.');
    }

    final existing = _firstOrNull(
      (await ((_db.select(_db.genres)
            ..where((table) => table.deletedAt.isNull())).get()))
          .where(
            (genre) => genre.name.toLowerCase() == normalized.toLowerCase(),
          )
          .where(
            (genre) =>
                catalogComparisonKey(genre.name) ==
                catalogComparisonKey(normalized),
          ),
    );
    if (existing != null) return existing.id;

    final now = _clock.now();
    final id = _ids.newId();
    await _db
        .into(_db.genres)
        .insert(
          GenresCompanion.insert(
            id: id,
            name: normalized,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> seedDefaultsIfEmpty() async {
    final platformCount = await (_db.select(_db.platforms)..where(
      (table) => table.deletedAt.isNull(),
    )).get().then((rows) => rows.length);
    if (platformCount == 0) {
      for (final name in [
        'PC',
        'Steam Deck',
        'Nintendo Switch',
        'PS1',
        'PS2',
        'PS3',
        'PS4',
        'PS5',
        'Xbox',
        'Xbox 360',
        'Xbox One',
        'Xbox Series X|S',
      ]) {
        await createPlatform(name);
      }
    }

    final genreCount = await (_db.select(_db.genres)..where(
      (table) => table.deletedAt.isNull(),
    )).get().then((rows) => rows.length);
    if (genreCount == 0) {
      for (final name in [
        'Acción',
        'Aventura',
        'RPG',
        'Puzzle',
        'Estrategia',
        'Terror',
        'Carreras',
        'Deportes',
        'Lucha',
        'Plataformas',
        'Simulación',
        'Shooter',
        'Indie',
      ]) {
        await createGenre(name);
      }
    }

    await normalizeCatalogs();
  }

  Future<void> normalizeCatalogs() async {
    await _db.transaction(() async {
      final now = _clock.now();
      await _normalizePlatforms(now);
      await _normalizeGenres(now);
    });
  }

  Future<void> _normalizePlatforms(DateTime now) async {
    final platforms =
        await ((_db.select(_db.platforms)
          ..where((table) => table.deletedAt.isNull())).get());
    final groups = <String, List<Platform>>{};
    for (final platform in platforms) {
      final canonical = canonicalPlatformName(platform.name);
      if (canonical.isEmpty) continue;
      groups
          .putIfAbsent(catalogComparisonKey(canonical), () => [])
          .add(platform);
    }

    for (final entry in groups.entries) {
      final canonicalName = canonicalPlatformName(entry.value.first.name);
      var canonical = _firstOrNull(
        entry.value.where(
          (platform) =>
              catalogComparisonKey(platform.name) ==
              catalogComparisonKey(canonicalName),
        ),
      );
      if (canonical == null) {
        final id = _ids.newId();
        await _db
            .into(_db.platforms)
            .insert(
              PlatformsCompanion.insert(
                id: id,
                name: canonicalName,
                createdAt: now,
                updatedAt: now,
              ),
            );
        canonical =
            await ((_db.select(_db.platforms)
              ..where((table) => table.id.equals(id))).getSingle());
      } else if (canonical.name != canonicalName) {
        await (_db.update(_db.platforms)
          ..where((table) => table.id.equals(canonical!.id))).write(
          PlatformsCompanion(name: Value(canonicalName), updatedAt: Value(now)),
        );
        canonical = canonical.copyWith(name: canonicalName);
      }

      final canonicalId = canonical.id;
      for (final alias in entry.value) {
        if (alias.id == canonicalId) continue;
        final links =
            await ((_db.select(_db.libraryEntryPlatforms)
                  ..where((table) => table.platformId.equals(alias.id))
                  ..where((table) => table.deletedAt.isNull()))
                .get());
        for (final link in links) {
          final duplicate =
              await ((_db.select(_db.libraryEntryPlatforms)
                    ..where(
                      (table) =>
                          table.libraryEntryId.equals(link.libraryEntryId),
                    )
                    ..where((table) => table.platformId.equals(canonicalId))
                    ..where((table) => table.deletedAt.isNull()))
                  .getSingleOrNull());
          if (duplicate != null) {
            await (_db.update(_db.libraryEntryPlatforms)
              ..where((table) => table.id.equals(link.id))).write(
              LibraryEntryPlatformsCompanion(
                updatedAt: Value(now),
                deletedAt: Value(now),
              ),
            );
          } else {
            await (_db.update(_db.libraryEntryPlatforms)
              ..where((table) => table.id.equals(link.id))).write(
              LibraryEntryPlatformsCompanion(
                platformId: Value(canonicalId),
                updatedAt: Value(now),
              ),
            );
          }
        }
        await (_db.update(_db.platforms)
          ..where((table) => table.id.equals(alias.id))).write(
          PlatformsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
        );
      }
    }
  }

  Future<void> _normalizeGenres(DateTime now) async {
    final genres =
        await ((_db.select(_db.genres)
          ..where((table) => table.deletedAt.isNull())).get());
    final groups = <String, List<Genre>>{};
    for (final genre in genres) {
      final canonical = canonicalGenreName(genre.name);
      if (canonical.isEmpty) continue;
      groups.putIfAbsent(catalogComparisonKey(canonical), () => []).add(genre);
    }

    for (final entry in groups.entries) {
      final canonicalName = canonicalGenreName(entry.value.first.name);
      var canonical = _firstOrNull(
        entry.value.where(
          (genre) =>
              catalogComparisonKey(genre.name) ==
              catalogComparisonKey(canonicalName),
        ),
      );
      if (canonical == null) {
        final id = _ids.newId();
        await _db
            .into(_db.genres)
            .insert(
              GenresCompanion.insert(
                id: id,
                name: canonicalName,
                createdAt: now,
                updatedAt: now,
              ),
            );
        canonical =
            await ((_db.select(_db.genres)
              ..where((table) => table.id.equals(id))).getSingle());
      } else if (canonical.name != canonicalName) {
        await (_db.update(_db.genres)
          ..where((table) => table.id.equals(canonical!.id))).write(
          GenresCompanion(name: Value(canonicalName), updatedAt: Value(now)),
        );
        canonical = canonical.copyWith(name: canonicalName);
      }

      final canonicalId = canonical.id;
      for (final alias in entry.value) {
        if (alias.id == canonicalId) continue;
        final links =
            await ((_db.select(_db.gameGenres)
                  ..where((table) => table.genreId.equals(alias.id))
                  ..where((table) => table.deletedAt.isNull()))
                .get());
        for (final link in links) {
          final duplicate =
              await ((_db.select(_db.gameGenres)
                    ..where((table) => table.gameId.equals(link.gameId))
                    ..where((table) => table.genreId.equals(canonicalId))
                    ..where((table) => table.deletedAt.isNull()))
                  .getSingleOrNull());
          if (duplicate != null) {
            await (_db.update(_db.gameGenres)
              ..where((table) => table.id.equals(link.id))).write(
              GameGenresCompanion(updatedAt: Value(now), deletedAt: Value(now)),
            );
          } else {
            await (_db.update(_db.gameGenres)
              ..where((table) => table.id.equals(link.id))).write(
              GameGenresCompanion(
                genreId: Value(canonicalId),
                updatedAt: Value(now),
              ),
            );
          }
        }
        await (_db.update(_db.genres)..where(
          (table) => table.id.equals(alias.id),
        )).write(GenresCompanion(updatedAt: Value(now), deletedAt: Value(now)));
      }
    }
  }
}

T? _firstOrNull<T>(Iterable<T> values) {
  final iterator = values.iterator;
  if (!iterator.moveNext()) return null;
  return iterator.current;
}
