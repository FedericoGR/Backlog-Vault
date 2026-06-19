// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortTitleMeta = const VerificationMeta(
    'sortTitle',
  );
  @override
  late final GeneratedColumn<String> sortTitle = GeneratedColumn<String>(
    'sort_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseDateMeta = const VerificationMeta(
    'releaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> releaseDate = GeneratedColumn<DateTime>(
    'release_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('game'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    sortTitle,
    releaseDate,
    type,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<Game> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('sort_title')) {
      context.handle(
        _sortTitleMeta,
        sortTitle.isAcceptableOrUnknown(data['sort_title']!, _sortTitleMeta),
      );
    }
    if (data.containsKey('release_date')) {
      context.handle(
        _releaseDateMeta,
        releaseDate.isAcceptableOrUnknown(
          data['release_date']!,
          _releaseDateMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      sortTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_title'],
      ),
      releaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}release_date'],
      ),
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class Game extends DataClass implements Insertable<Game> {
  final String id;
  final String title;
  final String? sortTitle;
  final DateTime? releaseDate;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Game({
    required this.id,
    required this.title,
    this.sortTitle,
    this.releaseDate,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || sortTitle != null) {
      map['sort_title'] = Variable<String>(sortTitle);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<DateTime>(releaseDate);
    }
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      title: Value(title),
      sortTitle:
          sortTitle == null && nullToAbsent
              ? const Value.absent()
              : Value(sortTitle),
      releaseDate:
          releaseDate == null && nullToAbsent
              ? const Value.absent()
              : Value(releaseDate),
      type: Value(type),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory Game.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      sortTitle: serializer.fromJson<String?>(json['sortTitle']),
      releaseDate: serializer.fromJson<DateTime?>(json['releaseDate']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'sortTitle': serializer.toJson<String?>(sortTitle),
      'releaseDate': serializer.toJson<DateTime?>(releaseDate),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Game copyWith({
    String? id,
    String? title,
    Value<String?> sortTitle = const Value.absent(),
    Value<DateTime?> releaseDate = const Value.absent(),
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Game(
    id: id ?? this.id,
    title: title ?? this.title,
    sortTitle: sortTitle.present ? sortTitle.value : this.sortTitle,
    releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      sortTitle: data.sortTitle.present ? data.sortTitle.value : this.sortTitle,
      releaseDate:
          data.releaseDate.present ? data.releaseDate.value : this.releaseDate,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sortTitle: $sortTitle, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    sortTitle,
    releaseDate,
    type,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.id == this.id &&
          other.title == this.title &&
          other.sortTitle == this.sortTitle &&
          other.releaseDate == this.releaseDate &&
          other.type == this.type &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> sortTitle;
  final Value<DateTime?> releaseDate;
  final Value<String> type;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.sortTitle = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamesCompanion.insert({
    required String id,
    required String title,
    this.sortTitle = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.type = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Game> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? sortTitle,
    Expression<DateTime>? releaseDate,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (sortTitle != null) 'sort_title': sortTitle,
      if (releaseDate != null) 'release_date': releaseDate,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? sortTitle,
    Value<DateTime?>? releaseDate,
    Value<String>? type,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      sortTitle: sortTitle ?? this.sortTitle,
      releaseDate: releaseDate ?? this.releaseDate,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sortTitle.present) {
      map['sort_title'] = Variable<String>(sortTitle.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<DateTime>(releaseDate.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sortTitle: $sortTitle, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryEntriesTable extends LibraryEntries
    with TableInfo<$LibraryEntriesTable, LibraryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personalRatingMeta = const VerificationMeta(
    'personalRating',
  );
  @override
  late final GeneratedColumn<int> personalRating = GeneratedColumn<int>(
    'personal_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personalNotesMeta = const VerificationMeta(
    'personalNotes',
  );
  @override
  late final GeneratedColumn<String> personalNotes = GeneratedColumn<String>(
    'personal_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    status,
    personalRating,
    personalNotes,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('personal_rating')) {
      context.handle(
        _personalRatingMeta,
        personalRating.isAcceptableOrUnknown(
          data['personal_rating']!,
          _personalRatingMeta,
        ),
      );
    }
    if (data.containsKey('personal_notes')) {
      context.handle(
        _personalNotesMeta,
        personalNotes.isAcceptableOrUnknown(
          data['personal_notes']!,
          _personalNotesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      gameId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}game_id'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      personalRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}personal_rating'],
      ),
      personalNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personal_notes'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LibraryEntriesTable createAlias(String alias) {
    return $LibraryEntriesTable(attachedDatabase, alias);
  }
}

class LibraryEntry extends DataClass implements Insertable<LibraryEntry> {
  final String id;
  final String gameId;
  final String status;
  final int? personalRating;
  final String? personalNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const LibraryEntry({
    required this.id,
    required this.gameId,
    required this.status,
    this.personalRating,
    this.personalNotes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_id'] = Variable<String>(gameId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || personalRating != null) {
      map['personal_rating'] = Variable<int>(personalRating);
    }
    if (!nullToAbsent || personalNotes != null) {
      map['personal_notes'] = Variable<String>(personalNotes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LibraryEntriesCompanion toCompanion(bool nullToAbsent) {
    return LibraryEntriesCompanion(
      id: Value(id),
      gameId: Value(gameId),
      status: Value(status),
      personalRating:
          personalRating == null && nullToAbsent
              ? const Value.absent()
              : Value(personalRating),
      personalNotes:
          personalNotes == null && nullToAbsent
              ? const Value.absent()
              : Value(personalNotes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory LibraryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryEntry(
      id: serializer.fromJson<String>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      status: serializer.fromJson<String>(json['status']),
      personalRating: serializer.fromJson<int?>(json['personalRating']),
      personalNotes: serializer.fromJson<String?>(json['personalNotes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameId': serializer.toJson<String>(gameId),
      'status': serializer.toJson<String>(status),
      'personalRating': serializer.toJson<int?>(personalRating),
      'personalNotes': serializer.toJson<String?>(personalNotes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LibraryEntry copyWith({
    String? id,
    String? gameId,
    String? status,
    Value<int?> personalRating = const Value.absent(),
    Value<String?> personalNotes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LibraryEntry(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    status: status ?? this.status,
    personalRating:
        personalRating.present ? personalRating.value : this.personalRating,
    personalNotes:
        personalNotes.present ? personalNotes.value : this.personalNotes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LibraryEntry copyWithCompanion(LibraryEntriesCompanion data) {
    return LibraryEntry(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      status: data.status.present ? data.status.value : this.status,
      personalRating:
          data.personalRating.present
              ? data.personalRating.value
              : this.personalRating,
      personalNotes:
          data.personalNotes.present
              ? data.personalNotes.value
              : this.personalNotes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntry(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('status: $status, ')
          ..write('personalRating: $personalRating, ')
          ..write('personalNotes: $personalNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    status,
    personalRating,
    personalNotes,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryEntry &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.status == this.status &&
          other.personalRating == this.personalRating &&
          other.personalNotes == this.personalNotes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LibraryEntriesCompanion extends UpdateCompanion<LibraryEntry> {
  final Value<String> id;
  final Value<String> gameId;
  final Value<String> status;
  final Value<int?> personalRating;
  final Value<String?> personalNotes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LibraryEntriesCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.status = const Value.absent(),
    this.personalRating = const Value.absent(),
    this.personalNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryEntriesCompanion.insert({
    required String id,
    required String gameId,
    required String status,
    this.personalRating = const Value.absent(),
    this.personalNotes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameId = Value(gameId),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LibraryEntry> custom({
    Expression<String>? id,
    Expression<String>? gameId,
    Expression<String>? status,
    Expression<int>? personalRating,
    Expression<String>? personalNotes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (status != null) 'status': status,
      if (personalRating != null) 'personal_rating': personalRating,
      if (personalNotes != null) 'personal_notes': personalNotes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? gameId,
    Value<String>? status,
    Value<int?>? personalRating,
    Value<String?>? personalNotes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LibraryEntriesCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      status: status ?? this.status,
      personalRating: personalRating ?? this.personalRating,
      personalNotes: personalNotes ?? this.personalNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (personalRating.present) {
      map['personal_rating'] = Variable<int>(personalRating.value);
    }
    if (personalNotes.present) {
      map['personal_notes'] = Variable<String>(personalNotes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('status: $status, ')
          ..write('personalRating: $personalRating, ')
          ..write('personalNotes: $personalNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlatformsTable extends Platforms
    with TableInfo<$PlatformsTable, Platform> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlatformsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    shortName,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'platforms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Platform> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Platform map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Platform(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PlatformsTable createAlias(String alias) {
    return $PlatformsTable(attachedDatabase, alias);
  }
}

class Platform extends DataClass implements Insertable<Platform> {
  final String id;
  final String name;
  final String? shortName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Platform({
    required this.id,
    required this.name,
    this.shortName,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || shortName != null) {
      map['short_name'] = Variable<String>(shortName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PlatformsCompanion toCompanion(bool nullToAbsent) {
    return PlatformsCompanion(
      id: Value(id),
      name: Value(name),
      shortName:
          shortName == null && nullToAbsent
              ? const Value.absent()
              : Value(shortName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory Platform.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Platform(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      shortName: serializer.fromJson<String?>(json['shortName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'shortName': serializer.toJson<String?>(shortName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Platform copyWith({
    String? id,
    String? name,
    Value<String?> shortName = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Platform(
    id: id ?? this.id,
    name: name ?? this.name,
    shortName: shortName.present ? shortName.value : this.shortName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Platform copyWithCompanion(PlatformsCompanion data) {
    return Platform(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Platform(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, shortName, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Platform &&
          other.id == this.id &&
          other.name == this.name &&
          other.shortName == this.shortName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PlatformsCompanion extends UpdateCompanion<Platform> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> shortName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PlatformsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlatformsCompanion.insert({
    required String id,
    required String name,
    this.shortName = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Platform> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? shortName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlatformsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? shortName,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PlatformsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlatformsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryEntryPlatformsTable extends LibraryEntryPlatforms
    with TableInfo<$LibraryEntryPlatformsTable, LibraryEntryPlatform> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryEntryPlatformsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _libraryEntryIdMeta = const VerificationMeta(
    'libraryEntryId',
  );
  @override
  late final GeneratedColumn<String> libraryEntryId = GeneratedColumn<String>(
    'library_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_entries (id)',
    ),
  );
  static const VerificationMeta _platformIdMeta = const VerificationMeta(
    'platformId',
  );
  @override
  late final GeneratedColumn<String> platformId = GeneratedColumn<String>(
    'platform_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES platforms (id)',
    ),
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    libraryEntryId,
    platformId,
    isPrimary,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_entry_platforms';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryEntryPlatform> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('library_entry_id')) {
      context.handle(
        _libraryEntryIdMeta,
        libraryEntryId.isAcceptableOrUnknown(
          data['library_entry_id']!,
          _libraryEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_libraryEntryIdMeta);
    }
    if (data.containsKey('platform_id')) {
      context.handle(
        _platformIdMeta,
        platformId.isAcceptableOrUnknown(data['platform_id']!, _platformIdMeta),
      );
    } else if (isInserting) {
      context.missing(_platformIdMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryEntryPlatform map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryEntryPlatform(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      libraryEntryId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}library_entry_id'],
          )!,
      platformId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}platform_id'],
          )!,
      isPrimary:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_primary'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LibraryEntryPlatformsTable createAlias(String alias) {
    return $LibraryEntryPlatformsTable(attachedDatabase, alias);
  }
}

class LibraryEntryPlatform extends DataClass
    implements Insertable<LibraryEntryPlatform> {
  final String id;
  final String libraryEntryId;
  final String platformId;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const LibraryEntryPlatform({
    required this.id,
    required this.libraryEntryId,
    required this.platformId,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['library_entry_id'] = Variable<String>(libraryEntryId);
    map['platform_id'] = Variable<String>(platformId);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LibraryEntryPlatformsCompanion toCompanion(bool nullToAbsent) {
    return LibraryEntryPlatformsCompanion(
      id: Value(id),
      libraryEntryId: Value(libraryEntryId),
      platformId: Value(platformId),
      isPrimary: Value(isPrimary),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory LibraryEntryPlatform.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryEntryPlatform(
      id: serializer.fromJson<String>(json['id']),
      libraryEntryId: serializer.fromJson<String>(json['libraryEntryId']),
      platformId: serializer.fromJson<String>(json['platformId']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'libraryEntryId': serializer.toJson<String>(libraryEntryId),
      'platformId': serializer.toJson<String>(platformId),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LibraryEntryPlatform copyWith({
    String? id,
    String? libraryEntryId,
    String? platformId,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LibraryEntryPlatform(
    id: id ?? this.id,
    libraryEntryId: libraryEntryId ?? this.libraryEntryId,
    platformId: platformId ?? this.platformId,
    isPrimary: isPrimary ?? this.isPrimary,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LibraryEntryPlatform copyWithCompanion(LibraryEntryPlatformsCompanion data) {
    return LibraryEntryPlatform(
      id: data.id.present ? data.id.value : this.id,
      libraryEntryId:
          data.libraryEntryId.present
              ? data.libraryEntryId.value
              : this.libraryEntryId,
      platformId:
          data.platformId.present ? data.platformId.value : this.platformId,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntryPlatform(')
          ..write('id: $id, ')
          ..write('libraryEntryId: $libraryEntryId, ')
          ..write('platformId: $platformId, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    libraryEntryId,
    platformId,
    isPrimary,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryEntryPlatform &&
          other.id == this.id &&
          other.libraryEntryId == this.libraryEntryId &&
          other.platformId == this.platformId &&
          other.isPrimary == this.isPrimary &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LibraryEntryPlatformsCompanion
    extends UpdateCompanion<LibraryEntryPlatform> {
  final Value<String> id;
  final Value<String> libraryEntryId;
  final Value<String> platformId;
  final Value<bool> isPrimary;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LibraryEntryPlatformsCompanion({
    this.id = const Value.absent(),
    this.libraryEntryId = const Value.absent(),
    this.platformId = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryEntryPlatformsCompanion.insert({
    required String id,
    required String libraryEntryId,
    required String platformId,
    this.isPrimary = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       libraryEntryId = Value(libraryEntryId),
       platformId = Value(platformId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LibraryEntryPlatform> custom({
    Expression<String>? id,
    Expression<String>? libraryEntryId,
    Expression<String>? platformId,
    Expression<bool>? isPrimary,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (libraryEntryId != null) 'library_entry_id': libraryEntryId,
      if (platformId != null) 'platform_id': platformId,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryEntryPlatformsCompanion copyWith({
    Value<String>? id,
    Value<String>? libraryEntryId,
    Value<String>? platformId,
    Value<bool>? isPrimary,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LibraryEntryPlatformsCompanion(
      id: id ?? this.id,
      libraryEntryId: libraryEntryId ?? this.libraryEntryId,
      platformId: platformId ?? this.platformId,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (libraryEntryId.present) {
      map['library_entry_id'] = Variable<String>(libraryEntryId.value);
    }
    if (platformId.present) {
      map['platform_id'] = Variable<String>(platformId.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntryPlatformsCompanion(')
          ..write('id: $id, ')
          ..write('libraryEntryId: $libraryEntryId, ')
          ..write('platformId: $platformId, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GenresTable extends Genres with TableInfo<$GenresTable, Genre> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GenresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'genres';
  @override
  VerificationContext validateIntegrity(
    Insertable<Genre> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Genre map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Genre(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $GenresTable createAlias(String alias) {
    return $GenresTable(attachedDatabase, alias);
  }
}

class Genre extends DataClass implements Insertable<Genre> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Genre({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  GenresCompanion toCompanion(bool nullToAbsent) {
    return GenresCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory Genre.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Genre(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Genre copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Genre(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Genre copyWithCompanion(GenresCompanion data) {
    return Genre(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Genre(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Genre &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class GenresCompanion extends UpdateCompanion<Genre> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const GenresCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GenresCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Genre> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GenresCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return GenresCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GenresCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameGenresTable extends GameGenres
    with TableInfo<$GameGenresTable, GameGenre> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameGenresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _genreIdMeta = const VerificationMeta(
    'genreId',
  );
  @override
  late final GeneratedColumn<String> genreId = GeneratedColumn<String>(
    'genre_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES genres (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    genreId,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_genres';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameGenre> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('genre_id')) {
      context.handle(
        _genreIdMeta,
        genreId.isAcceptableOrUnknown(data['genre_id']!, _genreIdMeta),
      );
    } else if (isInserting) {
      context.missing(_genreIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameGenre map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameGenre(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      gameId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}game_id'],
          )!,
      genreId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}genre_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $GameGenresTable createAlias(String alias) {
    return $GameGenresTable(attachedDatabase, alias);
  }
}

class GameGenre extends DataClass implements Insertable<GameGenre> {
  final String id;
  final String gameId;
  final String genreId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const GameGenre({
    required this.id,
    required this.gameId,
    required this.genreId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_id'] = Variable<String>(gameId);
    map['genre_id'] = Variable<String>(genreId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  GameGenresCompanion toCompanion(bool nullToAbsent) {
    return GameGenresCompanion(
      id: Value(id),
      gameId: Value(gameId),
      genreId: Value(genreId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory GameGenre.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameGenre(
      id: serializer.fromJson<String>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      genreId: serializer.fromJson<String>(json['genreId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameId': serializer.toJson<String>(gameId),
      'genreId': serializer.toJson<String>(genreId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  GameGenre copyWith({
    String? id,
    String? gameId,
    String? genreId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => GameGenre(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    genreId: genreId ?? this.genreId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  GameGenre copyWithCompanion(GameGenresCompanion data) {
    return GameGenre(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      genreId: data.genreId.present ? data.genreId.value : this.genreId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameGenre(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('genreId: $genreId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, gameId, genreId, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameGenre &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.genreId == this.genreId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class GameGenresCompanion extends UpdateCompanion<GameGenre> {
  final Value<String> id;
  final Value<String> gameId;
  final Value<String> genreId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const GameGenresCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.genreId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameGenresCompanion.insert({
    required String id,
    required String gameId,
    required String genreId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameId = Value(gameId),
       genreId = Value(genreId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GameGenre> custom({
    Expression<String>? id,
    Expression<String>? gameId,
    Expression<String>? genreId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (genreId != null) 'genre_id': genreId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameGenresCompanion copyWith({
    Value<String>? id,
    Value<String>? gameId,
    Value<String>? genreId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return GameGenresCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      genreId: genreId ?? this.genreId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (genreId.present) {
      map['genre_id'] = Variable<String>(genreId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameGenresCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('genreId: $genreId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaythroughsTable extends Playthroughs
    with TableInfo<$PlaythroughsTable, Playthrough> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaythroughsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _libraryEntryIdMeta = const VerificationMeta(
    'libraryEntryId',
  );
  @override
  late final GeneratedColumn<String> libraryEntryId = GeneratedColumn<String>(
    'library_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_entries (id)',
    ),
  );
  static const VerificationMeta _platformIdMeta = const VerificationMeta(
    'platformId',
  );
  @override
  late final GeneratedColumn<String> platformId = GeneratedColumn<String>(
    'platform_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES platforms (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hoursPlayedMeta = const VerificationMeta(
    'hoursPlayed',
  );
  @override
  late final GeneratedColumn<double> hoursPlayed = GeneratedColumn<double>(
    'hours_played',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    libraryEntryId,
    platformId,
    status,
    startedAt,
    completedAt,
    hoursPlayed,
    rating,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playthroughs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Playthrough> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('library_entry_id')) {
      context.handle(
        _libraryEntryIdMeta,
        libraryEntryId.isAcceptableOrUnknown(
          data['library_entry_id']!,
          _libraryEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_libraryEntryIdMeta);
    }
    if (data.containsKey('platform_id')) {
      context.handle(
        _platformIdMeta,
        platformId.isAcceptableOrUnknown(data['platform_id']!, _platformIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('hours_played')) {
      context.handle(
        _hoursPlayedMeta,
        hoursPlayed.isAcceptableOrUnknown(
          data['hours_played']!,
          _hoursPlayedMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playthrough map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playthrough(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      libraryEntryId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}library_entry_id'],
          )!,
      platformId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform_id'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      hoursPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hours_played'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PlaythroughsTable createAlias(String alias) {
    return $PlaythroughsTable(attachedDatabase, alias);
  }
}

class Playthrough extends DataClass implements Insertable<Playthrough> {
  final String id;
  final String libraryEntryId;
  final String? platformId;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? hoursPlayed;
  final int? rating;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Playthrough({
    required this.id,
    required this.libraryEntryId,
    this.platformId,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.hoursPlayed,
    this.rating,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['library_entry_id'] = Variable<String>(libraryEntryId);
    if (!nullToAbsent || platformId != null) {
      map['platform_id'] = Variable<String>(platformId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || hoursPlayed != null) {
      map['hours_played'] = Variable<double>(hoursPlayed);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PlaythroughsCompanion toCompanion(bool nullToAbsent) {
    return PlaythroughsCompanion(
      id: Value(id),
      libraryEntryId: Value(libraryEntryId),
      platformId:
          platformId == null && nullToAbsent
              ? const Value.absent()
              : Value(platformId),
      status: Value(status),
      startedAt:
          startedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(startedAt),
      completedAt:
          completedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(completedAt),
      hoursPlayed:
          hoursPlayed == null && nullToAbsent
              ? const Value.absent()
              : Value(hoursPlayed),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory Playthrough.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playthrough(
      id: serializer.fromJson<String>(json['id']),
      libraryEntryId: serializer.fromJson<String>(json['libraryEntryId']),
      platformId: serializer.fromJson<String?>(json['platformId']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      hoursPlayed: serializer.fromJson<double?>(json['hoursPlayed']),
      rating: serializer.fromJson<int?>(json['rating']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'libraryEntryId': serializer.toJson<String>(libraryEntryId),
      'platformId': serializer.toJson<String?>(platformId),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'hoursPlayed': serializer.toJson<double?>(hoursPlayed),
      'rating': serializer.toJson<int?>(rating),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Playthrough copyWith({
    String? id,
    String? libraryEntryId,
    Value<String?> platformId = const Value.absent(),
    String? status,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<double?> hoursPlayed = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Playthrough(
    id: id ?? this.id,
    libraryEntryId: libraryEntryId ?? this.libraryEntryId,
    platformId: platformId.present ? platformId.value : this.platformId,
    status: status ?? this.status,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    hoursPlayed: hoursPlayed.present ? hoursPlayed.value : this.hoursPlayed,
    rating: rating.present ? rating.value : this.rating,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Playthrough copyWithCompanion(PlaythroughsCompanion data) {
    return Playthrough(
      id: data.id.present ? data.id.value : this.id,
      libraryEntryId:
          data.libraryEntryId.present
              ? data.libraryEntryId.value
              : this.libraryEntryId,
      platformId:
          data.platformId.present ? data.platformId.value : this.platformId,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      hoursPlayed:
          data.hoursPlayed.present ? data.hoursPlayed.value : this.hoursPlayed,
      rating: data.rating.present ? data.rating.value : this.rating,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playthrough(')
          ..write('id: $id, ')
          ..write('libraryEntryId: $libraryEntryId, ')
          ..write('platformId: $platformId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('hoursPlayed: $hoursPlayed, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    libraryEntryId,
    platformId,
    status,
    startedAt,
    completedAt,
    hoursPlayed,
    rating,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playthrough &&
          other.id == this.id &&
          other.libraryEntryId == this.libraryEntryId &&
          other.platformId == this.platformId &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.hoursPlayed == this.hoursPlayed &&
          other.rating == this.rating &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PlaythroughsCompanion extends UpdateCompanion<Playthrough> {
  final Value<String> id;
  final Value<String> libraryEntryId;
  final Value<String?> platformId;
  final Value<String> status;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<double?> hoursPlayed;
  final Value<int?> rating;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PlaythroughsCompanion({
    this.id = const Value.absent(),
    this.libraryEntryId = const Value.absent(),
    this.platformId = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.hoursPlayed = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaythroughsCompanion.insert({
    required String id,
    required String libraryEntryId,
    this.platformId = const Value.absent(),
    required String status,
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.hoursPlayed = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       libraryEntryId = Value(libraryEntryId),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Playthrough> custom({
    Expression<String>? id,
    Expression<String>? libraryEntryId,
    Expression<String>? platformId,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<double>? hoursPlayed,
    Expression<int>? rating,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (libraryEntryId != null) 'library_entry_id': libraryEntryId,
      if (platformId != null) 'platform_id': platformId,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (hoursPlayed != null) 'hours_played': hoursPlayed,
      if (rating != null) 'rating': rating,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaythroughsCompanion copyWith({
    Value<String>? id,
    Value<String>? libraryEntryId,
    Value<String?>? platformId,
    Value<String>? status,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<double?>? hoursPlayed,
    Value<int?>? rating,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PlaythroughsCompanion(
      id: id ?? this.id,
      libraryEntryId: libraryEntryId ?? this.libraryEntryId,
      platformId: platformId ?? this.platformId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      hoursPlayed: hoursPlayed ?? this.hoursPlayed,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (libraryEntryId.present) {
      map['library_entry_id'] = Variable<String>(libraryEntryId.value);
    }
    if (platformId.present) {
      map['platform_id'] = Variable<String>(platformId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (hoursPlayed.present) {
      map['hours_played'] = Variable<double>(hoursPlayed.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaythroughsCompanion(')
          ..write('id: $id, ')
          ..write('libraryEntryId: $libraryEntryId, ')
          ..write('platformId: $platformId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('hoursPlayed: $hoursPlayed, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedViewsTable extends SavedViews
    with TableInfo<$SavedViewsTable, SavedView> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedViewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filterJsonMeta = const VerificationMeta(
    'filterJson',
  );
  @override
  late final GeneratedColumn<String> filterJson = GeneratedColumn<String>(
    'filter_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortJsonMeta = const VerificationMeta(
    'sortJson',
  );
  @override
  late final GeneratedColumn<String> sortJson = GeneratedColumn<String>(
    'sort_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _columnConfigJsonMeta = const VerificationMeta(
    'columnConfigJson',
  );
  @override
  late final GeneratedColumn<String> columnConfigJson = GeneratedColumn<String>(
    'column_config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    filterJson,
    sortJson,
    columnConfigJson,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_views';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedView> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('filter_json')) {
      context.handle(
        _filterJsonMeta,
        filterJson.isAcceptableOrUnknown(data['filter_json']!, _filterJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_filterJsonMeta);
    }
    if (data.containsKey('sort_json')) {
      context.handle(
        _sortJsonMeta,
        sortJson.isAcceptableOrUnknown(data['sort_json']!, _sortJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_sortJsonMeta);
    }
    if (data.containsKey('column_config_json')) {
      context.handle(
        _columnConfigJsonMeta,
        columnConfigJson.isAcceptableOrUnknown(
          data['column_config_json']!,
          _columnConfigJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_columnConfigJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedView map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedView(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      filterJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}filter_json'],
          )!,
      sortJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sort_json'],
          )!,
      columnConfigJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}column_config_json'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SavedViewsTable createAlias(String alias) {
    return $SavedViewsTable(attachedDatabase, alias);
  }
}

class SavedView extends DataClass implements Insertable<SavedView> {
  final String id;
  final String name;
  final String filterJson;
  final String sortJson;
  final String columnConfigJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const SavedView({
    required this.id,
    required this.name,
    required this.filterJson,
    required this.sortJson,
    required this.columnConfigJson,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['filter_json'] = Variable<String>(filterJson);
    map['sort_json'] = Variable<String>(sortJson);
    map['column_config_json'] = Variable<String>(columnConfigJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SavedViewsCompanion toCompanion(bool nullToAbsent) {
    return SavedViewsCompanion(
      id: Value(id),
      name: Value(name),
      filterJson: Value(filterJson),
      sortJson: Value(sortJson),
      columnConfigJson: Value(columnConfigJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory SavedView.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedView(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      filterJson: serializer.fromJson<String>(json['filterJson']),
      sortJson: serializer.fromJson<String>(json['sortJson']),
      columnConfigJson: serializer.fromJson<String>(json['columnConfigJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'filterJson': serializer.toJson<String>(filterJson),
      'sortJson': serializer.toJson<String>(sortJson),
      'columnConfigJson': serializer.toJson<String>(columnConfigJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  SavedView copyWith({
    String? id,
    String? name,
    String? filterJson,
    String? sortJson,
    String? columnConfigJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => SavedView(
    id: id ?? this.id,
    name: name ?? this.name,
    filterJson: filterJson ?? this.filterJson,
    sortJson: sortJson ?? this.sortJson,
    columnConfigJson: columnConfigJson ?? this.columnConfigJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SavedView copyWithCompanion(SavedViewsCompanion data) {
    return SavedView(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      filterJson:
          data.filterJson.present ? data.filterJson.value : this.filterJson,
      sortJson: data.sortJson.present ? data.sortJson.value : this.sortJson,
      columnConfigJson:
          data.columnConfigJson.present
              ? data.columnConfigJson.value
              : this.columnConfigJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedView(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('filterJson: $filterJson, ')
          ..write('sortJson: $sortJson, ')
          ..write('columnConfigJson: $columnConfigJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    filterJson,
    sortJson,
    columnConfigJson,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedView &&
          other.id == this.id &&
          other.name == this.name &&
          other.filterJson == this.filterJson &&
          other.sortJson == this.sortJson &&
          other.columnConfigJson == this.columnConfigJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class SavedViewsCompanion extends UpdateCompanion<SavedView> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> filterJson;
  final Value<String> sortJson;
  final Value<String> columnConfigJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const SavedViewsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.filterJson = const Value.absent(),
    this.sortJson = const Value.absent(),
    this.columnConfigJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedViewsCompanion.insert({
    required String id,
    required String name,
    required String filterJson,
    required String sortJson,
    required String columnConfigJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       filterJson = Value(filterJson),
       sortJson = Value(sortJson),
       columnConfigJson = Value(columnConfigJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SavedView> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? filterJson,
    Expression<String>? sortJson,
    Expression<String>? columnConfigJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (filterJson != null) 'filter_json': filterJson,
      if (sortJson != null) 'sort_json': sortJson,
      if (columnConfigJson != null) 'column_config_json': columnConfigJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedViewsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? filterJson,
    Value<String>? sortJson,
    Value<String>? columnConfigJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SavedViewsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      filterJson: filterJson ?? this.filterJson,
      sortJson: sortJson ?? this.sortJson,
      columnConfigJson: columnConfigJson ?? this.columnConfigJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (filterJson.present) {
      map['filter_json'] = Variable<String>(filterJson.value);
    }
    if (sortJson.present) {
      map['sort_json'] = Variable<String>(sortJson.value);
    }
    if (columnConfigJson.present) {
      map['column_config_json'] = Variable<String>(columnConfigJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedViewsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('filterJson: $filterJson, ')
          ..write('sortJson: $sortJson, ')
          ..write('columnConfigJson: $columnConfigJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExternalGameIdsTable extends ExternalGameIds
    with TableInfo<$ExternalGameIdsTable, ExternalGameId> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExternalGameIdsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalSlugMeta = const VerificationMeta(
    'externalSlug',
  );
  @override
  late final GeneratedColumn<String> externalSlug = GeneratedColumn<String>(
    'external_slug',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalUrlMeta = const VerificationMeta(
    'externalUrl',
  );
  @override
  late final GeneratedColumn<String> externalUrl = GeneratedColumn<String>(
    'external_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchedTitleMeta = const VerificationMeta(
    'matchedTitle',
  );
  @override
  late final GeneratedColumn<String> matchedTitle = GeneratedColumn<String>(
    'matched_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    provider,
    externalId,
    externalSlug,
    externalUrl,
    matchedTitle,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'external_game_ids';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExternalGameId> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('external_slug')) {
      context.handle(
        _externalSlugMeta,
        externalSlug.isAcceptableOrUnknown(
          data['external_slug']!,
          _externalSlugMeta,
        ),
      );
    }
    if (data.containsKey('external_url')) {
      context.handle(
        _externalUrlMeta,
        externalUrl.isAcceptableOrUnknown(
          data['external_url']!,
          _externalUrlMeta,
        ),
      );
    }
    if (data.containsKey('matched_title')) {
      context.handle(
        _matchedTitleMeta,
        matchedTitle.isAcceptableOrUnknown(
          data['matched_title']!,
          _matchedTitleMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExternalGameId map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExternalGameId(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      gameId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}game_id'],
          )!,
      provider:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}provider'],
          )!,
      externalId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}external_id'],
          )!,
      externalSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_slug'],
      ),
      externalUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_url'],
      ),
      matchedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matched_title'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ExternalGameIdsTable createAlias(String alias) {
    return $ExternalGameIdsTable(attachedDatabase, alias);
  }
}

class ExternalGameId extends DataClass implements Insertable<ExternalGameId> {
  final String id;
  final String gameId;
  final String provider;
  final String externalId;
  final String? externalSlug;
  final String? externalUrl;
  final String? matchedTitle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ExternalGameId({
    required this.id,
    required this.gameId,
    required this.provider,
    required this.externalId,
    this.externalSlug,
    this.externalUrl,
    this.matchedTitle,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_id'] = Variable<String>(gameId);
    map['provider'] = Variable<String>(provider);
    map['external_id'] = Variable<String>(externalId);
    if (!nullToAbsent || externalSlug != null) {
      map['external_slug'] = Variable<String>(externalSlug);
    }
    if (!nullToAbsent || externalUrl != null) {
      map['external_url'] = Variable<String>(externalUrl);
    }
    if (!nullToAbsent || matchedTitle != null) {
      map['matched_title'] = Variable<String>(matchedTitle);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ExternalGameIdsCompanion toCompanion(bool nullToAbsent) {
    return ExternalGameIdsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      provider: Value(provider),
      externalId: Value(externalId),
      externalSlug:
          externalSlug == null && nullToAbsent
              ? const Value.absent()
              : Value(externalSlug),
      externalUrl:
          externalUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(externalUrl),
      matchedTitle:
          matchedTitle == null && nullToAbsent
              ? const Value.absent()
              : Value(matchedTitle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory ExternalGameId.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExternalGameId(
      id: serializer.fromJson<String>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      provider: serializer.fromJson<String>(json['provider']),
      externalId: serializer.fromJson<String>(json['externalId']),
      externalSlug: serializer.fromJson<String?>(json['externalSlug']),
      externalUrl: serializer.fromJson<String?>(json['externalUrl']),
      matchedTitle: serializer.fromJson<String?>(json['matchedTitle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameId': serializer.toJson<String>(gameId),
      'provider': serializer.toJson<String>(provider),
      'externalId': serializer.toJson<String>(externalId),
      'externalSlug': serializer.toJson<String?>(externalSlug),
      'externalUrl': serializer.toJson<String?>(externalUrl),
      'matchedTitle': serializer.toJson<String?>(matchedTitle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ExternalGameId copyWith({
    String? id,
    String? gameId,
    String? provider,
    String? externalId,
    Value<String?> externalSlug = const Value.absent(),
    Value<String?> externalUrl = const Value.absent(),
    Value<String?> matchedTitle = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ExternalGameId(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    provider: provider ?? this.provider,
    externalId: externalId ?? this.externalId,
    externalSlug: externalSlug.present ? externalSlug.value : this.externalSlug,
    externalUrl: externalUrl.present ? externalUrl.value : this.externalUrl,
    matchedTitle: matchedTitle.present ? matchedTitle.value : this.matchedTitle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ExternalGameId copyWithCompanion(ExternalGameIdsCompanion data) {
    return ExternalGameId(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      provider: data.provider.present ? data.provider.value : this.provider,
      externalId:
          data.externalId.present ? data.externalId.value : this.externalId,
      externalSlug:
          data.externalSlug.present
              ? data.externalSlug.value
              : this.externalSlug,
      externalUrl:
          data.externalUrl.present ? data.externalUrl.value : this.externalUrl,
      matchedTitle:
          data.matchedTitle.present
              ? data.matchedTitle.value
              : this.matchedTitle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExternalGameId(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('provider: $provider, ')
          ..write('externalId: $externalId, ')
          ..write('externalSlug: $externalSlug, ')
          ..write('externalUrl: $externalUrl, ')
          ..write('matchedTitle: $matchedTitle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    provider,
    externalId,
    externalSlug,
    externalUrl,
    matchedTitle,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExternalGameId &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.provider == this.provider &&
          other.externalId == this.externalId &&
          other.externalSlug == this.externalSlug &&
          other.externalUrl == this.externalUrl &&
          other.matchedTitle == this.matchedTitle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ExternalGameIdsCompanion extends UpdateCompanion<ExternalGameId> {
  final Value<String> id;
  final Value<String> gameId;
  final Value<String> provider;
  final Value<String> externalId;
  final Value<String?> externalSlug;
  final Value<String?> externalUrl;
  final Value<String?> matchedTitle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ExternalGameIdsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.provider = const Value.absent(),
    this.externalId = const Value.absent(),
    this.externalSlug = const Value.absent(),
    this.externalUrl = const Value.absent(),
    this.matchedTitle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExternalGameIdsCompanion.insert({
    required String id,
    required String gameId,
    required String provider,
    required String externalId,
    this.externalSlug = const Value.absent(),
    this.externalUrl = const Value.absent(),
    this.matchedTitle = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameId = Value(gameId),
       provider = Value(provider),
       externalId = Value(externalId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExternalGameId> custom({
    Expression<String>? id,
    Expression<String>? gameId,
    Expression<String>? provider,
    Expression<String>? externalId,
    Expression<String>? externalSlug,
    Expression<String>? externalUrl,
    Expression<String>? matchedTitle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (provider != null) 'provider': provider,
      if (externalId != null) 'external_id': externalId,
      if (externalSlug != null) 'external_slug': externalSlug,
      if (externalUrl != null) 'external_url': externalUrl,
      if (matchedTitle != null) 'matched_title': matchedTitle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExternalGameIdsCompanion copyWith({
    Value<String>? id,
    Value<String>? gameId,
    Value<String>? provider,
    Value<String>? externalId,
    Value<String?>? externalSlug,
    Value<String?>? externalUrl,
    Value<String?>? matchedTitle,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ExternalGameIdsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      provider: provider ?? this.provider,
      externalId: externalId ?? this.externalId,
      externalSlug: externalSlug ?? this.externalSlug,
      externalUrl: externalUrl ?? this.externalUrl,
      matchedTitle: matchedTitle ?? this.matchedTitle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (externalSlug.present) {
      map['external_slug'] = Variable<String>(externalSlug.value);
    }
    if (externalUrl.present) {
      map['external_url'] = Variable<String>(externalUrl.value);
    }
    if (matchedTitle.present) {
      map['matched_title'] = Variable<String>(matchedTitle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExternalGameIdsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('provider: $provider, ')
          ..write('externalId: $externalId, ')
          ..write('externalSlug: $externalSlug, ')
          ..write('externalUrl: $externalUrl, ')
          ..write('matchedTitle: $matchedTitle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaAssetsTable extends MediaAssets
    with TableInfo<$MediaAssetsTable, MediaAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSelectedMeta = const VerificationMeta(
    'isSelected',
  );
  @override
  late final GeneratedColumn<bool> isSelected = GeneratedColumn<bool>(
    'is_selected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_selected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _attributionMeta = const VerificationMeta(
    'attribution',
  );
  @override
  late final GeneratedColumn<String> attribution = GeneratedColumn<String>(
    'attribution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    kind,
    source,
    provider,
    externalId,
    remoteUrl,
    localPath,
    fileName,
    mimeType,
    width,
    height,
    hash,
    isSelected,
    attribution,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    }
    if (data.containsKey('is_selected')) {
      context.handle(
        _isSelectedMeta,
        isSelected.isAcceptableOrUnknown(data['is_selected']!, _isSelectedMeta),
      );
    }
    if (data.containsKey('attribution')) {
      context.handle(
        _attributionMeta,
        attribution.isAcceptableOrUnknown(
          data['attribution']!,
          _attributionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaAsset(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      gameId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}game_id'],
          )!,
      kind:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}kind'],
          )!,
      source:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}source'],
          )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      ),
      localPath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}local_path'],
          )!,
      fileName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_name'],
          )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      ),
      isSelected:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_selected'],
          )!,
      attribution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attribution'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $MediaAssetsTable createAlias(String alias) {
    return $MediaAssetsTable(attachedDatabase, alias);
  }
}

class MediaAsset extends DataClass implements Insertable<MediaAsset> {
  final String id;
  final String gameId;
  final String kind;
  final String source;
  final String? provider;
  final String? externalId;
  final String? remoteUrl;
  final String localPath;
  final String fileName;
  final String? mimeType;
  final int? width;
  final int? height;
  final String? hash;
  final bool isSelected;
  final String? attribution;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const MediaAsset({
    required this.id,
    required this.gameId,
    required this.kind,
    required this.source,
    this.provider,
    this.externalId,
    this.remoteUrl,
    required this.localPath,
    required this.fileName,
    this.mimeType,
    this.width,
    this.height,
    this.hash,
    required this.isSelected,
    this.attribution,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_id'] = Variable<String>(gameId);
    map['kind'] = Variable<String>(kind);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    map['local_path'] = Variable<String>(localPath);
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || hash != null) {
      map['hash'] = Variable<String>(hash);
    }
    map['is_selected'] = Variable<bool>(isSelected);
    if (!nullToAbsent || attribution != null) {
      map['attribution'] = Variable<String>(attribution);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  MediaAssetsCompanion toCompanion(bool nullToAbsent) {
    return MediaAssetsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      kind: Value(kind),
      source: Value(source),
      provider:
          provider == null && nullToAbsent
              ? const Value.absent()
              : Value(provider),
      externalId:
          externalId == null && nullToAbsent
              ? const Value.absent()
              : Value(externalId),
      remoteUrl:
          remoteUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(remoteUrl),
      localPath: Value(localPath),
      fileName: Value(fileName),
      mimeType:
          mimeType == null && nullToAbsent
              ? const Value.absent()
              : Value(mimeType),
      width:
          width == null && nullToAbsent ? const Value.absent() : Value(width),
      height:
          height == null && nullToAbsent ? const Value.absent() : Value(height),
      hash: hash == null && nullToAbsent ? const Value.absent() : Value(hash),
      isSelected: Value(isSelected),
      attribution:
          attribution == null && nullToAbsent
              ? const Value.absent()
              : Value(attribution),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory MediaAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaAsset(
      id: serializer.fromJson<String>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      kind: serializer.fromJson<String>(json['kind']),
      source: serializer.fromJson<String>(json['source']),
      provider: serializer.fromJson<String?>(json['provider']),
      externalId: serializer.fromJson<String?>(json['externalId']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      localPath: serializer.fromJson<String>(json['localPath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      hash: serializer.fromJson<String?>(json['hash']),
      isSelected: serializer.fromJson<bool>(json['isSelected']),
      attribution: serializer.fromJson<String?>(json['attribution']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameId': serializer.toJson<String>(gameId),
      'kind': serializer.toJson<String>(kind),
      'source': serializer.toJson<String>(source),
      'provider': serializer.toJson<String?>(provider),
      'externalId': serializer.toJson<String?>(externalId),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'localPath': serializer.toJson<String>(localPath),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String?>(mimeType),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'hash': serializer.toJson<String?>(hash),
      'isSelected': serializer.toJson<bool>(isSelected),
      'attribution': serializer.toJson<String?>(attribution),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  MediaAsset copyWith({
    String? id,
    String? gameId,
    String? kind,
    String? source,
    Value<String?> provider = const Value.absent(),
    Value<String?> externalId = const Value.absent(),
    Value<String?> remoteUrl = const Value.absent(),
    String? localPath,
    String? fileName,
    Value<String?> mimeType = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<String?> hash = const Value.absent(),
    bool? isSelected,
    Value<String?> attribution = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => MediaAsset(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    kind: kind ?? this.kind,
    source: source ?? this.source,
    provider: provider.present ? provider.value : this.provider,
    externalId: externalId.present ? externalId.value : this.externalId,
    remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
    localPath: localPath ?? this.localPath,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    hash: hash.present ? hash.value : this.hash,
    isSelected: isSelected ?? this.isSelected,
    attribution: attribution.present ? attribution.value : this.attribution,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  MediaAsset copyWithCompanion(MediaAssetsCompanion data) {
    return MediaAsset(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      kind: data.kind.present ? data.kind.value : this.kind,
      source: data.source.present ? data.source.value : this.source,
      provider: data.provider.present ? data.provider.value : this.provider,
      externalId:
          data.externalId.present ? data.externalId.value : this.externalId,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      hash: data.hash.present ? data.hash.value : this.hash,
      isSelected:
          data.isSelected.present ? data.isSelected.value : this.isSelected,
      attribution:
          data.attribution.present ? data.attribution.value : this.attribution,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaAsset(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('provider: $provider, ')
          ..write('externalId: $externalId, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('localPath: $localPath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('hash: $hash, ')
          ..write('isSelected: $isSelected, ')
          ..write('attribution: $attribution, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    kind,
    source,
    provider,
    externalId,
    remoteUrl,
    localPath,
    fileName,
    mimeType,
    width,
    height,
    hash,
    isSelected,
    attribution,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaAsset &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.kind == this.kind &&
          other.source == this.source &&
          other.provider == this.provider &&
          other.externalId == this.externalId &&
          other.remoteUrl == this.remoteUrl &&
          other.localPath == this.localPath &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.width == this.width &&
          other.height == this.height &&
          other.hash == this.hash &&
          other.isSelected == this.isSelected &&
          other.attribution == this.attribution &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class MediaAssetsCompanion extends UpdateCompanion<MediaAsset> {
  final Value<String> id;
  final Value<String> gameId;
  final Value<String> kind;
  final Value<String> source;
  final Value<String?> provider;
  final Value<String?> externalId;
  final Value<String?> remoteUrl;
  final Value<String> localPath;
  final Value<String> fileName;
  final Value<String?> mimeType;
  final Value<int?> width;
  final Value<int?> height;
  final Value<String?> hash;
  final Value<bool> isSelected;
  final Value<String?> attribution;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const MediaAssetsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.kind = const Value.absent(),
    this.source = const Value.absent(),
    this.provider = const Value.absent(),
    this.externalId = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.hash = const Value.absent(),
    this.isSelected = const Value.absent(),
    this.attribution = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaAssetsCompanion.insert({
    required String id,
    required String gameId,
    required String kind,
    required String source,
    this.provider = const Value.absent(),
    this.externalId = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    required String localPath,
    required String fileName,
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.hash = const Value.absent(),
    this.isSelected = const Value.absent(),
    this.attribution = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameId = Value(gameId),
       kind = Value(kind),
       source = Value(source),
       localPath = Value(localPath),
       fileName = Value(fileName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MediaAsset> custom({
    Expression<String>? id,
    Expression<String>? gameId,
    Expression<String>? kind,
    Expression<String>? source,
    Expression<String>? provider,
    Expression<String>? externalId,
    Expression<String>? remoteUrl,
    Expression<String>? localPath,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? hash,
    Expression<bool>? isSelected,
    Expression<String>? attribution,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (kind != null) 'kind': kind,
      if (source != null) 'source': source,
      if (provider != null) 'provider': provider,
      if (externalId != null) 'external_id': externalId,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (localPath != null) 'local_path': localPath,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (hash != null) 'hash': hash,
      if (isSelected != null) 'is_selected': isSelected,
      if (attribution != null) 'attribution': attribution,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaAssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? gameId,
    Value<String>? kind,
    Value<String>? source,
    Value<String?>? provider,
    Value<String?>? externalId,
    Value<String?>? remoteUrl,
    Value<String>? localPath,
    Value<String>? fileName,
    Value<String?>? mimeType,
    Value<int?>? width,
    Value<int?>? height,
    Value<String?>? hash,
    Value<bool>? isSelected,
    Value<String?>? attribution,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return MediaAssetsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      kind: kind ?? this.kind,
      source: source ?? this.source,
      provider: provider ?? this.provider,
      externalId: externalId ?? this.externalId,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      localPath: localPath ?? this.localPath,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      hash: hash ?? this.hash,
      isSelected: isSelected ?? this.isSelected,
      attribution: attribution ?? this.attribution,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (isSelected.present) {
      map['is_selected'] = Variable<bool>(isSelected.value);
    }
    if (attribution.present) {
      map['attribution'] = Variable<String>(attribution.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaAssetsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('provider: $provider, ')
          ..write('externalId: $externalId, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('localPath: $localPath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('hash: $hash, ')
          ..write('isSelected: $isSelected, ')
          ..write('attribution: $attribution, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncGroupsTable extends SyncGroups
    with TableInfo<$SyncGroupsTable, SyncGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protocolVersionMeta = const VerificationMeta(
    'protocolVersion',
  );
  @override
  late final GeneratedColumn<int> protocolVersion = GeneratedColumn<int>(
    'protocol_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyIdMeta = const VerificationMeta('keyId');
  @override
  late final GeneratedColumn<String> keyId = GeneratedColumn<String>(
    'key_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyRotatedAtMeta = const VerificationMeta(
    'keyRotatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> keyRotatedAt = GeneratedColumn<DateTime>(
    'key_rotated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    protocolVersion,
    keyId,
    status,
    createdAt,
    updatedAt,
    keyRotatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('protocol_version')) {
      context.handle(
        _protocolVersionMeta,
        protocolVersion.isAcceptableOrUnknown(
          data['protocol_version']!,
          _protocolVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_protocolVersionMeta);
    }
    if (data.containsKey('key_id')) {
      context.handle(
        _keyIdMeta,
        keyId.isAcceptableOrUnknown(data['key_id']!, _keyIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('key_rotated_at')) {
      context.handle(
        _keyRotatedAtMeta,
        keyRotatedAt.isAcceptableOrUnknown(
          data['key_rotated_at']!,
          _keyRotatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncGroup(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      displayName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}display_name'],
          )!,
      protocolVersion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}protocol_version'],
          )!,
      keyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_id'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      keyRotatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}key_rotated_at'],
      ),
    );
  }

  @override
  $SyncGroupsTable createAlias(String alias) {
    return $SyncGroupsTable(attachedDatabase, alias);
  }
}

class SyncGroup extends DataClass implements Insertable<SyncGroup> {
  final String id;
  final String displayName;
  final int protocolVersion;
  final String? keyId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? keyRotatedAt;
  const SyncGroup({
    required this.id,
    required this.displayName,
    required this.protocolVersion,
    this.keyId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.keyRotatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['protocol_version'] = Variable<int>(protocolVersion);
    if (!nullToAbsent || keyId != null) {
      map['key_id'] = Variable<String>(keyId);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || keyRotatedAt != null) {
      map['key_rotated_at'] = Variable<DateTime>(keyRotatedAt);
    }
    return map;
  }

  SyncGroupsCompanion toCompanion(bool nullToAbsent) {
    return SyncGroupsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      protocolVersion: Value(protocolVersion),
      keyId:
          keyId == null && nullToAbsent ? const Value.absent() : Value(keyId),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      keyRotatedAt:
          keyRotatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(keyRotatedAt),
    );
  }

  factory SyncGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncGroup(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      protocolVersion: serializer.fromJson<int>(json['protocolVersion']),
      keyId: serializer.fromJson<String?>(json['keyId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      keyRotatedAt: serializer.fromJson<DateTime?>(json['keyRotatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'protocolVersion': serializer.toJson<int>(protocolVersion),
      'keyId': serializer.toJson<String?>(keyId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'keyRotatedAt': serializer.toJson<DateTime?>(keyRotatedAt),
    };
  }

  SyncGroup copyWith({
    String? id,
    String? displayName,
    int? protocolVersion,
    Value<String?> keyId = const Value.absent(),
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> keyRotatedAt = const Value.absent(),
  }) => SyncGroup(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    protocolVersion: protocolVersion ?? this.protocolVersion,
    keyId: keyId.present ? keyId.value : this.keyId,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    keyRotatedAt: keyRotatedAt.present ? keyRotatedAt.value : this.keyRotatedAt,
  );
  SyncGroup copyWithCompanion(SyncGroupsCompanion data) {
    return SyncGroup(
      id: data.id.present ? data.id.value : this.id,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      protocolVersion:
          data.protocolVersion.present
              ? data.protocolVersion.value
              : this.protocolVersion,
      keyId: data.keyId.present ? data.keyId.value : this.keyId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      keyRotatedAt:
          data.keyRotatedAt.present
              ? data.keyRotatedAt.value
              : this.keyRotatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncGroup(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('keyId: $keyId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('keyRotatedAt: $keyRotatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    protocolVersion,
    keyId,
    status,
    createdAt,
    updatedAt,
    keyRotatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncGroup &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.protocolVersion == this.protocolVersion &&
          other.keyId == this.keyId &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.keyRotatedAt == this.keyRotatedAt);
}

class SyncGroupsCompanion extends UpdateCompanion<SyncGroup> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<int> protocolVersion;
  final Value<String?> keyId;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> keyRotatedAt;
  final Value<int> rowid;
  const SyncGroupsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.protocolVersion = const Value.absent(),
    this.keyId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.keyRotatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncGroupsCompanion.insert({
    required String id,
    required String displayName,
    required int protocolVersion,
    this.keyId = const Value.absent(),
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.keyRotatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       protocolVersion = Value(protocolVersion),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SyncGroup> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<int>? protocolVersion,
    Expression<String>? keyId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? keyRotatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (protocolVersion != null) 'protocol_version': protocolVersion,
      if (keyId != null) 'key_id': keyId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (keyRotatedAt != null) 'key_rotated_at': keyRotatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<int>? protocolVersion,
    Value<String?>? keyId,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? keyRotatedAt,
    Value<int>? rowid,
  }) {
    return SyncGroupsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      keyId: keyId ?? this.keyId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      keyRotatedAt: keyRotatedAt ?? this.keyRotatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (protocolVersion.present) {
      map['protocol_version'] = Variable<int>(protocolVersion.value);
    }
    if (keyId.present) {
      map['key_id'] = Variable<String>(keyId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (keyRotatedAt.present) {
      map['key_rotated_at'] = Variable<DateTime>(keyRotatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncGroupsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('keyId: $keyId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('keyRotatedAt: $keyRotatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncDevicesTable extends SyncDevices
    with TableInfo<$SyncDevicesTable, SyncDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncGroupIdMeta = const VerificationMeta(
    'syncGroupId',
  );
  @override
  late final GeneratedColumn<String> syncGroupId = GeneratedColumn<String>(
    'sync_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLocalMeta = const VerificationMeta(
    'isLocal',
  );
  @override
  late final GeneratedColumn<bool> isLocal = GeneratedColumn<bool>(
    'is_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairedAtMeta = const VerificationMeta(
    'pairedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pairedAt = GeneratedColumn<DateTime>(
    'paired_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revokedAtMeta = const VerificationMeta(
    'revokedAt',
  );
  @override
  late final GeneratedColumn<DateTime> revokedAt = GeneratedColumn<DateTime>(
    'revoked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncGroupId,
    displayName,
    platform,
    isLocal,
    publicKey,
    fingerprint,
    status,
    createdAt,
    pairedAt,
    lastSeenAt,
    lastSyncAt,
    revokedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sync_group_id')) {
      context.handle(
        _syncGroupIdMeta,
        syncGroupId.isAcceptableOrUnknown(
          data['sync_group_id']!,
          _syncGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('is_local')) {
      context.handle(
        _isLocalMeta,
        isLocal.isAcceptableOrUnknown(data['is_local']!, _isLocalMeta),
      );
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('paired_at')) {
      context.handle(
        _pairedAtMeta,
        pairedAt.isAcceptableOrUnknown(data['paired_at']!, _pairedAtMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('revoked_at')) {
      context.handle(
        _revokedAtMeta,
        revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncDevice(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      syncGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_group_id'],
      ),
      displayName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}display_name'],
          )!,
      platform:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}platform'],
          )!,
      isLocal:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_local'],
          )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      ),
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      pairedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paired_at'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      revokedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}revoked_at'],
      ),
    );
  }

  @override
  $SyncDevicesTable createAlias(String alias) {
    return $SyncDevicesTable(attachedDatabase, alias);
  }
}

class SyncDevice extends DataClass implements Insertable<SyncDevice> {
  final String id;
  final String? syncGroupId;
  final String displayName;
  final String platform;
  final bool isLocal;
  final String? publicKey;
  final String? fingerprint;
  final String status;
  final DateTime createdAt;
  final DateTime? pairedAt;
  final DateTime? lastSeenAt;
  final DateTime? lastSyncAt;
  final DateTime? revokedAt;
  const SyncDevice({
    required this.id,
    this.syncGroupId,
    required this.displayName,
    required this.platform,
    required this.isLocal,
    this.publicKey,
    this.fingerprint,
    required this.status,
    required this.createdAt,
    this.pairedAt,
    this.lastSeenAt,
    this.lastSyncAt,
    this.revokedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || syncGroupId != null) {
      map['sync_group_id'] = Variable<String>(syncGroupId);
    }
    map['display_name'] = Variable<String>(displayName);
    map['platform'] = Variable<String>(platform);
    map['is_local'] = Variable<bool>(isLocal);
    if (!nullToAbsent || publicKey != null) {
      map['public_key'] = Variable<String>(publicKey);
    }
    if (!nullToAbsent || fingerprint != null) {
      map['fingerprint'] = Variable<String>(fingerprint);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || pairedAt != null) {
      map['paired_at'] = Variable<DateTime>(pairedAt);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<DateTime>(revokedAt);
    }
    return map;
  }

  SyncDevicesCompanion toCompanion(bool nullToAbsent) {
    return SyncDevicesCompanion(
      id: Value(id),
      syncGroupId:
          syncGroupId == null && nullToAbsent
              ? const Value.absent()
              : Value(syncGroupId),
      displayName: Value(displayName),
      platform: Value(platform),
      isLocal: Value(isLocal),
      publicKey:
          publicKey == null && nullToAbsent
              ? const Value.absent()
              : Value(publicKey),
      fingerprint:
          fingerprint == null && nullToAbsent
              ? const Value.absent()
              : Value(fingerprint),
      status: Value(status),
      createdAt: Value(createdAt),
      pairedAt:
          pairedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(pairedAt),
      lastSeenAt:
          lastSeenAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSeenAt),
      lastSyncAt:
          lastSyncAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSyncAt),
      revokedAt:
          revokedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(revokedAt),
    );
  }

  factory SyncDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncDevice(
      id: serializer.fromJson<String>(json['id']),
      syncGroupId: serializer.fromJson<String?>(json['syncGroupId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      platform: serializer.fromJson<String>(json['platform']),
      isLocal: serializer.fromJson<bool>(json['isLocal']),
      publicKey: serializer.fromJson<String?>(json['publicKey']),
      fingerprint: serializer.fromJson<String?>(json['fingerprint']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      pairedAt: serializer.fromJson<DateTime?>(json['pairedAt']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      revokedAt: serializer.fromJson<DateTime?>(json['revokedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncGroupId': serializer.toJson<String?>(syncGroupId),
      'displayName': serializer.toJson<String>(displayName),
      'platform': serializer.toJson<String>(platform),
      'isLocal': serializer.toJson<bool>(isLocal),
      'publicKey': serializer.toJson<String?>(publicKey),
      'fingerprint': serializer.toJson<String?>(fingerprint),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'pairedAt': serializer.toJson<DateTime?>(pairedAt),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'revokedAt': serializer.toJson<DateTime?>(revokedAt),
    };
  }

  SyncDevice copyWith({
    String? id,
    Value<String?> syncGroupId = const Value.absent(),
    String? displayName,
    String? platform,
    bool? isLocal,
    Value<String?> publicKey = const Value.absent(),
    Value<String?> fingerprint = const Value.absent(),
    String? status,
    DateTime? createdAt,
    Value<DateTime?> pairedAt = const Value.absent(),
    Value<DateTime?> lastSeenAt = const Value.absent(),
    Value<DateTime?> lastSyncAt = const Value.absent(),
    Value<DateTime?> revokedAt = const Value.absent(),
  }) => SyncDevice(
    id: id ?? this.id,
    syncGroupId: syncGroupId.present ? syncGroupId.value : this.syncGroupId,
    displayName: displayName ?? this.displayName,
    platform: platform ?? this.platform,
    isLocal: isLocal ?? this.isLocal,
    publicKey: publicKey.present ? publicKey.value : this.publicKey,
    fingerprint: fingerprint.present ? fingerprint.value : this.fingerprint,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    pairedAt: pairedAt.present ? pairedAt.value : this.pairedAt,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
  );
  SyncDevice copyWithCompanion(SyncDevicesCompanion data) {
    return SyncDevice(
      id: data.id.present ? data.id.value : this.id,
      syncGroupId:
          data.syncGroupId.present ? data.syncGroupId.value : this.syncGroupId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      platform: data.platform.present ? data.platform.value : this.platform,
      isLocal: data.isLocal.present ? data.isLocal.value : this.isLocal,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      fingerprint:
          data.fingerprint.present ? data.fingerprint.value : this.fingerprint,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      pairedAt: data.pairedAt.present ? data.pairedAt.value : this.pairedAt,
      lastSeenAt:
          data.lastSeenAt.present ? data.lastSeenAt.value : this.lastSeenAt,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncDevice(')
          ..write('id: $id, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('displayName: $displayName, ')
          ..write('platform: $platform, ')
          ..write('isLocal: $isLocal, ')
          ..write('publicKey: $publicKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('revokedAt: $revokedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncGroupId,
    displayName,
    platform,
    isLocal,
    publicKey,
    fingerprint,
    status,
    createdAt,
    pairedAt,
    lastSeenAt,
    lastSyncAt,
    revokedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncDevice &&
          other.id == this.id &&
          other.syncGroupId == this.syncGroupId &&
          other.displayName == this.displayName &&
          other.platform == this.platform &&
          other.isLocal == this.isLocal &&
          other.publicKey == this.publicKey &&
          other.fingerprint == this.fingerprint &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.pairedAt == this.pairedAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.lastSyncAt == this.lastSyncAt &&
          other.revokedAt == this.revokedAt);
}

class SyncDevicesCompanion extends UpdateCompanion<SyncDevice> {
  final Value<String> id;
  final Value<String?> syncGroupId;
  final Value<String> displayName;
  final Value<String> platform;
  final Value<bool> isLocal;
  final Value<String?> publicKey;
  final Value<String?> fingerprint;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> pairedAt;
  final Value<DateTime?> lastSeenAt;
  final Value<DateTime?> lastSyncAt;
  final Value<DateTime?> revokedAt;
  final Value<int> rowid;
  const SyncDevicesCompanion({
    this.id = const Value.absent(),
    this.syncGroupId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.platform = const Value.absent(),
    this.isLocal = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.pairedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncDevicesCompanion.insert({
    required String id,
    this.syncGroupId = const Value.absent(),
    required String displayName,
    required String platform,
    this.isLocal = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.fingerprint = const Value.absent(),
    required String status,
    required DateTime createdAt,
    this.pairedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       platform = Value(platform),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<SyncDevice> custom({
    Expression<String>? id,
    Expression<String>? syncGroupId,
    Expression<String>? displayName,
    Expression<String>? platform,
    Expression<bool>? isLocal,
    Expression<String>? publicKey,
    Expression<String>? fingerprint,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? pairedAt,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? lastSyncAt,
    Expression<DateTime>? revokedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncGroupId != null) 'sync_group_id': syncGroupId,
      if (displayName != null) 'display_name': displayName,
      if (platform != null) 'platform': platform,
      if (isLocal != null) 'is_local': isLocal,
      if (publicKey != null) 'public_key': publicKey,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (pairedAt != null) 'paired_at': pairedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (revokedAt != null) 'revoked_at': revokedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncDevicesCompanion copyWith({
    Value<String>? id,
    Value<String?>? syncGroupId,
    Value<String>? displayName,
    Value<String>? platform,
    Value<bool>? isLocal,
    Value<String?>? publicKey,
    Value<String?>? fingerprint,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? pairedAt,
    Value<DateTime?>? lastSeenAt,
    Value<DateTime?>? lastSyncAt,
    Value<DateTime?>? revokedAt,
    Value<int>? rowid,
  }) {
    return SyncDevicesCompanion(
      id: id ?? this.id,
      syncGroupId: syncGroupId ?? this.syncGroupId,
      displayName: displayName ?? this.displayName,
      platform: platform ?? this.platform,
      isLocal: isLocal ?? this.isLocal,
      publicKey: publicKey ?? this.publicKey,
      fingerprint: fingerprint ?? this.fingerprint,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      pairedAt: pairedAt ?? this.pairedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      revokedAt: revokedAt ?? this.revokedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncGroupId.present) {
      map['sync_group_id'] = Variable<String>(syncGroupId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (isLocal.present) {
      map['is_local'] = Variable<bool>(isLocal.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (pairedAt.present) {
      map['paired_at'] = Variable<DateTime>(pairedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<DateTime>(revokedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncDevicesCompanion(')
          ..write('id: $id, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('displayName: $displayName, ')
          ..write('platform: $platform, ')
          ..write('isLocal: $isLocal, ')
          ..write('publicKey: $publicKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncChangesTable extends SyncChanges
    with TableInfo<$SyncChangesTable, SyncChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _changeIdMeta = const VerificationMeta(
    'changeId',
  );
  @override
  late final GeneratedColumn<String> changeId = GeneratedColumn<String>(
    'change_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncGroupIdMeta = const VerificationMeta(
    'syncGroupId',
  );
  @override
  late final GeneratedColumn<String> syncGroupId = GeneratedColumn<String>(
    'sync_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originCounterMeta = const VerificationMeta(
    'originCounter',
  );
  @override
  late final GeneratedColumn<int> originCounter = GeneratedColumn<int>(
    'origin_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mutationSequenceMeta = const VerificationMeta(
    'mutationSequence',
  );
  @override
  late final GeneratedColumn<int> mutationSequence = GeneratedColumn<int>(
    'mutation_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changedFieldsJsonMeta = const VerificationMeta(
    'changedFieldsJson',
  );
  @override
  late final GeneratedColumn<String> changedFieldsJson =
      GeneratedColumn<String>(
        'changed_fields_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotJsonMeta = const VerificationMeta(
    'snapshotJson',
  );
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
    'snapshot_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _causalContextJsonMeta = const VerificationMeta(
    'causalContextJson',
  );
  @override
  late final GeneratedColumn<String> causalContextJson =
      GeneratedColumn<String>(
        'causal_context_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    changeId,
    syncGroupId,
    originDeviceId,
    originCounter,
    mutationId,
    mutationSequence,
    entityType,
    entityId,
    operation,
    changedFieldsJson,
    payloadJson,
    snapshotJson,
    causalContextJson,
    source,
    contentHash,
    createdAt,
    appliedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('change_id')) {
      context.handle(
        _changeIdMeta,
        changeId.isAcceptableOrUnknown(data['change_id']!, _changeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_changeIdMeta);
    }
    if (data.containsKey('sync_group_id')) {
      context.handle(
        _syncGroupIdMeta,
        syncGroupId.isAcceptableOrUnknown(
          data['sync_group_id']!,
          _syncGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('origin_counter')) {
      context.handle(
        _originCounterMeta,
        originCounter.isAcceptableOrUnknown(
          data['origin_counter']!,
          _originCounterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originCounterMeta);
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    if (data.containsKey('mutation_sequence')) {
      context.handle(
        _mutationSequenceMeta,
        mutationSequence.isAcceptableOrUnknown(
          data['mutation_sequence']!,
          _mutationSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mutationSequenceMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('changed_fields_json')) {
      context.handle(
        _changedFieldsJsonMeta,
        changedFieldsJson.isAcceptableOrUnknown(
          data['changed_fields_json']!,
          _changedFieldsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_changedFieldsJsonMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
        _snapshotJsonMeta,
        snapshotJson.isAcceptableOrUnknown(
          data['snapshot_json']!,
          _snapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotJsonMeta);
    }
    if (data.containsKey('causal_context_json')) {
      context.handle(
        _causalContextJsonMeta,
        causalContextJson.isAcceptableOrUnknown(
          data['causal_context_json']!,
          _causalContextJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_causalContextJsonMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {changeId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {originDeviceId, originCounter},
  ];
  @override
  SyncChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncChange(
      changeId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}change_id'],
          )!,
      syncGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_group_id'],
      ),
      originDeviceId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}origin_device_id'],
          )!,
      originCounter:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}origin_counter'],
          )!,
      mutationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}mutation_id'],
          )!,
      mutationSequence:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}mutation_sequence'],
          )!,
      entityType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_type'],
          )!,
      entityId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_id'],
          )!,
      operation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}operation'],
          )!,
      changedFieldsJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}changed_fields_json'],
          )!,
      payloadJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload_json'],
          )!,
      snapshotJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}snapshot_json'],
          )!,
      causalContextJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}causal_context_json'],
          )!,
      source:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}source'],
          )!,
      contentHash:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content_hash'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      ),
    );
  }

  @override
  $SyncChangesTable createAlias(String alias) {
    return $SyncChangesTable(attachedDatabase, alias);
  }
}

class SyncChange extends DataClass implements Insertable<SyncChange> {
  final String changeId;
  final String? syncGroupId;
  final String originDeviceId;
  final int originCounter;
  final String mutationId;
  final int mutationSequence;
  final String entityType;
  final String entityId;
  final String operation;
  final String changedFieldsJson;
  final String payloadJson;
  final String snapshotJson;
  final String causalContextJson;
  final String source;
  final String contentHash;
  final DateTime createdAt;
  final DateTime? appliedAt;
  const SyncChange({
    required this.changeId,
    this.syncGroupId,
    required this.originDeviceId,
    required this.originCounter,
    required this.mutationId,
    required this.mutationSequence,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.changedFieldsJson,
    required this.payloadJson,
    required this.snapshotJson,
    required this.causalContextJson,
    required this.source,
    required this.contentHash,
    required this.createdAt,
    this.appliedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['change_id'] = Variable<String>(changeId);
    if (!nullToAbsent || syncGroupId != null) {
      map['sync_group_id'] = Variable<String>(syncGroupId);
    }
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['origin_counter'] = Variable<int>(originCounter);
    map['mutation_id'] = Variable<String>(mutationId);
    map['mutation_sequence'] = Variable<int>(mutationSequence);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['changed_fields_json'] = Variable<String>(changedFieldsJson);
    map['payload_json'] = Variable<String>(payloadJson);
    map['snapshot_json'] = Variable<String>(snapshotJson);
    map['causal_context_json'] = Variable<String>(causalContextJson);
    map['source'] = Variable<String>(source);
    map['content_hash'] = Variable<String>(contentHash);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || appliedAt != null) {
      map['applied_at'] = Variable<DateTime>(appliedAt);
    }
    return map;
  }

  SyncChangesCompanion toCompanion(bool nullToAbsent) {
    return SyncChangesCompanion(
      changeId: Value(changeId),
      syncGroupId:
          syncGroupId == null && nullToAbsent
              ? const Value.absent()
              : Value(syncGroupId),
      originDeviceId: Value(originDeviceId),
      originCounter: Value(originCounter),
      mutationId: Value(mutationId),
      mutationSequence: Value(mutationSequence),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      changedFieldsJson: Value(changedFieldsJson),
      payloadJson: Value(payloadJson),
      snapshotJson: Value(snapshotJson),
      causalContextJson: Value(causalContextJson),
      source: Value(source),
      contentHash: Value(contentHash),
      createdAt: Value(createdAt),
      appliedAt:
          appliedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(appliedAt),
    );
  }

  factory SyncChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncChange(
      changeId: serializer.fromJson<String>(json['changeId']),
      syncGroupId: serializer.fromJson<String?>(json['syncGroupId']),
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      originCounter: serializer.fromJson<int>(json['originCounter']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
      mutationSequence: serializer.fromJson<int>(json['mutationSequence']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      changedFieldsJson: serializer.fromJson<String>(json['changedFieldsJson']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
      causalContextJson: serializer.fromJson<String>(json['causalContextJson']),
      source: serializer.fromJson<String>(json['source']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      appliedAt: serializer.fromJson<DateTime?>(json['appliedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'changeId': serializer.toJson<String>(changeId),
      'syncGroupId': serializer.toJson<String?>(syncGroupId),
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'originCounter': serializer.toJson<int>(originCounter),
      'mutationId': serializer.toJson<String>(mutationId),
      'mutationSequence': serializer.toJson<int>(mutationSequence),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'changedFieldsJson': serializer.toJson<String>(changedFieldsJson),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
      'causalContextJson': serializer.toJson<String>(causalContextJson),
      'source': serializer.toJson<String>(source),
      'contentHash': serializer.toJson<String>(contentHash),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'appliedAt': serializer.toJson<DateTime?>(appliedAt),
    };
  }

  SyncChange copyWith({
    String? changeId,
    Value<String?> syncGroupId = const Value.absent(),
    String? originDeviceId,
    int? originCounter,
    String? mutationId,
    int? mutationSequence,
    String? entityType,
    String? entityId,
    String? operation,
    String? changedFieldsJson,
    String? payloadJson,
    String? snapshotJson,
    String? causalContextJson,
    String? source,
    String? contentHash,
    DateTime? createdAt,
    Value<DateTime?> appliedAt = const Value.absent(),
  }) => SyncChange(
    changeId: changeId ?? this.changeId,
    syncGroupId: syncGroupId.present ? syncGroupId.value : this.syncGroupId,
    originDeviceId: originDeviceId ?? this.originDeviceId,
    originCounter: originCounter ?? this.originCounter,
    mutationId: mutationId ?? this.mutationId,
    mutationSequence: mutationSequence ?? this.mutationSequence,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    changedFieldsJson: changedFieldsJson ?? this.changedFieldsJson,
    payloadJson: payloadJson ?? this.payloadJson,
    snapshotJson: snapshotJson ?? this.snapshotJson,
    causalContextJson: causalContextJson ?? this.causalContextJson,
    source: source ?? this.source,
    contentHash: contentHash ?? this.contentHash,
    createdAt: createdAt ?? this.createdAt,
    appliedAt: appliedAt.present ? appliedAt.value : this.appliedAt,
  );
  SyncChange copyWithCompanion(SyncChangesCompanion data) {
    return SyncChange(
      changeId: data.changeId.present ? data.changeId.value : this.changeId,
      syncGroupId:
          data.syncGroupId.present ? data.syncGroupId.value : this.syncGroupId,
      originDeviceId:
          data.originDeviceId.present
              ? data.originDeviceId.value
              : this.originDeviceId,
      originCounter:
          data.originCounter.present
              ? data.originCounter.value
              : this.originCounter,
      mutationId:
          data.mutationId.present ? data.mutationId.value : this.mutationId,
      mutationSequence:
          data.mutationSequence.present
              ? data.mutationSequence.value
              : this.mutationSequence,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      changedFieldsJson:
          data.changedFieldsJson.present
              ? data.changedFieldsJson.value
              : this.changedFieldsJson,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      snapshotJson:
          data.snapshotJson.present
              ? data.snapshotJson.value
              : this.snapshotJson,
      causalContextJson:
          data.causalContextJson.present
              ? data.causalContextJson.value
              : this.causalContextJson,
      source: data.source.present ? data.source.value : this.source,
      contentHash:
          data.contentHash.present ? data.contentHash.value : this.contentHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncChange(')
          ..write('changeId: $changeId, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('originCounter: $originCounter, ')
          ..write('mutationId: $mutationId, ')
          ..write('mutationSequence: $mutationSequence, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('changedFieldsJson: $changedFieldsJson, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('causalContextJson: $causalContextJson, ')
          ..write('source: $source, ')
          ..write('contentHash: $contentHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('appliedAt: $appliedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    changeId,
    syncGroupId,
    originDeviceId,
    originCounter,
    mutationId,
    mutationSequence,
    entityType,
    entityId,
    operation,
    changedFieldsJson,
    payloadJson,
    snapshotJson,
    causalContextJson,
    source,
    contentHash,
    createdAt,
    appliedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncChange &&
          other.changeId == this.changeId &&
          other.syncGroupId == this.syncGroupId &&
          other.originDeviceId == this.originDeviceId &&
          other.originCounter == this.originCounter &&
          other.mutationId == this.mutationId &&
          other.mutationSequence == this.mutationSequence &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.changedFieldsJson == this.changedFieldsJson &&
          other.payloadJson == this.payloadJson &&
          other.snapshotJson == this.snapshotJson &&
          other.causalContextJson == this.causalContextJson &&
          other.source == this.source &&
          other.contentHash == this.contentHash &&
          other.createdAt == this.createdAt &&
          other.appliedAt == this.appliedAt);
}

class SyncChangesCompanion extends UpdateCompanion<SyncChange> {
  final Value<String> changeId;
  final Value<String?> syncGroupId;
  final Value<String> originDeviceId;
  final Value<int> originCounter;
  final Value<String> mutationId;
  final Value<int> mutationSequence;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> changedFieldsJson;
  final Value<String> payloadJson;
  final Value<String> snapshotJson;
  final Value<String> causalContextJson;
  final Value<String> source;
  final Value<String> contentHash;
  final Value<DateTime> createdAt;
  final Value<DateTime?> appliedAt;
  final Value<int> rowid;
  const SyncChangesCompanion({
    this.changeId = const Value.absent(),
    this.syncGroupId = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.originCounter = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.mutationSequence = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.changedFieldsJson = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.causalContextJson = const Value.absent(),
    this.source = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncChangesCompanion.insert({
    required String changeId,
    this.syncGroupId = const Value.absent(),
    required String originDeviceId,
    required int originCounter,
    required String mutationId,
    required int mutationSequence,
    required String entityType,
    required String entityId,
    required String operation,
    required String changedFieldsJson,
    required String payloadJson,
    required String snapshotJson,
    required String causalContextJson,
    required String source,
    required String contentHash,
    required DateTime createdAt,
    this.appliedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : changeId = Value(changeId),
       originDeviceId = Value(originDeviceId),
       originCounter = Value(originCounter),
       mutationId = Value(mutationId),
       mutationSequence = Value(mutationSequence),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       changedFieldsJson = Value(changedFieldsJson),
       payloadJson = Value(payloadJson),
       snapshotJson = Value(snapshotJson),
       causalContextJson = Value(causalContextJson),
       source = Value(source),
       contentHash = Value(contentHash),
       createdAt = Value(createdAt);
  static Insertable<SyncChange> custom({
    Expression<String>? changeId,
    Expression<String>? syncGroupId,
    Expression<String>? originDeviceId,
    Expression<int>? originCounter,
    Expression<String>? mutationId,
    Expression<int>? mutationSequence,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? changedFieldsJson,
    Expression<String>? payloadJson,
    Expression<String>? snapshotJson,
    Expression<String>? causalContextJson,
    Expression<String>? source,
    Expression<String>? contentHash,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? appliedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (changeId != null) 'change_id': changeId,
      if (syncGroupId != null) 'sync_group_id': syncGroupId,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (originCounter != null) 'origin_counter': originCounter,
      if (mutationId != null) 'mutation_id': mutationId,
      if (mutationSequence != null) 'mutation_sequence': mutationSequence,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (changedFieldsJson != null) 'changed_fields_json': changedFieldsJson,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (causalContextJson != null) 'causal_context_json': causalContextJson,
      if (source != null) 'source': source,
      if (contentHash != null) 'content_hash': contentHash,
      if (createdAt != null) 'created_at': createdAt,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncChangesCompanion copyWith({
    Value<String>? changeId,
    Value<String?>? syncGroupId,
    Value<String>? originDeviceId,
    Value<int>? originCounter,
    Value<String>? mutationId,
    Value<int>? mutationSequence,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? changedFieldsJson,
    Value<String>? payloadJson,
    Value<String>? snapshotJson,
    Value<String>? causalContextJson,
    Value<String>? source,
    Value<String>? contentHash,
    Value<DateTime>? createdAt,
    Value<DateTime?>? appliedAt,
    Value<int>? rowid,
  }) {
    return SyncChangesCompanion(
      changeId: changeId ?? this.changeId,
      syncGroupId: syncGroupId ?? this.syncGroupId,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      originCounter: originCounter ?? this.originCounter,
      mutationId: mutationId ?? this.mutationId,
      mutationSequence: mutationSequence ?? this.mutationSequence,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      changedFieldsJson: changedFieldsJson ?? this.changedFieldsJson,
      payloadJson: payloadJson ?? this.payloadJson,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      causalContextJson: causalContextJson ?? this.causalContextJson,
      source: source ?? this.source,
      contentHash: contentHash ?? this.contentHash,
      createdAt: createdAt ?? this.createdAt,
      appliedAt: appliedAt ?? this.appliedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (changeId.present) {
      map['change_id'] = Variable<String>(changeId.value);
    }
    if (syncGroupId.present) {
      map['sync_group_id'] = Variable<String>(syncGroupId.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (originCounter.present) {
      map['origin_counter'] = Variable<int>(originCounter.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (mutationSequence.present) {
      map['mutation_sequence'] = Variable<int>(mutationSequence.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (changedFieldsJson.present) {
      map['changed_fields_json'] = Variable<String>(changedFieldsJson.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (causalContextJson.present) {
      map['causal_context_json'] = Variable<String>(causalContextJson.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncChangesCompanion(')
          ..write('changeId: $changeId, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('originCounter: $originCounter, ')
          ..write('mutationId: $mutationId, ')
          ..write('mutationSequence: $mutationSequence, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('changedFieldsJson: $changedFieldsJson, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('causalContextJson: $causalContextJson, ')
          ..write('source: $source, ')
          ..write('contentHash: $contentHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncTombstonesTable extends SyncTombstones
    with TableInfo<$SyncTombstonesTable, SyncTombstone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncTombstonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tombstoneIdMeta = const VerificationMeta(
    'tombstoneId',
  );
  @override
  late final GeneratedColumn<String> tombstoneId = GeneratedColumn<String>(
    'tombstone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncGroupIdMeta = const VerificationMeta(
    'syncGroupId',
  );
  @override
  late final GeneratedColumn<String> syncGroupId = GeneratedColumn<String>(
    'sync_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deleteChangeIdMeta = const VerificationMeta(
    'deleteChangeId',
  );
  @override
  late final GeneratedColumn<String> deleteChangeId = GeneratedColumn<String>(
    'delete_change_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originCounterMeta = const VerificationMeta(
    'originCounter',
  );
  @override
  late final GeneratedColumn<int> originCounter = GeneratedColumn<int>(
    'origin_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _causalContextJsonMeta = const VerificationMeta(
    'causalContextJson',
  );
  @override
  late final GeneratedColumn<String> causalContextJson =
      GeneratedColumn<String>(
        'causal_context_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastContentHashMeta = const VerificationMeta(
    'lastContentHash',
  );
  @override
  late final GeneratedColumn<String> lastContentHash = GeneratedColumn<String>(
    'last_content_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullyAcknowledgedAtMeta =
      const VerificationMeta('fullyAcknowledgedAt');
  @override
  late final GeneratedColumn<DateTime> fullyAcknowledgedAt =
      GeneratedColumn<DateTime>(
        'fully_acknowledged_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _retainUntilMeta = const VerificationMeta(
    'retainUntil',
  );
  @override
  late final GeneratedColumn<DateTime> retainUntil = GeneratedColumn<DateTime>(
    'retain_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    tombstoneId,
    syncGroupId,
    entityType,
    entityId,
    deleteChangeId,
    originDeviceId,
    originCounter,
    causalContextJson,
    lastContentHash,
    deletedAt,
    fullyAcknowledgedAt,
    retainUntil,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_tombstones';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncTombstone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tombstone_id')) {
      context.handle(
        _tombstoneIdMeta,
        tombstoneId.isAcceptableOrUnknown(
          data['tombstone_id']!,
          _tombstoneIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tombstoneIdMeta);
    }
    if (data.containsKey('sync_group_id')) {
      context.handle(
        _syncGroupIdMeta,
        syncGroupId.isAcceptableOrUnknown(
          data['sync_group_id']!,
          _syncGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('delete_change_id')) {
      context.handle(
        _deleteChangeIdMeta,
        deleteChangeId.isAcceptableOrUnknown(
          data['delete_change_id']!,
          _deleteChangeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deleteChangeIdMeta);
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('origin_counter')) {
      context.handle(
        _originCounterMeta,
        originCounter.isAcceptableOrUnknown(
          data['origin_counter']!,
          _originCounterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originCounterMeta);
    }
    if (data.containsKey('causal_context_json')) {
      context.handle(
        _causalContextJsonMeta,
        causalContextJson.isAcceptableOrUnknown(
          data['causal_context_json']!,
          _causalContextJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_causalContextJsonMeta);
    }
    if (data.containsKey('last_content_hash')) {
      context.handle(
        _lastContentHashMeta,
        lastContentHash.isAcceptableOrUnknown(
          data['last_content_hash']!,
          _lastContentHashMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_deletedAtMeta);
    }
    if (data.containsKey('fully_acknowledged_at')) {
      context.handle(
        _fullyAcknowledgedAtMeta,
        fullyAcknowledgedAt.isAcceptableOrUnknown(
          data['fully_acknowledged_at']!,
          _fullyAcknowledgedAtMeta,
        ),
      );
    }
    if (data.containsKey('retain_until')) {
      context.handle(
        _retainUntilMeta,
        retainUntil.isAcceptableOrUnknown(
          data['retain_until']!,
          _retainUntilMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tombstoneId};
  @override
  SyncTombstone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncTombstone(
      tombstoneId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}tombstone_id'],
          )!,
      syncGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_group_id'],
      ),
      entityType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_type'],
          )!,
      entityId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_id'],
          )!,
      deleteChangeId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}delete_change_id'],
          )!,
      originDeviceId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}origin_device_id'],
          )!,
      originCounter:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}origin_counter'],
          )!,
      causalContextJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}causal_context_json'],
          )!,
      lastContentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_content_hash'],
      ),
      deletedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}deleted_at'],
          )!,
      fullyAcknowledgedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fully_acknowledged_at'],
      ),
      retainUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retain_until'],
      ),
    );
  }

  @override
  $SyncTombstonesTable createAlias(String alias) {
    return $SyncTombstonesTable(attachedDatabase, alias);
  }
}

class SyncTombstone extends DataClass implements Insertable<SyncTombstone> {
  final String tombstoneId;
  final String? syncGroupId;
  final String entityType;
  final String entityId;
  final String deleteChangeId;
  final String originDeviceId;
  final int originCounter;
  final String causalContextJson;
  final String? lastContentHash;
  final DateTime deletedAt;
  final DateTime? fullyAcknowledgedAt;
  final DateTime? retainUntil;
  const SyncTombstone({
    required this.tombstoneId,
    this.syncGroupId,
    required this.entityType,
    required this.entityId,
    required this.deleteChangeId,
    required this.originDeviceId,
    required this.originCounter,
    required this.causalContextJson,
    this.lastContentHash,
    required this.deletedAt,
    this.fullyAcknowledgedAt,
    this.retainUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tombstone_id'] = Variable<String>(tombstoneId);
    if (!nullToAbsent || syncGroupId != null) {
      map['sync_group_id'] = Variable<String>(syncGroupId);
    }
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['delete_change_id'] = Variable<String>(deleteChangeId);
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['origin_counter'] = Variable<int>(originCounter);
    map['causal_context_json'] = Variable<String>(causalContextJson);
    if (!nullToAbsent || lastContentHash != null) {
      map['last_content_hash'] = Variable<String>(lastContentHash);
    }
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    if (!nullToAbsent || fullyAcknowledgedAt != null) {
      map['fully_acknowledged_at'] = Variable<DateTime>(fullyAcknowledgedAt);
    }
    if (!nullToAbsent || retainUntil != null) {
      map['retain_until'] = Variable<DateTime>(retainUntil);
    }
    return map;
  }

  SyncTombstonesCompanion toCompanion(bool nullToAbsent) {
    return SyncTombstonesCompanion(
      tombstoneId: Value(tombstoneId),
      syncGroupId:
          syncGroupId == null && nullToAbsent
              ? const Value.absent()
              : Value(syncGroupId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      deleteChangeId: Value(deleteChangeId),
      originDeviceId: Value(originDeviceId),
      originCounter: Value(originCounter),
      causalContextJson: Value(causalContextJson),
      lastContentHash:
          lastContentHash == null && nullToAbsent
              ? const Value.absent()
              : Value(lastContentHash),
      deletedAt: Value(deletedAt),
      fullyAcknowledgedAt:
          fullyAcknowledgedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(fullyAcknowledgedAt),
      retainUntil:
          retainUntil == null && nullToAbsent
              ? const Value.absent()
              : Value(retainUntil),
    );
  }

  factory SyncTombstone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncTombstone(
      tombstoneId: serializer.fromJson<String>(json['tombstoneId']),
      syncGroupId: serializer.fromJson<String?>(json['syncGroupId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      deleteChangeId: serializer.fromJson<String>(json['deleteChangeId']),
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      originCounter: serializer.fromJson<int>(json['originCounter']),
      causalContextJson: serializer.fromJson<String>(json['causalContextJson']),
      lastContentHash: serializer.fromJson<String?>(json['lastContentHash']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
      fullyAcknowledgedAt: serializer.fromJson<DateTime?>(
        json['fullyAcknowledgedAt'],
      ),
      retainUntil: serializer.fromJson<DateTime?>(json['retainUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tombstoneId': serializer.toJson<String>(tombstoneId),
      'syncGroupId': serializer.toJson<String?>(syncGroupId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'deleteChangeId': serializer.toJson<String>(deleteChangeId),
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'originCounter': serializer.toJson<int>(originCounter),
      'causalContextJson': serializer.toJson<String>(causalContextJson),
      'lastContentHash': serializer.toJson<String?>(lastContentHash),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
      'fullyAcknowledgedAt': serializer.toJson<DateTime?>(fullyAcknowledgedAt),
      'retainUntil': serializer.toJson<DateTime?>(retainUntil),
    };
  }

  SyncTombstone copyWith({
    String? tombstoneId,
    Value<String?> syncGroupId = const Value.absent(),
    String? entityType,
    String? entityId,
    String? deleteChangeId,
    String? originDeviceId,
    int? originCounter,
    String? causalContextJson,
    Value<String?> lastContentHash = const Value.absent(),
    DateTime? deletedAt,
    Value<DateTime?> fullyAcknowledgedAt = const Value.absent(),
    Value<DateTime?> retainUntil = const Value.absent(),
  }) => SyncTombstone(
    tombstoneId: tombstoneId ?? this.tombstoneId,
    syncGroupId: syncGroupId.present ? syncGroupId.value : this.syncGroupId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    deleteChangeId: deleteChangeId ?? this.deleteChangeId,
    originDeviceId: originDeviceId ?? this.originDeviceId,
    originCounter: originCounter ?? this.originCounter,
    causalContextJson: causalContextJson ?? this.causalContextJson,
    lastContentHash:
        lastContentHash.present ? lastContentHash.value : this.lastContentHash,
    deletedAt: deletedAt ?? this.deletedAt,
    fullyAcknowledgedAt:
        fullyAcknowledgedAt.present
            ? fullyAcknowledgedAt.value
            : this.fullyAcknowledgedAt,
    retainUntil: retainUntil.present ? retainUntil.value : this.retainUntil,
  );
  SyncTombstone copyWithCompanion(SyncTombstonesCompanion data) {
    return SyncTombstone(
      tombstoneId:
          data.tombstoneId.present ? data.tombstoneId.value : this.tombstoneId,
      syncGroupId:
          data.syncGroupId.present ? data.syncGroupId.value : this.syncGroupId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      deleteChangeId:
          data.deleteChangeId.present
              ? data.deleteChangeId.value
              : this.deleteChangeId,
      originDeviceId:
          data.originDeviceId.present
              ? data.originDeviceId.value
              : this.originDeviceId,
      originCounter:
          data.originCounter.present
              ? data.originCounter.value
              : this.originCounter,
      causalContextJson:
          data.causalContextJson.present
              ? data.causalContextJson.value
              : this.causalContextJson,
      lastContentHash:
          data.lastContentHash.present
              ? data.lastContentHash.value
              : this.lastContentHash,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      fullyAcknowledgedAt:
          data.fullyAcknowledgedAt.present
              ? data.fullyAcknowledgedAt.value
              : this.fullyAcknowledgedAt,
      retainUntil:
          data.retainUntil.present ? data.retainUntil.value : this.retainUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncTombstone(')
          ..write('tombstoneId: $tombstoneId, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deleteChangeId: $deleteChangeId, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('originCounter: $originCounter, ')
          ..write('causalContextJson: $causalContextJson, ')
          ..write('lastContentHash: $lastContentHash, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fullyAcknowledgedAt: $fullyAcknowledgedAt, ')
          ..write('retainUntil: $retainUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    tombstoneId,
    syncGroupId,
    entityType,
    entityId,
    deleteChangeId,
    originDeviceId,
    originCounter,
    causalContextJson,
    lastContentHash,
    deletedAt,
    fullyAcknowledgedAt,
    retainUntil,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncTombstone &&
          other.tombstoneId == this.tombstoneId &&
          other.syncGroupId == this.syncGroupId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.deleteChangeId == this.deleteChangeId &&
          other.originDeviceId == this.originDeviceId &&
          other.originCounter == this.originCounter &&
          other.causalContextJson == this.causalContextJson &&
          other.lastContentHash == this.lastContentHash &&
          other.deletedAt == this.deletedAt &&
          other.fullyAcknowledgedAt == this.fullyAcknowledgedAt &&
          other.retainUntil == this.retainUntil);
}

class SyncTombstonesCompanion extends UpdateCompanion<SyncTombstone> {
  final Value<String> tombstoneId;
  final Value<String?> syncGroupId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> deleteChangeId;
  final Value<String> originDeviceId;
  final Value<int> originCounter;
  final Value<String> causalContextJson;
  final Value<String?> lastContentHash;
  final Value<DateTime> deletedAt;
  final Value<DateTime?> fullyAcknowledgedAt;
  final Value<DateTime?> retainUntil;
  final Value<int> rowid;
  const SyncTombstonesCompanion({
    this.tombstoneId = const Value.absent(),
    this.syncGroupId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.deleteChangeId = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.originCounter = const Value.absent(),
    this.causalContextJson = const Value.absent(),
    this.lastContentHash = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.fullyAcknowledgedAt = const Value.absent(),
    this.retainUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncTombstonesCompanion.insert({
    required String tombstoneId,
    this.syncGroupId = const Value.absent(),
    required String entityType,
    required String entityId,
    required String deleteChangeId,
    required String originDeviceId,
    required int originCounter,
    required String causalContextJson,
    this.lastContentHash = const Value.absent(),
    required DateTime deletedAt,
    this.fullyAcknowledgedAt = const Value.absent(),
    this.retainUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tombstoneId = Value(tombstoneId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       deleteChangeId = Value(deleteChangeId),
       originDeviceId = Value(originDeviceId),
       originCounter = Value(originCounter),
       causalContextJson = Value(causalContextJson),
       deletedAt = Value(deletedAt);
  static Insertable<SyncTombstone> custom({
    Expression<String>? tombstoneId,
    Expression<String>? syncGroupId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? deleteChangeId,
    Expression<String>? originDeviceId,
    Expression<int>? originCounter,
    Expression<String>? causalContextJson,
    Expression<String>? lastContentHash,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? fullyAcknowledgedAt,
    Expression<DateTime>? retainUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tombstoneId != null) 'tombstone_id': tombstoneId,
      if (syncGroupId != null) 'sync_group_id': syncGroupId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (deleteChangeId != null) 'delete_change_id': deleteChangeId,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (originCounter != null) 'origin_counter': originCounter,
      if (causalContextJson != null) 'causal_context_json': causalContextJson,
      if (lastContentHash != null) 'last_content_hash': lastContentHash,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (fullyAcknowledgedAt != null)
        'fully_acknowledged_at': fullyAcknowledgedAt,
      if (retainUntil != null) 'retain_until': retainUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncTombstonesCompanion copyWith({
    Value<String>? tombstoneId,
    Value<String?>? syncGroupId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? deleteChangeId,
    Value<String>? originDeviceId,
    Value<int>? originCounter,
    Value<String>? causalContextJson,
    Value<String?>? lastContentHash,
    Value<DateTime>? deletedAt,
    Value<DateTime?>? fullyAcknowledgedAt,
    Value<DateTime?>? retainUntil,
    Value<int>? rowid,
  }) {
    return SyncTombstonesCompanion(
      tombstoneId: tombstoneId ?? this.tombstoneId,
      syncGroupId: syncGroupId ?? this.syncGroupId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      deleteChangeId: deleteChangeId ?? this.deleteChangeId,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      originCounter: originCounter ?? this.originCounter,
      causalContextJson: causalContextJson ?? this.causalContextJson,
      lastContentHash: lastContentHash ?? this.lastContentHash,
      deletedAt: deletedAt ?? this.deletedAt,
      fullyAcknowledgedAt: fullyAcknowledgedAt ?? this.fullyAcknowledgedAt,
      retainUntil: retainUntil ?? this.retainUntil,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tombstoneId.present) {
      map['tombstone_id'] = Variable<String>(tombstoneId.value);
    }
    if (syncGroupId.present) {
      map['sync_group_id'] = Variable<String>(syncGroupId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (deleteChangeId.present) {
      map['delete_change_id'] = Variable<String>(deleteChangeId.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (originCounter.present) {
      map['origin_counter'] = Variable<int>(originCounter.value);
    }
    if (causalContextJson.present) {
      map['causal_context_json'] = Variable<String>(causalContextJson.value);
    }
    if (lastContentHash.present) {
      map['last_content_hash'] = Variable<String>(lastContentHash.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (fullyAcknowledgedAt.present) {
      map['fully_acknowledged_at'] = Variable<DateTime>(
        fullyAcknowledgedAt.value,
      );
    }
    if (retainUntil.present) {
      map['retain_until'] = Variable<DateTime>(retainUntil.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncTombstonesCompanion(')
          ..write('tombstoneId: $tombstoneId, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deleteChangeId: $deleteChangeId, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('originCounter: $originCounter, ')
          ..write('causalContextJson: $causalContextJson, ')
          ..write('lastContentHash: $lastContentHash, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fullyAcknowledgedAt: $fullyAcknowledgedAt, ')
          ..write('retainUntil: $retainUntil, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncGroupIdMeta = const VerificationMeta(
    'syncGroupId',
  );
  @override
  late final GeneratedColumn<String> syncGroupId = GeneratedColumn<String>(
    'sync_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localDeviceIdMeta = const VerificationMeta(
    'localDeviceId',
  );
  @override
  late final GeneratedColumn<String> localDeviceId = GeneratedColumn<String>(
    'local_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peerDeviceIdMeta = const VerificationMeta(
    'peerDeviceId',
  );
  @override
  late final GeneratedColumn<String> peerDeviceId = GeneratedColumn<String>(
    'peer_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextLocalCounterMeta = const VerificationMeta(
    'nextLocalCounter',
  );
  @override
  late final GeneratedColumn<int> nextLocalCounter = GeneratedColumn<int>(
    'next_local_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _seenVectorJsonMeta = const VerificationMeta(
    'seenVectorJson',
  );
  @override
  late final GeneratedColumn<String> seenVectorJson = GeneratedColumn<String>(
    'seen_vector_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _peerAckVectorJsonMeta = const VerificationMeta(
    'peerAckVectorJson',
  );
  @override
  late final GeneratedColumn<String> peerAckVectorJson =
      GeneratedColumn<String>(
        'peer_ack_vector_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _lastExportedVectorJsonMeta =
      const VerificationMeta('lastExportedVectorJson');
  @override
  late final GeneratedColumn<String> lastExportedVectorJson =
      GeneratedColumn<String>(
        'last_exported_vector_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _lastImportedPackageIdMeta =
      const VerificationMeta('lastImportedPackageId');
  @override
  late final GeneratedColumn<String> lastImportedPackageId =
      GeneratedColumn<String>(
        'last_imported_package_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _replicaEpochMeta = const VerificationMeta(
    'replicaEpoch',
  );
  @override
  late final GeneratedColumn<int> replicaEpoch = GeneratedColumn<int>(
    'replica_epoch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _baselineCreatedMeta = const VerificationMeta(
    'baselineCreated',
  );
  @override
  late final GeneratedColumn<bool> baselineCreated = GeneratedColumn<bool>(
    'baseline_created',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("baseline_created" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _requiresReconciliationMeta =
      const VerificationMeta('requiresReconciliation');
  @override
  late final GeneratedColumn<bool> requiresReconciliation =
      GeneratedColumn<bool>(
        'requires_reconciliation',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("requires_reconciliation" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _lastSuccessfulSyncAtMeta =
      const VerificationMeta('lastSuccessfulSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSuccessfulSyncAt =
      GeneratedColumn<DateTime>(
        'last_successful_sync_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncGroupId,
    localDeviceId,
    peerDeviceId,
    nextLocalCounter,
    seenVectorJson,
    peerAckVectorJson,
    lastExportedVectorJson,
    lastImportedPackageId,
    replicaEpoch,
    baselineCreated,
    requiresReconciliation,
    lastSuccessfulSyncAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sync_group_id')) {
      context.handle(
        _syncGroupIdMeta,
        syncGroupId.isAcceptableOrUnknown(
          data['sync_group_id']!,
          _syncGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('local_device_id')) {
      context.handle(
        _localDeviceIdMeta,
        localDeviceId.isAcceptableOrUnknown(
          data['local_device_id']!,
          _localDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localDeviceIdMeta);
    }
    if (data.containsKey('peer_device_id')) {
      context.handle(
        _peerDeviceIdMeta,
        peerDeviceId.isAcceptableOrUnknown(
          data['peer_device_id']!,
          _peerDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('next_local_counter')) {
      context.handle(
        _nextLocalCounterMeta,
        nextLocalCounter.isAcceptableOrUnknown(
          data['next_local_counter']!,
          _nextLocalCounterMeta,
        ),
      );
    }
    if (data.containsKey('seen_vector_json')) {
      context.handle(
        _seenVectorJsonMeta,
        seenVectorJson.isAcceptableOrUnknown(
          data['seen_vector_json']!,
          _seenVectorJsonMeta,
        ),
      );
    }
    if (data.containsKey('peer_ack_vector_json')) {
      context.handle(
        _peerAckVectorJsonMeta,
        peerAckVectorJson.isAcceptableOrUnknown(
          data['peer_ack_vector_json']!,
          _peerAckVectorJsonMeta,
        ),
      );
    }
    if (data.containsKey('last_exported_vector_json')) {
      context.handle(
        _lastExportedVectorJsonMeta,
        lastExportedVectorJson.isAcceptableOrUnknown(
          data['last_exported_vector_json']!,
          _lastExportedVectorJsonMeta,
        ),
      );
    }
    if (data.containsKey('last_imported_package_id')) {
      context.handle(
        _lastImportedPackageIdMeta,
        lastImportedPackageId.isAcceptableOrUnknown(
          data['last_imported_package_id']!,
          _lastImportedPackageIdMeta,
        ),
      );
    }
    if (data.containsKey('replica_epoch')) {
      context.handle(
        _replicaEpochMeta,
        replicaEpoch.isAcceptableOrUnknown(
          data['replica_epoch']!,
          _replicaEpochMeta,
        ),
      );
    }
    if (data.containsKey('baseline_created')) {
      context.handle(
        _baselineCreatedMeta,
        baselineCreated.isAcceptableOrUnknown(
          data['baseline_created']!,
          _baselineCreatedMeta,
        ),
      );
    }
    if (data.containsKey('requires_reconciliation')) {
      context.handle(
        _requiresReconciliationMeta,
        requiresReconciliation.isAcceptableOrUnknown(
          data['requires_reconciliation']!,
          _requiresReconciliationMeta,
        ),
      );
    }
    if (data.containsKey('last_successful_sync_at')) {
      context.handle(
        _lastSuccessfulSyncAtMeta,
        lastSuccessfulSyncAt.isAcceptableOrUnknown(
          data['last_successful_sync_at']!,
          _lastSuccessfulSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncState(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      syncGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_group_id'],
      ),
      localDeviceId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}local_device_id'],
          )!,
      peerDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_device_id'],
      ),
      nextLocalCounter:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}next_local_counter'],
          )!,
      seenVectorJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}seen_vector_json'],
          )!,
      peerAckVectorJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}peer_ack_vector_json'],
          )!,
      lastExportedVectorJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}last_exported_vector_json'],
          )!,
      lastImportedPackageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_imported_package_id'],
      ),
      replicaEpoch:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}replica_epoch'],
          )!,
      baselineCreated:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}baseline_created'],
          )!,
      requiresReconciliation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}requires_reconciliation'],
          )!,
      lastSuccessfulSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_successful_sync_at'],
      ),
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncState extends DataClass implements Insertable<SyncState> {
  final String id;
  final String? syncGroupId;
  final String localDeviceId;
  final String? peerDeviceId;
  final int nextLocalCounter;
  final String seenVectorJson;
  final String peerAckVectorJson;
  final String lastExportedVectorJson;
  final String? lastImportedPackageId;
  final int replicaEpoch;
  final bool baselineCreated;
  final bool requiresReconciliation;
  final DateTime? lastSuccessfulSyncAt;
  final DateTime updatedAt;
  const SyncState({
    required this.id,
    this.syncGroupId,
    required this.localDeviceId,
    this.peerDeviceId,
    required this.nextLocalCounter,
    required this.seenVectorJson,
    required this.peerAckVectorJson,
    required this.lastExportedVectorJson,
    this.lastImportedPackageId,
    required this.replicaEpoch,
    required this.baselineCreated,
    required this.requiresReconciliation,
    this.lastSuccessfulSyncAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || syncGroupId != null) {
      map['sync_group_id'] = Variable<String>(syncGroupId);
    }
    map['local_device_id'] = Variable<String>(localDeviceId);
    if (!nullToAbsent || peerDeviceId != null) {
      map['peer_device_id'] = Variable<String>(peerDeviceId);
    }
    map['next_local_counter'] = Variable<int>(nextLocalCounter);
    map['seen_vector_json'] = Variable<String>(seenVectorJson);
    map['peer_ack_vector_json'] = Variable<String>(peerAckVectorJson);
    map['last_exported_vector_json'] = Variable<String>(lastExportedVectorJson);
    if (!nullToAbsent || lastImportedPackageId != null) {
      map['last_imported_package_id'] = Variable<String>(lastImportedPackageId);
    }
    map['replica_epoch'] = Variable<int>(replicaEpoch);
    map['baseline_created'] = Variable<bool>(baselineCreated);
    map['requires_reconciliation'] = Variable<bool>(requiresReconciliation);
    if (!nullToAbsent || lastSuccessfulSyncAt != null) {
      map['last_successful_sync_at'] = Variable<DateTime>(lastSuccessfulSyncAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      id: Value(id),
      syncGroupId:
          syncGroupId == null && nullToAbsent
              ? const Value.absent()
              : Value(syncGroupId),
      localDeviceId: Value(localDeviceId),
      peerDeviceId:
          peerDeviceId == null && nullToAbsent
              ? const Value.absent()
              : Value(peerDeviceId),
      nextLocalCounter: Value(nextLocalCounter),
      seenVectorJson: Value(seenVectorJson),
      peerAckVectorJson: Value(peerAckVectorJson),
      lastExportedVectorJson: Value(lastExportedVectorJson),
      lastImportedPackageId:
          lastImportedPackageId == null && nullToAbsent
              ? const Value.absent()
              : Value(lastImportedPackageId),
      replicaEpoch: Value(replicaEpoch),
      baselineCreated: Value(baselineCreated),
      requiresReconciliation: Value(requiresReconciliation),
      lastSuccessfulSyncAt:
          lastSuccessfulSyncAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSuccessfulSyncAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncState(
      id: serializer.fromJson<String>(json['id']),
      syncGroupId: serializer.fromJson<String?>(json['syncGroupId']),
      localDeviceId: serializer.fromJson<String>(json['localDeviceId']),
      peerDeviceId: serializer.fromJson<String?>(json['peerDeviceId']),
      nextLocalCounter: serializer.fromJson<int>(json['nextLocalCounter']),
      seenVectorJson: serializer.fromJson<String>(json['seenVectorJson']),
      peerAckVectorJson: serializer.fromJson<String>(json['peerAckVectorJson']),
      lastExportedVectorJson: serializer.fromJson<String>(
        json['lastExportedVectorJson'],
      ),
      lastImportedPackageId: serializer.fromJson<String?>(
        json['lastImportedPackageId'],
      ),
      replicaEpoch: serializer.fromJson<int>(json['replicaEpoch']),
      baselineCreated: serializer.fromJson<bool>(json['baselineCreated']),
      requiresReconciliation: serializer.fromJson<bool>(
        json['requiresReconciliation'],
      ),
      lastSuccessfulSyncAt: serializer.fromJson<DateTime?>(
        json['lastSuccessfulSyncAt'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncGroupId': serializer.toJson<String?>(syncGroupId),
      'localDeviceId': serializer.toJson<String>(localDeviceId),
      'peerDeviceId': serializer.toJson<String?>(peerDeviceId),
      'nextLocalCounter': serializer.toJson<int>(nextLocalCounter),
      'seenVectorJson': serializer.toJson<String>(seenVectorJson),
      'peerAckVectorJson': serializer.toJson<String>(peerAckVectorJson),
      'lastExportedVectorJson': serializer.toJson<String>(
        lastExportedVectorJson,
      ),
      'lastImportedPackageId': serializer.toJson<String?>(
        lastImportedPackageId,
      ),
      'replicaEpoch': serializer.toJson<int>(replicaEpoch),
      'baselineCreated': serializer.toJson<bool>(baselineCreated),
      'requiresReconciliation': serializer.toJson<bool>(requiresReconciliation),
      'lastSuccessfulSyncAt': serializer.toJson<DateTime?>(
        lastSuccessfulSyncAt,
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncState copyWith({
    String? id,
    Value<String?> syncGroupId = const Value.absent(),
    String? localDeviceId,
    Value<String?> peerDeviceId = const Value.absent(),
    int? nextLocalCounter,
    String? seenVectorJson,
    String? peerAckVectorJson,
    String? lastExportedVectorJson,
    Value<String?> lastImportedPackageId = const Value.absent(),
    int? replicaEpoch,
    bool? baselineCreated,
    bool? requiresReconciliation,
    Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
    DateTime? updatedAt,
  }) => SyncState(
    id: id ?? this.id,
    syncGroupId: syncGroupId.present ? syncGroupId.value : this.syncGroupId,
    localDeviceId: localDeviceId ?? this.localDeviceId,
    peerDeviceId: peerDeviceId.present ? peerDeviceId.value : this.peerDeviceId,
    nextLocalCounter: nextLocalCounter ?? this.nextLocalCounter,
    seenVectorJson: seenVectorJson ?? this.seenVectorJson,
    peerAckVectorJson: peerAckVectorJson ?? this.peerAckVectorJson,
    lastExportedVectorJson:
        lastExportedVectorJson ?? this.lastExportedVectorJson,
    lastImportedPackageId:
        lastImportedPackageId.present
            ? lastImportedPackageId.value
            : this.lastImportedPackageId,
    replicaEpoch: replicaEpoch ?? this.replicaEpoch,
    baselineCreated: baselineCreated ?? this.baselineCreated,
    requiresReconciliation:
        requiresReconciliation ?? this.requiresReconciliation,
    lastSuccessfulSyncAt:
        lastSuccessfulSyncAt.present
            ? lastSuccessfulSyncAt.value
            : this.lastSuccessfulSyncAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncState copyWithCompanion(SyncStatesCompanion data) {
    return SyncState(
      id: data.id.present ? data.id.value : this.id,
      syncGroupId:
          data.syncGroupId.present ? data.syncGroupId.value : this.syncGroupId,
      localDeviceId:
          data.localDeviceId.present
              ? data.localDeviceId.value
              : this.localDeviceId,
      peerDeviceId:
          data.peerDeviceId.present
              ? data.peerDeviceId.value
              : this.peerDeviceId,
      nextLocalCounter:
          data.nextLocalCounter.present
              ? data.nextLocalCounter.value
              : this.nextLocalCounter,
      seenVectorJson:
          data.seenVectorJson.present
              ? data.seenVectorJson.value
              : this.seenVectorJson,
      peerAckVectorJson:
          data.peerAckVectorJson.present
              ? data.peerAckVectorJson.value
              : this.peerAckVectorJson,
      lastExportedVectorJson:
          data.lastExportedVectorJson.present
              ? data.lastExportedVectorJson.value
              : this.lastExportedVectorJson,
      lastImportedPackageId:
          data.lastImportedPackageId.present
              ? data.lastImportedPackageId.value
              : this.lastImportedPackageId,
      replicaEpoch:
          data.replicaEpoch.present
              ? data.replicaEpoch.value
              : this.replicaEpoch,
      baselineCreated:
          data.baselineCreated.present
              ? data.baselineCreated.value
              : this.baselineCreated,
      requiresReconciliation:
          data.requiresReconciliation.present
              ? data.requiresReconciliation.value
              : this.requiresReconciliation,
      lastSuccessfulSyncAt:
          data.lastSuccessfulSyncAt.present
              ? data.lastSuccessfulSyncAt.value
              : this.lastSuccessfulSyncAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncState(')
          ..write('id: $id, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('localDeviceId: $localDeviceId, ')
          ..write('peerDeviceId: $peerDeviceId, ')
          ..write('nextLocalCounter: $nextLocalCounter, ')
          ..write('seenVectorJson: $seenVectorJson, ')
          ..write('peerAckVectorJson: $peerAckVectorJson, ')
          ..write('lastExportedVectorJson: $lastExportedVectorJson, ')
          ..write('lastImportedPackageId: $lastImportedPackageId, ')
          ..write('replicaEpoch: $replicaEpoch, ')
          ..write('baselineCreated: $baselineCreated, ')
          ..write('requiresReconciliation: $requiresReconciliation, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncGroupId,
    localDeviceId,
    peerDeviceId,
    nextLocalCounter,
    seenVectorJson,
    peerAckVectorJson,
    lastExportedVectorJson,
    lastImportedPackageId,
    replicaEpoch,
    baselineCreated,
    requiresReconciliation,
    lastSuccessfulSyncAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncState &&
          other.id == this.id &&
          other.syncGroupId == this.syncGroupId &&
          other.localDeviceId == this.localDeviceId &&
          other.peerDeviceId == this.peerDeviceId &&
          other.nextLocalCounter == this.nextLocalCounter &&
          other.seenVectorJson == this.seenVectorJson &&
          other.peerAckVectorJson == this.peerAckVectorJson &&
          other.lastExportedVectorJson == this.lastExportedVectorJson &&
          other.lastImportedPackageId == this.lastImportedPackageId &&
          other.replicaEpoch == this.replicaEpoch &&
          other.baselineCreated == this.baselineCreated &&
          other.requiresReconciliation == this.requiresReconciliation &&
          other.lastSuccessfulSyncAt == this.lastSuccessfulSyncAt &&
          other.updatedAt == this.updatedAt);
}

class SyncStatesCompanion extends UpdateCompanion<SyncState> {
  final Value<String> id;
  final Value<String?> syncGroupId;
  final Value<String> localDeviceId;
  final Value<String?> peerDeviceId;
  final Value<int> nextLocalCounter;
  final Value<String> seenVectorJson;
  final Value<String> peerAckVectorJson;
  final Value<String> lastExportedVectorJson;
  final Value<String?> lastImportedPackageId;
  final Value<int> replicaEpoch;
  final Value<bool> baselineCreated;
  final Value<bool> requiresReconciliation;
  final Value<DateTime?> lastSuccessfulSyncAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.id = const Value.absent(),
    this.syncGroupId = const Value.absent(),
    this.localDeviceId = const Value.absent(),
    this.peerDeviceId = const Value.absent(),
    this.nextLocalCounter = const Value.absent(),
    this.seenVectorJson = const Value.absent(),
    this.peerAckVectorJson = const Value.absent(),
    this.lastExportedVectorJson = const Value.absent(),
    this.lastImportedPackageId = const Value.absent(),
    this.replicaEpoch = const Value.absent(),
    this.baselineCreated = const Value.absent(),
    this.requiresReconciliation = const Value.absent(),
    this.lastSuccessfulSyncAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String id,
    this.syncGroupId = const Value.absent(),
    required String localDeviceId,
    this.peerDeviceId = const Value.absent(),
    this.nextLocalCounter = const Value.absent(),
    this.seenVectorJson = const Value.absent(),
    this.peerAckVectorJson = const Value.absent(),
    this.lastExportedVectorJson = const Value.absent(),
    this.lastImportedPackageId = const Value.absent(),
    this.replicaEpoch = const Value.absent(),
    this.baselineCreated = const Value.absent(),
    this.requiresReconciliation = const Value.absent(),
    this.lastSuccessfulSyncAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       localDeviceId = Value(localDeviceId),
       updatedAt = Value(updatedAt);
  static Insertable<SyncState> custom({
    Expression<String>? id,
    Expression<String>? syncGroupId,
    Expression<String>? localDeviceId,
    Expression<String>? peerDeviceId,
    Expression<int>? nextLocalCounter,
    Expression<String>? seenVectorJson,
    Expression<String>? peerAckVectorJson,
    Expression<String>? lastExportedVectorJson,
    Expression<String>? lastImportedPackageId,
    Expression<int>? replicaEpoch,
    Expression<bool>? baselineCreated,
    Expression<bool>? requiresReconciliation,
    Expression<DateTime>? lastSuccessfulSyncAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncGroupId != null) 'sync_group_id': syncGroupId,
      if (localDeviceId != null) 'local_device_id': localDeviceId,
      if (peerDeviceId != null) 'peer_device_id': peerDeviceId,
      if (nextLocalCounter != null) 'next_local_counter': nextLocalCounter,
      if (seenVectorJson != null) 'seen_vector_json': seenVectorJson,
      if (peerAckVectorJson != null) 'peer_ack_vector_json': peerAckVectorJson,
      if (lastExportedVectorJson != null)
        'last_exported_vector_json': lastExportedVectorJson,
      if (lastImportedPackageId != null)
        'last_imported_package_id': lastImportedPackageId,
      if (replicaEpoch != null) 'replica_epoch': replicaEpoch,
      if (baselineCreated != null) 'baseline_created': baselineCreated,
      if (requiresReconciliation != null)
        'requires_reconciliation': requiresReconciliation,
      if (lastSuccessfulSyncAt != null)
        'last_successful_sync_at': lastSuccessfulSyncAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith({
    Value<String>? id,
    Value<String?>? syncGroupId,
    Value<String>? localDeviceId,
    Value<String?>? peerDeviceId,
    Value<int>? nextLocalCounter,
    Value<String>? seenVectorJson,
    Value<String>? peerAckVectorJson,
    Value<String>? lastExportedVectorJson,
    Value<String?>? lastImportedPackageId,
    Value<int>? replicaEpoch,
    Value<bool>? baselineCreated,
    Value<bool>? requiresReconciliation,
    Value<DateTime?>? lastSuccessfulSyncAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncStatesCompanion(
      id: id ?? this.id,
      syncGroupId: syncGroupId ?? this.syncGroupId,
      localDeviceId: localDeviceId ?? this.localDeviceId,
      peerDeviceId: peerDeviceId ?? this.peerDeviceId,
      nextLocalCounter: nextLocalCounter ?? this.nextLocalCounter,
      seenVectorJson: seenVectorJson ?? this.seenVectorJson,
      peerAckVectorJson: peerAckVectorJson ?? this.peerAckVectorJson,
      lastExportedVectorJson:
          lastExportedVectorJson ?? this.lastExportedVectorJson,
      lastImportedPackageId:
          lastImportedPackageId ?? this.lastImportedPackageId,
      replicaEpoch: replicaEpoch ?? this.replicaEpoch,
      baselineCreated: baselineCreated ?? this.baselineCreated,
      requiresReconciliation:
          requiresReconciliation ?? this.requiresReconciliation,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncGroupId.present) {
      map['sync_group_id'] = Variable<String>(syncGroupId.value);
    }
    if (localDeviceId.present) {
      map['local_device_id'] = Variable<String>(localDeviceId.value);
    }
    if (peerDeviceId.present) {
      map['peer_device_id'] = Variable<String>(peerDeviceId.value);
    }
    if (nextLocalCounter.present) {
      map['next_local_counter'] = Variable<int>(nextLocalCounter.value);
    }
    if (seenVectorJson.present) {
      map['seen_vector_json'] = Variable<String>(seenVectorJson.value);
    }
    if (peerAckVectorJson.present) {
      map['peer_ack_vector_json'] = Variable<String>(peerAckVectorJson.value);
    }
    if (lastExportedVectorJson.present) {
      map['last_exported_vector_json'] = Variable<String>(
        lastExportedVectorJson.value,
      );
    }
    if (lastImportedPackageId.present) {
      map['last_imported_package_id'] = Variable<String>(
        lastImportedPackageId.value,
      );
    }
    if (replicaEpoch.present) {
      map['replica_epoch'] = Variable<int>(replicaEpoch.value);
    }
    if (baselineCreated.present) {
      map['baseline_created'] = Variable<bool>(baselineCreated.value);
    }
    if (requiresReconciliation.present) {
      map['requires_reconciliation'] = Variable<bool>(
        requiresReconciliation.value,
      );
    }
    if (lastSuccessfulSyncAt.present) {
      map['last_successful_sync_at'] = Variable<DateTime>(
        lastSuccessfulSyncAt.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('id: $id, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('localDeviceId: $localDeviceId, ')
          ..write('peerDeviceId: $peerDeviceId, ')
          ..write('nextLocalCounter: $nextLocalCounter, ')
          ..write('seenVectorJson: $seenVectorJson, ')
          ..write('peerAckVectorJson: $peerAckVectorJson, ')
          ..write('lastExportedVectorJson: $lastExportedVectorJson, ')
          ..write('lastImportedPackageId: $lastImportedPackageId, ')
          ..write('replicaEpoch: $replicaEpoch, ')
          ..write('baselineCreated: $baselineCreated, ')
          ..write('requiresReconciliation: $requiresReconciliation, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncEntityStatesTable extends SyncEntityStates
    with TableInfo<$SyncEntityStatesTable, SyncEntityState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncEntityStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncGroupIdMeta = const VerificationMeta(
    'syncGroupId',
  );
  @override
  late final GeneratedColumn<String> syncGroupId = GeneratedColumn<String>(
    'sync_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldVersionsJsonMeta = const VerificationMeta(
    'fieldVersionsJson',
  );
  @override
  late final GeneratedColumn<String> fieldVersionsJson =
      GeneratedColumn<String>(
        'field_versions_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _entityVectorJsonMeta = const VerificationMeta(
    'entityVectorJson',
  );
  @override
  late final GeneratedColumn<String> entityVectorJson = GeneratedColumn<String>(
    'entity_vector_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastChangeIdMeta = const VerificationMeta(
    'lastChangeId',
  );
  @override
  late final GeneratedColumn<String> lastChangeId = GeneratedColumn<String>(
    'last_change_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncGroupId,
    entityType,
    entityId,
    fieldVersionsJson,
    entityVectorJson,
    lastChangeId,
    contentHash,
    isDeleted,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_entity_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncEntityState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sync_group_id')) {
      context.handle(
        _syncGroupIdMeta,
        syncGroupId.isAcceptableOrUnknown(
          data['sync_group_id']!,
          _syncGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field_versions_json')) {
      context.handle(
        _fieldVersionsJsonMeta,
        fieldVersionsJson.isAcceptableOrUnknown(
          data['field_versions_json']!,
          _fieldVersionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fieldVersionsJsonMeta);
    }
    if (data.containsKey('entity_vector_json')) {
      context.handle(
        _entityVectorJsonMeta,
        entityVectorJson.isAcceptableOrUnknown(
          data['entity_vector_json']!,
          _entityVectorJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityVectorJsonMeta);
    }
    if (data.containsKey('last_change_id')) {
      context.handle(
        _lastChangeIdMeta,
        lastChangeId.isAcceptableOrUnknown(
          data['last_change_id']!,
          _lastChangeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastChangeIdMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncEntityState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncEntityState(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      syncGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_group_id'],
      ),
      entityType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_type'],
          )!,
      entityId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_id'],
          )!,
      fieldVersionsJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}field_versions_json'],
          )!,
      entityVectorJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_vector_json'],
          )!,
      lastChangeId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}last_change_id'],
          )!,
      contentHash:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content_hash'],
          )!,
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $SyncEntityStatesTable createAlias(String alias) {
    return $SyncEntityStatesTable(attachedDatabase, alias);
  }
}

class SyncEntityState extends DataClass implements Insertable<SyncEntityState> {
  final String id;
  final String? syncGroupId;
  final String entityType;
  final String entityId;
  final String fieldVersionsJson;
  final String entityVectorJson;
  final String lastChangeId;
  final String contentHash;
  final bool isDeleted;
  final DateTime updatedAt;
  const SyncEntityState({
    required this.id,
    this.syncGroupId,
    required this.entityType,
    required this.entityId,
    required this.fieldVersionsJson,
    required this.entityVectorJson,
    required this.lastChangeId,
    required this.contentHash,
    required this.isDeleted,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || syncGroupId != null) {
      map['sync_group_id'] = Variable<String>(syncGroupId);
    }
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['field_versions_json'] = Variable<String>(fieldVersionsJson);
    map['entity_vector_json'] = Variable<String>(entityVectorJson);
    map['last_change_id'] = Variable<String>(lastChangeId);
    map['content_hash'] = Variable<String>(contentHash);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncEntityStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncEntityStatesCompanion(
      id: Value(id),
      syncGroupId:
          syncGroupId == null && nullToAbsent
              ? const Value.absent()
              : Value(syncGroupId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      fieldVersionsJson: Value(fieldVersionsJson),
      entityVectorJson: Value(entityVectorJson),
      lastChangeId: Value(lastChangeId),
      contentHash: Value(contentHash),
      isDeleted: Value(isDeleted),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncEntityState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncEntityState(
      id: serializer.fromJson<String>(json['id']),
      syncGroupId: serializer.fromJson<String?>(json['syncGroupId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      fieldVersionsJson: serializer.fromJson<String>(json['fieldVersionsJson']),
      entityVectorJson: serializer.fromJson<String>(json['entityVectorJson']),
      lastChangeId: serializer.fromJson<String>(json['lastChangeId']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncGroupId': serializer.toJson<String?>(syncGroupId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'fieldVersionsJson': serializer.toJson<String>(fieldVersionsJson),
      'entityVectorJson': serializer.toJson<String>(entityVectorJson),
      'lastChangeId': serializer.toJson<String>(lastChangeId),
      'contentHash': serializer.toJson<String>(contentHash),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncEntityState copyWith({
    String? id,
    Value<String?> syncGroupId = const Value.absent(),
    String? entityType,
    String? entityId,
    String? fieldVersionsJson,
    String? entityVectorJson,
    String? lastChangeId,
    String? contentHash,
    bool? isDeleted,
    DateTime? updatedAt,
  }) => SyncEntityState(
    id: id ?? this.id,
    syncGroupId: syncGroupId.present ? syncGroupId.value : this.syncGroupId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    fieldVersionsJson: fieldVersionsJson ?? this.fieldVersionsJson,
    entityVectorJson: entityVectorJson ?? this.entityVectorJson,
    lastChangeId: lastChangeId ?? this.lastChangeId,
    contentHash: contentHash ?? this.contentHash,
    isDeleted: isDeleted ?? this.isDeleted,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncEntityState copyWithCompanion(SyncEntityStatesCompanion data) {
    return SyncEntityState(
      id: data.id.present ? data.id.value : this.id,
      syncGroupId:
          data.syncGroupId.present ? data.syncGroupId.value : this.syncGroupId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      fieldVersionsJson:
          data.fieldVersionsJson.present
              ? data.fieldVersionsJson.value
              : this.fieldVersionsJson,
      entityVectorJson:
          data.entityVectorJson.present
              ? data.entityVectorJson.value
              : this.entityVectorJson,
      lastChangeId:
          data.lastChangeId.present
              ? data.lastChangeId.value
              : this.lastChangeId,
      contentHash:
          data.contentHash.present ? data.contentHash.value : this.contentHash,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntityState(')
          ..write('id: $id, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('fieldVersionsJson: $fieldVersionsJson, ')
          ..write('entityVectorJson: $entityVectorJson, ')
          ..write('lastChangeId: $lastChangeId, ')
          ..write('contentHash: $contentHash, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncGroupId,
    entityType,
    entityId,
    fieldVersionsJson,
    entityVectorJson,
    lastChangeId,
    contentHash,
    isDeleted,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncEntityState &&
          other.id == this.id &&
          other.syncGroupId == this.syncGroupId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.fieldVersionsJson == this.fieldVersionsJson &&
          other.entityVectorJson == this.entityVectorJson &&
          other.lastChangeId == this.lastChangeId &&
          other.contentHash == this.contentHash &&
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt);
}

class SyncEntityStatesCompanion extends UpdateCompanion<SyncEntityState> {
  final Value<String> id;
  final Value<String?> syncGroupId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> fieldVersionsJson;
  final Value<String> entityVectorJson;
  final Value<String> lastChangeId;
  final Value<String> contentHash;
  final Value<bool> isDeleted;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncEntityStatesCompanion({
    this.id = const Value.absent(),
    this.syncGroupId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.fieldVersionsJson = const Value.absent(),
    this.entityVectorJson = const Value.absent(),
    this.lastChangeId = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncEntityStatesCompanion.insert({
    required String id,
    this.syncGroupId = const Value.absent(),
    required String entityType,
    required String entityId,
    required String fieldVersionsJson,
    required String entityVectorJson,
    required String lastChangeId,
    required String contentHash,
    this.isDeleted = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       fieldVersionsJson = Value(fieldVersionsJson),
       entityVectorJson = Value(entityVectorJson),
       lastChangeId = Value(lastChangeId),
       contentHash = Value(contentHash),
       updatedAt = Value(updatedAt);
  static Insertable<SyncEntityState> custom({
    Expression<String>? id,
    Expression<String>? syncGroupId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? fieldVersionsJson,
    Expression<String>? entityVectorJson,
    Expression<String>? lastChangeId,
    Expression<String>? contentHash,
    Expression<bool>? isDeleted,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncGroupId != null) 'sync_group_id': syncGroupId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (fieldVersionsJson != null) 'field_versions_json': fieldVersionsJson,
      if (entityVectorJson != null) 'entity_vector_json': entityVectorJson,
      if (lastChangeId != null) 'last_change_id': lastChangeId,
      if (contentHash != null) 'content_hash': contentHash,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncEntityStatesCompanion copyWith({
    Value<String>? id,
    Value<String?>? syncGroupId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? fieldVersionsJson,
    Value<String>? entityVectorJson,
    Value<String>? lastChangeId,
    Value<String>? contentHash,
    Value<bool>? isDeleted,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncEntityStatesCompanion(
      id: id ?? this.id,
      syncGroupId: syncGroupId ?? this.syncGroupId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      fieldVersionsJson: fieldVersionsJson ?? this.fieldVersionsJson,
      entityVectorJson: entityVectorJson ?? this.entityVectorJson,
      lastChangeId: lastChangeId ?? this.lastChangeId,
      contentHash: contentHash ?? this.contentHash,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncGroupId.present) {
      map['sync_group_id'] = Variable<String>(syncGroupId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (fieldVersionsJson.present) {
      map['field_versions_json'] = Variable<String>(fieldVersionsJson.value);
    }
    if (entityVectorJson.present) {
      map['entity_vector_json'] = Variable<String>(entityVectorJson.value);
    }
    if (lastChangeId.present) {
      map['last_change_id'] = Variable<String>(lastChangeId.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntityStatesCompanion(')
          ..write('id: $id, ')
          ..write('syncGroupId: $syncGroupId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('fieldVersionsJson: $fieldVersionsJson, ')
          ..write('entityVectorJson: $entityVectorJson, ')
          ..write('lastChangeId: $lastChangeId, ')
          ..write('contentHash: $contentHash, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GamesTable games = $GamesTable(this);
  late final $LibraryEntriesTable libraryEntries = $LibraryEntriesTable(this);
  late final $PlatformsTable platforms = $PlatformsTable(this);
  late final $LibraryEntryPlatformsTable libraryEntryPlatforms =
      $LibraryEntryPlatformsTable(this);
  late final $GenresTable genres = $GenresTable(this);
  late final $GameGenresTable gameGenres = $GameGenresTable(this);
  late final $PlaythroughsTable playthroughs = $PlaythroughsTable(this);
  late final $SavedViewsTable savedViews = $SavedViewsTable(this);
  late final $ExternalGameIdsTable externalGameIds = $ExternalGameIdsTable(
    this,
  );
  late final $MediaAssetsTable mediaAssets = $MediaAssetsTable(this);
  late final $SyncGroupsTable syncGroups = $SyncGroupsTable(this);
  late final $SyncDevicesTable syncDevices = $SyncDevicesTable(this);
  late final $SyncChangesTable syncChanges = $SyncChangesTable(this);
  late final $SyncTombstonesTable syncTombstones = $SyncTombstonesTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final $SyncEntityStatesTable syncEntityStates = $SyncEntityStatesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    games,
    libraryEntries,
    platforms,
    libraryEntryPlatforms,
    genres,
    gameGenres,
    playthroughs,
    savedViews,
    externalGameIds,
    mediaAssets,
    syncGroups,
    syncDevices,
    syncChanges,
    syncTombstones,
    syncStates,
    syncEntityStates,
  ];
}

typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      required String id,
      required String title,
      Value<String?> sortTitle,
      Value<DateTime?> releaseDate,
      Value<String> type,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> sortTitle,
      Value<DateTime?> releaseDate,
      Value<String> type,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, Game> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LibraryEntriesTable, List<LibraryEntry>>
  _libraryEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.libraryEntries,
    aliasName: $_aliasNameGenerator(db.games.id, db.libraryEntries.gameId),
  );

  $$LibraryEntriesTableProcessedTableManager get libraryEntriesRefs {
    final manager = $$LibraryEntriesTableTableManager(
      $_db,
      $_db.libraryEntries,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_libraryEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GameGenresTable, List<GameGenre>>
  _gameGenresRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameGenres,
    aliasName: $_aliasNameGenerator(db.games.id, db.gameGenres.gameId),
  );

  $$GameGenresTableProcessedTableManager get gameGenresRefs {
    final manager = $$GameGenresTableTableManager(
      $_db,
      $_db.gameGenres,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameGenresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExternalGameIdsTable, List<ExternalGameId>>
  _externalGameIdsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.externalGameIds,
    aliasName: $_aliasNameGenerator(db.games.id, db.externalGameIds.gameId),
  );

  $$ExternalGameIdsTableProcessedTableManager get externalGameIdsRefs {
    final manager = $$ExternalGameIdsTableTableManager(
      $_db,
      $_db.externalGameIds,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _externalGameIdsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MediaAssetsTable, List<MediaAsset>>
  _mediaAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mediaAssets,
    aliasName: $_aliasNameGenerator(db.games.id, db.mediaAssets.gameId),
  );

  $$MediaAssetsTableProcessedTableManager get mediaAssetsRefs {
    final manager = $$MediaAssetsTableTableManager(
      $_db,
      $_db.mediaAssets,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mediaAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortTitle => $composableBuilder(
    column: $table.sortTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> libraryEntriesRefs(
    Expression<bool> Function($$LibraryEntriesTableFilterComposer f) f,
  ) {
    final $$LibraryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gameGenresRefs(
    Expression<bool> Function($$GameGenresTableFilterComposer f) f,
  ) {
    final $$GameGenresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameGenres,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameGenresTableFilterComposer(
            $db: $db,
            $table: $db.gameGenres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> externalGameIdsRefs(
    Expression<bool> Function($$ExternalGameIdsTableFilterComposer f) f,
  ) {
    final $$ExternalGameIdsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.externalGameIds,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExternalGameIdsTableFilterComposer(
            $db: $db,
            $table: $db.externalGameIds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mediaAssetsRefs(
    Expression<bool> Function($$MediaAssetsTableFilterComposer f) f,
  ) {
    final $$MediaAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaAssets,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaAssetsTableFilterComposer(
            $db: $db,
            $table: $db.mediaAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortTitle => $composableBuilder(
    column: $table.sortTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sortTitle =>
      $composableBuilder(column: $table.sortTitle, builder: (column) => column);

  GeneratedColumn<DateTime> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> libraryEntriesRefs<T extends Object>(
    Expression<T> Function($$LibraryEntriesTableAnnotationComposer a) f,
  ) {
    final $$LibraryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gameGenresRefs<T extends Object>(
    Expression<T> Function($$GameGenresTableAnnotationComposer a) f,
  ) {
    final $$GameGenresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameGenres,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameGenresTableAnnotationComposer(
            $db: $db,
            $table: $db.gameGenres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> externalGameIdsRefs<T extends Object>(
    Expression<T> Function($$ExternalGameIdsTableAnnotationComposer a) f,
  ) {
    final $$ExternalGameIdsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.externalGameIds,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExternalGameIdsTableAnnotationComposer(
            $db: $db,
            $table: $db.externalGameIds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mediaAssetsRefs<T extends Object>(
    Expression<T> Function($$MediaAssetsTableAnnotationComposer a) f,
  ) {
    final $$MediaAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaAssets,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          Game,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (Game, $$GamesTableReferences),
          Game,
          PrefetchHooks Function({
            bool libraryEntriesRefs,
            bool gameGenresRefs,
            bool externalGameIdsRefs,
            bool mediaAssetsRefs,
          })
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> sortTitle = const Value.absent(),
                Value<DateTime?> releaseDate = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                title: title,
                sortTitle: sortTitle,
                releaseDate: releaseDate,
                type: type,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> sortTitle = const Value.absent(),
                Value<DateTime?> releaseDate = const Value.absent(),
                Value<String> type = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                title: title,
                sortTitle: sortTitle,
                releaseDate: releaseDate,
                type: type,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$GamesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            libraryEntriesRefs = false,
            gameGenresRefs = false,
            externalGameIdsRefs = false,
            mediaAssetsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (libraryEntriesRefs) db.libraryEntries,
                if (gameGenresRefs) db.gameGenres,
                if (externalGameIdsRefs) db.externalGameIds,
                if (mediaAssetsRefs) db.mediaAssets,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (libraryEntriesRefs)
                    await $_getPrefetchedData<Game, $GamesTable, LibraryEntry>(
                      currentTable: table,
                      referencedTable: $$GamesTableReferences
                          ._libraryEntriesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).libraryEntriesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.gameId == item.id),
                      typedResults: items,
                    ),
                  if (gameGenresRefs)
                    await $_getPrefetchedData<Game, $GamesTable, GameGenre>(
                      currentTable: table,
                      referencedTable: $$GamesTableReferences
                          ._gameGenresRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).gameGenresRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.gameId == item.id),
                      typedResults: items,
                    ),
                  if (externalGameIdsRefs)
                    await $_getPrefetchedData<
                      Game,
                      $GamesTable,
                      ExternalGameId
                    >(
                      currentTable: table,
                      referencedTable: $$GamesTableReferences
                          ._externalGameIdsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).externalGameIdsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.gameId == item.id),
                      typedResults: items,
                    ),
                  if (mediaAssetsRefs)
                    await $_getPrefetchedData<Game, $GamesTable, MediaAsset>(
                      currentTable: table,
                      referencedTable: $$GamesTableReferences
                          ._mediaAssetsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).mediaAssetsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.gameId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      Game,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (Game, $$GamesTableReferences),
      Game,
      PrefetchHooks Function({
        bool libraryEntriesRefs,
        bool gameGenresRefs,
        bool externalGameIdsRefs,
        bool mediaAssetsRefs,
      })
    >;
typedef $$LibraryEntriesTableCreateCompanionBuilder =
    LibraryEntriesCompanion Function({
      required String id,
      required String gameId,
      required String status,
      Value<int?> personalRating,
      Value<String?> personalNotes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LibraryEntriesTableUpdateCompanionBuilder =
    LibraryEntriesCompanion Function({
      Value<String> id,
      Value<String> gameId,
      Value<String> status,
      Value<int?> personalRating,
      Value<String?> personalNotes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$LibraryEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $LibraryEntriesTable, LibraryEntry> {
  $$LibraryEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games.createAlias(
    $_aliasNameGenerator(db.libraryEntries.gameId, db.games.id),
  );

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $LibraryEntryPlatformsTable,
    List<LibraryEntryPlatform>
  >
  _libraryEntryPlatformsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.libraryEntryPlatforms,
        aliasName: $_aliasNameGenerator(
          db.libraryEntries.id,
          db.libraryEntryPlatforms.libraryEntryId,
        ),
      );

  $$LibraryEntryPlatformsTableProcessedTableManager
  get libraryEntryPlatformsRefs {
    final manager = $$LibraryEntryPlatformsTableTableManager(
      $_db,
      $_db.libraryEntryPlatforms,
    ).filter((f) => f.libraryEntryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _libraryEntryPlatformsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlaythroughsTable, List<Playthrough>>
  _playthroughsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playthroughs,
    aliasName: $_aliasNameGenerator(
      db.libraryEntries.id,
      db.playthroughs.libraryEntryId,
    ),
  );

  $$PlaythroughsTableProcessedTableManager get playthroughsRefs {
    final manager = $$PlaythroughsTableTableManager(
      $_db,
      $_db.playthroughs,
    ).filter((f) => f.libraryEntryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playthroughsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LibraryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get personalRating => $composableBuilder(
    column: $table.personalRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personalNotes => $composableBuilder(
    column: $table.personalNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> libraryEntryPlatformsRefs(
    Expression<bool> Function($$LibraryEntryPlatformsTableFilterComposer f) f,
  ) {
    final $$LibraryEntryPlatformsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.libraryEntryPlatforms,
          getReferencedColumn: (t) => t.libraryEntryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LibraryEntryPlatformsTableFilterComposer(
                $db: $db,
                $table: $db.libraryEntryPlatforms,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> playthroughsRefs(
    Expression<bool> Function($$PlaythroughsTableFilterComposer f) f,
  ) {
    final $$PlaythroughsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playthroughs,
      getReferencedColumn: (t) => t.libraryEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaythroughsTableFilterComposer(
            $db: $db,
            $table: $db.playthroughs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get personalRating => $composableBuilder(
    column: $table.personalRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personalNotes => $composableBuilder(
    column: $table.personalNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get personalRating => $composableBuilder(
    column: $table.personalRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personalNotes => $composableBuilder(
    column: $table.personalNotes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> libraryEntryPlatformsRefs<T extends Object>(
    Expression<T> Function($$LibraryEntryPlatformsTableAnnotationComposer a) f,
  ) {
    final $$LibraryEntryPlatformsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.libraryEntryPlatforms,
          getReferencedColumn: (t) => t.libraryEntryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LibraryEntryPlatformsTableAnnotationComposer(
                $db: $db,
                $table: $db.libraryEntryPlatforms,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> playthroughsRefs<T extends Object>(
    Expression<T> Function($$PlaythroughsTableAnnotationComposer a) f,
  ) {
    final $$PlaythroughsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playthroughs,
      getReferencedColumn: (t) => t.libraryEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaythroughsTableAnnotationComposer(
            $db: $db,
            $table: $db.playthroughs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryEntriesTable,
          LibraryEntry,
          $$LibraryEntriesTableFilterComposer,
          $$LibraryEntriesTableOrderingComposer,
          $$LibraryEntriesTableAnnotationComposer,
          $$LibraryEntriesTableCreateCompanionBuilder,
          $$LibraryEntriesTableUpdateCompanionBuilder,
          (LibraryEntry, $$LibraryEntriesTableReferences),
          LibraryEntry,
          PrefetchHooks Function({
            bool gameId,
            bool libraryEntryPlatformsRefs,
            bool playthroughsRefs,
          })
        > {
  $$LibraryEntriesTableTableManager(
    _$AppDatabase db,
    $LibraryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LibraryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LibraryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LibraryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> personalRating = const Value.absent(),
                Value<String?> personalNotes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntriesCompanion(
                id: id,
                gameId: gameId,
                status: status,
                personalRating: personalRating,
                personalNotes: personalNotes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gameId,
                required String status,
                Value<int?> personalRating = const Value.absent(),
                Value<String?> personalNotes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntriesCompanion.insert(
                id: id,
                gameId: gameId,
                status: status,
                personalRating: personalRating,
                personalNotes: personalNotes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LibraryEntriesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            gameId = false,
            libraryEntryPlatformsRefs = false,
            playthroughsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (libraryEntryPlatformsRefs) db.libraryEntryPlatforms,
                if (playthroughsRefs) db.playthroughs,
              ],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (gameId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.gameId,
                            referencedTable: $$LibraryEntriesTableReferences
                                ._gameIdTable(db),
                            referencedColumn:
                                $$LibraryEntriesTableReferences
                                    ._gameIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (libraryEntryPlatformsRefs)
                    await $_getPrefetchedData<
                      LibraryEntry,
                      $LibraryEntriesTable,
                      LibraryEntryPlatform
                    >(
                      currentTable: table,
                      referencedTable: $$LibraryEntriesTableReferences
                          ._libraryEntryPlatformsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$LibraryEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).libraryEntryPlatformsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.libraryEntryId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (playthroughsRefs)
                    await $_getPrefetchedData<
                      LibraryEntry,
                      $LibraryEntriesTable,
                      Playthrough
                    >(
                      currentTable: table,
                      referencedTable: $$LibraryEntriesTableReferences
                          ._playthroughsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$LibraryEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).playthroughsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.libraryEntryId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LibraryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryEntriesTable,
      LibraryEntry,
      $$LibraryEntriesTableFilterComposer,
      $$LibraryEntriesTableOrderingComposer,
      $$LibraryEntriesTableAnnotationComposer,
      $$LibraryEntriesTableCreateCompanionBuilder,
      $$LibraryEntriesTableUpdateCompanionBuilder,
      (LibraryEntry, $$LibraryEntriesTableReferences),
      LibraryEntry,
      PrefetchHooks Function({
        bool gameId,
        bool libraryEntryPlatformsRefs,
        bool playthroughsRefs,
      })
    >;
typedef $$PlatformsTableCreateCompanionBuilder =
    PlatformsCompanion Function({
      required String id,
      required String name,
      Value<String?> shortName,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PlatformsTableUpdateCompanionBuilder =
    PlatformsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> shortName,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$PlatformsTableReferences
    extends BaseReferences<_$AppDatabase, $PlatformsTable, Platform> {
  $$PlatformsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $LibraryEntryPlatformsTable,
    List<LibraryEntryPlatform>
  >
  _libraryEntryPlatformsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.libraryEntryPlatforms,
        aliasName: $_aliasNameGenerator(
          db.platforms.id,
          db.libraryEntryPlatforms.platformId,
        ),
      );

  $$LibraryEntryPlatformsTableProcessedTableManager
  get libraryEntryPlatformsRefs {
    final manager = $$LibraryEntryPlatformsTableTableManager(
      $_db,
      $_db.libraryEntryPlatforms,
    ).filter((f) => f.platformId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _libraryEntryPlatformsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlaythroughsTable, List<Playthrough>>
  _playthroughsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playthroughs,
    aliasName: $_aliasNameGenerator(
      db.platforms.id,
      db.playthroughs.platformId,
    ),
  );

  $$PlaythroughsTableProcessedTableManager get playthroughsRefs {
    final manager = $$PlaythroughsTableTableManager(
      $_db,
      $_db.playthroughs,
    ).filter((f) => f.platformId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playthroughsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlatformsTableFilterComposer
    extends Composer<_$AppDatabase, $PlatformsTable> {
  $$PlatformsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> libraryEntryPlatformsRefs(
    Expression<bool> Function($$LibraryEntryPlatformsTableFilterComposer f) f,
  ) {
    final $$LibraryEntryPlatformsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.libraryEntryPlatforms,
          getReferencedColumn: (t) => t.platformId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LibraryEntryPlatformsTableFilterComposer(
                $db: $db,
                $table: $db.libraryEntryPlatforms,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> playthroughsRefs(
    Expression<bool> Function($$PlaythroughsTableFilterComposer f) f,
  ) {
    final $$PlaythroughsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playthroughs,
      getReferencedColumn: (t) => t.platformId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaythroughsTableFilterComposer(
            $db: $db,
            $table: $db.playthroughs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlatformsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlatformsTable> {
  $$PlatformsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlatformsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlatformsTable> {
  $$PlatformsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> libraryEntryPlatformsRefs<T extends Object>(
    Expression<T> Function($$LibraryEntryPlatformsTableAnnotationComposer a) f,
  ) {
    final $$LibraryEntryPlatformsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.libraryEntryPlatforms,
          getReferencedColumn: (t) => t.platformId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LibraryEntryPlatformsTableAnnotationComposer(
                $db: $db,
                $table: $db.libraryEntryPlatforms,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> playthroughsRefs<T extends Object>(
    Expression<T> Function($$PlaythroughsTableAnnotationComposer a) f,
  ) {
    final $$PlaythroughsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playthroughs,
      getReferencedColumn: (t) => t.platformId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaythroughsTableAnnotationComposer(
            $db: $db,
            $table: $db.playthroughs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlatformsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlatformsTable,
          Platform,
          $$PlatformsTableFilterComposer,
          $$PlatformsTableOrderingComposer,
          $$PlatformsTableAnnotationComposer,
          $$PlatformsTableCreateCompanionBuilder,
          $$PlatformsTableUpdateCompanionBuilder,
          (Platform, $$PlatformsTableReferences),
          Platform,
          PrefetchHooks Function({
            bool libraryEntryPlatformsRefs,
            bool playthroughsRefs,
          })
        > {
  $$PlatformsTableTableManager(_$AppDatabase db, $PlatformsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PlatformsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PlatformsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PlatformsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> shortName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlatformsCompanion(
                id: id,
                name: name,
                shortName: shortName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> shortName = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlatformsCompanion.insert(
                id: id,
                name: name,
                shortName: shortName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PlatformsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            libraryEntryPlatformsRefs = false,
            playthroughsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (libraryEntryPlatformsRefs) db.libraryEntryPlatforms,
                if (playthroughsRefs) db.playthroughs,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (libraryEntryPlatformsRefs)
                    await $_getPrefetchedData<
                      Platform,
                      $PlatformsTable,
                      LibraryEntryPlatform
                    >(
                      currentTable: table,
                      referencedTable: $$PlatformsTableReferences
                          ._libraryEntryPlatformsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PlatformsTableReferences(
                                db,
                                table,
                                p0,
                              ).libraryEntryPlatformsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.platformId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (playthroughsRefs)
                    await $_getPrefetchedData<
                      Platform,
                      $PlatformsTable,
                      Playthrough
                    >(
                      currentTable: table,
                      referencedTable: $$PlatformsTableReferences
                          ._playthroughsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PlatformsTableReferences(
                                db,
                                table,
                                p0,
                              ).playthroughsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.platformId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlatformsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlatformsTable,
      Platform,
      $$PlatformsTableFilterComposer,
      $$PlatformsTableOrderingComposer,
      $$PlatformsTableAnnotationComposer,
      $$PlatformsTableCreateCompanionBuilder,
      $$PlatformsTableUpdateCompanionBuilder,
      (Platform, $$PlatformsTableReferences),
      Platform,
      PrefetchHooks Function({
        bool libraryEntryPlatformsRefs,
        bool playthroughsRefs,
      })
    >;
typedef $$LibraryEntryPlatformsTableCreateCompanionBuilder =
    LibraryEntryPlatformsCompanion Function({
      required String id,
      required String libraryEntryId,
      required String platformId,
      Value<bool> isPrimary,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LibraryEntryPlatformsTableUpdateCompanionBuilder =
    LibraryEntryPlatformsCompanion Function({
      Value<String> id,
      Value<String> libraryEntryId,
      Value<String> platformId,
      Value<bool> isPrimary,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$LibraryEntryPlatformsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LibraryEntryPlatformsTable,
          LibraryEntryPlatform
        > {
  $$LibraryEntryPlatformsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LibraryEntriesTable _libraryEntryIdTable(_$AppDatabase db) =>
      db.libraryEntries.createAlias(
        $_aliasNameGenerator(
          db.libraryEntryPlatforms.libraryEntryId,
          db.libraryEntries.id,
        ),
      );

  $$LibraryEntriesTableProcessedTableManager get libraryEntryId {
    final $_column = $_itemColumn<String>('library_entry_id')!;

    final manager = $$LibraryEntriesTableTableManager(
      $_db,
      $_db.libraryEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_libraryEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlatformsTable _platformIdTable(_$AppDatabase db) =>
      db.platforms.createAlias(
        $_aliasNameGenerator(
          db.libraryEntryPlatforms.platformId,
          db.platforms.id,
        ),
      );

  $$PlatformsTableProcessedTableManager get platformId {
    final $_column = $_itemColumn<String>('platform_id')!;

    final manager = $$PlatformsTableTableManager(
      $_db,
      $_db.platforms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_platformIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LibraryEntryPlatformsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryEntryPlatformsTable> {
  $$LibraryEntryPlatformsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LibraryEntriesTableFilterComposer get libraryEntryId {
    final $$LibraryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.libraryEntryId,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlatformsTableFilterComposer get platformId {
    final $$PlatformsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.platformId,
      referencedTable: $db.platforms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatformsTableFilterComposer(
            $db: $db,
            $table: $db.platforms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryEntryPlatformsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryEntryPlatformsTable> {
  $$LibraryEntryPlatformsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibraryEntriesTableOrderingComposer get libraryEntryId {
    final $$LibraryEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.libraryEntryId,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlatformsTableOrderingComposer get platformId {
    final $$PlatformsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.platformId,
      referencedTable: $db.platforms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatformsTableOrderingComposer(
            $db: $db,
            $table: $db.platforms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryEntryPlatformsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryEntryPlatformsTable> {
  $$LibraryEntryPlatformsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$LibraryEntriesTableAnnotationComposer get libraryEntryId {
    final $$LibraryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.libraryEntryId,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlatformsTableAnnotationComposer get platformId {
    final $$PlatformsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.platformId,
      referencedTable: $db.platforms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatformsTableAnnotationComposer(
            $db: $db,
            $table: $db.platforms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryEntryPlatformsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryEntryPlatformsTable,
          LibraryEntryPlatform,
          $$LibraryEntryPlatformsTableFilterComposer,
          $$LibraryEntryPlatformsTableOrderingComposer,
          $$LibraryEntryPlatformsTableAnnotationComposer,
          $$LibraryEntryPlatformsTableCreateCompanionBuilder,
          $$LibraryEntryPlatformsTableUpdateCompanionBuilder,
          (LibraryEntryPlatform, $$LibraryEntryPlatformsTableReferences),
          LibraryEntryPlatform,
          PrefetchHooks Function({bool libraryEntryId, bool platformId})
        > {
  $$LibraryEntryPlatformsTableTableManager(
    _$AppDatabase db,
    $LibraryEntryPlatformsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LibraryEntryPlatformsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$LibraryEntryPlatformsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$LibraryEntryPlatformsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> libraryEntryId = const Value.absent(),
                Value<String> platformId = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntryPlatformsCompanion(
                id: id,
                libraryEntryId: libraryEntryId,
                platformId: platformId,
                isPrimary: isPrimary,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String libraryEntryId,
                required String platformId,
                Value<bool> isPrimary = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntryPlatformsCompanion.insert(
                id: id,
                libraryEntryId: libraryEntryId,
                platformId: platformId,
                isPrimary: isPrimary,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LibraryEntryPlatformsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            libraryEntryId = false,
            platformId = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (libraryEntryId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.libraryEntryId,
                            referencedTable:
                                $$LibraryEntryPlatformsTableReferences
                                    ._libraryEntryIdTable(db),
                            referencedColumn:
                                $$LibraryEntryPlatformsTableReferences
                                    ._libraryEntryIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (platformId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.platformId,
                            referencedTable:
                                $$LibraryEntryPlatformsTableReferences
                                    ._platformIdTable(db),
                            referencedColumn:
                                $$LibraryEntryPlatformsTableReferences
                                    ._platformIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LibraryEntryPlatformsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryEntryPlatformsTable,
      LibraryEntryPlatform,
      $$LibraryEntryPlatformsTableFilterComposer,
      $$LibraryEntryPlatformsTableOrderingComposer,
      $$LibraryEntryPlatformsTableAnnotationComposer,
      $$LibraryEntryPlatformsTableCreateCompanionBuilder,
      $$LibraryEntryPlatformsTableUpdateCompanionBuilder,
      (LibraryEntryPlatform, $$LibraryEntryPlatformsTableReferences),
      LibraryEntryPlatform,
      PrefetchHooks Function({bool libraryEntryId, bool platformId})
    >;
typedef $$GenresTableCreateCompanionBuilder =
    GenresCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$GenresTableUpdateCompanionBuilder =
    GenresCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$GenresTableReferences
    extends BaseReferences<_$AppDatabase, $GenresTable, Genre> {
  $$GenresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GameGenresTable, List<GameGenre>>
  _gameGenresRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameGenres,
    aliasName: $_aliasNameGenerator(db.genres.id, db.gameGenres.genreId),
  );

  $$GameGenresTableProcessedTableManager get gameGenresRefs {
    final manager = $$GameGenresTableTableManager(
      $_db,
      $_db.gameGenres,
    ).filter((f) => f.genreId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameGenresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GenresTableFilterComposer
    extends Composer<_$AppDatabase, $GenresTable> {
  $$GenresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gameGenresRefs(
    Expression<bool> Function($$GameGenresTableFilterComposer f) f,
  ) {
    final $$GameGenresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameGenres,
      getReferencedColumn: (t) => t.genreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameGenresTableFilterComposer(
            $db: $db,
            $table: $db.gameGenres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GenresTableOrderingComposer
    extends Composer<_$AppDatabase, $GenresTable> {
  $$GenresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GenresTableAnnotationComposer
    extends Composer<_$AppDatabase, $GenresTable> {
  $$GenresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> gameGenresRefs<T extends Object>(
    Expression<T> Function($$GameGenresTableAnnotationComposer a) f,
  ) {
    final $$GameGenresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameGenres,
      getReferencedColumn: (t) => t.genreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameGenresTableAnnotationComposer(
            $db: $db,
            $table: $db.gameGenres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GenresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GenresTable,
          Genre,
          $$GenresTableFilterComposer,
          $$GenresTableOrderingComposer,
          $$GenresTableAnnotationComposer,
          $$GenresTableCreateCompanionBuilder,
          $$GenresTableUpdateCompanionBuilder,
          (Genre, $$GenresTableReferences),
          Genre,
          PrefetchHooks Function({bool gameGenresRefs})
        > {
  $$GenresTableTableManager(_$AppDatabase db, $GenresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$GenresTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$GenresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$GenresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GenresCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GenresCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$GenresTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({gameGenresRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gameGenresRefs) db.gameGenres],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gameGenresRefs)
                    await $_getPrefetchedData<Genre, $GenresTable, GameGenre>(
                      currentTable: table,
                      referencedTable: $$GenresTableReferences
                          ._gameGenresRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$GenresTableReferences(
                                db,
                                table,
                                p0,
                              ).gameGenresRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.genreId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GenresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GenresTable,
      Genre,
      $$GenresTableFilterComposer,
      $$GenresTableOrderingComposer,
      $$GenresTableAnnotationComposer,
      $$GenresTableCreateCompanionBuilder,
      $$GenresTableUpdateCompanionBuilder,
      (Genre, $$GenresTableReferences),
      Genre,
      PrefetchHooks Function({bool gameGenresRefs})
    >;
typedef $$GameGenresTableCreateCompanionBuilder =
    GameGenresCompanion Function({
      required String id,
      required String gameId,
      required String genreId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$GameGenresTableUpdateCompanionBuilder =
    GameGenresCompanion Function({
      Value<String> id,
      Value<String> gameId,
      Value<String> genreId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$GameGenresTableReferences
    extends BaseReferences<_$AppDatabase, $GameGenresTable, GameGenre> {
  $$GameGenresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games.createAlias(
    $_aliasNameGenerator(db.gameGenres.gameId, db.games.id),
  );

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GenresTable _genreIdTable(_$AppDatabase db) => db.genres.createAlias(
    $_aliasNameGenerator(db.gameGenres.genreId, db.genres.id),
  );

  $$GenresTableProcessedTableManager get genreId {
    final $_column = $_itemColumn<String>('genre_id')!;

    final manager = $$GenresTableTableManager(
      $_db,
      $_db.genres,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_genreIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GameGenresTableFilterComposer
    extends Composer<_$AppDatabase, $GameGenresTable> {
  $$GameGenresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GenresTableFilterComposer get genreId {
    final $$GenresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genreId,
      referencedTable: $db.genres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenresTableFilterComposer(
            $db: $db,
            $table: $db.genres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameGenresTableOrderingComposer
    extends Composer<_$AppDatabase, $GameGenresTable> {
  $$GameGenresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GenresTableOrderingComposer get genreId {
    final $$GenresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genreId,
      referencedTable: $db.genres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenresTableOrderingComposer(
            $db: $db,
            $table: $db.genres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameGenresTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameGenresTable> {
  $$GameGenresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GenresTableAnnotationComposer get genreId {
    final $$GenresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genreId,
      referencedTable: $db.genres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenresTableAnnotationComposer(
            $db: $db,
            $table: $db.genres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameGenresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameGenresTable,
          GameGenre,
          $$GameGenresTableFilterComposer,
          $$GameGenresTableOrderingComposer,
          $$GameGenresTableAnnotationComposer,
          $$GameGenresTableCreateCompanionBuilder,
          $$GameGenresTableUpdateCompanionBuilder,
          (GameGenre, $$GameGenresTableReferences),
          GameGenre,
          PrefetchHooks Function({bool gameId, bool genreId})
        > {
  $$GameGenresTableTableManager(_$AppDatabase db, $GameGenresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$GameGenresTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$GameGenresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$GameGenresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> genreId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameGenresCompanion(
                id: id,
                gameId: gameId,
                genreId: genreId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gameId,
                required String genreId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameGenresCompanion.insert(
                id: id,
                gameId: gameId,
                genreId: genreId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$GameGenresTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({gameId = false, genreId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (gameId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.gameId,
                            referencedTable: $$GameGenresTableReferences
                                ._gameIdTable(db),
                            referencedColumn:
                                $$GameGenresTableReferences._gameIdTable(db).id,
                          )
                          as T;
                }
                if (genreId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.genreId,
                            referencedTable: $$GameGenresTableReferences
                                ._genreIdTable(db),
                            referencedColumn:
                                $$GameGenresTableReferences
                                    ._genreIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GameGenresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameGenresTable,
      GameGenre,
      $$GameGenresTableFilterComposer,
      $$GameGenresTableOrderingComposer,
      $$GameGenresTableAnnotationComposer,
      $$GameGenresTableCreateCompanionBuilder,
      $$GameGenresTableUpdateCompanionBuilder,
      (GameGenre, $$GameGenresTableReferences),
      GameGenre,
      PrefetchHooks Function({bool gameId, bool genreId})
    >;
typedef $$PlaythroughsTableCreateCompanionBuilder =
    PlaythroughsCompanion Function({
      required String id,
      required String libraryEntryId,
      Value<String?> platformId,
      required String status,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<double?> hoursPlayed,
      Value<int?> rating,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PlaythroughsTableUpdateCompanionBuilder =
    PlaythroughsCompanion Function({
      Value<String> id,
      Value<String> libraryEntryId,
      Value<String?> platformId,
      Value<String> status,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<double?> hoursPlayed,
      Value<int?> rating,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$PlaythroughsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaythroughsTable, Playthrough> {
  $$PlaythroughsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LibraryEntriesTable _libraryEntryIdTable(_$AppDatabase db) =>
      db.libraryEntries.createAlias(
        $_aliasNameGenerator(
          db.playthroughs.libraryEntryId,
          db.libraryEntries.id,
        ),
      );

  $$LibraryEntriesTableProcessedTableManager get libraryEntryId {
    final $_column = $_itemColumn<String>('library_entry_id')!;

    final manager = $$LibraryEntriesTableTableManager(
      $_db,
      $_db.libraryEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_libraryEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlatformsTable _platformIdTable(_$AppDatabase db) =>
      db.platforms.createAlias(
        $_aliasNameGenerator(db.playthroughs.platformId, db.platforms.id),
      );

  $$PlatformsTableProcessedTableManager? get platformId {
    final $_column = $_itemColumn<String>('platform_id');
    if ($_column == null) return null;
    final manager = $$PlatformsTableTableManager(
      $_db,
      $_db.platforms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_platformIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaythroughsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaythroughsTable> {
  $$PlaythroughsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hoursPlayed => $composableBuilder(
    column: $table.hoursPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LibraryEntriesTableFilterComposer get libraryEntryId {
    final $$LibraryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.libraryEntryId,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlatformsTableFilterComposer get platformId {
    final $$PlatformsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.platformId,
      referencedTable: $db.platforms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatformsTableFilterComposer(
            $db: $db,
            $table: $db.platforms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaythroughsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaythroughsTable> {
  $$PlaythroughsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hoursPlayed => $composableBuilder(
    column: $table.hoursPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibraryEntriesTableOrderingComposer get libraryEntryId {
    final $$LibraryEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.libraryEntryId,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlatformsTableOrderingComposer get platformId {
    final $$PlatformsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.platformId,
      referencedTable: $db.platforms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatformsTableOrderingComposer(
            $db: $db,
            $table: $db.platforms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaythroughsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaythroughsTable> {
  $$PlaythroughsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hoursPlayed => $composableBuilder(
    column: $table.hoursPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$LibraryEntriesTableAnnotationComposer get libraryEntryId {
    final $$LibraryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.libraryEntryId,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlatformsTableAnnotationComposer get platformId {
    final $$PlatformsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.platformId,
      referencedTable: $db.platforms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatformsTableAnnotationComposer(
            $db: $db,
            $table: $db.platforms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaythroughsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaythroughsTable,
          Playthrough,
          $$PlaythroughsTableFilterComposer,
          $$PlaythroughsTableOrderingComposer,
          $$PlaythroughsTableAnnotationComposer,
          $$PlaythroughsTableCreateCompanionBuilder,
          $$PlaythroughsTableUpdateCompanionBuilder,
          (Playthrough, $$PlaythroughsTableReferences),
          Playthrough,
          PrefetchHooks Function({bool libraryEntryId, bool platformId})
        > {
  $$PlaythroughsTableTableManager(_$AppDatabase db, $PlaythroughsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PlaythroughsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PlaythroughsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$PlaythroughsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> libraryEntryId = const Value.absent(),
                Value<String?> platformId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<double?> hoursPlayed = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaythroughsCompanion(
                id: id,
                libraryEntryId: libraryEntryId,
                platformId: platformId,
                status: status,
                startedAt: startedAt,
                completedAt: completedAt,
                hoursPlayed: hoursPlayed,
                rating: rating,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String libraryEntryId,
                Value<String?> platformId = const Value.absent(),
                required String status,
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<double?> hoursPlayed = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaythroughsCompanion.insert(
                id: id,
                libraryEntryId: libraryEntryId,
                platformId: platformId,
                status: status,
                startedAt: startedAt,
                completedAt: completedAt,
                hoursPlayed: hoursPlayed,
                rating: rating,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PlaythroughsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            libraryEntryId = false,
            platformId = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (libraryEntryId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.libraryEntryId,
                            referencedTable: $$PlaythroughsTableReferences
                                ._libraryEntryIdTable(db),
                            referencedColumn:
                                $$PlaythroughsTableReferences
                                    ._libraryEntryIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (platformId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.platformId,
                            referencedTable: $$PlaythroughsTableReferences
                                ._platformIdTable(db),
                            referencedColumn:
                                $$PlaythroughsTableReferences
                                    ._platformIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaythroughsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaythroughsTable,
      Playthrough,
      $$PlaythroughsTableFilterComposer,
      $$PlaythroughsTableOrderingComposer,
      $$PlaythroughsTableAnnotationComposer,
      $$PlaythroughsTableCreateCompanionBuilder,
      $$PlaythroughsTableUpdateCompanionBuilder,
      (Playthrough, $$PlaythroughsTableReferences),
      Playthrough,
      PrefetchHooks Function({bool libraryEntryId, bool platformId})
    >;
typedef $$SavedViewsTableCreateCompanionBuilder =
    SavedViewsCompanion Function({
      required String id,
      required String name,
      required String filterJson,
      required String sortJson,
      required String columnConfigJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$SavedViewsTableUpdateCompanionBuilder =
    SavedViewsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> filterJson,
      Value<String> sortJson,
      Value<String> columnConfigJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$SavedViewsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedViewsTable> {
  $$SavedViewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterJson => $composableBuilder(
    column: $table.filterJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortJson => $composableBuilder(
    column: $table.sortJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get columnConfigJson => $composableBuilder(
    column: $table.columnConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedViewsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedViewsTable> {
  $$SavedViewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterJson => $composableBuilder(
    column: $table.filterJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortJson => $composableBuilder(
    column: $table.sortJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get columnConfigJson => $composableBuilder(
    column: $table.columnConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedViewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedViewsTable> {
  $$SavedViewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get filterJson => $composableBuilder(
    column: $table.filterJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sortJson =>
      $composableBuilder(column: $table.sortJson, builder: (column) => column);

  GeneratedColumn<String> get columnConfigJson => $composableBuilder(
    column: $table.columnConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$SavedViewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedViewsTable,
          SavedView,
          $$SavedViewsTableFilterComposer,
          $$SavedViewsTableOrderingComposer,
          $$SavedViewsTableAnnotationComposer,
          $$SavedViewsTableCreateCompanionBuilder,
          $$SavedViewsTableUpdateCompanionBuilder,
          (
            SavedView,
            BaseReferences<_$AppDatabase, $SavedViewsTable, SavedView>,
          ),
          SavedView,
          PrefetchHooks Function()
        > {
  $$SavedViewsTableTableManager(_$AppDatabase db, $SavedViewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SavedViewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SavedViewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SavedViewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> filterJson = const Value.absent(),
                Value<String> sortJson = const Value.absent(),
                Value<String> columnConfigJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedViewsCompanion(
                id: id,
                name: name,
                filterJson: filterJson,
                sortJson: sortJson,
                columnConfigJson: columnConfigJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String filterJson,
                required String sortJson,
                required String columnConfigJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedViewsCompanion.insert(
                id: id,
                name: name,
                filterJson: filterJson,
                sortJson: sortJson,
                columnConfigJson: columnConfigJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedViewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedViewsTable,
      SavedView,
      $$SavedViewsTableFilterComposer,
      $$SavedViewsTableOrderingComposer,
      $$SavedViewsTableAnnotationComposer,
      $$SavedViewsTableCreateCompanionBuilder,
      $$SavedViewsTableUpdateCompanionBuilder,
      (SavedView, BaseReferences<_$AppDatabase, $SavedViewsTable, SavedView>),
      SavedView,
      PrefetchHooks Function()
    >;
typedef $$ExternalGameIdsTableCreateCompanionBuilder =
    ExternalGameIdsCompanion Function({
      required String id,
      required String gameId,
      required String provider,
      required String externalId,
      Value<String?> externalSlug,
      Value<String?> externalUrl,
      Value<String?> matchedTitle,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ExternalGameIdsTableUpdateCompanionBuilder =
    ExternalGameIdsCompanion Function({
      Value<String> id,
      Value<String> gameId,
      Value<String> provider,
      Value<String> externalId,
      Value<String?> externalSlug,
      Value<String?> externalUrl,
      Value<String?> matchedTitle,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$ExternalGameIdsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ExternalGameIdsTable, ExternalGameId> {
  $$ExternalGameIdsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games.createAlias(
    $_aliasNameGenerator(db.externalGameIds.gameId, db.games.id),
  );

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExternalGameIdsTableFilterComposer
    extends Composer<_$AppDatabase, $ExternalGameIdsTable> {
  $$ExternalGameIdsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalSlug => $composableBuilder(
    column: $table.externalSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalUrl => $composableBuilder(
    column: $table.externalUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchedTitle => $composableBuilder(
    column: $table.matchedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExternalGameIdsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExternalGameIdsTable> {
  $$ExternalGameIdsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalSlug => $composableBuilder(
    column: $table.externalSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalUrl => $composableBuilder(
    column: $table.externalUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchedTitle => $composableBuilder(
    column: $table.matchedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExternalGameIdsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExternalGameIdsTable> {
  $$ExternalGameIdsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalSlug => $composableBuilder(
    column: $table.externalSlug,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalUrl => $composableBuilder(
    column: $table.externalUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchedTitle => $composableBuilder(
    column: $table.matchedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExternalGameIdsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExternalGameIdsTable,
          ExternalGameId,
          $$ExternalGameIdsTableFilterComposer,
          $$ExternalGameIdsTableOrderingComposer,
          $$ExternalGameIdsTableAnnotationComposer,
          $$ExternalGameIdsTableCreateCompanionBuilder,
          $$ExternalGameIdsTableUpdateCompanionBuilder,
          (ExternalGameId, $$ExternalGameIdsTableReferences),
          ExternalGameId,
          PrefetchHooks Function({bool gameId})
        > {
  $$ExternalGameIdsTableTableManager(
    _$AppDatabase db,
    $ExternalGameIdsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$ExternalGameIdsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ExternalGameIdsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ExternalGameIdsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String?> externalSlug = const Value.absent(),
                Value<String?> externalUrl = const Value.absent(),
                Value<String?> matchedTitle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExternalGameIdsCompanion(
                id: id,
                gameId: gameId,
                provider: provider,
                externalId: externalId,
                externalSlug: externalSlug,
                externalUrl: externalUrl,
                matchedTitle: matchedTitle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gameId,
                required String provider,
                required String externalId,
                Value<String?> externalSlug = const Value.absent(),
                Value<String?> externalUrl = const Value.absent(),
                Value<String?> matchedTitle = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExternalGameIdsCompanion.insert(
                id: id,
                gameId: gameId,
                provider: provider,
                externalId: externalId,
                externalSlug: externalSlug,
                externalUrl: externalUrl,
                matchedTitle: matchedTitle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ExternalGameIdsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (gameId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.gameId,
                            referencedTable: $$ExternalGameIdsTableReferences
                                ._gameIdTable(db),
                            referencedColumn:
                                $$ExternalGameIdsTableReferences
                                    ._gameIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExternalGameIdsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExternalGameIdsTable,
      ExternalGameId,
      $$ExternalGameIdsTableFilterComposer,
      $$ExternalGameIdsTableOrderingComposer,
      $$ExternalGameIdsTableAnnotationComposer,
      $$ExternalGameIdsTableCreateCompanionBuilder,
      $$ExternalGameIdsTableUpdateCompanionBuilder,
      (ExternalGameId, $$ExternalGameIdsTableReferences),
      ExternalGameId,
      PrefetchHooks Function({bool gameId})
    >;
typedef $$MediaAssetsTableCreateCompanionBuilder =
    MediaAssetsCompanion Function({
      required String id,
      required String gameId,
      required String kind,
      required String source,
      Value<String?> provider,
      Value<String?> externalId,
      Value<String?> remoteUrl,
      required String localPath,
      required String fileName,
      Value<String?> mimeType,
      Value<int?> width,
      Value<int?> height,
      Value<String?> hash,
      Value<bool> isSelected,
      Value<String?> attribution,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$MediaAssetsTableUpdateCompanionBuilder =
    MediaAssetsCompanion Function({
      Value<String> id,
      Value<String> gameId,
      Value<String> kind,
      Value<String> source,
      Value<String?> provider,
      Value<String?> externalId,
      Value<String?> remoteUrl,
      Value<String> localPath,
      Value<String> fileName,
      Value<String?> mimeType,
      Value<int?> width,
      Value<int?> height,
      Value<String?> hash,
      Value<bool> isSelected,
      Value<String?> attribution,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$MediaAssetsTableReferences
    extends BaseReferences<_$AppDatabase, $MediaAssetsTable, MediaAsset> {
  $$MediaAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games.createAlias(
    $_aliasNameGenerator(db.mediaAssets.gameId, db.games.id),
  );

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MediaAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSelected => $composableBuilder(
    column: $table.isSelected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSelected => $composableBuilder(
    column: $table.isSelected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<bool> get isSelected => $composableBuilder(
    column: $table.isSelected,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaAssetsTable,
          MediaAsset,
          $$MediaAssetsTableFilterComposer,
          $$MediaAssetsTableOrderingComposer,
          $$MediaAssetsTableAnnotationComposer,
          $$MediaAssetsTableCreateCompanionBuilder,
          $$MediaAssetsTableUpdateCompanionBuilder,
          (MediaAsset, $$MediaAssetsTableReferences),
          MediaAsset,
          PrefetchHooks Function({bool gameId})
        > {
  $$MediaAssetsTableTableManager(_$AppDatabase db, $MediaAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MediaAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MediaAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$MediaAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String?> hash = const Value.absent(),
                Value<bool> isSelected = const Value.absent(),
                Value<String?> attribution = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaAssetsCompanion(
                id: id,
                gameId: gameId,
                kind: kind,
                source: source,
                provider: provider,
                externalId: externalId,
                remoteUrl: remoteUrl,
                localPath: localPath,
                fileName: fileName,
                mimeType: mimeType,
                width: width,
                height: height,
                hash: hash,
                isSelected: isSelected,
                attribution: attribution,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gameId,
                required String kind,
                required String source,
                Value<String?> provider = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                required String localPath,
                required String fileName,
                Value<String?> mimeType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String?> hash = const Value.absent(),
                Value<bool> isSelected = const Value.absent(),
                Value<String?> attribution = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaAssetsCompanion.insert(
                id: id,
                gameId: gameId,
                kind: kind,
                source: source,
                provider: provider,
                externalId: externalId,
                remoteUrl: remoteUrl,
                localPath: localPath,
                fileName: fileName,
                mimeType: mimeType,
                width: width,
                height: height,
                hash: hash,
                isSelected: isSelected,
                attribution: attribution,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$MediaAssetsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (gameId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.gameId,
                            referencedTable: $$MediaAssetsTableReferences
                                ._gameIdTable(db),
                            referencedColumn:
                                $$MediaAssetsTableReferences
                                    ._gameIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MediaAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaAssetsTable,
      MediaAsset,
      $$MediaAssetsTableFilterComposer,
      $$MediaAssetsTableOrderingComposer,
      $$MediaAssetsTableAnnotationComposer,
      $$MediaAssetsTableCreateCompanionBuilder,
      $$MediaAssetsTableUpdateCompanionBuilder,
      (MediaAsset, $$MediaAssetsTableReferences),
      MediaAsset,
      PrefetchHooks Function({bool gameId})
    >;
typedef $$SyncGroupsTableCreateCompanionBuilder =
    SyncGroupsCompanion Function({
      required String id,
      required String displayName,
      required int protocolVersion,
      Value<String?> keyId,
      required String status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> keyRotatedAt,
      Value<int> rowid,
    });
typedef $$SyncGroupsTableUpdateCompanionBuilder =
    SyncGroupsCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<int> protocolVersion,
      Value<String?> keyId,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> keyRotatedAt,
      Value<int> rowid,
    });

class $$SyncGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncGroupsTable> {
  $$SyncGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyId => $composableBuilder(
    column: $table.keyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get keyRotatedAt => $composableBuilder(
    column: $table.keyRotatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncGroupsTable> {
  $$SyncGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyId => $composableBuilder(
    column: $table.keyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get keyRotatedAt => $composableBuilder(
    column: $table.keyRotatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncGroupsTable> {
  $$SyncGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keyId =>
      $composableBuilder(column: $table.keyId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get keyRotatedAt => $composableBuilder(
    column: $table.keyRotatedAt,
    builder: (column) => column,
  );
}

class $$SyncGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncGroupsTable,
          SyncGroup,
          $$SyncGroupsTableFilterComposer,
          $$SyncGroupsTableOrderingComposer,
          $$SyncGroupsTableAnnotationComposer,
          $$SyncGroupsTableCreateCompanionBuilder,
          $$SyncGroupsTableUpdateCompanionBuilder,
          (
            SyncGroup,
            BaseReferences<_$AppDatabase, $SyncGroupsTable, SyncGroup>,
          ),
          SyncGroup,
          PrefetchHooks Function()
        > {
  $$SyncGroupsTableTableManager(_$AppDatabase db, $SyncGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> protocolVersion = const Value.absent(),
                Value<String?> keyId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> keyRotatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncGroupsCompanion(
                id: id,
                displayName: displayName,
                protocolVersion: protocolVersion,
                keyId: keyId,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                keyRotatedAt: keyRotatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required int protocolVersion,
                Value<String?> keyId = const Value.absent(),
                required String status,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> keyRotatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncGroupsCompanion.insert(
                id: id,
                displayName: displayName,
                protocolVersion: protocolVersion,
                keyId: keyId,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                keyRotatedAt: keyRotatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncGroupsTable,
      SyncGroup,
      $$SyncGroupsTableFilterComposer,
      $$SyncGroupsTableOrderingComposer,
      $$SyncGroupsTableAnnotationComposer,
      $$SyncGroupsTableCreateCompanionBuilder,
      $$SyncGroupsTableUpdateCompanionBuilder,
      (SyncGroup, BaseReferences<_$AppDatabase, $SyncGroupsTable, SyncGroup>),
      SyncGroup,
      PrefetchHooks Function()
    >;
typedef $$SyncDevicesTableCreateCompanionBuilder =
    SyncDevicesCompanion Function({
      required String id,
      Value<String?> syncGroupId,
      required String displayName,
      required String platform,
      Value<bool> isLocal,
      Value<String?> publicKey,
      Value<String?> fingerprint,
      required String status,
      required DateTime createdAt,
      Value<DateTime?> pairedAt,
      Value<DateTime?> lastSeenAt,
      Value<DateTime?> lastSyncAt,
      Value<DateTime?> revokedAt,
      Value<int> rowid,
    });
typedef $$SyncDevicesTableUpdateCompanionBuilder =
    SyncDevicesCompanion Function({
      Value<String> id,
      Value<String?> syncGroupId,
      Value<String> displayName,
      Value<String> platform,
      Value<bool> isLocal,
      Value<String?> publicKey,
      Value<String?> fingerprint,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> pairedAt,
      Value<DateTime?> lastSeenAt,
      Value<DateTime?> lastSyncAt,
      Value<DateTime?> revokedAt,
      Value<int> rowid,
    });

class $$SyncDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncDevicesTable> {
  $$SyncDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocal => $composableBuilder(
    column: $table.isLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncDevicesTable> {
  $$SyncDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocal => $composableBuilder(
    column: $table.isLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncDevicesTable> {
  $$SyncDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<bool> get isLocal =>
      $composableBuilder(column: $table.isLocal, builder: (column) => column);

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get pairedAt =>
      $composableBuilder(column: $table.pairedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);
}

class $$SyncDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncDevicesTable,
          SyncDevice,
          $$SyncDevicesTableFilterComposer,
          $$SyncDevicesTableOrderingComposer,
          $$SyncDevicesTableAnnotationComposer,
          $$SyncDevicesTableCreateCompanionBuilder,
          $$SyncDevicesTableUpdateCompanionBuilder,
          (
            SyncDevice,
            BaseReferences<_$AppDatabase, $SyncDevicesTable, SyncDevice>,
          ),
          SyncDevice,
          PrefetchHooks Function()
        > {
  $$SyncDevicesTableTableManager(_$AppDatabase db, $SyncDevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$SyncDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> syncGroupId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<bool> isLocal = const Value.absent(),
                Value<String?> publicKey = const Value.absent(),
                Value<String?> fingerprint = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> pairedAt = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncDevicesCompanion(
                id: id,
                syncGroupId: syncGroupId,
                displayName: displayName,
                platform: platform,
                isLocal: isLocal,
                publicKey: publicKey,
                fingerprint: fingerprint,
                status: status,
                createdAt: createdAt,
                pairedAt: pairedAt,
                lastSeenAt: lastSeenAt,
                lastSyncAt: lastSyncAt,
                revokedAt: revokedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> syncGroupId = const Value.absent(),
                required String displayName,
                required String platform,
                Value<bool> isLocal = const Value.absent(),
                Value<String?> publicKey = const Value.absent(),
                Value<String?> fingerprint = const Value.absent(),
                required String status,
                required DateTime createdAt,
                Value<DateTime?> pairedAt = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncDevicesCompanion.insert(
                id: id,
                syncGroupId: syncGroupId,
                displayName: displayName,
                platform: platform,
                isLocal: isLocal,
                publicKey: publicKey,
                fingerprint: fingerprint,
                status: status,
                createdAt: createdAt,
                pairedAt: pairedAt,
                lastSeenAt: lastSeenAt,
                lastSyncAt: lastSyncAt,
                revokedAt: revokedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncDevicesTable,
      SyncDevice,
      $$SyncDevicesTableFilterComposer,
      $$SyncDevicesTableOrderingComposer,
      $$SyncDevicesTableAnnotationComposer,
      $$SyncDevicesTableCreateCompanionBuilder,
      $$SyncDevicesTableUpdateCompanionBuilder,
      (
        SyncDevice,
        BaseReferences<_$AppDatabase, $SyncDevicesTable, SyncDevice>,
      ),
      SyncDevice,
      PrefetchHooks Function()
    >;
typedef $$SyncChangesTableCreateCompanionBuilder =
    SyncChangesCompanion Function({
      required String changeId,
      Value<String?> syncGroupId,
      required String originDeviceId,
      required int originCounter,
      required String mutationId,
      required int mutationSequence,
      required String entityType,
      required String entityId,
      required String operation,
      required String changedFieldsJson,
      required String payloadJson,
      required String snapshotJson,
      required String causalContextJson,
      required String source,
      required String contentHash,
      required DateTime createdAt,
      Value<DateTime?> appliedAt,
      Value<int> rowid,
    });
typedef $$SyncChangesTableUpdateCompanionBuilder =
    SyncChangesCompanion Function({
      Value<String> changeId,
      Value<String?> syncGroupId,
      Value<String> originDeviceId,
      Value<int> originCounter,
      Value<String> mutationId,
      Value<int> mutationSequence,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> changedFieldsJson,
      Value<String> payloadJson,
      Value<String> snapshotJson,
      Value<String> causalContextJson,
      Value<String> source,
      Value<String> contentHash,
      Value<DateTime> createdAt,
      Value<DateTime?> appliedAt,
      Value<int> rowid,
    });

class $$SyncChangesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncChangesTable> {
  $$SyncChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originCounter => $composableBuilder(
    column: $table.originCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mutationSequence => $composableBuilder(
    column: $table.mutationSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changedFieldsJson => $composableBuilder(
    column: $table.changedFieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get causalContextJson => $composableBuilder(
    column: $table.causalContextJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncChangesTable> {
  $$SyncChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originCounter => $composableBuilder(
    column: $table.originCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mutationSequence => $composableBuilder(
    column: $table.mutationSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changedFieldsJson => $composableBuilder(
    column: $table.changedFieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get causalContextJson => $composableBuilder(
    column: $table.causalContextJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncChangesTable> {
  $$SyncChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get changeId =>
      $composableBuilder(column: $table.changeId, builder: (column) => column);

  GeneratedColumn<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originCounter => $composableBuilder(
    column: $table.originCounter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mutationSequence => $composableBuilder(
    column: $table.mutationSequence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get changedFieldsJson => $composableBuilder(
    column: $table.changedFieldsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get causalContextJson => $composableBuilder(
    column: $table.causalContextJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);
}

class $$SyncChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncChangesTable,
          SyncChange,
          $$SyncChangesTableFilterComposer,
          $$SyncChangesTableOrderingComposer,
          $$SyncChangesTableAnnotationComposer,
          $$SyncChangesTableCreateCompanionBuilder,
          $$SyncChangesTableUpdateCompanionBuilder,
          (
            SyncChange,
            BaseReferences<_$AppDatabase, $SyncChangesTable, SyncChange>,
          ),
          SyncChange,
          PrefetchHooks Function()
        > {
  $$SyncChangesTableTableManager(_$AppDatabase db, $SyncChangesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$SyncChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> changeId = const Value.absent(),
                Value<String?> syncGroupId = const Value.absent(),
                Value<String> originDeviceId = const Value.absent(),
                Value<int> originCounter = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<int> mutationSequence = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> changedFieldsJson = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> snapshotJson = const Value.absent(),
                Value<String> causalContextJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> appliedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncChangesCompanion(
                changeId: changeId,
                syncGroupId: syncGroupId,
                originDeviceId: originDeviceId,
                originCounter: originCounter,
                mutationId: mutationId,
                mutationSequence: mutationSequence,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                changedFieldsJson: changedFieldsJson,
                payloadJson: payloadJson,
                snapshotJson: snapshotJson,
                causalContextJson: causalContextJson,
                source: source,
                contentHash: contentHash,
                createdAt: createdAt,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String changeId,
                Value<String?> syncGroupId = const Value.absent(),
                required String originDeviceId,
                required int originCounter,
                required String mutationId,
                required int mutationSequence,
                required String entityType,
                required String entityId,
                required String operation,
                required String changedFieldsJson,
                required String payloadJson,
                required String snapshotJson,
                required String causalContextJson,
                required String source,
                required String contentHash,
                required DateTime createdAt,
                Value<DateTime?> appliedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncChangesCompanion.insert(
                changeId: changeId,
                syncGroupId: syncGroupId,
                originDeviceId: originDeviceId,
                originCounter: originCounter,
                mutationId: mutationId,
                mutationSequence: mutationSequence,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                changedFieldsJson: changedFieldsJson,
                payloadJson: payloadJson,
                snapshotJson: snapshotJson,
                causalContextJson: causalContextJson,
                source: source,
                contentHash: contentHash,
                createdAt: createdAt,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncChangesTable,
      SyncChange,
      $$SyncChangesTableFilterComposer,
      $$SyncChangesTableOrderingComposer,
      $$SyncChangesTableAnnotationComposer,
      $$SyncChangesTableCreateCompanionBuilder,
      $$SyncChangesTableUpdateCompanionBuilder,
      (
        SyncChange,
        BaseReferences<_$AppDatabase, $SyncChangesTable, SyncChange>,
      ),
      SyncChange,
      PrefetchHooks Function()
    >;
typedef $$SyncTombstonesTableCreateCompanionBuilder =
    SyncTombstonesCompanion Function({
      required String tombstoneId,
      Value<String?> syncGroupId,
      required String entityType,
      required String entityId,
      required String deleteChangeId,
      required String originDeviceId,
      required int originCounter,
      required String causalContextJson,
      Value<String?> lastContentHash,
      required DateTime deletedAt,
      Value<DateTime?> fullyAcknowledgedAt,
      Value<DateTime?> retainUntil,
      Value<int> rowid,
    });
typedef $$SyncTombstonesTableUpdateCompanionBuilder =
    SyncTombstonesCompanion Function({
      Value<String> tombstoneId,
      Value<String?> syncGroupId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> deleteChangeId,
      Value<String> originDeviceId,
      Value<int> originCounter,
      Value<String> causalContextJson,
      Value<String?> lastContentHash,
      Value<DateTime> deletedAt,
      Value<DateTime?> fullyAcknowledgedAt,
      Value<DateTime?> retainUntil,
      Value<int> rowid,
    });

class $$SyncTombstonesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncTombstonesTable> {
  $$SyncTombstonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tombstoneId => $composableBuilder(
    column: $table.tombstoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deleteChangeId => $composableBuilder(
    column: $table.deleteChangeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originCounter => $composableBuilder(
    column: $table.originCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get causalContextJson => $composableBuilder(
    column: $table.causalContextJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastContentHash => $composableBuilder(
    column: $table.lastContentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fullyAcknowledgedAt => $composableBuilder(
    column: $table.fullyAcknowledgedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get retainUntil => $composableBuilder(
    column: $table.retainUntil,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncTombstonesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncTombstonesTable> {
  $$SyncTombstonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tombstoneId => $composableBuilder(
    column: $table.tombstoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deleteChangeId => $composableBuilder(
    column: $table.deleteChangeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originCounter => $composableBuilder(
    column: $table.originCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get causalContextJson => $composableBuilder(
    column: $table.causalContextJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastContentHash => $composableBuilder(
    column: $table.lastContentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fullyAcknowledgedAt => $composableBuilder(
    column: $table.fullyAcknowledgedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get retainUntil => $composableBuilder(
    column: $table.retainUntil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncTombstonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncTombstonesTable> {
  $$SyncTombstonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tombstoneId => $composableBuilder(
    column: $table.tombstoneId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get deleteChangeId => $composableBuilder(
    column: $table.deleteChangeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originCounter => $composableBuilder(
    column: $table.originCounter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get causalContextJson => $composableBuilder(
    column: $table.causalContextJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastContentHash => $composableBuilder(
    column: $table.lastContentHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get fullyAcknowledgedAt => $composableBuilder(
    column: $table.fullyAcknowledgedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get retainUntil => $composableBuilder(
    column: $table.retainUntil,
    builder: (column) => column,
  );
}

class $$SyncTombstonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncTombstonesTable,
          SyncTombstone,
          $$SyncTombstonesTableFilterComposer,
          $$SyncTombstonesTableOrderingComposer,
          $$SyncTombstonesTableAnnotationComposer,
          $$SyncTombstonesTableCreateCompanionBuilder,
          $$SyncTombstonesTableUpdateCompanionBuilder,
          (
            SyncTombstone,
            BaseReferences<_$AppDatabase, $SyncTombstonesTable, SyncTombstone>,
          ),
          SyncTombstone,
          PrefetchHooks Function()
        > {
  $$SyncTombstonesTableTableManager(
    _$AppDatabase db,
    $SyncTombstonesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncTombstonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$SyncTombstonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncTombstonesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> tombstoneId = const Value.absent(),
                Value<String?> syncGroupId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> deleteChangeId = const Value.absent(),
                Value<String> originDeviceId = const Value.absent(),
                Value<int> originCounter = const Value.absent(),
                Value<String> causalContextJson = const Value.absent(),
                Value<String?> lastContentHash = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<DateTime?> fullyAcknowledgedAt = const Value.absent(),
                Value<DateTime?> retainUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncTombstonesCompanion(
                tombstoneId: tombstoneId,
                syncGroupId: syncGroupId,
                entityType: entityType,
                entityId: entityId,
                deleteChangeId: deleteChangeId,
                originDeviceId: originDeviceId,
                originCounter: originCounter,
                causalContextJson: causalContextJson,
                lastContentHash: lastContentHash,
                deletedAt: deletedAt,
                fullyAcknowledgedAt: fullyAcknowledgedAt,
                retainUntil: retainUntil,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tombstoneId,
                Value<String?> syncGroupId = const Value.absent(),
                required String entityType,
                required String entityId,
                required String deleteChangeId,
                required String originDeviceId,
                required int originCounter,
                required String causalContextJson,
                Value<String?> lastContentHash = const Value.absent(),
                required DateTime deletedAt,
                Value<DateTime?> fullyAcknowledgedAt = const Value.absent(),
                Value<DateTime?> retainUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncTombstonesCompanion.insert(
                tombstoneId: tombstoneId,
                syncGroupId: syncGroupId,
                entityType: entityType,
                entityId: entityId,
                deleteChangeId: deleteChangeId,
                originDeviceId: originDeviceId,
                originCounter: originCounter,
                causalContextJson: causalContextJson,
                lastContentHash: lastContentHash,
                deletedAt: deletedAt,
                fullyAcknowledgedAt: fullyAcknowledgedAt,
                retainUntil: retainUntil,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncTombstonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncTombstonesTable,
      SyncTombstone,
      $$SyncTombstonesTableFilterComposer,
      $$SyncTombstonesTableOrderingComposer,
      $$SyncTombstonesTableAnnotationComposer,
      $$SyncTombstonesTableCreateCompanionBuilder,
      $$SyncTombstonesTableUpdateCompanionBuilder,
      (
        SyncTombstone,
        BaseReferences<_$AppDatabase, $SyncTombstonesTable, SyncTombstone>,
      ),
      SyncTombstone,
      PrefetchHooks Function()
    >;
typedef $$SyncStatesTableCreateCompanionBuilder =
    SyncStatesCompanion Function({
      required String id,
      Value<String?> syncGroupId,
      required String localDeviceId,
      Value<String?> peerDeviceId,
      Value<int> nextLocalCounter,
      Value<String> seenVectorJson,
      Value<String> peerAckVectorJson,
      Value<String> lastExportedVectorJson,
      Value<String?> lastImportedPackageId,
      Value<int> replicaEpoch,
      Value<bool> baselineCreated,
      Value<bool> requiresReconciliation,
      Value<DateTime?> lastSuccessfulSyncAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncStatesTableUpdateCompanionBuilder =
    SyncStatesCompanion Function({
      Value<String> id,
      Value<String?> syncGroupId,
      Value<String> localDeviceId,
      Value<String?> peerDeviceId,
      Value<int> nextLocalCounter,
      Value<String> seenVectorJson,
      Value<String> peerAckVectorJson,
      Value<String> lastExportedVectorJson,
      Value<String?> lastImportedPackageId,
      Value<int> replicaEpoch,
      Value<bool> baselineCreated,
      Value<bool> requiresReconciliation,
      Value<DateTime?> lastSuccessfulSyncAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDeviceId => $composableBuilder(
    column: $table.localDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextLocalCounter => $composableBuilder(
    column: $table.nextLocalCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seenVectorJson => $composableBuilder(
    column: $table.seenVectorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerAckVectorJson => $composableBuilder(
    column: $table.peerAckVectorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastExportedVectorJson => $composableBuilder(
    column: $table.lastExportedVectorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastImportedPackageId => $composableBuilder(
    column: $table.lastImportedPackageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replicaEpoch => $composableBuilder(
    column: $table.replicaEpoch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get baselineCreated => $composableBuilder(
    column: $table.baselineCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiresReconciliation => $composableBuilder(
    column: $table.requiresReconciliation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDeviceId => $composableBuilder(
    column: $table.localDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextLocalCounter => $composableBuilder(
    column: $table.nextLocalCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seenVectorJson => $composableBuilder(
    column: $table.seenVectorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerAckVectorJson => $composableBuilder(
    column: $table.peerAckVectorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastExportedVectorJson => $composableBuilder(
    column: $table.lastExportedVectorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastImportedPackageId => $composableBuilder(
    column: $table.lastImportedPackageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replicaEpoch => $composableBuilder(
    column: $table.replicaEpoch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get baselineCreated => $composableBuilder(
    column: $table.baselineCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiresReconciliation => $composableBuilder(
    column: $table.requiresReconciliation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDeviceId => $composableBuilder(
    column: $table.localDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get peerDeviceId => $composableBuilder(
    column: $table.peerDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextLocalCounter => $composableBuilder(
    column: $table.nextLocalCounter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seenVectorJson => $composableBuilder(
    column: $table.seenVectorJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get peerAckVectorJson => $composableBuilder(
    column: $table.peerAckVectorJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastExportedVectorJson => $composableBuilder(
    column: $table.lastExportedVectorJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastImportedPackageId => $composableBuilder(
    column: $table.lastImportedPackageId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get replicaEpoch => $composableBuilder(
    column: $table.replicaEpoch,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get baselineCreated => $composableBuilder(
    column: $table.baselineCreated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requiresReconciliation => $composableBuilder(
    column: $table.requiresReconciliation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatesTable,
          SyncState,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            SyncState,
            BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>,
          ),
          SyncState,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> syncGroupId = const Value.absent(),
                Value<String> localDeviceId = const Value.absent(),
                Value<String?> peerDeviceId = const Value.absent(),
                Value<int> nextLocalCounter = const Value.absent(),
                Value<String> seenVectorJson = const Value.absent(),
                Value<String> peerAckVectorJson = const Value.absent(),
                Value<String> lastExportedVectorJson = const Value.absent(),
                Value<String?> lastImportedPackageId = const Value.absent(),
                Value<int> replicaEpoch = const Value.absent(),
                Value<bool> baselineCreated = const Value.absent(),
                Value<bool> requiresReconciliation = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion(
                id: id,
                syncGroupId: syncGroupId,
                localDeviceId: localDeviceId,
                peerDeviceId: peerDeviceId,
                nextLocalCounter: nextLocalCounter,
                seenVectorJson: seenVectorJson,
                peerAckVectorJson: peerAckVectorJson,
                lastExportedVectorJson: lastExportedVectorJson,
                lastImportedPackageId: lastImportedPackageId,
                replicaEpoch: replicaEpoch,
                baselineCreated: baselineCreated,
                requiresReconciliation: requiresReconciliation,
                lastSuccessfulSyncAt: lastSuccessfulSyncAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> syncGroupId = const Value.absent(),
                required String localDeviceId,
                Value<String?> peerDeviceId = const Value.absent(),
                Value<int> nextLocalCounter = const Value.absent(),
                Value<String> seenVectorJson = const Value.absent(),
                Value<String> peerAckVectorJson = const Value.absent(),
                Value<String> lastExportedVectorJson = const Value.absent(),
                Value<String?> lastImportedPackageId = const Value.absent(),
                Value<int> replicaEpoch = const Value.absent(),
                Value<bool> baselineCreated = const Value.absent(),
                Value<bool> requiresReconciliation = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                id: id,
                syncGroupId: syncGroupId,
                localDeviceId: localDeviceId,
                peerDeviceId: peerDeviceId,
                nextLocalCounter: nextLocalCounter,
                seenVectorJson: seenVectorJson,
                peerAckVectorJson: peerAckVectorJson,
                lastExportedVectorJson: lastExportedVectorJson,
                lastImportedPackageId: lastImportedPackageId,
                replicaEpoch: replicaEpoch,
                baselineCreated: baselineCreated,
                requiresReconciliation: requiresReconciliation,
                lastSuccessfulSyncAt: lastSuccessfulSyncAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatesTable,
      SyncState,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (SyncState, BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>),
      SyncState,
      PrefetchHooks Function()
    >;
typedef $$SyncEntityStatesTableCreateCompanionBuilder =
    SyncEntityStatesCompanion Function({
      required String id,
      Value<String?> syncGroupId,
      required String entityType,
      required String entityId,
      required String fieldVersionsJson,
      required String entityVectorJson,
      required String lastChangeId,
      required String contentHash,
      Value<bool> isDeleted,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncEntityStatesTableUpdateCompanionBuilder =
    SyncEntityStatesCompanion Function({
      Value<String> id,
      Value<String?> syncGroupId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> fieldVersionsJson,
      Value<String> entityVectorJson,
      Value<String> lastChangeId,
      Value<String> contentHash,
      Value<bool> isDeleted,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncEntityStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncEntityStatesTable> {
  $$SyncEntityStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldVersionsJson => $composableBuilder(
    column: $table.fieldVersionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityVectorJson => $composableBuilder(
    column: $table.entityVectorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastChangeId => $composableBuilder(
    column: $table.lastChangeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncEntityStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncEntityStatesTable> {
  $$SyncEntityStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldVersionsJson => $composableBuilder(
    column: $table.fieldVersionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityVectorJson => $composableBuilder(
    column: $table.entityVectorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastChangeId => $composableBuilder(
    column: $table.lastChangeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncEntityStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncEntityStatesTable> {
  $$SyncEntityStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncGroupId => $composableBuilder(
    column: $table.syncGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get fieldVersionsJson => $composableBuilder(
    column: $table.fieldVersionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityVectorJson => $composableBuilder(
    column: $table.entityVectorJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastChangeId => $composableBuilder(
    column: $table.lastChangeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncEntityStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncEntityStatesTable,
          SyncEntityState,
          $$SyncEntityStatesTableFilterComposer,
          $$SyncEntityStatesTableOrderingComposer,
          $$SyncEntityStatesTableAnnotationComposer,
          $$SyncEntityStatesTableCreateCompanionBuilder,
          $$SyncEntityStatesTableUpdateCompanionBuilder,
          (
            SyncEntityState,
            BaseReferences<
              _$AppDatabase,
              $SyncEntityStatesTable,
              SyncEntityState
            >,
          ),
          SyncEntityState,
          PrefetchHooks Function()
        > {
  $$SyncEntityStatesTableTableManager(
    _$AppDatabase db,
    $SyncEntityStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$SyncEntityStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncEntityStatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$SyncEntityStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> syncGroupId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> fieldVersionsJson = const Value.absent(),
                Value<String> entityVectorJson = const Value.absent(),
                Value<String> lastChangeId = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncEntityStatesCompanion(
                id: id,
                syncGroupId: syncGroupId,
                entityType: entityType,
                entityId: entityId,
                fieldVersionsJson: fieldVersionsJson,
                entityVectorJson: entityVectorJson,
                lastChangeId: lastChangeId,
                contentHash: contentHash,
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> syncGroupId = const Value.absent(),
                required String entityType,
                required String entityId,
                required String fieldVersionsJson,
                required String entityVectorJson,
                required String lastChangeId,
                required String contentHash,
                Value<bool> isDeleted = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncEntityStatesCompanion.insert(
                id: id,
                syncGroupId: syncGroupId,
                entityType: entityType,
                entityId: entityId,
                fieldVersionsJson: fieldVersionsJson,
                entityVectorJson: entityVectorJson,
                lastChangeId: lastChangeId,
                contentHash: contentHash,
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncEntityStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncEntityStatesTable,
      SyncEntityState,
      $$SyncEntityStatesTableFilterComposer,
      $$SyncEntityStatesTableOrderingComposer,
      $$SyncEntityStatesTableAnnotationComposer,
      $$SyncEntityStatesTableCreateCompanionBuilder,
      $$SyncEntityStatesTableUpdateCompanionBuilder,
      (
        SyncEntityState,
        BaseReferences<_$AppDatabase, $SyncEntityStatesTable, SyncEntityState>,
      ),
      SyncEntityState,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$LibraryEntriesTableTableManager get libraryEntries =>
      $$LibraryEntriesTableTableManager(_db, _db.libraryEntries);
  $$PlatformsTableTableManager get platforms =>
      $$PlatformsTableTableManager(_db, _db.platforms);
  $$LibraryEntryPlatformsTableTableManager get libraryEntryPlatforms =>
      $$LibraryEntryPlatformsTableTableManager(_db, _db.libraryEntryPlatforms);
  $$GenresTableTableManager get genres =>
      $$GenresTableTableManager(_db, _db.genres);
  $$GameGenresTableTableManager get gameGenres =>
      $$GameGenresTableTableManager(_db, _db.gameGenres);
  $$PlaythroughsTableTableManager get playthroughs =>
      $$PlaythroughsTableTableManager(_db, _db.playthroughs);
  $$SavedViewsTableTableManager get savedViews =>
      $$SavedViewsTableTableManager(_db, _db.savedViews);
  $$ExternalGameIdsTableTableManager get externalGameIds =>
      $$ExternalGameIdsTableTableManager(_db, _db.externalGameIds);
  $$MediaAssetsTableTableManager get mediaAssets =>
      $$MediaAssetsTableTableManager(_db, _db.mediaAssets);
  $$SyncGroupsTableTableManager get syncGroups =>
      $$SyncGroupsTableTableManager(_db, _db.syncGroups);
  $$SyncDevicesTableTableManager get syncDevices =>
      $$SyncDevicesTableTableManager(_db, _db.syncDevices);
  $$SyncChangesTableTableManager get syncChanges =>
      $$SyncChangesTableTableManager(_db, _db.syncChanges);
  $$SyncTombstonesTableTableManager get syncTombstones =>
      $$SyncTombstonesTableTableManager(_db, _db.syncTombstones);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
  $$SyncEntityStatesTableTableManager get syncEntityStates =>
      $$SyncEntityStatesTableTableManager(_db, _db.syncEntityStates);
}
