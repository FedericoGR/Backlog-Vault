import 'dart:convert';

import '../../../core/version/app_versions.dart';

const backupAppName = 'Backlog Vault';
const backupFormatVersion = 1;
const supportedBackupSchemaVersion = logicalLibrarySchemaVersion;

class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupCounts {
  const BackupCounts({
    required this.games,
    required this.libraryEntries,
    required this.platforms,
    required this.genres,
    required this.playthroughs,
    required this.savedViews,
    required this.externalGameIds,
    required this.mediaAssets,
    required this.mediaFiles,
  });

  final int games;
  final int libraryEntries;
  final int platforms;
  final int genres;
  final int playthroughs;
  final int savedViews;
  final int externalGameIds;
  final int mediaAssets;
  final int mediaFiles;

  factory BackupCounts.fromJson(Map<String, Object?> json) {
    return BackupCounts(
      games: _int(json['games']),
      libraryEntries: _int(json['libraryEntries']),
      platforms: _int(json['platforms']),
      genres: _int(json['genres']),
      playthroughs: _int(json['playthroughs']),
      savedViews: _int(json['savedViews']),
      externalGameIds: _int(json['externalGameIds']),
      mediaAssets: _int(json['mediaAssets']),
      mediaFiles: _int(json['mediaFiles']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'games': games,
      'libraryEntries': libraryEntries,
      'platforms': platforms,
      'genres': genres,
      'playthroughs': playthroughs,
      'savedViews': savedViews,
      'externalGameIds': externalGameIds,
      'mediaAssets': mediaAssets,
      'mediaFiles': mediaFiles,
    };
  }
}

class BackupWarning {
  const BackupWarning({required this.code, required this.message, this.path});

  final String code;
  final String message;
  final String? path;

  factory BackupWarning.fromJson(Map<String, Object?> json) {
    return BackupWarning(
      code: _string(json['code']),
      message: _string(json['message']),
      path: json['path'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {'code': code, 'message': message, if (path != null) 'path': path};
  }
}

class BackupManifest {
  const BackupManifest({
    required this.appName,
    required this.backupFormatVersion,
    required this.backupId,
    required this.createdAt,
    required this.appSchemaVersion,
    required this.sourcePlatform,
    required this.mediaIncluded,
    required this.counts,
    required this.libraryJsonSha256,
    required this.warnings,
  });

  final String appName;
  final int backupFormatVersion;
  final String backupId;
  final DateTime createdAt;
  final int appSchemaVersion;
  final String sourcePlatform;
  final bool mediaIncluded;
  final BackupCounts counts;
  final String libraryJsonSha256;
  final List<BackupWarning> warnings;

  factory BackupManifest.fromJson(Map<String, Object?> json) {
    return BackupManifest(
      appName: _string(json['appName']),
      backupFormatVersion: _int(json['backupFormatVersion']),
      backupId: _string(json['backupId']),
      createdAt: DateTime.parse(_string(json['createdAt'])),
      appSchemaVersion: _int(json['appSchemaVersion']),
      sourcePlatform: _string(json['sourcePlatform']),
      mediaIncluded: json['mediaIncluded'] == true,
      counts: BackupCounts.fromJson(_map(json['counts'])),
      libraryJsonSha256: _string(json['libraryJsonSha256']),
      warnings:
          _list(
            json['warnings'],
          ).map((item) => BackupWarning.fromJson(_map(item))).toList(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'appName': appName,
      'backupFormatVersion': backupFormatVersion,
      'backupId': backupId,
      'createdAt': createdAt.toIso8601String(),
      'appSchemaVersion': appSchemaVersion,
      'sourcePlatform': sourcePlatform,
      'mediaIncluded': mediaIncluded,
      'counts': counts.toJson(),
      'libraryJsonSha256': libraryJsonSha256,
      'warnings': warnings.map((warning) => warning.toJson()).toList(),
    };
  }
}

class LogicalLibraryExport {
  const LogicalLibraryExport({
    required this.formatVersion,
    required this.schemaVersion,
    required this.exportedAt,
    required this.games,
    required this.libraryEntries,
    required this.platforms,
    required this.libraryEntryPlatforms,
    required this.genres,
    required this.gameGenres,
    required this.playthroughs,
    required this.savedViews,
    required this.externalGameIds,
    required this.mediaAssets,
  });

  final int formatVersion;
  final int schemaVersion;
  final DateTime exportedAt;
  final List<Map<String, Object?>> games;
  final List<Map<String, Object?>> libraryEntries;
  final List<Map<String, Object?>> platforms;
  final List<Map<String, Object?>> libraryEntryPlatforms;
  final List<Map<String, Object?>> genres;
  final List<Map<String, Object?>> gameGenres;
  final List<Map<String, Object?>> playthroughs;
  final List<Map<String, Object?>> savedViews;
  final List<Map<String, Object?>> externalGameIds;
  final List<Map<String, Object?>> mediaAssets;

  factory LogicalLibraryExport.fromJson(Map<String, Object?> json) {
    final entities = _map(json['entities']);
    return LogicalLibraryExport(
      formatVersion: _int(json['formatVersion']),
      schemaVersion: _int(json['schemaVersion']),
      exportedAt: DateTime.parse(_string(json['exportedAt'])),
      games: _mapList(entities['games']),
      libraryEntries: _mapList(entities['library_entries']),
      platforms: _mapList(entities['platforms']),
      libraryEntryPlatforms: _mapList(entities['library_entry_platforms']),
      genres: _mapList(entities['genres']),
      gameGenres: _mapList(entities['game_genres']),
      playthroughs: _mapList(entities['playthroughs']),
      savedViews: _mapList(entities['saved_views']),
      externalGameIds: _mapList(entities['external_game_ids']),
      mediaAssets: _mapList(entities['media_assets']),
    );
  }

  factory LogicalLibraryExport.fromJsonString(String source) {
    return LogicalLibraryExport.fromJson(
      jsonDecode(source) as Map<String, Object?>,
    );
  }

  BackupCounts toCounts({int mediaFiles = 0}) {
    return BackupCounts(
      games: games.length,
      libraryEntries: libraryEntries.length,
      platforms: platforms.length,
      genres: genres.length,
      playthroughs: playthroughs.length,
      savedViews: savedViews.length,
      externalGameIds: externalGameIds.length,
      mediaAssets: mediaAssets.length,
      mediaFiles: mediaFiles,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'formatVersion': formatVersion,
      'schemaVersion': schemaVersion,
      'exportedAt': exportedAt.toIso8601String(),
      'entities': {
        'games': games,
        'library_entries': libraryEntries,
        'platforms': platforms,
        'library_entry_platforms': libraryEntryPlatforms,
        'genres': genres,
        'game_genres': gameGenres,
        'playthroughs': playthroughs,
        'saved_views': savedViews,
        'external_game_ids': externalGameIds,
        'media_assets': mediaAssets,
      },
    };
  }

  String toJsonString() => jsonEncode(toJson());
}

class BackupPreview {
  const BackupPreview({
    required this.manifest,
    required this.checksumValid,
    required this.warnings,
  });

  final BackupManifest manifest;
  final bool checksumValid;
  final List<BackupWarning> warnings;
}

class ExportResult {
  const ExportResult({
    required this.fileName,
    required this.bytes,
    required this.warnings,
  });

  final String fileName;
  final List<int> bytes;
  final List<BackupWarning> warnings;
}

class RestoreResult {
  const RestoreResult({
    required this.restoredCounts,
    required this.preRestoreBackupPath,
    required this.warnings,
  });

  final BackupCounts restoredCounts;
  final String preRestoreBackupPath;
  final List<BackupWarning> warnings;
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw const FormatException('Expected integer backup field.');
}

String _string(Object? value) {
  if (value is String) return value;
  throw const FormatException('Expected string backup field.');
}

Map<String, Object?> _map(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);
  throw const FormatException('Expected object backup field.');
}

List<Object?> _list(Object? value) {
  if (value is List) return value;
  throw const FormatException('Expected list backup field.');
}

List<Map<String, Object?>> _mapList(Object? value) {
  return _list(value).map(_map).toList();
}
