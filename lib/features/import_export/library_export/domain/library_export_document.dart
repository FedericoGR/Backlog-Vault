import 'dart:convert';
import 'dart:typed_data';

const libraryExportFormat = 'backlog-vault-library-export';
const libraryExportFormatVersion = 1;

class LibraryExportSummary {
  const LibraryExportSummary({
    required this.games,
    required this.libraryEntries,
    required this.playthroughs,
    required this.platforms,
    required this.genres,
    required this.libraryEntryPlatforms,
    required this.gameGenres,
    required this.savedViews,
    required this.metadata,
    required this.media,
  });

  final int games;
  final int libraryEntries;
  final int playthroughs;
  final int platforms;
  final int genres;
  final int libraryEntryPlatforms;
  final int gameGenres;
  final int savedViews;
  final int metadata;
  final int media;

  Map<String, Object?> toJson() {
    return {
      'games': games,
      'libraryEntries': libraryEntries,
      'playthroughs': playthroughs,
      'platforms': platforms,
      'genres': genres,
      'libraryEntryPlatforms': libraryEntryPlatforms,
      'gameGenres': gameGenres,
      'savedViews': savedViews,
      'metadata': metadata,
      'media': media,
    };
  }
}

class LibraryExportDocument {
  const LibraryExportDocument({
    required this.exportedAt,
    required this.appVersion,
    required this.sourcePlatform,
    required this.games,
    required this.libraryEntries,
    required this.playthroughs,
    required this.platforms,
    required this.genres,
    required this.libraryEntryPlatforms,
    required this.gameGenres,
    required this.savedViews,
    required this.metadata,
    required this.media,
  });

  final DateTime exportedAt;
  final String appVersion;
  final String sourcePlatform;
  final List<Map<String, Object?>> games;
  final List<Map<String, Object?>> libraryEntries;
  final List<Map<String, Object?>> playthroughs;
  final List<Map<String, Object?>> platforms;
  final List<Map<String, Object?>> genres;
  final List<Map<String, Object?>> libraryEntryPlatforms;
  final List<Map<String, Object?>> gameGenres;
  final List<Map<String, Object?>> savedViews;
  final List<Map<String, Object?>> metadata;
  final List<Map<String, Object?>> media;

  LibraryExportSummary get summary {
    return LibraryExportSummary(
      games: games.length,
      libraryEntries: libraryEntries.length,
      playthroughs: playthroughs.length,
      platforms: platforms.length,
      genres: genres.length,
      libraryEntryPlatforms: libraryEntryPlatforms.length,
      gameGenres: gameGenres.length,
      savedViews: savedViews.length,
      metadata: metadata.length,
      media: media.length,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'format': libraryExportFormat,
      'formatVersion': libraryExportFormatVersion,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'appVersion': appVersion,
      'sourcePlatform': sourcePlatform,
      'summary': summary.toJson(),
      'games': games,
      'libraryEntries': libraryEntries,
      'playthroughs': playthroughs,
      'platforms': platforms,
      'genres': genres,
      'libraryEntryPlatforms': libraryEntryPlatforms,
      'gameGenres': gameGenres,
      'savedViews': savedViews,
      'metadata': metadata,
      'media': media,
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  Uint8List toUtf8Bytes() => Uint8List.fromList(utf8.encode(toPrettyJson()));
}

String libraryExportFileName(DateTime exportedAt) {
  final utc = exportedAt.toUtc();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return 'backlog-vault-library-'
      '${utc.year}${twoDigits(utc.month)}${twoDigits(utc.day)}-'
      '${twoDigits(utc.hour)}${twoDigits(utc.minute)}${twoDigits(utc.second)}'
      '.json';
}
