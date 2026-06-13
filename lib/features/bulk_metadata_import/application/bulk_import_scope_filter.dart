import '../../library/domain/library_game_row.dart';
import '../domain/bulk_metadata_import_models.dart';

class BulkImportScopeFilter {
  const BulkImportScopeFilter();

  List<LibraryGameRow> apply({
    required List<LibraryGameRow> rows,
    required BulkMetadataImportScope scope,
  }) {
    return rows.where((row) => includes(row: row, scope: scope)).toList();
  }

  bool includes({
    required LibraryGameRow row,
    required BulkMetadataImportScope scope,
  }) {
    return switch (scope) {
      BulkMetadataImportScope.all => true,
      BulkMetadataImportScope.onlyWithoutMetadata => !row.hasExternalMetadata,
      BulkMetadataImportScope.onlyWithoutCover =>
        row.selectedCoverLocalPath == null,
      BulkMetadataImportScope.onlyIncompleteFields => _hasIncompleteFields(row),
    };
  }

  bool _hasIncompleteFields(LibraryGameRow row) {
    return row.releaseDate == null ||
        row.platforms.isEmpty ||
        row.genres.isEmpty ||
        row.type.trim().isEmpty ||
        !row.hasExternalMetadata;
  }
}
