import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../application/playthrough_form_model.dart';

final playthroughRepositoryProvider = Provider<PlaythroughRepository>((ref) {
  return PlaythroughRepository(ref.watch(appDatabaseProvider));
});

/// Persists the lifecycle of individual play experiences.
class PlaythroughRepository {
  PlaythroughRepository(this._db, {IdGenerator? ids, Clock clock = systemClock})
    : _ids = ids ?? defaultIdGenerator,
      _clock = clock;

  final AppDatabase _db;
  final IdGenerator _ids;
  final Clock _clock;

  Future<void> save(PlaythroughFormModel model) {
    model.validate();
    return model.playthroughId == null ? _create(model) : _update(model);
  }

  Future<void> _create(PlaythroughFormModel model) {
    return _db.transaction(() async {
      final now = _clock.now();
      await _requireEntry(model.libraryEntryId);
      await _db
          .into(_db.playthroughs)
          .insert(
            PlaythroughsCompanion.insert(
              id: _ids.newId(),
              libraryEntryId: model.libraryEntryId,
              platformId: Value(model.platformId),
              status: model.status.name,
              startedAt: Value(model.startedAt),
              completedAt: Value(model.completedAt),
              hoursPlayed: Value(model.hoursPlayed),
              rating: Value(model.rating),
              notes: Value(_blankToNull(model.notes)),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _touchEntry(model.libraryEntryId, now);
    });
  }

  Future<void> _update(PlaythroughFormModel model) {
    return _db.transaction(() async {
      final now = _clock.now();
      await _requireEntry(model.libraryEntryId);
      final existing =
          await ((_db.select(_db.playthroughs)
                ..where((table) => table.id.equals(model.playthroughId!))
                ..where(
                  (table) => table.libraryEntryId.equals(model.libraryEntryId),
                )
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      if (existing == null) {
        throw const AppException('No se encontró la partida.');
      }
      await (_db.update(_db.playthroughs)
        ..where((table) => table.id.equals(existing.id))).write(
        PlaythroughsCompanion(
          platformId: Value(model.platformId),
          status: Value(model.status.name),
          startedAt: Value(model.startedAt),
          completedAt: Value(model.completedAt),
          hoursPlayed: Value(model.hoursPlayed),
          rating: Value(model.rating),
          notes: Value(_blankToNull(model.notes)),
          updatedAt: Value(now),
        ),
      );
      await _touchEntry(model.libraryEntryId, now);
    });
  }

  Future<void> softDelete(String playthroughId) {
    return _db.transaction(() async {
      final now = _clock.now();
      final playthrough =
          await ((_db.select(_db.playthroughs)
                ..where((table) => table.id.equals(playthroughId))
                ..where((table) => table.deletedAt.isNull()))
              .getSingleOrNull());
      if (playthrough == null) return;
      await (_db.update(_db.playthroughs)
        ..where((table) => table.id.equals(playthroughId))).write(
        PlaythroughsCompanion(updatedAt: Value(now), deletedAt: Value(now)),
      );
      await _touchEntry(playthrough.libraryEntryId, now);
    });
  }

  Future<void> _touchEntry(String entryId, DateTime now) {
    return (_db.update(_db.libraryEntries)..where(
      (table) => table.id.equals(entryId),
    )).write(LibraryEntriesCompanion(updatedAt: Value(now)));
  }

  Future<void> _requireEntry(String entryId) async {
    final entry =
        await ((_db.select(_db.libraryEntries)
              ..where((table) => table.id.equals(entryId))
              ..where((table) => table.deletedAt.isNull()))
            .getSingleOrNull());
    if (entry == null) {
      throw const AppException('No se encontró el juego en la biblioteca.');
    }
  }
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
