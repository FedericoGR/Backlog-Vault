import 'package:drift/drift.dart';

class Games extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  TextColumn get type => text().withDefault(const Constant('game'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LibraryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get gameId => text().references(Games, #id)();
  TextColumn get status => text()();
  IntColumn get personalRating => integer().nullable()();
  TextColumn get personalNotes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Platforms extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get shortName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LibraryEntryPlatforms extends Table {
  TextColumn get id => text()();
  TextColumn get libraryEntryId => text().references(LibraryEntries, #id)();
  TextColumn get platformId => text().references(Platforms, #id)();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Genres extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class GameGenres extends Table {
  TextColumn get id => text()();
  TextColumn get gameId => text().references(Games, #id)();
  TextColumn get genreId => text().references(Genres, #id)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Playthroughs extends Table {
  TextColumn get id => text()();
  TextColumn get libraryEntryId => text().references(LibraryEntries, #id)();
  TextColumn get platformId => text().nullable().references(Platforms, #id)();
  TextColumn get status => text()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  RealColumn get hoursPlayed => real().nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SavedViews extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get filterJson => text()();
  TextColumn get sortJson => text()();
  TextColumn get columnConfigJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ExternalGameIds extends Table {
  TextColumn get id => text()();
  TextColumn get gameId => text().references(Games, #id)();
  TextColumn get provider => text()();
  TextColumn get externalId => text()();
  TextColumn get externalSlug => text().nullable()();
  TextColumn get externalUrl => text().nullable()();
  TextColumn get matchedTitle => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MediaAssets extends Table {
  TextColumn get id => text()();
  TextColumn get gameId => text().references(Games, #id)();
  TextColumn get kind => text()();
  TextColumn get source => text()();
  TextColumn get provider => text().nullable()();
  TextColumn get externalId => text().nullable()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get localPath => text()();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get hash => text().nullable()();
  BoolColumn get isSelected => boolean().withDefault(const Constant(false))();
  TextColumn get attribution => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncGroups extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  IntColumn get protocolVersion => integer()();
  TextColumn get keyId => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get keyRotatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncDevices extends Table {
  TextColumn get id => text()();
  TextColumn get syncGroupId => text().nullable()();
  TextColumn get displayName => text()();
  TextColumn get platform => text()();
  BoolColumn get isLocal => boolean().withDefault(const Constant(false))();
  TextColumn get publicKey => text().nullable()();
  TextColumn get fingerprint => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get pairedAt => dateTime().nullable()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  DateTimeColumn get revokedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncChanges extends Table {
  TextColumn get changeId => text()();
  TextColumn get syncGroupId => text().nullable()();
  TextColumn get originDeviceId => text()();
  IntColumn get originCounter => integer()();
  TextColumn get mutationId => text()();
  IntColumn get mutationSequence => integer()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get changedFieldsJson => text()();
  TextColumn get payloadJson => text()();
  TextColumn get snapshotJson => text()();
  TextColumn get causalContextJson => text()();
  TextColumn get source => text()();
  TextColumn get contentHash => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get appliedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {changeId};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {originDeviceId, originCounter},
  ];
}

class SyncTombstones extends Table {
  TextColumn get tombstoneId => text()();
  TextColumn get syncGroupId => text().nullable()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get deleteChangeId => text()();
  TextColumn get originDeviceId => text()();
  IntColumn get originCounter => integer()();
  TextColumn get causalContextJson => text()();
  TextColumn get lastContentHash => text().nullable()();
  DateTimeColumn get deletedAt => dateTime()();
  DateTimeColumn get fullyAcknowledgedAt => dateTime().nullable()();
  DateTimeColumn get retainUntil => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {tombstoneId};
}

class SyncStates extends Table {
  TextColumn get id => text()();
  TextColumn get syncGroupId => text().nullable()();
  TextColumn get localDeviceId => text()();
  TextColumn get peerDeviceId => text().nullable()();
  IntColumn get nextLocalCounter => integer().withDefault(const Constant(1))();
  TextColumn get seenVectorJson => text().withDefault(const Constant('{}'))();
  TextColumn get peerAckVectorJson =>
      text().withDefault(const Constant('{}'))();
  TextColumn get lastExportedVectorJson =>
      text().withDefault(const Constant('{}'))();
  TextColumn get lastImportedPackageId => text().nullable()();
  IntColumn get replicaEpoch => integer().withDefault(const Constant(1))();
  BoolColumn get baselineCreated =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get requiresReconciliation =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSuccessfulSyncAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncEntityStates extends Table {
  TextColumn get id => text()();
  TextColumn get syncGroupId => text().nullable()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get fieldVersionsJson => text()();
  TextColumn get entityVectorJson => text()();
  TextColumn get lastChangeId => text()();
  TextColumn get contentHash => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
