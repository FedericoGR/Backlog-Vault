import 'game_status.dart';

const _unset = Object();

class LibraryFilterState {
  const LibraryFilterState({
    this.textQuery = '',
    this.statuses = const {},
    this.platformIds = const {},
    this.genreIds = const {},
    this.minRating,
    this.maxRating,
    this.releaseDateFrom,
    this.releaseDateTo,
    this.completedDateFrom,
    this.completedDateTo,
    this.minHours,
    this.maxHours,
    this.type,
    this.hasRating = false,
    this.missingRating = false,
    this.hasPlatform = false,
    this.missingPlatform = false,
    this.hasGenre = false,
    this.missingGenre = false,
    this.hasCompletedDate = false,
    this.missingCompletedDate = false,
  });

  final String textQuery;
  final Set<GameStatus> statuses;
  final Set<String> platformIds;
  final Set<String> genreIds;
  final int? minRating;
  final int? maxRating;
  final DateTime? releaseDateFrom;
  final DateTime? releaseDateTo;
  final DateTime? completedDateFrom;
  final DateTime? completedDateTo;
  final double? minHours;
  final double? maxHours;
  final String? type;
  final bool hasRating;
  final bool missingRating;
  final bool hasPlatform;
  final bool missingPlatform;
  final bool hasGenre;
  final bool missingGenre;
  final bool hasCompletedDate;
  final bool missingCompletedDate;

  bool get isEmpty => activeCount == 0;

  int get activeCount {
    var count = 0;
    if (textQuery.trim().isNotEmpty) count++;
    if (statuses.isNotEmpty) count++;
    if (platformIds.isNotEmpty) count++;
    if (genreIds.isNotEmpty) count++;
    if (minRating != null || maxRating != null) count++;
    if (releaseDateFrom != null || releaseDateTo != null) count++;
    if (completedDateFrom != null || completedDateTo != null) count++;
    if (minHours != null || maxHours != null) count++;
    if (type?.trim().isNotEmpty ?? false) count++;
    if (hasRating) count++;
    if (missingRating) count++;
    if (hasPlatform) count++;
    if (missingPlatform) count++;
    if (hasGenre) count++;
    if (missingGenre) count++;
    if (hasCompletedDate) count++;
    if (missingCompletedDate) count++;
    return count;
  }

  LibraryFilterState copyWith({
    String? textQuery,
    Set<GameStatus>? statuses,
    Set<String>? platformIds,
    Set<String>? genreIds,
    Object? minRating = _unset,
    Object? maxRating = _unset,
    Object? releaseDateFrom = _unset,
    Object? releaseDateTo = _unset,
    Object? completedDateFrom = _unset,
    Object? completedDateTo = _unset,
    Object? minHours = _unset,
    Object? maxHours = _unset,
    Object? type = _unset,
    bool? hasRating,
    bool? missingRating,
    bool? hasPlatform,
    bool? missingPlatform,
    bool? hasGenre,
    bool? missingGenre,
    bool? hasCompletedDate,
    bool? missingCompletedDate,
  }) {
    return LibraryFilterState(
      textQuery: textQuery ?? this.textQuery,
      statuses: statuses ?? this.statuses,
      platformIds: platformIds ?? this.platformIds,
      genreIds: genreIds ?? this.genreIds,
      minRating:
          identical(minRating, _unset) ? this.minRating : minRating as int?,
      maxRating:
          identical(maxRating, _unset) ? this.maxRating : maxRating as int?,
      releaseDateFrom:
          identical(releaseDateFrom, _unset)
              ? this.releaseDateFrom
              : releaseDateFrom as DateTime?,
      releaseDateTo:
          identical(releaseDateTo, _unset)
              ? this.releaseDateTo
              : releaseDateTo as DateTime?,
      completedDateFrom:
          identical(completedDateFrom, _unset)
              ? this.completedDateFrom
              : completedDateFrom as DateTime?,
      completedDateTo:
          identical(completedDateTo, _unset)
              ? this.completedDateTo
              : completedDateTo as DateTime?,
      minHours:
          identical(minHours, _unset) ? this.minHours : minHours as double?,
      maxHours:
          identical(maxHours, _unset) ? this.maxHours : maxHours as double?,
      type: identical(type, _unset) ? this.type : type as String?,
      hasRating: hasRating ?? this.hasRating,
      missingRating: missingRating ?? this.missingRating,
      hasPlatform: hasPlatform ?? this.hasPlatform,
      missingPlatform: missingPlatform ?? this.missingPlatform,
      hasGenre: hasGenre ?? this.hasGenre,
      missingGenre: missingGenre ?? this.missingGenre,
      hasCompletedDate: hasCompletedDate ?? this.hasCompletedDate,
      missingCompletedDate: missingCompletedDate ?? this.missingCompletedDate,
    );
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    'textQuery': textQuery,
    'statuses': statuses.map((status) => status.name).toList(),
    'platformIds': platformIds.toList(),
    'genreIds': genreIds.toList(),
    'minRating': minRating,
    'maxRating': maxRating,
    'releaseDateFrom': releaseDateFrom?.toIso8601String(),
    'releaseDateTo': releaseDateTo?.toIso8601String(),
    'completedDateFrom': completedDateFrom?.toIso8601String(),
    'completedDateTo': completedDateTo?.toIso8601String(),
    'minHours': minHours,
    'maxHours': maxHours,
    'type': type,
    'hasRating': hasRating,
    'missingRating': missingRating,
    'hasPlatform': hasPlatform,
    'missingPlatform': missingPlatform,
    'hasGenre': hasGenre,
    'missingGenre': missingGenre,
    'hasCompletedDate': hasCompletedDate,
    'missingCompletedDate': missingCompletedDate,
  };

  factory LibraryFilterState.fromJson(Map<String, Object?> json) {
    return LibraryFilterState(
      textQuery: json['textQuery'] as String? ?? '',
      statuses: _statusSet(json['statuses']),
      platformIds: _stringSet(json['platformIds']),
      genreIds: _stringSet(json['genreIds']),
      minRating: _intOrNull(json['minRating']),
      maxRating: _intOrNull(json['maxRating']),
      releaseDateFrom: _dateOrNull(json['releaseDateFrom']),
      releaseDateTo: _dateOrNull(json['releaseDateTo']),
      completedDateFrom: _dateOrNull(json['completedDateFrom']),
      completedDateTo: _dateOrNull(json['completedDateTo']),
      minHours: _doubleOrNull(json['minHours']),
      maxHours: _doubleOrNull(json['maxHours']),
      type: json['type'] as String?,
      hasRating: json['hasRating'] as bool? ?? false,
      missingRating: json['missingRating'] as bool? ?? false,
      hasPlatform: json['hasPlatform'] as bool? ?? false,
      missingPlatform: json['missingPlatform'] as bool? ?? false,
      hasGenre: json['hasGenre'] as bool? ?? false,
      missingGenre: json['missingGenre'] as bool? ?? false,
      hasCompletedDate: json['hasCompletedDate'] as bool? ?? false,
      missingCompletedDate: json['missingCompletedDate'] as bool? ?? false,
    );
  }
}

Set<String> _stringSet(Object? value) {
  if (value is! List) return const {};
  return value.whereType<String>().toSet();
}

Set<GameStatus> _statusSet(Object? value) {
  if (value is! List) return const {};
  return value.whereType<String>().map(parseGameStatus).toSet();
}

int? _intOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

double? _doubleOrNull(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return null;
}

DateTime? _dateOrNull(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
