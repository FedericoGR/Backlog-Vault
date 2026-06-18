import '../features/bulk_metadata_import/domain/bulk_metadata_import_models.dart';
import '../features/import_export/notion_csv/domain/import_field.dart';
import '../features/library/domain/game_status.dart';
import '../features/library/domain/library_column_config.dart';
import '../features/library/domain/library_layout_mode.dart';
import '../features/metadata/domain/metadata_field.dart';
import '../features/playthroughs/domain/playthrough_status.dart';
import 'app_localizations.dart';

extension DomainLocalizations on AppLocalizations {
  String gameStatusLabel(GameStatus status) => switch (status) {
    GameStatus.wishlist => statusWishlist,
    GameStatus.backlog => statusBacklog,
    GameStatus.playing => statusPlaying,
    GameStatus.paused => statusPaused,
    GameStatus.completed => statusCompleted,
    GameStatus.dropped => statusDropped,
    GameStatus.retired => statusRetired,
  };

  String playthroughStatusLabel(PlaythroughStatus status) => switch (status) {
    PlaythroughStatus.planned => playthroughPlanned,
    PlaythroughStatus.active => playthroughActive,
    PlaythroughStatus.paused => playthroughPaused,
    PlaythroughStatus.completed => playthroughCompleted,
    PlaythroughStatus.dropped => playthroughDropped,
  };

  String monthLabel(int month) => switch (month) {
    1 => monthJanuary,
    2 => monthFebruary,
    3 => monthMarch,
    4 => monthApril,
    5 => monthMay,
    6 => monthJune,
    7 => monthJuly,
    8 => monthAugust,
    9 => monthSeptember,
    10 => monthOctober,
    11 => monthNovember,
    12 => monthDecember,
    _ => month.toString(),
  };

  String libraryColumnLabel(LibraryColumnKey column) => switch (column) {
    LibraryColumnKey.cover => columnCover,
    LibraryColumnKey.title => columnTitle,
    LibraryColumnKey.status => columnStatus,
    LibraryColumnKey.platforms => columnPlatforms,
    LibraryColumnKey.genres => columnGenres,
    LibraryColumnKey.rating => columnRating,
    LibraryColumnKey.releaseDate => columnReleaseDate,
    LibraryColumnKey.completedDate => columnCompletedDate,
    LibraryColumnKey.hours => columnHours,
    LibraryColumnKey.type => columnType,
    LibraryColumnKey.notes => columnNotes,
    LibraryColumnKey.updatedAt => columnUpdatedAt,
    LibraryColumnKey.playthroughs => columnPlaythroughs,
  };

  String libraryLayoutLabel(LibraryLayoutMode mode) => switch (mode) {
    LibraryLayoutMode.table => table,
    LibraryLayoutMode.gallery => gallery,
    LibraryLayoutMode.list => list,
  };

  String displayGameType(String value) => switch (value.trim().toLowerCase()) {
    'un jugador' || 'single_player' || 'single player' => gameTypeSinglePlayer,
    'multijugador' || 'multiplayer' => gameTypeMultiplayer,
    'cooperativo' || 'cooperative' || 'coop' || 'co-op' => gameTypeCooperative,
    _ => '-',
  };

  String metadataFieldLabel(MetadataField field) => switch (field) {
    MetadataField.title => columnTitle,
    MetadataField.releaseDate => gameReleaseDate,
    MetadataField.type => libraryType,
    MetadataField.genres => libraryGenres,
    MetadataField.platforms => libraryPlatforms,
  };

  String importFieldLabel(ImportField field) => switch (field) {
    ImportField.title => importFieldTitle,
    ImportField.releaseDate => importFieldReleaseDate,
    ImportField.completedAt => importFieldCompletedAt,
    ImportField.hoursPlayed => importFieldHours,
    ImportField.personalRating => importFieldRating,
    ImportField.genres => importFieldGenres,
    ImportField.platforms => importFieldPlatforms,
    ImportField.status => importFieldStatus,
    ImportField.type => importFieldType,
    ImportField.personalNotes => importFieldNotes,
  };

  String bulkScopeLabel(BulkMetadataImportScope value) => switch (value) {
    BulkMetadataImportScope.all => bulkScopeAll,
    BulkMetadataImportScope.onlyWithoutMetadata => bulkScopeNoMetadata,
    BulkMetadataImportScope.onlyWithoutCover => bulkScopeNoCover,
    BulkMetadataImportScope.onlyIncompleteFields => bulkScopeIncomplete,
  };

  String bulkContentModeLabel(BulkImportContentMode value) => switch (value) {
    BulkImportContentMode.metadataOnly => bulkContentMetadataOnly,
    BulkImportContentMode.coverOnly => bulkContentCoverOnly,
    BulkImportContentMode.metadataAndCover => bulkContentBoth,
  };

  String bulkContentModeDescription(
    BulkImportContentMode value,
  ) => switch (value) {
    BulkImportContentMode.metadataOnly => bulkContentMetadataOnlyDescription,
    BulkImportContentMode.coverOnly => bulkContentCoverOnlyDescription,
    BulkImportContentMode.metadataAndCover => bulkContentBothDescription,
  };

  String bulkConfidenceLabel(BulkMetadataConfidence value) => switch (value) {
    BulkMetadataConfidence.safe => bulkConfidenceSafe,
    BulkMetadataConfidence.probable => bulkConfidenceProbable,
    BulkMetadataConfidence.ambiguous => bulkConfidenceAmbiguous,
    BulkMetadataConfidence.none => bulkConfidenceNone,
  };

  String bulkApplyModeLabel(BulkMetadataApplyMode value) => switch (value) {
    BulkMetadataApplyMode.completeMissing => bulkCompleteMissing,
    BulkMetadataApplyMode.reviewAndReplace => bulkReviewReplace,
  };

  String bulkCoverProviderLabel(BulkCoverProviderMode value) => switch (value) {
    BulkCoverProviderMode.none => bulkNoCovers,
    BulkCoverProviderMode.igdb => 'IGDB',
    BulkCoverProviderMode.steamgriddb => 'SteamGridDB',
    BulkCoverProviderMode.igdbThenSteamGridDb => bulkIgdbFirst,
    BulkCoverProviderMode.steamGridDbThenIgdb => bulkSteamFirst,
  };

  String bulkExistingCoverModeLabel(BulkExistingCoverMode value) =>
      switch (value) {
        BulkExistingCoverMode.keepExisting => bulkKeepCovers,
        BulkExistingCoverMode.allowReplace => bulkAllowCoverReplace,
      };
}
