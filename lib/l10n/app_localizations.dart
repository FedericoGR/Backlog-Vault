import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Backlog Vault'**
  String get appTitle;

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navigationLibrary;

  /// No description provided for @navigationStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navigationStatistics;

  /// No description provided for @navigationSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigationSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used on this device.'**
  String get languageDescription;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLocalStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Local status'**
  String get settingsLocalStatusTitle;

  /// No description provided for @settingsLocalStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backlog Vault remains offline-first: your library lives on this device and external integrations are optional.'**
  String get settingsLocalStatusSubtitle;

  /// No description provided for @settingsAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Account required'**
  String get settingsAccountRequired;

  /// No description provided for @settingsUsageMode.
  ///
  /// In en, this message translates to:
  /// **'Usage mode'**
  String get settingsUsageMode;

  /// No description provided for @settingsLocalDatabase.
  ///
  /// In en, this message translates to:
  /// **'Local database'**
  String get settingsLocalDatabase;

  /// No description provided for @settingsLoadingStatus.
  ///
  /// In en, this message translates to:
  /// **'Loading status'**
  String get settingsLoadingStatus;

  /// No description provided for @settingsLoadingConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Loading configuration…'**
  String get settingsLoadingConfiguration;

  /// No description provided for @settingsPrivacyProtection.
  ///
  /// In en, this message translates to:
  /// **'Privacy and protection'**
  String get settingsPrivacyProtection;

  /// No description provided for @settingsPrivacyProtectionMessage.
  ///
  /// In en, this message translates to:
  /// **'The local database and media files are not encrypted at rest yet. Encrypted backups are available for export and restore.'**
  String get settingsPrivacyProtectionMessage;

  /// No description provided for @settingsDataBackups.
  ///
  /// In en, this message translates to:
  /// **'Data and backups'**
  String get settingsDataBackups;

  /// No description provided for @settingsDataBackupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export JSON/CSV, create regular or encrypted backups, and restore local files.'**
  String get settingsDataBackupsSubtitle;

  /// No description provided for @settingsOpenBackups.
  ///
  /// In en, this message translates to:
  /// **'Open backups'**
  String get settingsOpenBackups;

  /// No description provided for @settingsGoodPractices.
  ///
  /// In en, this message translates to:
  /// **'Good practices'**
  String get settingsGoodPractices;

  /// No description provided for @settingsGoodPracticesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Never paste real keys into README files, issues, logs, tests, or commits. Credentials stay in local secure storage.'**
  String get settingsGoodPracticesSubtitle;

  /// No description provided for @settingsRawgSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional source for game metadata. The key is stored locally in the system secure storage.'**
  String get settingsRawgSubtitle;

  /// No description provided for @settingsIgdbSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Client credentials used to query IGDB. The access token is renewed locally and the secret is never displayed.'**
  String get settingsIgdbSubtitle;

  /// No description provided for @settingsSteamGridDbSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional key for cover search. Backlog Vault still asks for explicit confirmation before saving covers.'**
  String get settingsSteamGridDbSubtitle;

  /// No description provided for @settingsNewApiKey.
  ///
  /// In en, this message translates to:
  /// **'New API key'**
  String get settingsNewApiKey;

  /// No description provided for @settingsApiKeyHelper.
  ///
  /// In en, this message translates to:
  /// **'It is excluded from backups, never shown in plain text, and must not end up in commits.'**
  String get settingsApiKeyHelper;

  /// No description provided for @settingsClientIdHelper.
  ///
  /// In en, this message translates to:
  /// **'Stored only on this device and excluded from backups.'**
  String get settingsClientIdHelper;

  /// No description provided for @settingsClientSecretHelper.
  ///
  /// In en, this message translates to:
  /// **'Never paste it into logs, README files, tests, or issues.'**
  String get settingsClientSecretHelper;

  /// No description provided for @settingsMediaApiKeyHelper.
  ///
  /// In en, this message translates to:
  /// **'Used only for media search and kept on this device.'**
  String get settingsMediaApiKeyHelper;

  /// No description provided for @settingsExternalKeysDeletion.
  ///
  /// In en, this message translates to:
  /// **'External key removal'**
  String get settingsExternalKeysDeletion;

  /// No description provided for @settingsExternalKeysDeletionMessage.
  ///
  /// In en, this message translates to:
  /// **'Only locally stored credentials are removed. Games, applied metadata, external IDs, and saved covers are not changed.'**
  String get settingsExternalKeysDeletionMessage;

  /// No description provided for @settingsDeleteAllKeys.
  ///
  /// In en, this message translates to:
  /// **'Delete all keys'**
  String get settingsDeleteAllKeys;

  /// No description provided for @settingsEnterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter an API key before saving.'**
  String get settingsEnterApiKey;

  /// No description provided for @settingsRawgSaved.
  ///
  /// In en, this message translates to:
  /// **'RAWG API key saved locally.'**
  String get settingsRawgSaved;

  /// No description provided for @settingsRawgDeleted.
  ///
  /// In en, this message translates to:
  /// **'RAWG API key deleted.'**
  String get settingsRawgDeleted;

  /// No description provided for @settingsEnterIgdbCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter a Client ID and Client Secret before saving.'**
  String get settingsEnterIgdbCredentials;

  /// No description provided for @settingsIgdbSaved.
  ///
  /// In en, this message translates to:
  /// **'IGDB credentials saved locally.'**
  String get settingsIgdbSaved;

  /// No description provided for @settingsIgdbDeleted.
  ///
  /// In en, this message translates to:
  /// **'IGDB credentials deleted.'**
  String get settingsIgdbDeleted;

  /// No description provided for @settingsSteamGridDbSaved.
  ///
  /// In en, this message translates to:
  /// **'SteamGridDB API key saved locally.'**
  String get settingsSteamGridDbSaved;

  /// No description provided for @settingsSteamGridDbDeleted.
  ///
  /// In en, this message translates to:
  /// **'SteamGridDB API key deleted.'**
  String get settingsSteamGridDbDeleted;

  /// No description provided for @settingsDeleteExternalKeysTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete external keys'**
  String get settingsDeleteExternalKeysTitle;

  /// No description provided for @settingsDeleteExternalKeysConfirmation.
  ///
  /// In en, this message translates to:
  /// **'The RAWG, IGDB, and SteamGridDB keys stored on this device will be deleted. Your games, applied metadata, external IDs, and covers will not be changed.'**
  String get settingsDeleteExternalKeysConfirmation;

  /// No description provided for @settingsDeleteKeys.
  ///
  /// In en, this message translates to:
  /// **'Delete keys'**
  String get settingsDeleteKeys;

  /// No description provided for @settingsExternalKeysDeleted.
  ///
  /// In en, this message translates to:
  /// **'External keys deleted.'**
  String get settingsExternalKeysDeleted;

  /// No description provided for @settingsConfigured.
  ///
  /// In en, this message translates to:
  /// **'Configured'**
  String get settingsConfigured;

  /// No description provided for @settingsNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get settingsNotConfigured;

  /// No description provided for @settingsConfigurationPresent.
  ///
  /// In en, this message translates to:
  /// **'Configuration present'**
  String get settingsConfigurationPresent;

  /// No description provided for @settingsConfigurationPending.
  ///
  /// In en, this message translates to:
  /// **'Configuration pending'**
  String get settingsConfigurationPending;

  /// No description provided for @settingsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get settingsPending;

  /// No description provided for @statusWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get statusWishlist;

  /// No description provided for @statusBacklog.
  ///
  /// In en, this message translates to:
  /// **'Backlog'**
  String get statusBacklog;

  /// No description provided for @statusPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get statusPlaying;

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get statusPaused;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get statusDropped;

  /// No description provided for @statusRetired.
  ///
  /// In en, this message translates to:
  /// **'Retired'**
  String get statusRetired;

  /// No description provided for @playthroughPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get playthroughPlanned;

  /// No description provided for @playthroughActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get playthroughActive;

  /// No description provided for @playthroughPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get playthroughPaused;

  /// No description provided for @playthroughCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get playthroughCompleted;

  /// No description provided for @playthroughDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get playthroughDropped;

  /// No description provided for @gameTypeUndefined.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get gameTypeUndefined;

  /// No description provided for @gameTypeSinglePlayer.
  ///
  /// In en, this message translates to:
  /// **'Single-player'**
  String get gameTypeSinglePlayer;

  /// No description provided for @gameTypeMultiplayer.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer'**
  String get gameTypeMultiplayer;

  /// No description provided for @gameTypeCooperative.
  ///
  /// In en, this message translates to:
  /// **'Co-op'**
  String get gameTypeCooperative;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @backlog.
  ///
  /// In en, this message translates to:
  /// **'Backlog'**
  String get backlog;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playing;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @missingCover.
  ///
  /// In en, this message translates to:
  /// **'Missing cover'**
  String get missingCover;

  /// No description provided for @missingMetadata.
  ///
  /// In en, this message translates to:
  /// **'Missing metadata'**
  String get missingMetadata;

  /// No description provided for @missingRating.
  ///
  /// In en, this message translates to:
  /// **'Missing rating'**
  String get missingRating;

  /// No description provided for @missingPlatform.
  ///
  /// In en, this message translates to:
  /// **'Missing platform'**
  String get missingPlatform;

  /// No description provided for @missingGenre.
  ///
  /// In en, this message translates to:
  /// **'Missing genre'**
  String get missingGenre;

  /// No description provided for @homeNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing now'**
  String get homeNowPlaying;

  /// No description provided for @homeNowPlayingDescription.
  ///
  /// In en, this message translates to:
  /// **'The most active games in your personal library.'**
  String get homeNowPlayingDescription;

  /// No description provided for @homeNowPlayingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No games are currently in progress.'**
  String get homeNowPlayingEmpty;

  /// No description provided for @homeBacklogDescription.
  ///
  /// In en, this message translates to:
  /// **'Pending games ready for another look.'**
  String get homeBacklogDescription;

  /// No description provided for @homeBacklogEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no pending backlog games.'**
  String get homeBacklogEmpty;

  /// No description provided for @homeRecentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Recently completed'**
  String get homeRecentCompleted;

  /// No description provided for @homeRecentCompletedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your latest games with a recorded completion date.'**
  String get homeRecentCompletedDescription;

  /// No description provided for @homeRecentCompletedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed games have a recorded date.'**
  String get homeRecentCompletedEmpty;

  /// No description provided for @homeMissingCoverDescription.
  ///
  /// In en, this message translates to:
  /// **'Entries that still need a visual selection.'**
  String get homeMissingCoverDescription;

  /// No description provided for @homeMissingCoverEmpty.
  ///
  /// In en, this message translates to:
  /// **'Every visible game has a cover.'**
  String get homeMissingCoverEmpty;

  /// No description provided for @homeMissingMetadataDescription.
  ///
  /// In en, this message translates to:
  /// **'Games worth enriching before organizing further.'**
  String get homeMissingMetadataDescription;

  /// No description provided for @homeMissingMetadataEmpty.
  ///
  /// In en, this message translates to:
  /// **'Every visible game has external metadata.'**
  String get homeMissingMetadataEmpty;

  /// No description provided for @homeRecentlyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get homeRecentlyUpdated;

  /// No description provided for @homeRecentlyUpdatedDescription.
  ///
  /// In en, this message translates to:
  /// **'Recent changes to statuses, notes, and playthroughs.'**
  String get homeRecentlyUpdatedDescription;

  /// No description provided for @homeRecentlyUpdatedEmpty.
  ///
  /// In en, this message translates to:
  /// **'There is no recent activity.'**
  String get homeRecentlyUpdatedEmpty;

  /// No description provided for @homeLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading home'**
  String get homeLoading;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Home could not be loaded'**
  String get homeLoadError;

  /// No description provided for @homeLibrarySummary.
  ///
  /// In en, this message translates to:
  /// **'{total} active games, {completedCount} completed, and {playingCount} in progress.'**
  String homeLibrarySummary(
    Object completedCount,
    Object playingCount,
    Object total,
  );

  /// No description provided for @homeOpenLibrary.
  ///
  /// In en, this message translates to:
  /// **'Open library'**
  String get homeOpenLibrary;

  /// No description provided for @homeQuickPanel.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickPanel;

  /// No description provided for @homeQuickPanelDescription.
  ///
  /// In en, this message translates to:
  /// **'Jump to statistics or review games still missing covers or metadata.'**
  String get homeQuickPanelDescription;

  /// No description provided for @homeViewStatistics.
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get homeViewStatistics;

  /// No description provided for @homeCreateGame.
  ///
  /// In en, this message translates to:
  /// **'Create game'**
  String get homeCreateGame;

  /// No description provided for @homeViewLibrary.
  ///
  /// In en, this message translates to:
  /// **'View library'**
  String get homeViewLibrary;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your library is still empty.'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Once you add your first games, this dashboard will show activity, pending games, and data quality.'**
  String get homeEmptyMessage;

  /// No description provided for @homeCreateFirstGame.
  ///
  /// In en, this message translates to:
  /// **'Create first game'**
  String get homeCreateFirstGame;

  /// No description provided for @statisticsLibraryLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading library'**
  String get statisticsLibraryLoading;

  /// No description provided for @statisticsProgressLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading progress'**
  String get statisticsProgressLoading;

  /// No description provided for @statisticsLoadProgressError.
  ///
  /// In en, this message translates to:
  /// **'Progress could not be loaded'**
  String get statisticsLoadProgressError;

  /// No description provided for @statisticsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Statistics could not be loaded'**
  String get statisticsLoadError;

  /// No description provided for @statisticsLibraryByStatus.
  ///
  /// In en, this message translates to:
  /// **'Library by status'**
  String get statisticsLibraryByStatus;

  /// No description provided for @statisticsLibraryByStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick distribution of your current backlog.'**
  String get statisticsLibraryByStatusSubtitle;

  /// No description provided for @statisticsRatings.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get statisticsRatings;

  /// No description provided for @statisticsRatingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How your personal scores are distributed across rated games.'**
  String get statisticsRatingsSubtitle;

  /// No description provided for @statisticsDataQuality.
  ///
  /// In en, this message translates to:
  /// **'Data quality'**
  String get statisticsDataQuality;

  /// No description provided for @statisticsDataQualitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Metadata gaps that are still worth reviewing.'**
  String get statisticsDataQualitySubtitle;

  /// No description provided for @statisticsAnnualProgress.
  ///
  /// In en, this message translates to:
  /// **'Annual progress'**
  String get statisticsAnnualProgress;

  /// No description provided for @statisticsAnnualProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Completed playthroughs with dates and logged hours by period.'**
  String get statisticsAnnualProgressSubtitle;

  /// No description provided for @statisticsTopPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Most-used platforms'**
  String get statisticsTopPlatforms;

  /// No description provided for @statisticsTopPlatformsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where most of your play activity is concentrated.'**
  String get statisticsTopPlatformsSubtitle;

  /// No description provided for @statisticsNoPlatforms.
  ///
  /// In en, this message translates to:
  /// **'No platforms have been recorded.'**
  String get statisticsNoPlatforms;

  /// No description provided for @statisticsTopGenres.
  ///
  /// In en, this message translates to:
  /// **'Most-used genres'**
  String get statisticsTopGenres;

  /// No description provided for @statisticsTopGenresSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The styles that dominate your personal library.'**
  String get statisticsTopGenresSubtitle;

  /// No description provided for @statisticsNoGenres.
  ///
  /// In en, this message translates to:
  /// **'No genres have been recorded.'**
  String get statisticsNoGenres;

  /// No description provided for @statisticsRecentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Recently completed'**
  String get statisticsRecentCompleted;

  /// No description provided for @statisticsRecentCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your latest completions with a recorded date.'**
  String get statisticsRecentCompletedSubtitle;

  /// No description provided for @statisticsPulse.
  ///
  /// In en, this message translates to:
  /// **'Library pulse'**
  String get statisticsPulse;

  /// No description provided for @statisticsPulseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick look at backlog, progress, and data quality from the same catalog.'**
  String get statisticsPulseSubtitle;

  /// No description provided for @statisticsCompletedHours.
  ///
  /// In en, this message translates to:
  /// **'{completedCount} completed · {hours} hours'**
  String statisticsCompletedHours(Object completedCount, Object hours);

  /// No description provided for @statisticsTotalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Total completed'**
  String get statisticsTotalCompleted;

  /// No description provided for @statisticsLoggedHours.
  ///
  /// In en, this message translates to:
  /// **'Logged hours'**
  String get statisticsLoggedHours;

  /// No description provided for @statisticsAverageRating.
  ///
  /// In en, this message translates to:
  /// **'Average rating'**
  String get statisticsAverageRating;

  /// No description provided for @statisticsYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get statisticsYear;

  /// No description provided for @statisticsNoAnnualProgress.
  ///
  /// In en, this message translates to:
  /// **'No annual progress yet'**
  String get statisticsNoAnnualProgress;

  /// No description provided for @statisticsNoAnnualProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'Once you complete dated playthroughs, this panel will summarize them by year and month.'**
  String get statisticsNoAnnualProgressMessage;

  /// No description provided for @statisticsMonthsOf.
  ///
  /// In en, this message translates to:
  /// **'Months of {year}'**
  String statisticsMonthsOf(Object year);

  /// No description provided for @statisticsNoRatings.
  ///
  /// In en, this message translates to:
  /// **'No ratings yet'**
  String get statisticsNoRatings;

  /// No description provided for @statisticsNoRatingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Once you start rating games, this section will show how your scores are distributed.'**
  String get statisticsNoRatingsMessage;

  /// No description provided for @statisticsStars.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star} other{{count} stars}}'**
  String statisticsStars(num count);

  /// No description provided for @statisticsUnrated.
  ///
  /// In en, this message translates to:
  /// **'Unrated: {count}'**
  String statisticsUnrated(Object count);

  /// No description provided for @statisticsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get statisticsNoData;

  /// No description provided for @statisticsCompletedWithoutDate.
  ///
  /// In en, this message translates to:
  /// **'Completed without date'**
  String get statisticsCompletedWithoutDate;

  /// No description provided for @statisticsNoCompleted.
  ///
  /// In en, this message translates to:
  /// **'No completed games yet'**
  String get statisticsNoCompleted;

  /// No description provided for @statisticsNoCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Record a completion date in your playthroughs to see them here.'**
  String get statisticsNoCompletedMessage;

  /// No description provided for @statisticsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'There is not enough data to calculate statistics yet.'**
  String get statisticsEmptyTitle;

  /// No description provided for @statisticsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Once you add games and playthroughs, this dashboard will summarize progress, ratings, and metadata quality.'**
  String get statisticsEmptyMessage;

  /// No description provided for @statisticsGoToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Go to library'**
  String get statisticsGoToLibrary;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'{value} h'**
  String hoursShort(Object value);

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @columns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get columns;

  /// No description provided for @saveView.
  ///
  /// In en, this message translates to:
  /// **'Save view'**
  String get saveView;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// No description provided for @importMetadata.
  ///
  /// In en, this message translates to:
  /// **'Import metadata'**
  String get importMetadata;

  /// No description provided for @libraryExitSelection.
  ///
  /// In en, this message translates to:
  /// **'Exit selection'**
  String get libraryExitSelection;

  /// No description provided for @librarySelectMultiple.
  ///
  /// In en, this message translates to:
  /// **'Select multiple'**
  String get librarySelectMultiple;

  /// No description provided for @libraryLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading library'**
  String get libraryLoading;

  /// No description provided for @libraryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Library could not be loaded'**
  String get libraryLoadError;

  /// No description provided for @libraryDeleteSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete selected games'**
  String get libraryDeleteSelectedTitle;

  /// No description provided for @libraryDeleteSelectedMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} games will be marked as deleted. They will not be physically removed.'**
  String libraryDeleteSelectedMessage(Object count);

  /// No description provided for @libraryTypeDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm.'**
  String get libraryTypeDeleteConfirmation;

  /// No description provided for @libraryDeleteKeyword.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get libraryDeleteKeyword;

  /// No description provided for @libraryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get libraryConfirmation;

  /// No description provided for @libraryDeleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get libraryDeleteSelected;

  /// No description provided for @libraryFiltersCount.
  ///
  /// In en, this message translates to:
  /// **'Filters ({count})'**
  String libraryFiltersCount(Object count);

  /// No description provided for @libraryActions.
  ///
  /// In en, this message translates to:
  /// **'Library actions'**
  String get libraryActions;

  /// No description provided for @libraryUpdateView.
  ///
  /// In en, this message translates to:
  /// **'Update view'**
  String get libraryUpdateView;

  /// No description provided for @libraryRenameView.
  ///
  /// In en, this message translates to:
  /// **'Rename view'**
  String get libraryRenameView;

  /// No description provided for @libraryDeleteView.
  ///
  /// In en, this message translates to:
  /// **'Delete view'**
  String get libraryDeleteView;

  /// No description provided for @libraryYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get libraryYear;

  /// No description provided for @libraryFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {value}'**
  String libraryFilterStatus(Object value);

  /// No description provided for @libraryFilterPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform: {value}'**
  String libraryFilterPlatform(Object value);

  /// No description provided for @libraryFilterGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre: {value}'**
  String libraryFilterGenre(Object value);

  /// No description provided for @libraryFilterSearch.
  ///
  /// In en, this message translates to:
  /// **'Search: {value}'**
  String libraryFilterSearch(Object value);

  /// No description provided for @libraryMissingCompletedDate.
  ///
  /// In en, this message translates to:
  /// **'Missing completion date'**
  String get libraryMissingCompletedDate;

  /// No description provided for @libraryOpenDetails.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get libraryOpenDetails;

  /// No description provided for @libraryActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get libraryActionsTooltip;

  /// No description provided for @libraryAdvancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters'**
  String get libraryAdvancedFilters;

  /// No description provided for @libraryClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get libraryClearFilters;

  /// No description provided for @libraryStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get libraryStatus;

  /// No description provided for @libraryPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Platforms'**
  String get libraryPlatforms;

  /// No description provided for @libraryGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get libraryGenres;

  /// No description provided for @libraryMinimumRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum rating'**
  String get libraryMinimumRating;

  /// No description provided for @libraryMaximumRating.
  ///
  /// In en, this message translates to:
  /// **'Maximum rating'**
  String get libraryMaximumRating;

  /// No description provided for @libraryMinimumHours.
  ///
  /// In en, this message translates to:
  /// **'Minimum hours'**
  String get libraryMinimumHours;

  /// No description provided for @libraryMaximumHours.
  ///
  /// In en, this message translates to:
  /// **'Maximum hours'**
  String get libraryMaximumHours;

  /// No description provided for @libraryType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get libraryType;

  /// No description provided for @libraryReleaseFrom.
  ///
  /// In en, this message translates to:
  /// **'Released from'**
  String get libraryReleaseFrom;

  /// No description provided for @libraryReleaseTo.
  ///
  /// In en, this message translates to:
  /// **'Released through'**
  String get libraryReleaseTo;

  /// No description provided for @libraryCompletedFrom.
  ///
  /// In en, this message translates to:
  /// **'Completed from'**
  String get libraryCompletedFrom;

  /// No description provided for @libraryCompletedTo.
  ///
  /// In en, this message translates to:
  /// **'Completed through'**
  String get libraryCompletedTo;

  /// No description provided for @libraryWithRating.
  ///
  /// In en, this message translates to:
  /// **'With rating'**
  String get libraryWithRating;

  /// No description provided for @libraryWithPlatform.
  ///
  /// In en, this message translates to:
  /// **'With platform'**
  String get libraryWithPlatform;

  /// No description provided for @libraryWithGenre.
  ///
  /// In en, this message translates to:
  /// **'With genre'**
  String get libraryWithGenre;

  /// No description provided for @libraryWithCompletedDate.
  ///
  /// In en, this message translates to:
  /// **'With completion date'**
  String get libraryWithCompletedDate;

  /// No description provided for @libraryNoOptions.
  ///
  /// In en, this message translates to:
  /// **'No options available.'**
  String get libraryNoOptions;

  /// No description provided for @libraryClearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get libraryClearDate;

  /// No description provided for @libraryChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get libraryChooseDate;

  /// No description provided for @libraryVisibleColumns.
  ///
  /// In en, this message translates to:
  /// **'Visible columns'**
  String get libraryVisibleColumns;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'There are no games in your library yet.'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Once you add the first one, the catalog will start taking shape.'**
  String get libraryEmptyMessage;

  /// No description provided for @libraryEmptyFilteredTitle.
  ///
  /// In en, this message translates to:
  /// **'No games match the current view.'**
  String get libraryEmptyFilteredTitle;

  /// No description provided for @libraryEmptyFilteredMessage.
  ///
  /// In en, this message translates to:
  /// **'Try relaxing filters, changing the saved view, or clearing the search.'**
  String get libraryEmptyFilteredMessage;

  /// No description provided for @libraryViewUpdated.
  ///
  /// In en, this message translates to:
  /// **'View updated.'**
  String get libraryViewUpdated;

  /// No description provided for @libraryDeleteViewMessage.
  ///
  /// In en, this message translates to:
  /// **'The view “{name}” will be deleted.'**
  String libraryDeleteViewMessage(Object name);

  /// No description provided for @libraryDeleteGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete game'**
  String get libraryDeleteGameTitle;

  /// No description provided for @libraryDeleteGameMessage.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be hidden from the library.'**
  String libraryDeleteGameMessage(Object title);

  /// No description provided for @libraryNoLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get libraryNoLimit;

  /// No description provided for @libraryDefaultAll.
  ///
  /// In en, this message translates to:
  /// **'All games'**
  String get libraryDefaultAll;

  /// No description provided for @libraryDefaultPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get libraryDefaultPending;

  /// No description provided for @libraryDefaultCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get libraryDefaultCompleted;

  /// No description provided for @libraryDefaultByYear.
  ///
  /// In en, this message translates to:
  /// **'Filter by year'**
  String get libraryDefaultByYear;

  /// No description provided for @librarySelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String librarySelectedCount(Object count);

  /// No description provided for @librarySelectVisible.
  ///
  /// In en, this message translates to:
  /// **'Select visible ({count})'**
  String librarySelectVisible(Object count);

  /// No description provided for @librarySelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all ({count})'**
  String librarySelectAll(Object count);

  /// No description provided for @libraryClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get libraryClearSelection;

  /// No description provided for @libraryAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get libraryAverage;

  /// No description provided for @libraryHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get libraryHours;

  /// No description provided for @libraryNoOptionsShort.
  ///
  /// In en, this message translates to:
  /// **'No options'**
  String get libraryNoOptionsShort;

  /// No description provided for @columnCover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get columnCover;

  /// No description provided for @columnTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get columnTitle;

  /// No description provided for @columnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get columnStatus;

  /// No description provided for @columnPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Platforms'**
  String get columnPlatforms;

  /// No description provided for @columnGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get columnGenres;

  /// No description provided for @columnRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get columnRating;

  /// No description provided for @columnReleaseDate.
  ///
  /// In en, this message translates to:
  /// **'Release date'**
  String get columnReleaseDate;

  /// No description provided for @columnCompletedDate.
  ///
  /// In en, this message translates to:
  /// **'Completion date'**
  String get columnCompletedDate;

  /// No description provided for @columnHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get columnHours;

  /// No description provided for @columnType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get columnType;

  /// No description provided for @columnNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get columnNotes;

  /// No description provided for @columnUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get columnUpdatedAt;

  /// No description provided for @columnPlaythroughs.
  ///
  /// In en, this message translates to:
  /// **'Playthroughs'**
  String get columnPlaythroughs;

  /// No description provided for @gameCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create game'**
  String get gameCreateTitle;

  /// No description provided for @gameEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit game'**
  String get gameEditTitle;

  /// No description provided for @gameIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get gameIdentity;

  /// No description provided for @gameIdentitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Game information and external metadata.'**
  String get gameIdentitySubtitle;

  /// No description provided for @gameName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get gameName;

  /// No description provided for @gameNameRequired.
  ///
  /// In en, this message translates to:
  /// **'The name is required.'**
  String get gameNameRequired;

  /// No description provided for @gameReleaseDate.
  ///
  /// In en, this message translates to:
  /// **'Release date'**
  String get gameReleaseDate;

  /// No description provided for @gamePersonalLibrary.
  ///
  /// In en, this message translates to:
  /// **'Personal library'**
  String get gamePersonalLibrary;

  /// No description provided for @gamePersonalLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Status, rating, and private notes.'**
  String get gamePersonalLibrarySubtitle;

  /// No description provided for @gamePersonalRating.
  ///
  /// In en, this message translates to:
  /// **'Personal rating'**
  String get gamePersonalRating;

  /// No description provided for @gamePersonalNotes.
  ///
  /// In en, this message translates to:
  /// **'Personal notes'**
  String get gamePersonalNotes;

  /// No description provided for @gameCatalogs.
  ///
  /// In en, this message translates to:
  /// **'Catalogs'**
  String get gameCatalogs;

  /// No description provided for @gameCatalogsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Associated platforms and genres.'**
  String get gameCatalogsSubtitle;

  /// No description provided for @gameAddPlatform.
  ///
  /// In en, this message translates to:
  /// **'Add platform'**
  String get gameAddPlatform;

  /// No description provided for @gameAddGenre.
  ///
  /// In en, this message translates to:
  /// **'Add genre'**
  String get gameAddGenre;

  /// No description provided for @gameCompletionSection.
  ///
  /// In en, this message translates to:
  /// **'Completion / playthrough'**
  String get gameCompletionSection;

  /// No description provided for @gameCompletionSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Initial details when marking the game as completed.'**
  String get gameCompletionSectionSubtitle;

  /// No description provided for @gameImportMetadata.
  ///
  /// In en, this message translates to:
  /// **'Import metadata'**
  String get gameImportMetadata;

  /// No description provided for @gameSearchByTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by title'**
  String get gameSearchByTitle;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @gameNoCandidates.
  ///
  /// In en, this message translates to:
  /// **'No candidates yet'**
  String get gameNoCandidates;

  /// No description provided for @gameNoCandidatesMessage.
  ///
  /// In en, this message translates to:
  /// **'Search for a game to prefill fields from {provider}.'**
  String gameNoCandidatesMessage(Object provider);

  /// No description provided for @gameApplyToForm.
  ///
  /// In en, this message translates to:
  /// **'Apply to form'**
  String get gameApplyToForm;

  /// No description provided for @providerNoCandidates.
  ///
  /// In en, this message translates to:
  /// **'{provider} returned no candidates.'**
  String providerNoCandidates(Object provider);

  /// No description provided for @gameSaveIncludedCover.
  ///
  /// In en, this message translates to:
  /// **'Save included cover'**
  String get gameSaveIncludedCover;

  /// No description provided for @gameIncludedCoverReplace.
  ///
  /// In en, this message translates to:
  /// **'The current cover will be replaced when the game is saved.'**
  String get gameIncludedCoverReplace;

  /// No description provided for @gameIncludedCoverSave.
  ///
  /// In en, this message translates to:
  /// **'The cover will be stored locally after the game is saved.'**
  String get gameIncludedCoverSave;

  /// No description provided for @gameSearchMetadata.
  ///
  /// In en, this message translates to:
  /// **'Search metadata'**
  String get gameSearchMetadata;

  /// No description provided for @gamePendingCover.
  ///
  /// In en, this message translates to:
  /// **'Pending cover: {provider}'**
  String gamePendingCover(Object provider);

  /// No description provided for @ratingNone.
  ///
  /// In en, this message translates to:
  /// **'No rating'**
  String get ratingNone;

  /// No description provided for @ratingOneStar.
  ///
  /// In en, this message translates to:
  /// **'1 star'**
  String get ratingOneStar;

  /// No description provided for @ratingStars.
  ///
  /// In en, this message translates to:
  /// **'{count} stars'**
  String ratingStars(Object count);

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @gameCompletionDate.
  ///
  /// In en, this message translates to:
  /// **'Completion date'**
  String get gameCompletionDate;

  /// No description provided for @gameHoursPlayed.
  ///
  /// In en, this message translates to:
  /// **'Hours played'**
  String get gameHoursPlayed;

  /// No description provided for @gamePlaythroughRating.
  ///
  /// In en, this message translates to:
  /// **'Playthrough rating'**
  String get gamePlaythroughRating;

  /// No description provided for @gamePlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get gamePlatform;

  /// No description provided for @gameNoPlatform.
  ///
  /// In en, this message translates to:
  /// **'No platform'**
  String get gameNoPlatform;

  /// No description provided for @gameNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Game not found'**
  String get gameNotFoundTitle;

  /// No description provided for @gameNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The game could not be found.'**
  String get gameNotFoundMessage;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @coverSearch.
  ///
  /// In en, this message translates to:
  /// **'Search cover'**
  String get coverSearch;

  /// No description provided for @coverChange.
  ///
  /// In en, this message translates to:
  /// **'Change cover'**
  String get coverChange;

  /// No description provided for @metadataSearch.
  ///
  /// In en, this message translates to:
  /// **'Search metadata'**
  String get metadataSearch;

  /// No description provided for @gameDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete game'**
  String get gameDeleteTooltip;

  /// No description provided for @gameActions.
  ///
  /// In en, this message translates to:
  /// **'Game actions'**
  String get gameActions;

  /// No description provided for @gameRemoveCover.
  ///
  /// In en, this message translates to:
  /// **'Remove cover'**
  String get gameRemoveCover;

  /// No description provided for @gameSummaryProgress.
  ///
  /// In en, this message translates to:
  /// **'Summary and progress'**
  String get gameSummaryProgress;

  /// No description provided for @gameLastCompleted.
  ///
  /// In en, this message translates to:
  /// **'Last completed'**
  String get gameLastCompleted;

  /// No description provided for @gamePlaythroughs.
  ///
  /// In en, this message translates to:
  /// **'Playthroughs'**
  String get gamePlaythroughs;

  /// No description provided for @gameMarkPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get gameMarkPlaying;

  /// No description provided for @gamePause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get gamePause;

  /// No description provided for @gameComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get gameComplete;

  /// No description provided for @gameDrop.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get gameDrop;

  /// No description provided for @gameMoveToBacklog.
  ///
  /// In en, this message translates to:
  /// **'Backlog'**
  String get gameMoveToBacklog;

  /// No description provided for @gameNewPlaythrough.
  ///
  /// In en, this message translates to:
  /// **'New playthrough'**
  String get gameNewPlaythrough;

  /// No description provided for @gameNoPlaythroughs.
  ///
  /// In en, this message translates to:
  /// **'No playthroughs recorded'**
  String get gameNoPlaythroughs;

  /// No description provided for @gameNoPlaythroughsMessage.
  ///
  /// In en, this message translates to:
  /// **'Played or completed playthroughs will appear here.'**
  String get gameNoPlaythroughsMessage;

  /// No description provided for @gamePlaythroughActions.
  ///
  /// In en, this message translates to:
  /// **'Playthrough actions'**
  String get gamePlaythroughActions;

  /// No description provided for @metadataApplied.
  ///
  /// In en, this message translates to:
  /// **'Metadata applied.'**
  String get metadataApplied;

  /// No description provided for @coverUpdated.
  ///
  /// In en, this message translates to:
  /// **'Cover updated.'**
  String get coverUpdated;

  /// No description provided for @coverRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove cover'**
  String get coverRemoveTitle;

  /// No description provided for @coverRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'The cover will be hidden from the game without physically deleting your media history.'**
  String get coverRemoveMessage;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @coverRemoved.
  ///
  /// In en, this message translates to:
  /// **'Cover removed.'**
  String get coverRemoved;

  /// No description provided for @gameDeletePlaythroughTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete playthrough'**
  String get gameDeletePlaythroughTitle;

  /// No description provided for @gameDeletePlaythroughMessage.
  ///
  /// In en, this message translates to:
  /// **'The playthrough will be hidden from history.'**
  String get gameDeletePlaythroughMessage;

  /// No description provided for @gameMarkCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get gameMarkCompletedTitle;

  /// No description provided for @gameNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get gameNote;

  /// No description provided for @gameRegisterPlaythrough.
  ///
  /// In en, this message translates to:
  /// **'Register playthrough'**
  String get gameRegisterPlaythrough;

  /// No description provided for @gameEditPlaythrough.
  ///
  /// In en, this message translates to:
  /// **'Edit playthrough'**
  String get gameEditPlaythrough;

  /// No description provided for @gameStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get gameStartDate;

  /// No description provided for @gameNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get gameNotes;

  /// No description provided for @gamePlaythroughStart.
  ///
  /// In en, this message translates to:
  /// **'Start {date}'**
  String gamePlaythroughStart(Object date);

  /// No description provided for @gamePlaythroughEnd.
  ///
  /// In en, this message translates to:
  /// **'End {date}'**
  String gamePlaythroughEnd(Object date);

  /// No description provided for @metadataDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Search metadata'**
  String get metadataDialogTitle;

  /// No description provided for @metadataTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get metadataTitleField;

  /// No description provided for @metadataNoCandidates.
  ///
  /// In en, this message translates to:
  /// **'No candidates yet'**
  String get metadataNoCandidates;

  /// No description provided for @metadataNoCandidatesMessage.
  ///
  /// In en, this message translates to:
  /// **'Search for a game to see results from {provider}.'**
  String metadataNoCandidatesMessage(Object provider);

  /// No description provided for @metadataSaveLink.
  ///
  /// In en, this message translates to:
  /// **'Save link'**
  String get metadataSaveLink;

  /// No description provided for @metadataApply.
  ///
  /// In en, this message translates to:
  /// **'Apply metadata'**
  String get metadataApply;

  /// No description provided for @metadataCoverSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Metadata was applied, but the cover could not be saved. {error}'**
  String metadataCoverSaveFailed(Object error);

  /// No description provided for @metadataReplaceCoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace cover'**
  String get metadataReplaceCoverTitle;

  /// No description provided for @metadataReplaceCoverMessage.
  ///
  /// In en, this message translates to:
  /// **'This game already has a selected cover. Replace it with the cover included by IGDB?'**
  String get metadataReplaceCoverMessage;

  /// No description provided for @metadataReplaceExternalTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace external match'**
  String get metadataReplaceExternalTitle;

  /// No description provided for @metadataReplaceExternalMessage.
  ///
  /// In en, this message translates to:
  /// **'This game already has another external match for this provider. Replace it with the selected candidate?'**
  String get metadataReplaceExternalMessage;

  /// No description provided for @metadataOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'The metadata operation could not be completed.'**
  String get metadataOperationFailed;

  /// No description provided for @metadataIncludedCoverExisting.
  ///
  /// In en, this message translates to:
  /// **'This game already has a cover. Confirmation will be requested before replacing it.'**
  String get metadataIncludedCoverExisting;

  /// No description provided for @metadataIncludedCoverOffline.
  ///
  /// In en, this message translates to:
  /// **'The cover will be stored locally and remain available offline.'**
  String get metadataIncludedCoverOffline;

  /// No description provided for @metadataNoNewFields.
  ///
  /// In en, this message translates to:
  /// **'There are no new fields to apply. You can still save the external link.'**
  String get metadataNoNewFields;

  /// No description provided for @metadataReplaces.
  ///
  /// In en, this message translates to:
  /// **'replaces'**
  String get metadataReplaces;

  /// No description provided for @metadataProtected.
  ///
  /// In en, this message translates to:
  /// **'protected'**
  String get metadataProtected;

  /// No description provided for @metadataCurrentExternal.
  ///
  /// In en, this message translates to:
  /// **'Current: {current}\n{provider}: {external}'**
  String metadataCurrentExternal(
    Object current,
    Object external,
    Object provider,
  );

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @coverDialogSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search cover'**
  String get coverDialogSearchTitle;

  /// No description provided for @coverDialogChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change cover'**
  String get coverDialogChangeTitle;

  /// No description provided for @coverSearchIn.
  ///
  /// In en, this message translates to:
  /// **'Search in {provider}'**
  String coverSearchIn(Object provider);

  /// No description provided for @coverUseLocalFile.
  ///
  /// In en, this message translates to:
  /// **'Use local file'**
  String get coverUseLocalFile;

  /// No description provided for @coverNoResults.
  ///
  /// In en, this message translates to:
  /// **'No covers yet'**
  String get coverNoResults;

  /// No description provided for @coverNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Search for a game in {provider} or choose a local file.'**
  String coverNoResultsMessage(Object provider);

  /// No description provided for @coverSave.
  ///
  /// In en, this message translates to:
  /// **'Save cover'**
  String get coverSave;

  /// No description provided for @providerNoCovers.
  ///
  /// In en, this message translates to:
  /// **'{provider} returned no covers.'**
  String providerNoCovers(Object provider);

  /// No description provided for @coverOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'The cover operation could not be completed.'**
  String get coverOperationFailed;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Data and backups'**
  String get backupTitle;

  /// No description provided for @backupLocalPortability.
  ///
  /// In en, this message translates to:
  /// **'Local portability'**
  String get backupLocalPortability;

  /// No description provided for @backupLocalPortabilityMessage.
  ///
  /// In en, this message translates to:
  /// **'.vaultbackup is not encrypted and may include personal notes, games, statuses, and local media. .vaultbackup.enc encrypts the complete backup with a password the app does not store.'**
  String get backupLocalPortabilityMessage;

  /// No description provided for @backupProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing file'**
  String get backupProcessingTitle;

  /// No description provided for @backupProcessingMessage.
  ///
  /// In en, this message translates to:
  /// **'Wait while Backlog Vault prepares or validates the selected content.'**
  String get backupProcessingMessage;

  /// No description provided for @backupLastOperation.
  ///
  /// In en, this message translates to:
  /// **'Last operation'**
  String get backupLastOperation;

  /// No description provided for @backupRestoreLogicTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore and logical replacement'**
  String get backupRestoreLogicTitle;

  /// No description provided for @backupRestoreLogicMessage.
  ///
  /// In en, this message translates to:
  /// **'Before restoring, the app creates an automatic backup. Restore inserts or updates file content and soft-deletes current records left outside it.'**
  String get backupRestoreLogicMessage;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get backupRestore;

  /// No description provided for @backupRestoreEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Restore encrypted backup'**
  String get backupRestoreEncrypted;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Complete backup created.'**
  String get backupCreated;

  /// No description provided for @backupEncryptedCreated.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup created.'**
  String get backupEncryptedCreated;

  /// No description provided for @backupJsonCreated.
  ///
  /// In en, this message translates to:
  /// **'JSON export created.'**
  String get backupJsonCreated;

  /// No description provided for @backupCsvCreated.
  ///
  /// In en, this message translates to:
  /// **'CSV export created.'**
  String get backupCsvCreated;

  /// No description provided for @backupRestoredWithSafety.
  ///
  /// In en, this message translates to:
  /// **'Backup restored. An automatic safety backup was created.'**
  String get backupRestoredWithSafety;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored.'**
  String get backupRestored;

  /// No description provided for @backupEncryptedRestoredWithSafety.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup restored. An automatic encrypted safety backup was created.'**
  String get backupEncryptedRestoredWithSafety;

  /// No description provided for @backupEncryptedRestored.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup restored.'**
  String get backupEncryptedRestored;

  /// No description provided for @backupConfirmRestore.
  ///
  /// In en, this message translates to:
  /// **'Confirm restore'**
  String get backupConfirmRestore;

  /// No description provided for @backupDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String backupDate(Object date);

  /// No description provided for @backupGames.
  ///
  /// In en, this message translates to:
  /// **'Games: {count}'**
  String backupGames(Object count);

  /// No description provided for @backupPlaythroughs.
  ///
  /// In en, this message translates to:
  /// **'Playthroughs: {count}'**
  String backupPlaythroughs(Object count);

  /// No description provided for @backupMediaFiles.
  ///
  /// In en, this message translates to:
  /// **'Media: {count} files'**
  String backupMediaFiles(Object count);

  /// No description provided for @backupSchema.
  ///
  /// In en, this message translates to:
  /// **'Schema: {version}'**
  String backupSchema(Object version);

  /// No description provided for @backupWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings: {count}'**
  String backupWarnings(Object count);

  /// No description provided for @backupTypeRestore.
  ///
  /// In en, this message translates to:
  /// **'Type RESTORE to continue.'**
  String get backupTypeRestore;

  /// No description provided for @backupRestoreKeyword.
  ///
  /// In en, this message translates to:
  /// **'RESTORE'**
  String get backupRestoreKeyword;

  /// No description provided for @backupOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'The operation could not be completed.'**
  String get backupOperationFailed;

  /// No description provided for @backupCreateEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Create encrypted backup'**
  String get backupCreateEncrypted;

  /// No description provided for @backupOpenEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Open encrypted backup'**
  String get backupOpenEncrypted;

  /// No description provided for @backupPasswordWarning.
  ///
  /// In en, this message translates to:
  /// **'The password is not stored. If you lose it, the encrypted backup cannot be recovered.'**
  String get backupPasswordWarning;

  /// No description provided for @backupPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get backupPassword;

  /// No description provided for @backupRepeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get backupRepeatPassword;

  /// No description provided for @backupEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a password.'**
  String get backupEnterPassword;

  /// No description provided for @backupPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get backupPasswordsMismatch;

  /// No description provided for @openAction.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openAction;

  /// No description provided for @backupCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete backup'**
  String get backupCompleteTitle;

  /// No description provided for @backupCompleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Creates a .vaultbackup with games, playthroughs, applied metadata, and unencrypted local media.'**
  String get backupCompleteDescription;

  /// No description provided for @backupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get backupCreate;

  /// No description provided for @backupEncryptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup'**
  String get backupEncryptedTitle;

  /// No description provided for @backupEncryptedDescription.
  ///
  /// In en, this message translates to:
  /// **'Creates a password-protected .vaultbackup.enc. The password is not stored.'**
  String get backupEncryptedDescription;

  /// No description provided for @backupExportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get backupExportJson;

  /// No description provided for @backupExportJsonDescription.
  ///
  /// In en, this message translates to:
  /// **'Exports the library in a readable format useful for review or local scripting.'**
  String get backupExportJsonDescription;

  /// No description provided for @backupExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get backupExportCsv;

  /// No description provided for @backupExportCsvDescription.
  ///
  /// In en, this message translates to:
  /// **'Creates a compact tabular export for spreadsheets or manual exchange.'**
  String get backupExportCsvDescription;

  /// No description provided for @backupRestoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Opens a .vaultbackup, shows a preview, and requires strong confirmation before applying changes.'**
  String get backupRestoreDescription;

  /// No description provided for @backupRestoreEncryptedDescription.
  ///
  /// In en, this message translates to:
  /// **'Opens a .vaultbackup.enc, asks for its password, and validates the content before replacing data.'**
  String get backupRestoreEncryptedDescription;

  /// No description provided for @warnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get warnings;

  /// No description provided for @errors.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get errors;

  /// No description provided for @csvImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Notion CSV'**
  String get csvImportTitle;

  /// No description provided for @csvFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Import workflow'**
  String get csvFlowTitle;

  /// No description provided for @csvFlowDescription.
  ///
  /// In en, this message translates to:
  /// **'This workflow creates new games from a CSV exported by Notion. It does not update existing games and lets you review the mapping before applying changes.'**
  String get csvFlowDescription;

  /// No description provided for @csvMappingNeedsName.
  ///
  /// In en, this message translates to:
  /// **'The mapping needs a Name column.'**
  String get csvMappingNeedsName;

  /// No description provided for @csvConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm import'**
  String get csvConfirmTitle;

  /// No description provided for @csvConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} games will be imported. Existing games will not be updated.'**
  String csvConfirmMessage(Object count);

  /// No description provided for @csvImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get csvImportAction;

  /// No description provided for @stepOne.
  ///
  /// In en, this message translates to:
  /// **'Step 1'**
  String get stepOne;

  /// No description provided for @stepTwo.
  ///
  /// In en, this message translates to:
  /// **'Step 2'**
  String get stepTwo;

  /// No description provided for @stepThree.
  ///
  /// In en, this message translates to:
  /// **'Step 3'**
  String get stepThree;

  /// No description provided for @stepFour.
  ///
  /// In en, this message translates to:
  /// **'Step 4'**
  String get stepFour;

  /// No description provided for @csvChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get csvChooseFile;

  /// No description provided for @csvChooseFileDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the CSV exported by Notion. The app detects the delimiter, columns, and row count before continuing.'**
  String get csvChooseFileDescription;

  /// No description provided for @csvNoFile.
  ///
  /// In en, this message translates to:
  /// **'No file selected yet'**
  String get csvNoFile;

  /// No description provided for @csvNoFileMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a CSV to review headers, mapping, and the import preview.'**
  String get csvNoFileMessage;

  /// No description provided for @csvRows.
  ///
  /// In en, this message translates to:
  /// **'{count} rows'**
  String csvRows(Object count);

  /// No description provided for @csvColumns.
  ///
  /// In en, this message translates to:
  /// **'{count} columns'**
  String csvColumns(Object count);

  /// No description provided for @csvDelimiter.
  ///
  /// In en, this message translates to:
  /// **'Delimiter “{delimiter}”'**
  String csvDelimiter(Object delimiter);

  /// No description provided for @csvSelect.
  ///
  /// In en, this message translates to:
  /// **'Select CSV'**
  String get csvSelect;

  /// No description provided for @csvChange.
  ///
  /// In en, this message translates to:
  /// **'Change CSV'**
  String get csvChange;

  /// No description provided for @csvColumnMapping.
  ///
  /// In en, this message translates to:
  /// **'Column mapping'**
  String get csvColumnMapping;

  /// No description provided for @csvColumnMappingDescription.
  ///
  /// In en, this message translates to:
  /// **'Define how CSV headers are interpreted. Only Name is required to generate the preview.'**
  String get csvColumnMappingDescription;

  /// No description provided for @csvMissingNameMapping.
  ///
  /// In en, this message translates to:
  /// **'Map Name before generating the preview.'**
  String get csvMissingNameMapping;

  /// No description provided for @csvDoNotImport.
  ///
  /// In en, this message translates to:
  /// **'Do not import'**
  String get csvDoNotImport;

  /// No description provided for @csvGeneratePreview.
  ///
  /// In en, this message translates to:
  /// **'Generate preview'**
  String get csvGeneratePreview;

  /// No description provided for @csvPreviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Review which rows will be imported, omitted, or reported with warnings and duplicates.'**
  String get csvPreviewDescription;

  /// No description provided for @csvConfirmImport.
  ///
  /// In en, this message translates to:
  /// **'Confirm import'**
  String get csvConfirmImport;

  /// No description provided for @csvImportable.
  ///
  /// In en, this message translates to:
  /// **'{count} importable'**
  String csvImportable(Object count);

  /// No description provided for @csvOmitted.
  ///
  /// In en, this message translates to:
  /// **'{count} omitted'**
  String csvOmitted(Object count);

  /// No description provided for @csvWithWarnings.
  ///
  /// In en, this message translates to:
  /// **'{count} with warnings'**
  String csvWithWarnings(Object count);

  /// No description provided for @csvWithErrors.
  ///
  /// In en, this message translates to:
  /// **'{count} with errors'**
  String csvWithErrors(Object count);

  /// No description provided for @csvDuplicates.
  ///
  /// In en, this message translates to:
  /// **'{count} duplicates'**
  String csvDuplicates(Object count);

  /// No description provided for @csvNoRows.
  ///
  /// In en, this message translates to:
  /// **'No rows to review'**
  String get csvNoRows;

  /// No description provided for @csvNoRowsMessage.
  ///
  /// In en, this message translates to:
  /// **'The preview did not generate visible rows to import.'**
  String get csvNoRowsMessage;

  /// No description provided for @csvUnnamedRow.
  ///
  /// In en, this message translates to:
  /// **'Row {row} without a name'**
  String csvUnnamedRow(Object row);

  /// No description provided for @csvHasErrors.
  ///
  /// In en, this message translates to:
  /// **'Has errors'**
  String get csvHasErrors;

  /// No description provided for @csvWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get csvWarning;

  /// No description provided for @csvDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get csvDuplicate;

  /// No description provided for @csvSkipDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Skip duplicate'**
  String get csvSkipDuplicate;

  /// No description provided for @csvCreateAnyway.
  ///
  /// In en, this message translates to:
  /// **'Create anyway'**
  String get csvCreateAnyway;

  /// No description provided for @csvResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get csvResult;

  /// No description provided for @csvResultDescription.
  ///
  /// In en, this message translates to:
  /// **'A summary of what actually entered your local library.'**
  String get csvResultDescription;

  /// No description provided for @csvImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count}'**
  String csvImported(Object count);

  /// No description provided for @csvSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped {count}'**
  String csvSkipped(Object count);

  /// No description provided for @csvDuplicateSkipped.
  ///
  /// In en, this message translates to:
  /// **'Duplicates {count}'**
  String csvDuplicateSkipped(Object count);

  /// No description provided for @csvPlatformsCreated.
  ///
  /// In en, this message translates to:
  /// **'Platforms {count}'**
  String csvPlatformsCreated(Object count);

  /// No description provided for @csvGenresCreated.
  ///
  /// In en, this message translates to:
  /// **'Genres {count}'**
  String csvGenresCreated(Object count);

  /// No description provided for @csvPlaythroughsCreated.
  ///
  /// In en, this message translates to:
  /// **'Playthroughs {count}'**
  String csvPlaythroughsCreated(Object count);

  /// No description provided for @csvBackToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Back to library'**
  String get csvBackToLibrary;

  /// No description provided for @cannotContinue.
  ///
  /// In en, this message translates to:
  /// **'Could not continue'**
  String get cannotContinue;

  /// No description provided for @importFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get importFieldTitle;

  /// No description provided for @importFieldReleaseDate.
  ///
  /// In en, this message translates to:
  /// **'Release date'**
  String get importFieldReleaseDate;

  /// No description provided for @importFieldCompletedAt.
  ///
  /// In en, this message translates to:
  /// **'Completion date'**
  String get importFieldCompletedAt;

  /// No description provided for @importFieldHours.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get importFieldHours;

  /// No description provided for @importFieldRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get importFieldRating;

  /// No description provided for @importFieldGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get importFieldGenres;

  /// No description provided for @importFieldPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Platforms'**
  String get importFieldPlatforms;

  /// No description provided for @importFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get importFieldStatus;

  /// No description provided for @importFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get importFieldType;

  /// No description provided for @importFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get importFieldNotes;

  /// No description provided for @bulkTitle.
  ///
  /// In en, this message translates to:
  /// **'Import metadata'**
  String get bulkTitle;

  /// No description provided for @bulkIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk import'**
  String get bulkIntroTitle;

  /// No description provided for @bulkIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'Define the scope, review the preview, and confirm exactly which metadata or covers will be applied before running batch changes.'**
  String get bulkIntroDescription;

  /// No description provided for @bulkLoadingLibrary.
  ///
  /// In en, this message translates to:
  /// **'Loading library'**
  String get bulkLoadingLibrary;

  /// No description provided for @bulkPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'The preview could not be generated. {error}'**
  String bulkPreviewFailed(Object error);

  /// No description provided for @bulkConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm bulk import'**
  String get bulkConfirmTitle;

  /// No description provided for @bulkConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Only selected games, fields, and covers will be applied.'**
  String get bulkConfirmMessage;

  /// No description provided for @bulkConfirmSummary.
  ///
  /// In en, this message translates to:
  /// **'Games: {games}\nNew fields: {newFields}\nReplaced fields: {replacedFields}\nNew covers: {newCovers}\nReplaced covers: {replacedCovers}'**
  String bulkConfirmSummary(
    Object games,
    Object newCovers,
    Object newFields,
    Object replacedCovers,
    Object replacedFields,
  );

  /// No description provided for @bulkTypeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Type {keyword} to confirm.'**
  String bulkTypeConfirmation(Object keyword);

  /// No description provided for @bulkReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get bulkReplace;

  /// No description provided for @bulkApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get bulkApply;

  /// No description provided for @bulkWhatImport.
  ///
  /// In en, this message translates to:
  /// **'What do you want to import?'**
  String get bulkWhatImport;

  /// No description provided for @bulkWhatImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the import type, then adjust scope, provider, and replacement rules before generating the preview.'**
  String get bulkWhatImportDescription;

  /// No description provided for @bulkGamesToAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Games to analyze'**
  String get bulkGamesToAnalyze;

  /// No description provided for @bulkGamesToAnalyzeHelper.
  ///
  /// In en, this message translates to:
  /// **'This does not decide what gets overwritten.'**
  String get bulkGamesToAnalyzeHelper;

  /// No description provided for @bulkMetadataProvider.
  ///
  /// In en, this message translates to:
  /// **'Metadata provider'**
  String get bulkMetadataProvider;

  /// No description provided for @bulkMetadataMode.
  ///
  /// In en, this message translates to:
  /// **'Metadata mode'**
  String get bulkMetadataMode;

  /// No description provided for @bulkCoverSource.
  ///
  /// In en, this message translates to:
  /// **'Cover source'**
  String get bulkCoverSource;

  /// No description provided for @bulkExistingCovers.
  ///
  /// In en, this message translates to:
  /// **'Existing covers'**
  String get bulkExistingCovers;

  /// No description provided for @bulkScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning library'**
  String get bulkScanning;

  /// No description provided for @bulkPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get bulkPreviewTitle;

  /// No description provided for @bulkPreviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Filter matches, review changes, and leave selected only the games and fields you want to apply.'**
  String get bulkPreviewDescription;

  /// No description provided for @bulkAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'Analyzed'**
  String get bulkAnalyzed;

  /// No description provided for @bulkWithMatch.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get bulkWithMatch;

  /// No description provided for @bulkWithoutMatch.
  ///
  /// In en, this message translates to:
  /// **'No match'**
  String get bulkWithoutMatch;

  /// No description provided for @bulkSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get bulkSafe;

  /// No description provided for @bulkProbable.
  ///
  /// In en, this message translates to:
  /// **'Probable'**
  String get bulkProbable;

  /// No description provided for @bulkAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Ambiguous'**
  String get bulkAmbiguous;

  /// No description provided for @bulkWithCover.
  ///
  /// In en, this message translates to:
  /// **'With cover'**
  String get bulkWithCover;

  /// No description provided for @bulkWithoutCover.
  ///
  /// In en, this message translates to:
  /// **'Without cover'**
  String get bulkWithoutCover;

  /// No description provided for @bulkSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get bulkSelected;

  /// No description provided for @bulkNewFields.
  ///
  /// In en, this message translates to:
  /// **'New fields'**
  String get bulkNewFields;

  /// No description provided for @bulkReplacedFields.
  ///
  /// In en, this message translates to:
  /// **'Replaced fields'**
  String get bulkReplacedFields;

  /// No description provided for @bulkNewCovers.
  ///
  /// In en, this message translates to:
  /// **'New covers'**
  String get bulkNewCovers;

  /// No description provided for @bulkReplacedCovers.
  ///
  /// In en, this message translates to:
  /// **'Replaced covers'**
  String get bulkReplacedCovers;

  /// No description provided for @bulkSelectVisible.
  ///
  /// In en, this message translates to:
  /// **'Select visible'**
  String get bulkSelectVisible;

  /// No description provided for @bulkDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get bulkDeselectAll;

  /// No description provided for @bulkSelectSafe.
  ///
  /// In en, this message translates to:
  /// **'Select safe'**
  String get bulkSelectSafe;

  /// No description provided for @bulkNewCoverSelection.
  ///
  /// In en, this message translates to:
  /// **'New covers'**
  String get bulkNewCoverSelection;

  /// No description provided for @bulkCoverReplacements.
  ///
  /// In en, this message translates to:
  /// **'Cover replacements'**
  String get bulkCoverReplacements;

  /// No description provided for @bulkReplaceableFields.
  ///
  /// In en, this message translates to:
  /// **'Replaceable fields'**
  String get bulkReplaceableFields;

  /// No description provided for @bulkNoGamesForFilter.
  ///
  /// In en, this message translates to:
  /// **'No games match this filter'**
  String get bulkNoGamesForFilter;

  /// No description provided for @bulkNoGamesForFilterMessage.
  ///
  /// In en, this message translates to:
  /// **'Try changing the preview filter or reviewing the scope selected in the previous step.'**
  String get bulkNoGamesForFilterMessage;

  /// No description provided for @bulkCandidates.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get bulkCandidates;

  /// No description provided for @bulkUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get bulkUse;

  /// No description provided for @bulkNoMetadataFields.
  ///
  /// In en, this message translates to:
  /// **'There are no metadata fields to apply.'**
  String get bulkNoMetadataFields;

  /// No description provided for @bulkFields.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get bulkFields;

  /// No description provided for @bulkCurrentExternal.
  ///
  /// In en, this message translates to:
  /// **'Current: {current}\nExternal: {external}'**
  String bulkCurrentExternal(Object current, Object external);

  /// No description provided for @bulkSaveCover.
  ///
  /// In en, this message translates to:
  /// **'Save cover'**
  String get bulkSaveCover;

  /// No description provided for @bulkChooseCover.
  ///
  /// In en, this message translates to:
  /// **'Choose cover'**
  String get bulkChooseCover;

  /// No description provided for @bulkNoCoverFound.
  ///
  /// In en, this message translates to:
  /// **'No cover found'**
  String get bulkNoCoverFound;

  /// No description provided for @bulkCoverReplacementSelected.
  ///
  /// In en, this message translates to:
  /// **'Cover replacement selected'**
  String get bulkCoverReplacementSelected;

  /// No description provided for @bulkNewCoverSelected.
  ///
  /// In en, this message translates to:
  /// **'New cover selected'**
  String get bulkNewCoverSelected;

  /// No description provided for @bulkAlreadyHasCover.
  ///
  /// In en, this message translates to:
  /// **'Already has a cover'**
  String get bulkAlreadyHasCover;

  /// No description provided for @bulkCoverFound.
  ///
  /// In en, this message translates to:
  /// **'Cover found'**
  String get bulkCoverFound;

  /// No description provided for @bulkChooseCoverFor.
  ///
  /// In en, this message translates to:
  /// **'Choose cover · {title}'**
  String bulkChooseCoverFor(Object title);

  /// No description provided for @bulkFinalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Final confirmation'**
  String get bulkFinalConfirmation;

  /// No description provided for @bulkFinalConfirmationDescription.
  ///
  /// In en, this message translates to:
  /// **'Only games, fields, and covers that remain selected in the preview will be applied.'**
  String get bulkFinalConfirmationDescription;

  /// No description provided for @bulkFinalSummary.
  ///
  /// In en, this message translates to:
  /// **'{games} selected games · {newFields} fields to complete · {replacedFields} fields to replace · {newCovers} new covers · {replacedCovers} covers to replace.'**
  String bulkFinalSummary(
    Object games,
    Object newCovers,
    Object newFields,
    Object replacedCovers,
    Object replacedFields,
  );

  /// No description provided for @bulkApplyChanges.
  ///
  /// In en, this message translates to:
  /// **'Apply changes'**
  String get bulkApplyChanges;

  /// No description provided for @bulkResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Import complete'**
  String get bulkResultTitle;

  /// No description provided for @bulkResultDescription.
  ///
  /// In en, this message translates to:
  /// **'A summary of matches, saved changes, and warnings or errors returned by the process.'**
  String get bulkResultDescription;

  /// No description provided for @bulkProcessed.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get bulkProcessed;

  /// No description provided for @bulkNewMetadata.
  ///
  /// In en, this message translates to:
  /// **'New metadata'**
  String get bulkNewMetadata;

  /// No description provided for @bulkReplacedMetadata.
  ///
  /// In en, this message translates to:
  /// **'Replaced metadata'**
  String get bulkReplacedMetadata;

  /// No description provided for @bulkLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get bulkLinks;

  /// No description provided for @bulkSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get bulkSkipped;

  /// No description provided for @bulkNewPreview.
  ///
  /// In en, this message translates to:
  /// **'Generate new preview'**
  String get bulkNewPreview;

  /// No description provided for @bulkFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get bulkFilterAll;

  /// No description provided for @bulkFilterSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get bulkFilterSelected;

  /// No description provided for @bulkFilterSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get bulkFilterSafe;

  /// No description provided for @bulkFilterProbable.
  ///
  /// In en, this message translates to:
  /// **'Probable'**
  String get bulkFilterProbable;

  /// No description provided for @bulkFilterAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Ambiguous'**
  String get bulkFilterAmbiguous;

  /// No description provided for @bulkFilterErrors.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get bulkFilterErrors;

  /// No description provided for @bulkFilterNoResult.
  ///
  /// In en, this message translates to:
  /// **'No result'**
  String get bulkFilterNoResult;

  /// No description provided for @bulkFilterMetadata.
  ///
  /// In en, this message translates to:
  /// **'With metadata'**
  String get bulkFilterMetadata;

  /// No description provided for @bulkFilterCover.
  ///
  /// In en, this message translates to:
  /// **'With cover'**
  String get bulkFilterCover;

  /// No description provided for @bulkFilterReplacements.
  ///
  /// In en, this message translates to:
  /// **'With replacements'**
  String get bulkFilterReplacements;

  /// No description provided for @bulkScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All active games'**
  String get bulkScopeAll;

  /// No description provided for @bulkScopeNoMetadata.
  ///
  /// In en, this message translates to:
  /// **'Only without metadata'**
  String get bulkScopeNoMetadata;

  /// No description provided for @bulkScopeNoCover.
  ///
  /// In en, this message translates to:
  /// **'Only without cover'**
  String get bulkScopeNoCover;

  /// No description provided for @bulkScopeIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Only incomplete data'**
  String get bulkScopeIncomplete;

  /// No description provided for @bulkContentMetadataOnly.
  ///
  /// In en, this message translates to:
  /// **'Metadata only'**
  String get bulkContentMetadataOnly;

  /// No description provided for @bulkContentCoverOnly.
  ///
  /// In en, this message translates to:
  /// **'Cover art only'**
  String get bulkContentCoverOnly;

  /// No description provided for @bulkContentBoth.
  ///
  /// In en, this message translates to:
  /// **'Metadata + cover art'**
  String get bulkContentBoth;

  /// No description provided for @bulkContentMetadataOnlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete or review metadata fields without downloading covers.'**
  String get bulkContentMetadataOnlyDescription;

  /// No description provided for @bulkContentCoverOnlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Search for covers for existing games without applying metadata fields.'**
  String get bulkContentCoverOnlyDescription;

  /// No description provided for @bulkContentBothDescription.
  ///
  /// In en, this message translates to:
  /// **'Review metadata and covers in the same preview before applying.'**
  String get bulkContentBothDescription;

  /// No description provided for @bulkConfidenceSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get bulkConfidenceSafe;

  /// No description provided for @bulkConfidenceProbable.
  ///
  /// In en, this message translates to:
  /// **'Probable'**
  String get bulkConfidenceProbable;

  /// No description provided for @bulkConfidenceAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Ambiguous'**
  String get bulkConfidenceAmbiguous;

  /// No description provided for @bulkConfidenceNone.
  ///
  /// In en, this message translates to:
  /// **'No match'**
  String get bulkConfidenceNone;

  /// No description provided for @bulkCompleteMissing.
  ///
  /// In en, this message translates to:
  /// **'Complete missing'**
  String get bulkCompleteMissing;

  /// No description provided for @bulkReviewReplace.
  ///
  /// In en, this message translates to:
  /// **'Review and replace'**
  String get bulkReviewReplace;

  /// No description provided for @bulkNoCovers.
  ///
  /// In en, this message translates to:
  /// **'Do not import covers'**
  String get bulkNoCovers;

  /// No description provided for @bulkIgdbFirst.
  ///
  /// In en, this message translates to:
  /// **'IGDB first + SteamGridDB fallback'**
  String get bulkIgdbFirst;

  /// No description provided for @bulkSteamFirst.
  ///
  /// In en, this message translates to:
  /// **'SteamGridDB first + IGDB fallback'**
  String get bulkSteamFirst;

  /// No description provided for @bulkKeepCovers.
  ///
  /// In en, this message translates to:
  /// **'Keep existing covers'**
  String get bulkKeepCovers;

  /// No description provided for @bulkAllowCoverReplace.
  ///
  /// In en, this message translates to:
  /// **'Allow replacement with confirmation'**
  String get bulkAllowCoverReplace;

  /// No description provided for @bulkCurrentCover.
  ///
  /// In en, this message translates to:
  /// **'current cover'**
  String get bulkCurrentCover;

  /// No description provided for @bulkReplacesCover.
  ///
  /// In en, this message translates to:
  /// **'replaces {cover}'**
  String bulkReplacesCover(Object cover);

  /// No description provided for @syncSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual synchronization'**
  String get syncSectionTitle;

  /// No description provided for @syncSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Encrypted device-to-device change exchange without accounts, cloud, or a network connection.'**
  String get syncSectionDescription;

  /// No description provided for @syncFoundationReady.
  ///
  /// In en, this message translates to:
  /// **'Technical foundation ready'**
  String get syncFoundationReady;

  /// No description provided for @syncManualAvailable.
  ///
  /// In en, this message translates to:
  /// **'Encrypted manual sync packages are available.'**
  String get syncManualAvailable;

  /// No description provided for @syncNotReady.
  ///
  /// In en, this message translates to:
  /// **'Sync foundation is not ready on this device.'**
  String get syncNotReady;

  /// No description provided for @syncLocalDevice.
  ///
  /// In en, this message translates to:
  /// **'Local device'**
  String get syncLocalDevice;

  /// No description provided for @syncExportPackage.
  ///
  /// In en, this message translates to:
  /// **'Export sync package'**
  String get syncExportPackage;

  /// No description provided for @syncImportPackage.
  ///
  /// In en, this message translates to:
  /// **'Import sync package'**
  String get syncImportPackage;

  /// No description provided for @syncEncryptedNotice.
  ///
  /// In en, this message translates to:
  /// **'This package is encrypted with a password.'**
  String get syncEncryptedNotice;

  /// No description provided for @syncConflictNotice.
  ///
  /// In en, this message translates to:
  /// **'Conflicting changes will not be applied automatically.'**
  String get syncConflictNotice;

  /// No description provided for @syncMediaNotice.
  ///
  /// In en, this message translates to:
  /// **'Cover file synchronization will arrive in a later stage.'**
  String get syncMediaNotice;

  /// No description provided for @syncPackageVsBackup.
  ///
  /// In en, this message translates to:
  /// **'.vaultsync carries encrypted changes; it is not a complete backup. Use .vaultbackup.enc for full migration or recovery.'**
  String get syncPackageVsBackup;

  /// No description provided for @syncPasswordExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypt sync package'**
  String get syncPasswordExportTitle;

  /// No description provided for @syncPasswordImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Open sync package'**
  String get syncPasswordImportTitle;

  /// No description provided for @syncPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get syncPassword;

  /// No description provided for @syncRepeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get syncRepeatPassword;

  /// No description provided for @syncPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a password.'**
  String get syncPasswordRequired;

  /// No description provided for @syncPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get syncPasswordMismatch;

  /// No description provided for @syncPasswordForgotten.
  ///
  /// In en, this message translates to:
  /// **'The password is not stored. If you lose it, this package cannot be recovered.'**
  String get syncPasswordForgotten;

  /// No description provided for @syncSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save encrypted sync package'**
  String get syncSaveDialogTitle;

  /// No description provided for @syncExportCreated.
  ///
  /// In en, this message translates to:
  /// **'Encrypted sync package created with {count} changes.'**
  String syncExportCreated(Object count);

  /// No description provided for @syncPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync package preview'**
  String get syncPreviewTitle;

  /// No description provided for @syncFromDevice.
  ///
  /// In en, this message translates to:
  /// **'From: {name}'**
  String syncFromDevice(Object name);

  /// No description provided for @syncPackageDate.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String syncPackageDate(Object date);

  /// No description provided for @syncPreviewChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes: {count}'**
  String syncPreviewChanges(Object count);

  /// No description provided for @syncPreviewAlreadyApplied.
  ///
  /// In en, this message translates to:
  /// **'Already applied: {count}'**
  String syncPreviewAlreadyApplied(Object count);

  /// No description provided for @syncPreviewApplicable.
  ///
  /// In en, this message translates to:
  /// **'Safe to apply: {count}'**
  String syncPreviewApplicable(Object count);

  /// No description provided for @syncPreviewConflicts.
  ///
  /// In en, this message translates to:
  /// **'Conflicts skipped: {count}'**
  String syncPreviewConflicts(Object count);

  /// No description provided for @syncPreviewUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Unsupported: {count}'**
  String syncPreviewUnsupported(Object count);

  /// No description provided for @syncPreviewInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid: {count}'**
  String syncPreviewInvalid(Object count);

  /// No description provided for @syncPreviewPendingMedia.
  ///
  /// In en, this message translates to:
  /// **'Pending cover files: {count}'**
  String syncPreviewPendingMedia(Object count);

  /// No description provided for @syncApplySafeChanges.
  ///
  /// In en, this message translates to:
  /// **'Apply safe changes'**
  String get syncApplySafeChanges;

  /// No description provided for @syncAppliedCount.
  ///
  /// In en, this message translates to:
  /// **'Applied {count} safe changes.'**
  String syncAppliedCount(Object count);

  /// No description provided for @syncNoSafeChanges.
  ///
  /// In en, this message translates to:
  /// **'There are no new safe changes to apply.'**
  String get syncNoSafeChanges;

  /// No description provided for @syncImportResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual sync result'**
  String get syncImportResultTitle;

  /// No description provided for @syncOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'The sync package operation could not be completed. Check the password and file.'**
  String get syncOperationFailed;

  /// No description provided for @syncPairingTitle.
  ///
  /// In en, this message translates to:
  /// **'Device pairing'**
  String get syncPairingTitle;

  /// No description provided for @syncPairingDescription.
  ///
  /// In en, this message translates to:
  /// **'Pairing lets you use sync packages without typing a password every time. Local network sync will come in a later stage.'**
  String get syncPairingDescription;

  /// No description provided for @syncNoGroup.
  ///
  /// In en, this message translates to:
  /// **'No sync group configured'**
  String get syncNoGroup;

  /// No description provided for @syncGroupConfigured.
  ///
  /// In en, this message translates to:
  /// **'Sync group configured'**
  String get syncGroupConfigured;

  /// No description provided for @syncGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group: {name}'**
  String syncGroupName(Object name);

  /// No description provided for @syncPairedDevices.
  ///
  /// In en, this message translates to:
  /// **'Known paired devices: {count}'**
  String syncPairedDevices(Object count);

  /// No description provided for @syncGroupKeyAvailable.
  ///
  /// In en, this message translates to:
  /// **'The group key is protected by this device\'s secure storage.'**
  String get syncGroupKeyAvailable;

  /// No description provided for @syncGroupKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'The group key is missing on this device. Pair it again before using group packages.'**
  String get syncGroupKeyMissing;

  /// No description provided for @syncCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create sync group'**
  String get syncCreateGroup;

  /// No description provided for @syncCreateGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create sync group'**
  String get syncCreateGroupTitle;

  /// No description provided for @syncGroupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get syncGroupNameLabel;

  /// No description provided for @syncGroupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a group name.'**
  String get syncGroupNameRequired;

  /// No description provided for @syncExportInvitation.
  ///
  /// In en, this message translates to:
  /// **'Export pairing invitation'**
  String get syncExportInvitation;

  /// No description provided for @syncImportInvitation.
  ///
  /// In en, this message translates to:
  /// **'Import pairing invitation'**
  String get syncImportInvitation;

  /// No description provided for @syncInvitationNotice.
  ///
  /// In en, this message translates to:
  /// **'The .vaultpair invitation contains the group key inside a password-encrypted payload. Share the file and its temporary password through separate trusted channels.'**
  String get syncInvitationNotice;

  /// No description provided for @syncPairingPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect pairing invitation'**
  String get syncPairingPasswordTitle;

  /// No description provided for @syncPairingPasswordOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Open pairing invitation'**
  String get syncPairingPasswordOpenTitle;

  /// No description provided for @syncPairingSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save encrypted pairing invitation'**
  String get syncPairingSaveDialogTitle;

  /// No description provided for @syncInvitationCreated.
  ///
  /// In en, this message translates to:
  /// **'Encrypted pairing invitation created. It expires after 24 hours.'**
  String get syncInvitationCreated;

  /// No description provided for @syncInvitationImported.
  ///
  /// In en, this message translates to:
  /// **'This device joined the sync group.'**
  String get syncInvitationImported;

  /// No description provided for @syncInvitationExpired.
  ///
  /// In en, this message translates to:
  /// **'This pairing invitation has expired.'**
  String get syncInvitationExpired;

  /// No description provided for @syncPairingExistingGroup.
  ///
  /// In en, this message translates to:
  /// **'This device already belongs to another sync group. Leave it before importing a different invitation.'**
  String get syncPairingExistingGroup;

  /// No description provided for @syncGroupPackageMismatch.
  ///
  /// In en, this message translates to:
  /// **'This sync package belongs to another sync group.'**
  String get syncGroupPackageMismatch;

  /// No description provided for @syncGroupKeyMismatch.
  ///
  /// In en, this message translates to:
  /// **'This sync package uses another group key. Pair this device again.'**
  String get syncGroupKeyMismatch;

  /// No description provided for @syncLeaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave sync group'**
  String get syncLeaveGroup;

  /// No description provided for @syncLeaveGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave sync group?'**
  String get syncLeaveGroupTitle;

  /// No description provided for @syncLeaveGroupWarning.
  ///
  /// In en, this message translates to:
  /// **'The group key will be removed from secure storage. Your library and change history will not be deleted.'**
  String get syncLeaveGroupWarning;

  /// No description provided for @syncLeaveGroupDone.
  ///
  /// In en, this message translates to:
  /// **'This device left the sync group.'**
  String get syncLeaveGroupDone;

  /// No description provided for @syncGroupPackagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Paired group packages'**
  String get syncGroupPackagesTitle;

  /// No description provided for @syncExportGroupPackage.
  ///
  /// In en, this message translates to:
  /// **'Export with group key'**
  String get syncExportGroupPackage;

  /// No description provided for @syncImportGroupPackage.
  ///
  /// In en, this message translates to:
  /// **'Import from paired group'**
  String get syncImportGroupPackage;

  /// No description provided for @syncGroupPackageCreated.
  ///
  /// In en, this message translates to:
  /// **'Group-encrypted sync package created with {count} changes.'**
  String syncGroupPackageCreated(Object count);

  /// No description provided for @syncPairingOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'The pairing operation could not be completed. Check the invitation and temporary password.'**
  String get syncPairingOperationFailed;

  /// No description provided for @syncNoAutomaticSync.
  ///
  /// In en, this message translates to:
  /// **'Pairing does not synchronize automatically and does not enable LAN sync yet.'**
  String get syncNoAutomaticSync;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
