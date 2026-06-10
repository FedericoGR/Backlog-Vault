import 'library_column_config.dart';
import 'library_filter_state.dart';
import 'library_sort_state.dart';

class SavedLibraryView {
  const SavedLibraryView({
    required this.id,
    required this.name,
    required this.filter,
    required this.sort,
    required this.columnConfig,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final LibraryFilterState filter;
  final LibrarySortState sort;
  final LibraryColumnConfig columnConfig;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SavedLibraryView copyWith({
    String? id,
    String? name,
    LibraryFilterState? filter,
    LibrarySortState? sort,
    LibraryColumnConfig? columnConfig,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedLibraryView(
      id: id ?? this.id,
      name: name ?? this.name,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      columnConfig: columnConfig ?? this.columnConfig,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
