import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../domain/apply_metadata_request.dart';
import '../domain/metadata_exception.dart';
import '../domain/metadata_field.dart';

final metadataRepositoryProvider = Provider<MetadataRepository>((ref) {
  return MetadataRepository(ref.watch(appDatabaseProvider));
});

class MetadataRepository {
  MetadataRepository(this._db, {IdGenerator? ids, Clock clock = systemClock})
    : _ids = ids ?? defaultIdGenerator,
      _clock = clock;

  final AppDatabase _db;
  final IdGenerator _ids;
  final Clock _clock;

  Future<List<ExternalGameId>> externalIdsForGame(String gameId) {
    return (_db.select(_db.externalGameIds)
          ..where((table) => table.gameId.equals(gameId))
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.asc(table.provider)]))
        .get();
  }

  Future<void> applyMetadata(ApplyMetadataRequest request) {
    return _db.transaction(() async {
      final now = _clock.now();
      final game =
          await ((_db.select(_db.games)
                ..where((table) => table.id.equals(request.gameId))
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      final entry =
          await ((_db.select(_db.libraryEntries)
                ..where((table) => table.id.equals(request.libraryEntryId))
                ..where((table) => table.gameId.equals(request.gameId))
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      if (game == null || entry == null) {
        throw const MetadataException(
          'No se encontró el juego en la biblioteca.',
          type: MetadataErrorType.notFound,
        );
      }

      await _upsertExternalId(request, now);

      var touchedGame = false;
      if (request.selectedFields.contains(MetadataField.title)) {
        await (_db.update(_db.games)
          ..where((table) => table.id.equals(request.gameId))).write(
          GamesCompanion(
            title: Value(request.details.title.trim()),
            updatedAt: Value(now),
          ),
        );
        touchedGame = true;
      }
      if (request.selectedFields.contains(MetadataField.releaseDate)) {
        await (_db.update(_db.games)
          ..where((table) => table.id.equals(request.gameId))).write(
          GamesCompanion(
            releaseDate: Value(request.details.releaseDate),
            updatedAt: Value(now),
          ),
        );
        touchedGame = true;
      }
      if (request.selectedFields.contains(MetadataField.type)) {
        await (_db.update(_db.games)
          ..where((table) => table.id.equals(request.gameId))).write(
          GamesCompanion(
            type: Value(
              request.details.type.trim().isEmpty
                  ? 'game'
                  : request.details.type.trim(),
            ),
            updatedAt: Value(now),
          ),
        );
        touchedGame = true;
      }
      if (request.selectedFields.contains(MetadataField.genres)) {
        if (request.replaceFields.contains(MetadataField.genres)) {
          await _softDeleteGameGenres(request.gameId, now);
        }
        await _addGenres(request.gameId, request.details.genres, now);
        touchedGame = true;
      }
      if (request.selectedFields.contains(MetadataField.platforms)) {
        if (request.replaceFields.contains(MetadataField.platforms)) {
          await _softDeleteLibraryEntryPlatforms(request.libraryEntryId, now);
        }
        await _addPlatforms(
          request.libraryEntryId,
          request.details.platforms,
          now,
        );
        await _touchEntry(request.libraryEntryId, now);
      }
      if (!touchedGame) return;
      await _touchGame(request.gameId, now);
    });
  }

  Future<void> _upsertExternalId(
    ApplyMetadataRequest request,
    DateTime now,
  ) async {
    final details = request.details;
    final sameExternalId =
        await ((_db.select(_db.externalGameIds)
              ..where((table) => table.provider.equals(details.providerId))
              ..where((table) => table.externalId.equals(details.externalId))
              ..where((table) => table.deletedAt.isNull()))
            .get());
    for (final match in sameExternalId) {
      if (match.gameId != request.gameId) {
        throw const MetadataException(
          'Ese resultado externo ya está vinculado a otro juego.',
          type: MetadataErrorType.conflict,
        );
      }
    }

    final existingForProvider =
        await ((_db.select(_db.externalGameIds)
              ..where((table) => table.gameId.equals(request.gameId))
              ..where((table) => table.provider.equals(details.providerId))
              ..where((table) => table.deletedAt.isNull()))
            .getSingleOrNull());

    if (existingForProvider == null) {
      await _db
          .into(_db.externalGameIds)
          .insert(
            ExternalGameIdsCompanion.insert(
              id: _ids.newId(),
              gameId: request.gameId,
              provider: details.providerId,
              externalId: details.externalId,
              externalSlug: Value(details.externalSlug),
              externalUrl: Value(details.externalUrl),
              matchedTitle: Value(details.title),
              createdAt: now,
              updatedAt: now,
            ),
          );
      return;
    }

    if (existingForProvider.externalId != details.externalId &&
        !request.replaceExistingExternalId) {
      throw const MetadataException(
        'Este juego ya tiene otro match externo. Confirmá el reemplazo para cambiarlo.',
        type: MetadataErrorType.conflict,
      );
    }

    await (_db.update(_db.externalGameIds)
      ..where((table) => table.id.equals(existingForProvider.id))).write(
      ExternalGameIdsCompanion(
        externalId: Value(details.externalId),
        externalSlug: Value(details.externalSlug),
        externalUrl: Value(details.externalUrl),
        matchedTitle: Value(details.title),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> _addGenres(
    String gameId,
    List<String> genreNames,
    DateTime now,
  ) async {
    final genreIds = <String>[];
    for (final name in genreNames) {
      final id = await _getOrCreateGenre(name, now);
      if (id != null) genreIds.add(id);
    }

    final existingLinks =
        await ((_db.select(_db.gameGenres)
              ..where((table) => table.gameId.equals(gameId))
              ..where((table) => table.deletedAt.isNull()))
            .get());
    final existingGenreIds = existingLinks.map((link) => link.genreId).toSet();
    for (final genreId in genreIds.toSet()) {
      if (existingGenreIds.contains(genreId)) continue;
      await _db
          .into(_db.gameGenres)
          .insert(
            GameGenresCompanion.insert(
              id: _ids.newId(),
              gameId: gameId,
              genreId: genreId,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  Future<void> _softDeleteGameGenres(String gameId, DateTime now) async {
    await (_db.update(_db.gameGenres)
          ..where((table) => table.gameId.equals(gameId))
          ..where((table) => table.deletedAt.isNull()))
        .write(
          GameGenresCompanion(updatedAt: Value(now), deletedAt: Value(now)),
        );
  }

  Future<void> _addPlatforms(
    String libraryEntryId,
    List<String> platformNames,
    DateTime now,
  ) async {
    final platformIds = <String>[];
    for (final name in platformNames) {
      final id = await _getOrCreatePlatform(name, now);
      if (id != null) platformIds.add(id);
    }

    final existingLinks =
        await ((_db.select(_db.libraryEntryPlatforms)
              ..where((table) => table.libraryEntryId.equals(libraryEntryId))
              ..where((table) => table.deletedAt.isNull()))
            .get());
    final existingPlatformIds =
        existingLinks.map((link) => link.platformId).toSet();
    final shouldSetPrimary = existingLinks.isEmpty;
    var insertedCount = 0;
    for (final platformId in platformIds.toSet()) {
      if (existingPlatformIds.contains(platformId)) continue;
      await _db
          .into(_db.libraryEntryPlatforms)
          .insert(
            LibraryEntryPlatformsCompanion.insert(
              id: _ids.newId(),
              libraryEntryId: libraryEntryId,
              platformId: platformId,
              isPrimary: Value(shouldSetPrimary && insertedCount == 0),
              createdAt: now,
              updatedAt: now,
            ),
          );
      insertedCount++;
    }
  }

  Future<void> _softDeleteLibraryEntryPlatforms(
    String libraryEntryId,
    DateTime now,
  ) async {
    await (_db.update(_db.libraryEntryPlatforms)
          ..where((table) => table.libraryEntryId.equals(libraryEntryId))
          ..where((table) => table.deletedAt.isNull()))
        .write(
          LibraryEntryPlatformsCompanion(
            updatedAt: Value(now),
            deletedAt: Value(now),
          ),
        );
  }

  Future<String?> _getOrCreateGenre(String name, DateTime now) async {
    final normalized = name.trim();
    if (normalized.isEmpty) return null;
    final existing = _firstByName(
      await ((_db.select(_db.genres)
        ..where((table) => table.deletedAt.isNull())).get()),
      normalized,
      (genre) => genre.name,
    );
    if (existing != null) return existing.id;
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

  Future<String?> _getOrCreatePlatform(String name, DateTime now) async {
    final normalized = name.trim();
    if (normalized.isEmpty) return null;
    final existing = _firstByName(
      await ((_db.select(_db.platforms)
        ..where((table) => table.deletedAt.isNull())).get()),
      normalized,
      (platform) => platform.name,
    );
    if (existing != null) return existing.id;
    final id = _ids.newId();
    await _db
        .into(_db.platforms)
        .insert(
          PlatformsCompanion.insert(
            id: id,
            name: normalized,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  T? _firstByName<T>(
    Iterable<T> items,
    String name,
    String Function(T item) readName,
  ) {
    final normalized = name.toLowerCase();
    for (final item in items) {
      if (readName(item).toLowerCase() == normalized) return item;
    }
    return null;
  }

  Future<void> _touchGame(String gameId, DateTime now) async {
    await (_db.update(_db.games)..where(
      (table) => table.id.equals(gameId),
    )).write(GamesCompanion(updatedAt: Value(now)));
  }

  Future<void> _touchEntry(String entryId, DateTime now) async {
    await (_db.update(_db.libraryEntries)..where(
      (table) => table.id.equals(entryId),
    )).write(LibraryEntriesCompanion(updatedAt: Value(now)));
  }
}
