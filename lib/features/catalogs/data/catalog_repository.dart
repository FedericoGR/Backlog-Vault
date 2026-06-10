import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';

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
  CatalogRepository(
    this._db, {
    IdGenerator? ids,
    Clock clock = systemClock,
  })  : _ids = ids ?? defaultIdGenerator,
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
    final normalized = name.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('El nombre de la plataforma es obligatorio.');
    }

    final existing = _firstOrNull(
      (await ((_db.select(_db.platforms)
                ..where((table) => table.deletedAt.isNull()))
              .get()))
          .where(
        (platform) => platform.name.toLowerCase() == normalized.toLowerCase(),
      ),
    );
    if (existing != null) return existing.id;

    final now = _clock.now();
    final id = _ids.newId();
    await _db.into(_db.platforms).insert(
          PlatformsCompanion.insert(
            id: id,
            name: normalized,
            shortName: Value(shortName?.trim().isEmpty ?? true
                ? null
                : shortName!.trim()),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<String> createGenre(String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('El nombre del género es obligatorio.');
    }

    final existing = _firstOrNull(
      (await ((_db.select(_db.genres)
                ..where((table) => table.deletedAt.isNull()))
              .get()))
          .where((genre) => genre.name.toLowerCase() == normalized.toLowerCase()),
    );
    if (existing != null) return existing.id;

    final now = _clock.now();
    final id = _ids.newId();
    await _db.into(_db.genres).insert(
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
    final platformCount = await (_db.select(_db.platforms)
          ..where((table) => table.deletedAt.isNull()))
        .get()
        .then((rows) => rows.length);
    if (platformCount == 0) {
      for (final name in ['PC', 'Nintendo Switch', 'PlayStation', 'Xbox']) {
        await createPlatform(name);
      }
    }

    final genreCount = await (_db.select(_db.genres)
          ..where((table) => table.deletedAt.isNull()))
        .get()
        .then((rows) => rows.length);
    if (genreCount == 0) {
      for (final name in ['Acción', 'Aventura', 'RPG', 'Puzzle', 'Estrategia']) {
        await createGenre(name);
      }
    }
  }
}

T? _firstOrNull<T>(Iterable<T> values) {
  final iterator = values.iterator;
  if (!iterator.moveNext()) return null;
  return iterator.current;
}
