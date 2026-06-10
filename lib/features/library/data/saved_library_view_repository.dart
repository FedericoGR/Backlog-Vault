import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../domain/library_column_config.dart';
import '../domain/library_filter_state.dart';
import '../domain/library_sort_state.dart';
import '../domain/saved_library_view.dart';

final savedLibraryViewRepositoryProvider = Provider<SavedLibraryViewRepository>(
  (ref) {
    return SavedLibraryViewRepository(ref.watch(appDatabaseProvider));
  },
);

final customLibraryViewsProvider =
    StreamProvider.autoDispose<List<SavedLibraryView>>((ref) {
      return ref.watch(savedLibraryViewRepositoryProvider).watchCustomViews();
    });

class SavedLibraryViewRepository {
  SavedLibraryViewRepository(
    this._db, {
    IdGenerator? ids,
    Clock clock = systemClock,
  }) : _ids = ids ?? defaultIdGenerator,
       _clock = clock;

  final AppDatabase _db;
  final IdGenerator _ids;
  final Clock _clock;

  Stream<List<SavedLibraryView>> watchCustomViews() {
    final query =
        _db.select(_db.savedViews)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.asc(table.name)]);

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Future<String> create({
    required String name,
    required LibraryFilterState filter,
    required LibrarySortState sort,
    required LibraryColumnConfig columnConfig,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre de la vista es obligatorio.');
    }
    final now = _clock.now();
    final id = _ids.newId();
    await _db
        .into(_db.savedViews)
        .insert(
          SavedViewsCompanion.insert(
            id: id,
            name: normalizedName,
            filterJson: jsonEncode(filter.toJson()),
            sortJson: jsonEncode(sort.toJson()),
            columnConfigJson: jsonEncode(columnConfig.toJson()),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> update(SavedLibraryView view) async {
    if (view.isDefault) return;
    final normalizedName = view.name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre de la vista es obligatorio.');
    }
    await (_db.update(_db.savedViews)
      ..where((table) => table.id.equals(view.id))).write(
      SavedViewsCompanion(
        name: Value(normalizedName),
        filterJson: Value(jsonEncode(view.filter.toJson())),
        sortJson: Value(jsonEncode(view.sort.toJson())),
        columnConfigJson: Value(jsonEncode(view.columnConfig.toJson())),
        updatedAt: Value(_clock.now()),
      ),
    );
  }

  Future<void> softDelete(String id) async {
    final now = _clock.now();
    await (_db.update(_db.savedViews)..where(
      (table) => table.id.equals(id),
    )).write(SavedViewsCompanion(updatedAt: Value(now), deletedAt: Value(now)));
  }

  SavedLibraryView _toDomain(SavedView row) {
    return SavedLibraryView(
      id: row.id,
      name: row.name,
      filter: LibraryFilterState.fromJson(_decode(row.filterJson)),
      sort: LibrarySortState.fromJson(_decode(row.sortJson)),
      columnConfig: LibraryColumnConfig.fromJson(_decode(row.columnConfigJson)),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Map<String, Object?> _decode(String value) {
    final decoded = jsonDecode(value);
    if (decoded is Map<String, Object?>) return decoded;
    if (decoded is Map) return decoded.cast<String, Object?>();
    return const {};
  }
}
