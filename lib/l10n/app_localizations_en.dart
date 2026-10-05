// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Backlog Vault';

  @override
  String get navigationLibrary => 'Games';

  @override
  String get navigationStatistics => 'Statistics';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Choose the language used on this device.';

  @override
  String get languageSystem => 'System';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAction => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get continueAction => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get retry => 'Retry';

  @override
  String get confirm => 'Confirm';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Create';

  @override
  String get replace => 'Replace';

  @override
  String get search => 'Search';

  @override
  String get clear => 'Clear';

  @override
  String get select => 'Select';

  @override
  String get selected => 'Selected';

  @override
  String get none => 'None';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ready => 'Ready';

  @override
  String get loading => 'Loading…';

  @override
  String get unexpectedErrorMessage => 'Something went wrong. Try again.';

  @override
  String get gameLoadError => 'The game could not be loaded.';

  @override
  String get gameSaveFailed => 'The game could not be saved.';

  @override
  String get csvOperationFailed => 'The CSV operation could not be completed.';

  @override
  String get bulkOperationFailed =>
      'The bulk operation could not be completed.';

  @override
  String get notAvailable => 'Not available';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLocalStatusTitle => 'Local status';

  @override
  String get settingsLocalStatusSubtitle =>
      'Backlog Vault remains offline-first: your library lives on this device and external integrations are optional.';

  @override
  String get settingsAccountRequired => 'Account required';

  @override
  String get settingsUsageMode => 'Usage mode';

  @override
  String get settingsLocalDatabase => 'Local database';

  @override
  String get settingsLoadingStatus => 'Loading status';

  @override
  String get settingsLoadingConfiguration => 'Loading configuration…';

  @override
  String get settingsPrivacyProtection => 'Privacy and protection';

  @override
  String get settingsPrivacyProtectionMessage =>
      'The local database and media files stay on this device. Library exports exclude images and credentials.';

  @override
  String get settingsLibraryData => 'Library data';

  @override
  String get settingsLibraryDataSubtitle =>
      'Save your games and personal data to a JSON file. The export does not include images or credentials.';

  @override
  String get settingsExportLibrary => 'Export library';

  @override
  String get libraryExportSucceeded => 'Library exported successfully.';

  @override
  String get libraryExportCancelled => 'No location was selected.';

  @override
  String get libraryExportFailed => 'The library could not be exported.';

  @override
  String get settingsGoodPractices => 'Good practices';

  @override
  String get settingsGoodPracticesSubtitle =>
      'Never paste real keys into README files, issues, logs, tests, or commits. Credentials stay in local secure storage.';

  @override
  String get settingsRawgSubtitle =>
      'Optional source for game metadata. The key is stored locally in the system secure storage.';

  @override
  String get settingsIgdbSubtitle =>
      'Client credentials used to query IGDB. The access token is renewed locally and the secret is never displayed.';

  @override
  String get settingsSteamGridDbSubtitle =>
      'Optional key for cover search. Backlog Vault still asks for explicit confirmation before saving covers.';

  @override
  String get settingsNewApiKey => 'New API key';

  @override
  String get settingsClientId => 'Client ID';

  @override
  String get settingsClientSecret => 'Client Secret';

  @override
  String get settingsApiKeyHelper =>
      'It is excluded from library exports, never shown in plain text, and must not end up in commits.';

  @override
  String get settingsClientIdHelper =>
      'Stored only on this device and excluded from library exports.';

  @override
  String get settingsClientSecretHelper =>
      'Never paste it into logs, README files, tests, or issues.';

  @override
  String get settingsMediaApiKeyHelper =>
      'Used only for media search and kept on this device.';

  @override
  String get settingsExternalKeysDeletion => 'External key removal';

  @override
  String get settingsExternalKeysDeletionMessage =>
      'Only locally stored credentials are removed. Games, applied metadata, external IDs, and saved covers are not changed.';

  @override
  String get settingsDeleteAllKeys => 'Delete all keys';

  @override
  String get settingsEnterApiKey => 'Enter an API key before saving.';

  @override
  String get settingsRawgSaved => 'RAWG API key saved locally.';

  @override
  String get settingsRawgDeleted => 'RAWG API key deleted.';

  @override
  String get settingsEnterIgdbCredentials =>
      'Enter a Client ID and Client Secret before saving.';

  @override
  String get settingsIgdbSaved => 'IGDB credentials saved locally.';

  @override
  String get settingsIgdbDeleted => 'IGDB credentials deleted.';

  @override
  String get settingsSteamGridDbSaved => 'SteamGridDB API key saved locally.';

  @override
  String get settingsSteamGridDbDeleted => 'SteamGridDB API key deleted.';

  @override
  String get settingsDeleteExternalKeysTitle => 'Delete external keys';

  @override
  String get settingsDeleteExternalKeysConfirmation =>
      'The RAWG, IGDB, and SteamGridDB keys stored on this device will be deleted. Your games, applied metadata, external IDs, and covers will not be changed.';

  @override
  String get settingsDeleteKeys => 'Delete keys';

  @override
  String get settingsExternalKeysDeleted => 'External keys deleted.';

  @override
  String get settingsConfigured => 'Configured';

  @override
  String get settingsNotConfigured => 'Not configured';

  @override
  String get settingsConfigurationPresent => 'Configuration present';

  @override
  String get settingsConfigurationPending => 'Configuration pending';

  @override
  String get settingsPending => 'Pending';

  @override
  String get statusBacklog => 'Not finished';

  @override
  String get statusCompleted => 'Finished';

  @override
  String get gameTypeUndefined => 'Not specified';

  @override
  String get gameTypeSinglePlayer => 'Single-player';

  @override
  String get gameTypeMultiplayer => 'Multiplayer';

  @override
  String get gameTypeCooperative => 'Co-op';

  @override
  String get games => 'Games';

  @override
  String get completed => 'Completed';

  @override
  String get missingCover => 'Missing cover';

  @override
  String get missingMetadata => 'Missing metadata';

  @override
  String get missingGenre => 'Missing genre';

  @override
  String get statisticsLibraryLoading => 'Loading library';

  @override
  String get statisticsLoadError => 'Statistics could not be loaded';

  @override
  String get statisticsAverageRating => 'Average rating';

  @override
  String hoursShort(Object value) {
    return '$value h';
  }

  @override
  String get apply => 'Apply';

  @override
  String get name => 'Name';

  @override
  String get view => 'View';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get importMetadata => 'Import metadata';

  @override
  String get libraryLoading => 'Loading library';

  @override
  String get libraryLoadError => 'Library could not be loaded';

  @override
  String get libraryConfirmation => 'Confirmation';

  @override
  String get libraryPlatforms => 'Platforms';

  @override
  String get libraryGenres => 'Genres';

  @override
  String get libraryType => 'Type';

  @override
  String get libraryDeleteGameTitle => 'Delete game';

  @override
  String libraryDeleteGameMessage(Object title) {
    return '“$title” will be hidden from the library.';
  }

  @override
  String get libraryHours => 'Hours';

  @override
  String get gameCreateTitle => 'Create game';

  @override
  String get gameEditTitle => 'Edit game';

  @override
  String get gameName => 'Name';

  @override
  String get gameNameRequired => 'The name is required.';

  @override
  String get gameReleaseDate => 'Release date';

  @override
  String get gameMyRecord => 'My record';

  @override
  String get gameMyRecordHint =>
      'Your experience with the game. All fields are optional.';

  @override
  String get gameInformation => 'Game information';

  @override
  String get gameInformationHint =>
      'Release date, type, genres, and catalog platforms.';

  @override
  String get gameFindGame => 'Find game';

  @override
  String get gameIdentifyHint =>
      'Find a game or enter its name to add it manually.';

  @override
  String get gameFinishDate => 'Completion date (optional)';

  @override
  String get gameRating => 'Rating';

  @override
  String get gamePersonalRating => 'Personal rating';

  @override
  String get gamePersonalNotes => 'Personal notes';

  @override
  String get gameAddPlatform => 'Add platform';

  @override
  String get gameAddGenre => 'Add genre';

  @override
  String get gameImportMetadata => 'Import metadata';

  @override
  String get gameSearchByTitle => 'Search by title';

  @override
  String get provider => 'Provider';

  @override
  String get gameNoCandidates => 'No candidates yet';

  @override
  String gameNoCandidatesMessage(Object provider) {
    return 'Search for a game to prefill fields from $provider.';
  }

  @override
  String get gameApplyToForm => 'Apply to form';

  @override
  String providerNoCandidates(Object provider) {
    return '$provider returned no candidates.';
  }

  @override
  String get gameSaveIncludedCover => 'Save included cover';

  @override
  String get gameIncludedCoverReplace =>
      'The current cover will be replaced when the game is saved.';

  @override
  String get gameIncludedCoverSave =>
      'The cover will be stored locally after the game is saved.';

  @override
  String gamePendingCover(Object provider) {
    return 'Pending cover: $provider';
  }

  @override
  String get ratingOneStar => '1 star';

  @override
  String ratingStars(Object count) {
    return '$count stars';
  }

  @override
  String get choose => 'Choose';

  @override
  String get gameCompletionDate => 'Completion date';

  @override
  String get gameHoursPlayed => 'Hours played';

  @override
  String get gamePlatform => 'Platform';

  @override
  String get gameNoPlatform => 'No platform';

  @override
  String get gameNotFoundTitle => 'Game not found';

  @override
  String get gameNotFoundMessage => 'The game could not be found.';

  @override
  String get errorTitle => 'Error';

  @override
  String get coverSearch => 'Search cover';

  @override
  String get coverChange => 'Change cover';

  @override
  String get metadataSearch => 'Search metadata';

  @override
  String get gameDeleteTooltip => 'Delete game';

  @override
  String get gameActions => 'Game actions';

  @override
  String get gameRemoveCover => 'Remove cover';

  @override
  String get metadataApplied => 'Metadata applied.';

  @override
  String get coverUpdated => 'Cover updated.';

  @override
  String get coverRemoveTitle => 'Remove cover';

  @override
  String get coverRemoveMessage =>
      'The cover will be hidden from the game without physically deleting your media history.';

  @override
  String get remove => 'Remove';

  @override
  String get coverRemoved => 'Cover removed.';

  @override
  String get gameNote => 'Note';

  @override
  String get gameNotes => 'Notes';

  @override
  String get metadataDialogTitle => 'Search metadata';

  @override
  String get metadataTitleField => 'Title';

  @override
  String externalIdValue(Object id, Object provider) {
    return '$provider · ID $id';
  }

  @override
  String get metadataNoCandidates => 'No candidates yet';

  @override
  String metadataNoCandidatesMessage(Object provider) {
    return 'Search for a game to see results from $provider.';
  }

  @override
  String get metadataSaveLink => 'Save link';

  @override
  String get metadataApply => 'Apply metadata';

  @override
  String get metadataCoverSaveFailed =>
      'Metadata was applied, but the cover could not be saved.';

  @override
  String get metadataReplaceCoverTitle => 'Replace cover';

  @override
  String get metadataReplaceCoverMessage =>
      'This game already has a selected cover. Replace it with the cover included by IGDB?';

  @override
  String get metadataReplaceExternalTitle => 'Replace external match';

  @override
  String get metadataReplaceExternalMessage =>
      'This game already has another external match for this provider. Replace it with the selected candidate?';

  @override
  String get metadataOperationFailed =>
      'The metadata operation could not be completed.';

  @override
  String get metadataIncludedCoverExisting =>
      'This game already has a cover. Confirmation will be requested before replacing it.';

  @override
  String get metadataIncludedCoverOffline =>
      'The cover will be stored locally and remain available offline.';

  @override
  String get metadataNoNewFields =>
      'There are no new fields to apply. You can still save the external link.';

  @override
  String get metadataReplaces => 'replaces';

  @override
  String get metadataProtected => 'protected';

  @override
  String metadataCurrentExternal(
    Object current,
    Object external,
    Object provider,
  ) {
    return 'Current: $current\n$provider: $external';
  }

  @override
  String get openSettings => 'Open settings';

  @override
  String get coverDialogSearchTitle => 'Search cover';

  @override
  String get coverDialogChangeTitle => 'Change cover';

  @override
  String coverSearchIn(Object provider) {
    return 'Search in $provider';
  }

  @override
  String get coverUseLocalFile => 'Use local file';

  @override
  String get coverNoResults => 'No covers yet';

  @override
  String coverNoResultsMessage(Object provider) {
    return 'Search for a game in $provider or choose a local file.';
  }

  @override
  String get coverSave => 'Save cover';

  @override
  String providerNoCovers(Object provider) {
    return '$provider returned no covers.';
  }

  @override
  String get coverOperationFailed =>
      'The cover operation could not be completed.';

  @override
  String get warnings => 'Warnings';

  @override
  String get errors => 'Errors';

  @override
  String get csvImportTitle => 'Import Notion CSV';

  @override
  String get csvFlowTitle => 'Import workflow';

  @override
  String get csvFlowDescription =>
      'This workflow creates new games from a CSV exported by Notion. It does not update existing games and lets you review the mapping before applying changes.';

  @override
  String get csvMappingNeedsName => 'The mapping needs a Name column.';

  @override
  String get csvConfirmTitle => 'Confirm import';

  @override
  String csvConfirmMessage(Object count) {
    return '$count games will be imported. Existing games will not be updated.';
  }

  @override
  String get csvImportAction => 'Import';

  @override
  String get stepOne => 'Step 1';

  @override
  String get stepTwo => 'Step 2';

  @override
  String get stepThree => 'Step 3';

  @override
  String get stepFour => 'Step 4';

  @override
  String get csvChooseFile => 'Choose file';

  @override
  String get csvChooseFileDescription =>
      'Select the CSV exported by Notion. The app detects the delimiter, columns, and row count before continuing.';

  @override
  String get csvNoFile => 'No file selected yet';

  @override
  String get csvNoFileMessage =>
      'Choose a CSV to review headers, mapping, and the import preview.';

  @override
  String csvRows(Object count) {
    return '$count rows';
  }

  @override
  String csvColumns(Object count) {
    return '$count columns';
  }

  @override
  String csvDelimiter(Object delimiter) {
    return 'Delimiter “$delimiter”';
  }

  @override
  String get csvSelect => 'Select CSV';

  @override
  String get csvChange => 'Change CSV';

  @override
  String get csvColumnMapping => 'Column mapping';

  @override
  String get csvColumnMappingDescription =>
      'Define how CSV headers are interpreted. Only Name is required to generate the preview.';

  @override
  String get csvMissingNameMapping => 'Map Name before generating the preview.';

  @override
  String get csvDoNotImport => 'Do not import';

  @override
  String get csvGeneratePreview => 'Generate preview';

  @override
  String get csvPreviewDescription =>
      'Review which rows will be imported, omitted, or reported with warnings and duplicates.';

  @override
  String get csvConfirmImport => 'Confirm import';

  @override
  String csvImportable(Object count) {
    return '$count importable';
  }

  @override
  String csvOmitted(Object count) {
    return '$count omitted';
  }

  @override
  String csvWithWarnings(Object count) {
    return '$count with warnings';
  }

  @override
  String csvWithErrors(Object count) {
    return '$count with errors';
  }

  @override
  String csvDuplicates(Object count) {
    return '$count duplicates';
  }

  @override
  String get csvNoRows => 'No rows to review';

  @override
  String get csvNoRowsMessage =>
      'The preview did not generate visible rows to import.';

  @override
  String csvUnnamedRow(Object row) {
    return 'Row $row without a name';
  }

  @override
  String get csvHasErrors => 'Has errors';

  @override
  String get csvWarning => 'Warning';

  @override
  String get csvDuplicate => 'Duplicate';

  @override
  String get csvSkipDuplicate => 'Skip duplicate';

  @override
  String get csvCreateAnyway => 'Create anyway';

  @override
  String get csvResult => 'Result';

  @override
  String get csvResultDescription =>
      'A summary of what actually entered your local library.';

  @override
  String csvImported(Object count) {
    return 'Imported $count';
  }

  @override
  String csvSkipped(Object count) {
    return 'Skipped $count';
  }

  @override
  String csvDuplicateSkipped(Object count) {
    return 'Duplicates $count';
  }

  @override
  String csvPlatformsCreated(Object count) {
    return 'Platforms $count';
  }

  @override
  String csvGenresCreated(Object count) {
    return 'Genres $count';
  }

  @override
  String get csvBackToLibrary => 'Back to library';

  @override
  String get cannotContinue => 'Could not continue';

  @override
  String get importFieldTitle => 'Name';

  @override
  String get importFieldReleaseDate => 'Release date';

  @override
  String get importFieldCompletedAt => 'Completion date';

  @override
  String get importFieldHours => 'Duration';

  @override
  String get importFieldRating => 'Rating';

  @override
  String get importFieldGenres => 'Genres';

  @override
  String get importFieldPlatforms => 'Platforms';

  @override
  String get importFieldStatus => 'Status';

  @override
  String get importFieldType => 'Type';

  @override
  String get importFieldNotes => 'Notes';

  @override
  String get bulkTitle => 'Import metadata';

  @override
  String get bulkIntroTitle => 'Bulk import';

  @override
  String get bulkIntroDescription =>
      'Define the scope, review the preview, and confirm exactly which metadata or covers will be applied before running batch changes.';

  @override
  String get bulkLoadingLibrary => 'Loading library';

  @override
  String get bulkPreviewFailed => 'The preview could not be generated.';

  @override
  String get bulkConfirmTitle => 'Confirm bulk import';

  @override
  String get bulkConfirmMessage =>
      'Only selected games, fields, and covers will be applied.';

  @override
  String bulkConfirmSummary(
    Object games,
    Object newCovers,
    Object newFields,
    Object replacedCovers,
    Object replacedFields,
  ) {
    return 'Games: $games\nNew fields: $newFields\nReplaced fields: $replacedFields\nNew covers: $newCovers\nReplaced covers: $replacedCovers';
  }

  @override
  String bulkTypeConfirmation(Object keyword) {
    return 'Type $keyword to confirm.';
  }

  @override
  String get bulkReplace => 'Replace';

  @override
  String get bulkApply => 'Apply';

  @override
  String bulkScoreValue(Object score) {
    return 'Score $score';
  }

  @override
  String get bulkGlobalIssue => 'Global';

  @override
  String get bulkIssueNoCandidates => 'The provider returned no candidates.';

  @override
  String get bulkIssueProbableMatch =>
      'Probable match: review it before applying.';

  @override
  String get bulkIssueAmbiguousMatch =>
      'Ambiguous match: manual review is required.';

  @override
  String get bulkIssueExternalReplacementAllowed =>
      'This game already has another external match for the provider. It is replaced only when you include the game and confirm the replacement.';

  @override
  String get bulkIssueExternalReplacementBlocked =>
      'This game already has another external match for the provider. Choose Review and replace to allow the replacement.';

  @override
  String get bulkIssueExistingCover => 'A cover is already selected.';

  @override
  String get bulkIssueReplacementAvailable =>
      'A cover replacement is available.';

  @override
  String get bulkIssueNoCover => 'No applicable cover was found.';

  @override
  String get bulkIssueReviewRequired =>
      'Review this item before applying changes.';

  @override
  String get bulkMatchReasonExistingExternalId => 'existing external ID';

  @override
  String get bulkMatchReasonExactTitle => 'exact title';

  @override
  String get bulkMatchReasonSimilarTitle => 'similar title';

  @override
  String get bulkMatchReasonSameYear => 'same year';

  @override
  String get bulkMatchReasonNearbyYear => 'nearby year';

  @override
  String get bulkMatchReasonMatchingPlatform => 'matching platform';

  @override
  String get bulkMatchReasonFirstCandidate => 'first candidate';

  @override
  String get bulkMatchReasonOther => 'provider match';

  @override
  String get bulkWhatImport => 'What do you want to import?';

  @override
  String get bulkWhatImportDescription =>
      'Choose the import type, then adjust scope, provider, and replacement rules before generating the preview.';

  @override
  String get bulkGamesToAnalyze => 'Games to analyze';

  @override
  String get bulkGamesToAnalyzeHelper =>
      'This does not decide what gets overwritten.';

  @override
  String get bulkMetadataProvider => 'Metadata provider';

  @override
  String get bulkMetadataMode => 'Metadata mode';

  @override
  String get bulkCoverSource => 'Cover source';

  @override
  String get bulkExistingCovers => 'Existing covers';

  @override
  String get bulkScanning => 'Scanning library';

  @override
  String get bulkPreviewTitle => 'Preview';

  @override
  String get bulkPreviewDescription =>
      'Filter matches, review changes, and leave selected only the games and fields you want to apply.';

  @override
  String get bulkAnalyzed => 'Analyzed';

  @override
  String get bulkWithMatch => 'Matched';

  @override
  String get bulkWithoutMatch => 'No match';

  @override
  String get bulkSafe => 'Safe';

  @override
  String get bulkProbable => 'Probable';

  @override
  String get bulkAmbiguous => 'Ambiguous';

  @override
  String get bulkWithCover => 'With cover';

  @override
  String get bulkWithoutCover => 'Without cover';

  @override
  String get bulkSelected => 'Selected';

  @override
  String get bulkNewFields => 'New fields';

  @override
  String get bulkReplacedFields => 'Replaced fields';

  @override
  String get bulkNewCovers => 'New covers';

  @override
  String get bulkReplacedCovers => 'Replaced covers';

  @override
  String get bulkSelectVisible => 'Select visible';

  @override
  String get bulkDeselectAll => 'Deselect all';

  @override
  String get bulkSelectSafe => 'Select safe';

  @override
  String get bulkNewCoverSelection => 'New covers';

  @override
  String get bulkCoverReplacements => 'Cover replacements';

  @override
  String get bulkReplaceableFields => 'Replaceable fields';

  @override
  String get bulkNoGamesForFilter => 'No games match this filter';

  @override
  String get bulkNoGamesForFilterMessage =>
      'Try changing the preview filter or reviewing the scope selected in the previous step.';

  @override
  String get bulkCandidates => 'Candidates';

  @override
  String get bulkUse => 'Use';

  @override
  String get bulkNoMetadataFields => 'There are no metadata fields to apply.';

  @override
  String get bulkFields => 'Fields';

  @override
  String bulkCurrentExternal(Object current, Object external) {
    return 'Current: $current\nExternal: $external';
  }

  @override
  String get bulkSaveCover => 'Save cover';

  @override
  String get bulkChooseCover => 'Choose cover';

  @override
  String get bulkNoCoverFound => 'No cover found';

  @override
  String get bulkCoverReplacementSelected => 'Cover replacement selected';

  @override
  String get bulkNewCoverSelected => 'New cover selected';

  @override
  String get bulkAlreadyHasCover => 'Already has a cover';

  @override
  String get bulkCoverFound => 'Cover found';

  @override
  String bulkChooseCoverFor(Object title) {
    return 'Choose cover · $title';
  }

  @override
  String get bulkFinalConfirmation => 'Final confirmation';

  @override
  String get bulkFinalConfirmationDescription =>
      'Only games, fields, and covers that remain selected in the preview will be applied.';

  @override
  String bulkFinalSummary(
    Object games,
    Object newCovers,
    Object newFields,
    Object replacedCovers,
    Object replacedFields,
  ) {
    return '$games selected games · $newFields fields to complete · $replacedFields fields to replace · $newCovers new covers · $replacedCovers covers to replace.';
  }

  @override
  String get bulkApplyChanges => 'Apply changes';

  @override
  String get bulkResultTitle => 'Import complete';

  @override
  String get bulkResultDescription =>
      'A summary of matches, saved changes, and warnings or errors returned by the process.';

  @override
  String get bulkProcessed => 'Processed';

  @override
  String get bulkNewMetadata => 'New metadata';

  @override
  String get bulkReplacedMetadata => 'Replaced metadata';

  @override
  String get bulkLinks => 'Links';

  @override
  String get bulkSkipped => 'Skipped';

  @override
  String get bulkNewPreview => 'Generate new preview';

  @override
  String get bulkFilterAll => 'All';

  @override
  String get bulkFilterSelected => 'Selected';

  @override
  String get bulkFilterSafe => 'Safe';

  @override
  String get bulkFilterProbable => 'Probable';

  @override
  String get bulkFilterAmbiguous => 'Ambiguous';

  @override
  String get bulkFilterErrors => 'Errors';

  @override
  String get bulkFilterNoResult => 'No result';

  @override
  String get bulkFilterMetadata => 'With metadata';

  @override
  String get bulkFilterCover => 'With cover';

  @override
  String get bulkFilterReplacements => 'With replacements';

  @override
  String get bulkScopeAll => 'All active games';

  @override
  String get bulkScopeNoMetadata => 'Only without metadata';

  @override
  String get bulkScopeNoCover => 'Only without cover';

  @override
  String get bulkScopeIncomplete => 'Only incomplete data';

  @override
  String get bulkContentMetadataOnly => 'Metadata only';

  @override
  String get bulkContentCoverOnly => 'Cover art only';

  @override
  String get bulkContentBoth => 'Metadata + cover art';

  @override
  String get bulkContentMetadataOnlyDescription =>
      'Complete or review metadata fields without downloading covers.';

  @override
  String get bulkContentCoverOnlyDescription =>
      'Search for covers for existing games without applying metadata fields.';

  @override
  String get bulkContentBothDescription =>
      'Review metadata and covers in the same preview before applying.';

  @override
  String get bulkConfidenceSafe => 'Safe';

  @override
  String get bulkConfidenceProbable => 'Probable';

  @override
  String get bulkConfidenceAmbiguous => 'Ambiguous';

  @override
  String get bulkConfidenceNone => 'No match';

  @override
  String get bulkCompleteMissing => 'Complete missing';

  @override
  String get bulkReviewReplace => 'Review and replace';

  @override
  String get bulkNoCovers => 'Do not import covers';

  @override
  String get bulkIgdbFirst => 'IGDB first + SteamGridDB fallback';

  @override
  String get bulkSteamFirst => 'SteamGridDB first + IGDB fallback';

  @override
  String get bulkKeepCovers => 'Keep existing covers';

  @override
  String get bulkAllowCoverReplace => 'Allow replacement with confirmation';

  @override
  String get bulkCurrentCover => 'current cover';

  @override
  String bulkReplacesCover(Object cover) {
    return 'replaces $cover';
  }

  @override
  String get gamePlayedPlatform => 'Played on';

  @override
  String get gameHoursInvalid => 'Enter a non-negative number.';

  @override
  String get logPreviousYear => 'Previous year';

  @override
  String get logNextYear => 'Next year';

  @override
  String get logUnknownYear => 'No year';

  @override
  String get logPlayedYear => 'Played year (optional)';

  @override
  String get logInvalidYear => 'Enter a year between 1 and 9999.';

  @override
  String get logAddGame => 'Add game';

  @override
  String get logEmptyYear => 'No games here yet';

  @override
  String get logEmptyYearHint =>
      'Add a game or choose another year. Undated records are under No year.';

  @override
  String get logNoSearchResults => 'No matching games';

  @override
  String get logSearchHint => 'Try another title or choose another year.';

  @override
  String get statisticsFinished => 'Finished';

  @override
  String get statisticsUnavailable => 'No data';

  @override
  String get statisticsEmptyYear => 'No games this year';

  @override
  String get statisticsEmptyYearHint =>
      'Games without a year remain available in Games → No year.';

  @override
  String get statisticsFavorites => 'Favorites';

  @override
  String get statisticsNoRatedGames => 'No rated games this year yet.';

  @override
  String get statisticsPlayedPlatforms => 'Where I played';

  @override
  String get statisticsPlayedPlatformsHint =>
      'Games by recorded played platform.';

  @override
  String get statisticsNoPlayedPlatforms =>
      'No played platforms recorded this year yet.';

  @override
  String get columnTitle => 'Title';
}
