import 'dart:io' as io;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_providers.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/version/app_versions.dart';
import '../domain/library_export_document.dart';

final libraryExportRepositoryProvider = Provider<LibraryExportRepository>((
  ref,
) {
  return LibraryExportRepository(
    ref.watch(appDatabaseProvider),
    sourcePlatform: io.Platform.isAndroid ? 'android' : 'windows',
  );
});

class LibraryExportRepository {
  const LibraryExportRepository(
    this._db, {
    required this.sourcePlatform,
    this.appVersion = appVersionName,
    Clock clock = systemClock,
  }) : _clock = clock;

  final AppDatabase _db;
  final String sourcePlatform;
  final String appVersion;
  final Clock _clock;

  Future<LibraryExportDocument> createDocument() {
    return _db.transaction(() async {
      final exportedAt = _clock.now().toUtc();
      return LibraryExportDocument(
        exportedAt: exportedAt,
        appVersion: appVersion,
        sourcePlatform: sourcePlatform,
        games: await _games(),
        libraryEntries: await _libraryEntries(),
        playthroughs: await _playthroughs(),
        platforms: await _platforms(),
        genres: await _genres(),
        libraryEntryPlatforms: await _libraryEntryPlatforms(),
        gameGenres: await _gameGenres(),
        savedViews: await _savedViews(),
        metadata: await _metadata(),
        media: await _media(),
      );
    });
  }

  Future<List<Map<String, Object?>>> _games() async {
    final rows =
        await (_db.select(_db.games)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get();
    return [
      for (final row in rows)
        {
          'id': row.id,
          'title': row.title,
          'sortTitle': row.sortTitle,
          'releaseDate': _date(row.releaseDate),
          'type': row.type,
          'createdAt': _date(row.createdAt),
          'updatedAt': _date(row.updatedAt),
          'deletedAt': _date(row.deletedAt),
        },
    ];
  }

  Future<List<Map<String, Object?>>> _libraryEntries() async {
    final rows =
        await (_db.select(_db.libraryEntries)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get();
    return [
      for (final row in rows)
        {
          'id': row.id,
          'gameId': row.gameId,
          'status':
              row.status, // Legacy value retained for archival compatibility.
          'isCompleted': row.isCompleted,
          'completedAt': _date(row.completedAt),
          'hoursPlayed': row.hoursPlayed,
          'playedPlatformId': row.playedPlatformId,
          'personalRating': row.personalRating,
          'personalNotes': row.personalNotes,
          'createdAt': _date(row.createdAt),
          'updatedAt': _date(row.updatedAt),
          'deletedAt': _date(row.deletedAt),
        },
    ];
  }

  Future<List<Map<String, Object?>>> _playthroughs() async {
    final rows =
        await (_db.select(_db.playthroughs)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get();
    return [
      for (final row in rows)
        {
          'id': row.id,
          'libraryEntryId': row.libraryEntryId,
          'platformId': row.platformId,
          'status': row.status,
          'startedAt': _date(row.startedAt),
          'completedAt': _date(row.completedAt),
          'hoursPlayed': row.hoursPlayed,
          'rating': row.rating,
          'notes': row.notes,
          'createdAt': _date(row.createdAt),
          'updatedAt': _date(row.updatedAt),
          'deletedAt': _date(row.deletedAt),
        },
    ];
  }

  Future<List<Map<String, Object?>>> _platforms() async {
    final rows =
        await (_db.select(_db.platforms)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get();
    return [
      for (final row in rows)
        {
          'id': row.id,
          'name': row.name,
          'shortName': row.shortName,
          'createdAt': _date(row.createdAt),
          'updatedAt': _date(row.updatedAt),
          'deletedAt': _date(row.deletedAt),
        },
    ];
  }

  Future<List<Map<String, Object?>>> _genres() async {
    final rows =
        await (_db.select(_db.genres)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get();
    return [
      for (final row in rows)
        {
          'id': row.id,
          'name': row.name,
          'createdAt': _date(row.createdAt),
          'updatedAt': _date(row.updatedAt),
          'deletedAt': _date(row.deletedAt),
        },
    ];
  }

  Future<List<Map<String, Object?>>> _libraryEntryPlatforms() async {
    final rows =
        await (_db.select(_db.libraryEntryPlatforms)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get();
    return [
      for (final row in rows)
        {
          'id': row.id,
          'libraryEntryId': row.libraryEntryId,
          'platformId': row.platformId,
          'isPrimary': row.isPrimary,
          'createdAt': _date(row.createdAt),
          'updatedAt': _date(row.updatedAt),
          'deletedAt': _date(row.deletedAt),
        },
    ];
  }

  Future<List<Map<String, Object?>>> _gameGenres() async {
    final rows =
        await (_db.select(_db.gameGenres)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get();
    return [
      for (final row in rows)
        {
          'id': row.id,
          'gameId': row.gameId,
          'genreId': row.genreId,
          'createdAt': _date(row.createdAt),
          'updatedAt': _date(row.updatedAt),
          'deletedAt': _date(row.deletedAt),
        },
    ];
  }

  Future<List<Map<String, Object?>>> _savedViews() async {
    final rows =
        await (_db.select(_db.savedViews)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get();
    return [
      for (final row in rows)
        {
          'id': row.id,
          'name': row.name,
          'filterJson': row.filterJson,
          'sortJson': row.sortJson,
          'columnConfigJson': row.columnConfigJson,
          'createdAt': _date(row.createdAt),
          'updatedAt': _date(row.updatedAt),
          'deletedAt': _date(row.deletedAt),
        },
    ];
  }

  Future<List<Map<String, Object?>>> _metadata() async {
    final rows =
        await (_db.select(_db.externalGameIds)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get();
    return [
      for (final row in rows)
        {
          'id': row.id,
          'gameId': row.gameId,
          'provider': row.provider,
          'externalId': row.externalId,
          'externalSlug': row.externalSlug,
          'externalUrl': _publicUrl(row.externalUrl),
          'matchedTitle': row.matchedTitle,
          'createdAt': _date(row.createdAt),
          'updatedAt': _date(row.updatedAt),
          'deletedAt': _date(row.deletedAt),
        },
    ];
  }

  Future<List<Map<String, Object?>>> _media() async {
    final rows =
        await (_db.select(_db.mediaAssets)
          ..orderBy([(table) => OrderingTerm.asc(table.id)])).get();
    return [
      for (final row in rows)
        {
          'id': row.id,
          'gameId': row.gameId,
          'kind': row.kind,
          'source': row.source,
          'provider': row.provider,
          'externalId': row.externalId,
          'remoteUrl': _publicUrl(row.remoteUrl),
          'mimeType': row.mimeType,
          'width': row.width,
          'height': row.height,
          'hash': row.hash,
          'isSelected': row.isSelected,
          'attribution': row.attribution,
          'hasLocalFile': row.localPath.isNotEmpty,
          'createdAt': _date(row.createdAt),
          'updatedAt': _date(row.updatedAt),
          'deletedAt': _date(row.deletedAt),
        },
    ];
  }
}

String? _date(DateTime? value) => value?.toUtc().toIso8601String();

String? _publicUrl(String? value) {
  if (value == null) return null;
  final uri = Uri.tryParse(value);
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    return null;
  }
  final sanitized =
      uri.replace(userInfo: '', query: '', fragment: '').toString();
  return sanitized.replaceFirst(RegExp(r'[?#]+$'), '');
}
