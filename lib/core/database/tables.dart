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
