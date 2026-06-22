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
  String get navigationHome => 'Home';

  @override
  String get navigationLibrary => 'Library';

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
      'The local database and media files are not encrypted at rest yet. Encrypted backups are available for export and restore.';

  @override
  String get settingsDataBackups => 'Data and backups';

  @override
  String get settingsDataBackupsSubtitle =>
      'Export JSON/CSV, create regular or encrypted backups, and restore local files.';

  @override
  String get settingsOpenBackups => 'Open backups';

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
  String get settingsApiKeyHelper =>
      'It is excluded from backups, never shown in plain text, and must not end up in commits.';

  @override
  String get settingsClientIdHelper =>
      'Stored only on this device and excluded from backups.';

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
  String get statusWishlist => 'Wishlist';

  @override
  String get statusBacklog => 'Backlog';

  @override
  String get statusPlaying => 'Playing';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusDropped => 'Dropped';

  @override
  String get statusRetired => 'Retired';

  @override
  String get playthroughPlanned => 'Planned';

  @override
  String get playthroughActive => 'Active';

  @override
  String get playthroughPaused => 'Paused';

  @override
  String get playthroughCompleted => 'Completed';

  @override
  String get playthroughDropped => 'Dropped';

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
  String get backlog => 'Backlog';

  @override
  String get playing => 'Playing';

  @override
  String get completed => 'Completed';

  @override
  String get missingCover => 'Missing cover';

  @override
  String get missingMetadata => 'Missing metadata';

  @override
  String get missingRating => 'Missing rating';

  @override
  String get missingPlatform => 'Missing platform';

  @override
  String get missingGenre => 'Missing genre';

  @override
  String get homeNowPlaying => 'Playing now';

  @override
  String get homeNowPlayingDescription =>
      'The most active games in your personal library.';

  @override
  String get homeNowPlayingEmpty => 'No games are currently in progress.';

  @override
  String get homeBacklogDescription => 'Pending games ready for another look.';

  @override
  String get homeBacklogEmpty => 'There are no pending backlog games.';

  @override
  String get homeRecentCompleted => 'Recently completed';

  @override
  String get homeRecentCompletedDescription =>
      'Your latest games with a recorded completion date.';

  @override
  String get homeRecentCompletedEmpty =>
      'No completed games have a recorded date.';

  @override
  String get homeMissingCoverDescription =>
      'Entries that still need a visual selection.';

  @override
  String get homeMissingCoverEmpty => 'Every visible game has a cover.';

  @override
  String get homeMissingMetadataDescription =>
      'Games worth enriching before organizing further.';

  @override
  String get homeMissingMetadataEmpty =>
      'Every visible game has external metadata.';

  @override
  String get homeRecentlyUpdated => 'Recently updated';

  @override
  String get homeRecentlyUpdatedDescription =>
      'Recent changes to statuses, notes, and playthroughs.';

  @override
  String get homeRecentlyUpdatedEmpty => 'There is no recent activity.';

  @override
  String get homeLoading => 'Loading home';

  @override
  String get homeLoadError => 'Home could not be loaded';

  @override
  String homeLibrarySummary(
    Object completedCount,
    Object playingCount,
    Object total,
  ) {
    return '$total active games, $completedCount completed, and $playingCount in progress.';
  }

  @override
  String get homeOpenLibrary => 'Open library';

  @override
  String get homeQuickPanel => 'Quick actions';

  @override
  String get homeQuickPanelDescription =>
      'Jump to statistics or review games still missing covers or metadata.';

  @override
  String get homeViewStatistics => 'View statistics';

  @override
  String get homeCreateGame => 'Create game';

  @override
  String get homeViewLibrary => 'View library';

  @override
  String get homeEmptyTitle => 'Your library is still empty.';

  @override
  String get homeEmptyMessage =>
      'Once you add your first games, this dashboard will show activity, pending games, and data quality.';

  @override
  String get homeCreateFirstGame => 'Create first game';

  @override
  String get statisticsLibraryLoading => 'Loading library';

  @override
  String get statisticsProgressLoading => 'Loading progress';

  @override
  String get statisticsLoadProgressError => 'Progress could not be loaded';

  @override
  String get statisticsLoadError => 'Statistics could not be loaded';

  @override
  String get statisticsLibraryByStatus => 'Library by status';

  @override
  String get statisticsLibraryByStatusSubtitle =>
      'A quick distribution of your current backlog.';

  @override
  String get statisticsRatings => 'Ratings';

  @override
  String get statisticsRatingsSubtitle =>
      'How your personal scores are distributed across rated games.';

  @override
  String get statisticsDataQuality => 'Data quality';

  @override
  String get statisticsDataQualitySubtitle =>
      'Metadata gaps that are still worth reviewing.';

  @override
  String get statisticsAnnualProgress => 'Annual progress';

  @override
  String get statisticsAnnualProgressSubtitle =>
      'Completed playthroughs with dates and logged hours by period.';

  @override
  String get statisticsTopPlatforms => 'Most-used platforms';

  @override
  String get statisticsTopPlatformsSubtitle =>
      'Where most of your play activity is concentrated.';

  @override
  String get statisticsNoPlatforms => 'No platforms have been recorded.';

  @override
  String get statisticsTopGenres => 'Most-used genres';

  @override
  String get statisticsTopGenresSubtitle =>
      'The styles that dominate your personal library.';

  @override
  String get statisticsNoGenres => 'No genres have been recorded.';

  @override
  String get statisticsRecentCompleted => 'Recently completed';

  @override
  String get statisticsRecentCompletedSubtitle =>
      'Your latest completions with a recorded date.';

  @override
  String get statisticsPulse => 'Library pulse';

  @override
  String get statisticsPulseSubtitle =>
      'A quick look at backlog, progress, and data quality from the same catalog.';

  @override
  String statisticsCompletedHours(Object completedCount, Object hours) {
    return '$completedCount completed · $hours hours';
  }

  @override
  String get statisticsTotalCompleted => 'Total completed';

  @override
  String get statisticsLoggedHours => 'Logged hours';

  @override
  String get statisticsAverageRating => 'Average rating';

  @override
  String get statisticsYear => 'Year';

  @override
  String get statisticsNoAnnualProgress => 'No annual progress yet';

  @override
  String get statisticsNoAnnualProgressMessage =>
      'Once you complete dated playthroughs, this panel will summarize them by year and month.';

  @override
  String statisticsMonthsOf(Object year) {
    return 'Months of $year';
  }

  @override
  String get statisticsNoRatings => 'No ratings yet';

  @override
  String get statisticsNoRatingsMessage =>
      'Once you start rating games, this section will show how your scores are distributed.';

  @override
  String statisticsStars(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String statisticsUnrated(Object count) {
    return 'Unrated: $count';
  }

  @override
  String get statisticsNoData => 'No data yet';

  @override
  String get statisticsCompletedWithoutDate => 'Completed without date';

  @override
  String get statisticsNoCompleted => 'No completed games yet';

  @override
  String get statisticsNoCompletedMessage =>
      'Record a completion date in your playthroughs to see them here.';

  @override
  String get statisticsEmptyTitle =>
      'There is not enough data to calculate statistics yet.';

  @override
  String get statisticsEmptyMessage =>
      'Once you add games and playthroughs, this dashboard will summarize progress, ratings, and metadata quality.';

  @override
  String get statisticsGoToLibrary => 'Go to library';

  @override
  String hoursShort(Object value) {
    return '$value h';
  }

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get apply => 'Apply';

  @override
  String get name => 'Name';

  @override
  String get view => 'View';

  @override
  String get filters => 'Filters';

  @override
  String get table => 'Table';

  @override
  String get gallery => 'Gallery';

  @override
  String get list => 'List';

  @override
  String get columns => 'Columns';

  @override
  String get saveView => 'Save view';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get importMetadata => 'Import metadata';

  @override
  String get libraryExitSelection => 'Exit selection';

  @override
  String get librarySelectMultiple => 'Select multiple';

  @override
  String get libraryLoading => 'Loading library';

  @override
  String get libraryLoadError => 'Library could not be loaded';

  @override
  String get libraryDeleteSelectedTitle => 'Delete selected games';

  @override
  String libraryDeleteSelectedMessage(Object count) {
    return '$count games will be marked as deleted. They will not be physically removed.';
  }

  @override
  String get libraryTypeDeleteConfirmation => 'Type DELETE to confirm.';

  @override
  String get libraryDeleteKeyword => 'DELETE';

  @override
  String get libraryConfirmation => 'Confirmation';

  @override
  String get libraryDeleteSelected => 'Delete selected';

  @override
  String libraryFiltersCount(Object count) {
    return 'Filters ($count)';
  }

  @override
  String get libraryActions => 'Library actions';

  @override
  String get libraryUpdateView => 'Update view';

  @override
  String get libraryRenameView => 'Rename view';

  @override
  String get libraryDeleteView => 'Delete view';

  @override
  String get libraryYear => 'Year';

  @override
  String libraryFilterStatus(Object value) {
    return 'Status: $value';
  }

  @override
  String libraryFilterPlatform(Object value) {
    return 'Platform: $value';
  }

  @override
  String libraryFilterGenre(Object value) {
    return 'Genre: $value';
  }

  @override
  String libraryFilterSearch(Object value) {
    return 'Search: $value';
  }

  @override
  String get libraryMissingCompletedDate => 'Missing completion date';

  @override
  String get libraryOpenDetails => 'Open details';

  @override
  String get libraryActionsTooltip => 'Actions';

  @override
  String get libraryAdvancedFilters => 'Advanced filters';

  @override
  String get libraryClearFilters => 'Clear filters';

  @override
  String get libraryStatus => 'Status';

  @override
  String get libraryPlatforms => 'Platforms';

  @override
  String get libraryGenres => 'Genres';

  @override
  String get libraryMinimumRating => 'Minimum rating';

  @override
  String get libraryMaximumRating => 'Maximum rating';

  @override
  String get libraryMinimumHours => 'Minimum hours';

  @override
  String get libraryMaximumHours => 'Maximum hours';

  @override
  String get libraryType => 'Type';

  @override
  String get libraryReleaseFrom => 'Released from';

  @override
  String get libraryReleaseTo => 'Released through';

  @override
  String get libraryCompletedFrom => 'Completed from';

  @override
  String get libraryCompletedTo => 'Completed through';

  @override
  String get libraryWithRating => 'With rating';

  @override
  String get libraryWithPlatform => 'With platform';

  @override
  String get libraryWithGenre => 'With genre';

  @override
  String get libraryWithCompletedDate => 'With completion date';

  @override
  String get libraryNoOptions => 'No options available.';

  @override
  String get libraryClearDate => 'Clear date';

  @override
  String get libraryChooseDate => 'Choose date';

  @override
  String get libraryVisibleColumns => 'Visible columns';

  @override
  String get libraryEmptyTitle => 'There are no games in your library yet.';

  @override
  String get libraryEmptyMessage =>
      'Once you add the first one, the catalog will start taking shape.';

  @override
  String get libraryEmptyFilteredTitle => 'No games match the current view.';

  @override
  String get libraryEmptyFilteredMessage =>
      'Try relaxing filters, changing the saved view, or clearing the search.';

  @override
  String get libraryViewUpdated => 'View updated.';

  @override
  String libraryDeleteViewMessage(Object name) {
    return 'The view “$name” will be deleted.';
  }

  @override
  String get libraryDeleteGameTitle => 'Delete game';

  @override
  String libraryDeleteGameMessage(Object title) {
    return '“$title” will be hidden from the library.';
  }

  @override
  String get libraryNoLimit => 'No limit';

  @override
  String get libraryDefaultAll => 'All games';

  @override
  String get libraryDefaultPending => 'Pending';

  @override
  String get libraryDefaultCompleted => 'Completed';

  @override
  String get libraryDefaultByYear => 'Filter by year';

  @override
  String librarySelectedCount(Object count) {
    return '$count selected';
  }

  @override
  String librarySelectVisible(Object count) {
    return 'Select visible ($count)';
  }

  @override
  String librarySelectAll(Object count) {
    return 'Select all ($count)';
  }

  @override
  String get libraryClearSelection => 'Clear selection';

  @override
  String get libraryAverage => 'Average';

  @override
  String get libraryHours => 'Hours';

  @override
  String get libraryNoOptionsShort => 'No options';

  @override
  String get columnCover => 'Cover';

  @override
  String get columnTitle => 'Title';

  @override
  String get columnStatus => 'Status';

  @override
  String get columnPlatforms => 'Platforms';

  @override
  String get columnGenres => 'Genres';

  @override
  String get columnRating => 'Rating';

  @override
  String get columnReleaseDate => 'Release date';

  @override
  String get columnCompletedDate => 'Completion date';

  @override
  String get columnHours => 'Hours';

  @override
  String get columnType => 'Type';

  @override
  String get columnNotes => 'Notes';

  @override
  String get columnUpdatedAt => 'Updated';

  @override
  String get columnPlaythroughs => 'Playthroughs';

  @override
  String get gameCreateTitle => 'Create game';

  @override
  String get gameEditTitle => 'Edit game';

  @override
  String get gameIdentity => 'Identity';

  @override
  String get gameIdentitySubtitle => 'Game information and external metadata.';

  @override
  String get gameName => 'Name';

  @override
  String get gameNameRequired => 'The name is required.';

  @override
  String get gameReleaseDate => 'Release date';

  @override
  String get gamePersonalLibrary => 'Personal library';

  @override
  String get gamePersonalLibrarySubtitle =>
      'Status, rating, and private notes.';

  @override
  String get gamePersonalRating => 'Personal rating';

  @override
  String get gamePersonalNotes => 'Personal notes';

  @override
  String get gameCatalogs => 'Catalogs';

  @override
  String get gameCatalogsSubtitle => 'Associated platforms and genres.';

  @override
  String get gameAddPlatform => 'Add platform';

  @override
  String get gameAddGenre => 'Add genre';

  @override
  String get gameCompletionSection => 'Completion / playthrough';

  @override
  String get gameCompletionSectionSubtitle =>
      'Initial details when marking the game as completed.';

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
  String get gameSearchMetadata => 'Search metadata';

  @override
  String gamePendingCover(Object provider) {
    return 'Pending cover: $provider';
  }

  @override
  String get ratingNone => 'No rating';

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
  String get gamePlaythroughRating => 'Playthrough rating';

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
  String get gameSummaryProgress => 'Summary and progress';

  @override
  String get gameLastCompleted => 'Last completed';

  @override
  String get gamePlaythroughs => 'Playthroughs';

  @override
  String get gameMarkPlaying => 'Playing';

  @override
  String get gamePause => 'Pause';

  @override
  String get gameComplete => 'Complete';

  @override
  String get gameDrop => 'Drop';

  @override
  String get gameMoveToBacklog => 'Backlog';

  @override
  String get gameNewPlaythrough => 'New playthrough';

  @override
  String get gameNoPlaythroughs => 'No playthroughs recorded';

  @override
  String get gameNoPlaythroughsMessage =>
      'Played or completed playthroughs will appear here.';

  @override
  String get gamePlaythroughActions => 'Playthrough actions';

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
  String get gameDeletePlaythroughTitle => 'Delete playthrough';

  @override
  String get gameDeletePlaythroughMessage =>
      'The playthrough will be hidden from history.';

  @override
  String get gameMarkCompletedTitle => 'Mark as completed';

  @override
  String get gameNote => 'Note';

  @override
  String get gameRegisterPlaythrough => 'Register playthrough';

  @override
  String get gameEditPlaythrough => 'Edit playthrough';

  @override
  String get gameStartDate => 'Start date';

  @override
  String get gameNotes => 'Notes';

  @override
  String gamePlaythroughStart(Object date) {
    return 'Start $date';
  }

  @override
  String gamePlaythroughEnd(Object date) {
    return 'End $date';
  }

  @override
  String get metadataDialogTitle => 'Search metadata';

  @override
  String get metadataTitleField => 'Title';

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
  String metadataCoverSaveFailed(Object error) {
    return 'Metadata was applied, but the cover could not be saved. $error';
  }

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
  String get backupTitle => 'Data and backups';

  @override
  String get backupLocalPortability => 'Local portability';

  @override
  String get backupLocalPortabilityMessage =>
      '.vaultbackup is not encrypted and may include personal notes, games, statuses, and local media. .vaultbackup.enc encrypts the complete backup with a password the app does not store.';

  @override
  String get backupProcessingTitle => 'Processing file';

  @override
  String get backupProcessingMessage =>
      'Wait while Backlog Vault prepares or validates the selected content.';

  @override
  String get backupLastOperation => 'Last operation';

  @override
  String get backupRestoreLogicTitle => 'Restore and logical replacement';

  @override
  String get backupRestoreLogicMessage =>
      'Before restoring, the app creates an automatic backup. Restore inserts or updates file content and soft-deletes current records left outside it.';

  @override
  String get backupRestore => 'Restore backup';

  @override
  String get backupRestoreEncrypted => 'Restore encrypted backup';

  @override
  String get backupCreated => 'Complete backup created.';

  @override
  String get backupEncryptedCreated => 'Encrypted backup created.';

  @override
  String get backupJsonCreated => 'JSON export created.';

  @override
  String get backupCsvCreated => 'CSV export created.';

  @override
  String get backupRestoredWithSafety =>
      'Backup restored. An automatic safety backup was created.';

  @override
  String get backupRestored => 'Backup restored.';

  @override
  String get backupEncryptedRestoredWithSafety =>
      'Encrypted backup restored. An automatic encrypted safety backup was created.';

  @override
  String get backupEncryptedRestored => 'Encrypted backup restored.';

  @override
  String get backupConfirmRestore => 'Confirm restore';

  @override
  String backupDate(Object date) {
    return 'Date: $date';
  }

  @override
  String backupGames(Object count) {
    return 'Games: $count';
  }

  @override
  String backupPlaythroughs(Object count) {
    return 'Playthroughs: $count';
  }

  @override
  String backupMediaFiles(Object count) {
    return 'Media: $count files';
  }

  @override
  String backupSchema(Object version) {
    return 'Schema: $version';
  }

  @override
  String backupWarnings(Object count) {
    return 'Warnings: $count';
  }

  @override
  String get backupTypeRestore => 'Type RESTORE to continue.';

  @override
  String get backupRestoreKeyword => 'RESTORE';

  @override
  String get backupOperationFailed => 'The operation could not be completed.';

  @override
  String get backupCreateEncrypted => 'Create encrypted backup';

  @override
  String get backupOpenEncrypted => 'Open encrypted backup';

  @override
  String get backupPasswordWarning =>
      'The password is not stored. If you lose it, the encrypted backup cannot be recovered.';

  @override
  String get backupPassword => 'Password';

  @override
  String get backupRepeatPassword => 'Repeat password';

  @override
  String get backupEnterPassword => 'Enter a password.';

  @override
  String get backupPasswordsMismatch => 'Passwords do not match.';

  @override
  String get openAction => 'Open';

  @override
  String get backupCompleteTitle => 'Complete backup';

  @override
  String get backupCompleteDescription =>
      'Creates a .vaultbackup with games, playthroughs, applied metadata, and unencrypted local media.';

  @override
  String get backupCreate => 'Create backup';

  @override
  String get backupEncryptedTitle => 'Encrypted backup';

  @override
  String get backupEncryptedDescription =>
      'Creates a password-protected .vaultbackup.enc. The password is not stored.';

  @override
  String get backupExportJson => 'Export JSON';

  @override
  String get backupExportJsonDescription =>
      'Exports the library in a readable format useful for review or local scripting.';

  @override
  String get backupExportCsv => 'Export CSV';

  @override
  String get backupExportCsvDescription =>
      'Creates a compact tabular export for spreadsheets or manual exchange.';

  @override
  String get backupRestoreDescription =>
      'Opens a .vaultbackup, shows a preview, and requires strong confirmation before applying changes.';

  @override
  String get backupRestoreEncryptedDescription =>
      'Opens a .vaultbackup.enc, asks for its password, and validates the content before replacing data.';

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
  String csvPlaythroughsCreated(Object count) {
    return 'Playthroughs $count';
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
  String bulkPreviewFailed(Object error) {
    return 'The preview could not be generated. $error';
  }

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
  String get syncSectionTitle => 'Manual synchronization';

  @override
  String get syncSectionDescription =>
      'Encrypted device-to-device change exchange without accounts, cloud, or a network connection.';

  @override
  String get syncFoundationReady => 'Technical foundation ready';

  @override
  String get syncManualAvailable =>
      'Encrypted manual sync packages are available.';

  @override
  String get syncNotReady => 'Sync foundation is not ready on this device.';

  @override
  String get syncLocalDevice => 'Local device';

  @override
  String get syncExportPackage => 'Export sync package';

  @override
  String get syncImportPackage => 'Import sync package';

  @override
  String get syncEncryptedNotice =>
      'This package is encrypted with a password.';

  @override
  String get syncConflictNotice =>
      'Conflicting changes will not be applied automatically.';

  @override
  String get syncMediaNotice =>
      'Cover file synchronization will arrive in a later stage.';

  @override
  String get syncPackageVsBackup =>
      '.vaultsync carries encrypted changes; it is not a complete backup. Use .vaultbackup.enc for full migration or recovery.';

  @override
  String get syncPasswordExportTitle => 'Encrypt sync package';

  @override
  String get syncPasswordImportTitle => 'Open sync package';

  @override
  String get syncPassword => 'Password';

  @override
  String get syncRepeatPassword => 'Repeat password';

  @override
  String get syncPasswordRequired => 'Enter a password.';

  @override
  String get syncPasswordMismatch => 'Passwords do not match.';

  @override
  String get syncPasswordForgotten =>
      'The password is not stored. If you lose it, this package cannot be recovered.';

  @override
  String get syncSaveDialogTitle => 'Save encrypted sync package';

  @override
  String syncExportCreated(Object count) {
    return 'Encrypted sync package created with $count changes.';
  }

  @override
  String get syncPreviewTitle => 'Sync package preview';

  @override
  String syncFromDevice(Object name) {
    return 'From: $name';
  }

  @override
  String syncPackageDate(Object date) {
    return 'Created: $date';
  }

  @override
  String syncPreviewChanges(Object count) {
    return 'Changes: $count';
  }

  @override
  String syncPreviewAlreadyApplied(Object count) {
    return 'Already applied: $count';
  }

  @override
  String syncPreviewApplicable(Object count) {
    return 'Safe to apply: $count';
  }

  @override
  String syncPreviewConflicts(Object count) {
    return 'Conflicts skipped: $count';
  }

  @override
  String syncPreviewUnsupported(Object count) {
    return 'Unsupported: $count';
  }

  @override
  String syncPreviewInvalid(Object count) {
    return 'Invalid: $count';
  }

  @override
  String syncPreviewPendingMedia(Object count) {
    return 'Pending cover files: $count';
  }

  @override
  String get syncApplySafeChanges => 'Apply safe changes';

  @override
  String syncAppliedCount(Object count) {
    return 'Applied $count safe changes.';
  }

  @override
  String get syncNoSafeChanges => 'There are no new safe changes to apply.';

  @override
  String get syncImportResultTitle => 'Manual sync result';

  @override
  String get syncOperationFailed =>
      'The sync package operation could not be completed. Check the password and file.';

  @override
  String get syncPairingTitle => 'Device pairing';

  @override
  String get syncPairingDescription =>
      'Pairing lets you use sync packages without typing a password every time. Local network sync will come in a later stage.';

  @override
  String get syncNoGroup => 'No sync group configured';

  @override
  String get syncGroupConfigured => 'Sync group configured';

  @override
  String syncGroupName(Object name) {
    return 'Group: $name';
  }

  @override
  String syncPairedDevices(Object count) {
    return 'Known paired devices: $count';
  }

  @override
  String get syncGroupKeyAvailable =>
      'The group key is protected by this device\'s secure storage.';

  @override
  String get syncGroupKeyMissing =>
      'The group key is missing on this device. Pair it again before using group packages.';

  @override
  String get syncCreateGroup => 'Create sync group';

  @override
  String get syncCreateGroupTitle => 'Create sync group';

  @override
  String get syncGroupNameLabel => 'Group name';

  @override
  String get syncGroupNameRequired => 'Enter a group name.';

  @override
  String get syncExportInvitation => 'Export pairing invitation';

  @override
  String get syncImportInvitation => 'Import pairing invitation';

  @override
  String get syncInvitationNotice =>
      'The .vaultpair invitation contains the group key inside a password-encrypted payload. Share the file and its temporary password through separate trusted channels.';

  @override
  String get syncPairingPasswordTitle => 'Protect pairing invitation';

  @override
  String get syncPairingPasswordOpenTitle => 'Open pairing invitation';

  @override
  String get syncPairingSaveDialogTitle => 'Save encrypted pairing invitation';

  @override
  String get syncInvitationCreated =>
      'Encrypted pairing invitation created. It expires after 24 hours.';

  @override
  String get syncInvitationImported => 'This device joined the sync group.';

  @override
  String get syncInvitationExpired => 'This pairing invitation has expired.';

  @override
  String get syncPairingExistingGroup =>
      'This device already belongs to another sync group. Leave it before importing a different invitation.';

  @override
  String get syncGroupPackageMismatch =>
      'This sync package belongs to another sync group.';

  @override
  String get syncGroupKeyMismatch =>
      'This sync package uses another group key. Pair this device again.';

  @override
  String get syncLeaveGroup => 'Leave sync group';

  @override
  String get syncLeaveGroupTitle => 'Leave sync group?';

  @override
  String get syncLeaveGroupWarning =>
      'The group key will be removed from secure storage. Your library and change history will not be deleted.';

  @override
  String get syncLeaveGroupDone => 'This device left the sync group.';

  @override
  String get syncGroupPackagesTitle => 'Paired group packages';

  @override
  String get syncExportGroupPackage => 'Export with group key';

  @override
  String get syncImportGroupPackage => 'Import from paired group';

  @override
  String syncGroupPackageCreated(Object count) {
    return 'Group-encrypted sync package created with $count changes.';
  }

  @override
  String get syncPairingOperationFailed =>
      'The pairing operation could not be completed. Check the invitation and temporary password.';

  @override
  String get syncNoAutomaticSync =>
      'Pairing does not synchronize automatically and does not enable LAN sync yet.';
}
