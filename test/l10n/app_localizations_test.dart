import 'package:backlog_vault/l10n/app_localizations_en.dart';
import 'package:backlog_vault/l10n/app_localizations_es.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Spanish catalogs expose the offline product surfaces', () {
    final english = AppLocalizationsEn();
    final spanish = AppLocalizationsEs();

    expect(english.navigationLibrary, 'Library');
    expect(english.settingsTitle, 'Settings');
    expect(english.settingsLibraryData, 'Library data');
    expect(english.settingsExportLibrary, 'Export library');
    expect(english.bulkTitle, 'Import metadata');
    expect(english.settingsUsageMode, 'Usage mode');
    expect(english.settingsLocalDatabase, 'Local database');
    expect(english.settingsRawgSubtitle, contains('stored locally'));
    expect(english.settingsIgdbSubtitle, contains('renewed locally'));
    expect(english.settingsSteamGridDbSubtitle, contains('cover search'));

    expect(spanish.navigationLibrary, 'Biblioteca');
    expect(spanish.settingsTitle, 'Ajustes');
    expect(spanish.settingsLibraryData, 'Datos de la biblioteca');
    expect(spanish.settingsExportLibrary, 'Exportar biblioteca');
    expect(spanish.bulkTitle, 'Importar metadata');
    expect(spanish.settingsUsageMode, 'Modo de uso');
    expect(spanish.settingsLocalDatabase, 'Base local');
    expect(spanish.settingsRawgSubtitle, contains('localmente'));
    expect(spanish.settingsIgdbSubtitle, contains('renueva localmente'));
    expect(spanish.settingsSteamGridDbSubtitle, contains('portadas'));
  });

  test(
    'user-facing failures stay localized and omit technical exception data',
    () {
      final catalogs = [AppLocalizationsEn(), AppLocalizationsEs()];

      for (final catalog in catalogs) {
        final messages = [
          catalog.unexpectedErrorMessage,
          catalog.gameLoadError,
          catalog.gameSaveFailed,
          catalog.playthroughSaveFailed,
          catalog.csvOperationFailed,
          catalog.bulkOperationFailed,
          catalog.metadataCoverSaveFailed,
          catalog.bulkPreviewFailed,
          catalog.bulkIssueNoCandidates,
          catalog.bulkIssueProbableMatch,
          catalog.bulkIssueAmbiguousMatch,
          catalog.bulkIssueExternalReplacementAllowed,
          catalog.bulkIssueExternalReplacementBlocked,
          catalog.bulkIssueExistingCover,
          catalog.bulkIssueReplacementAvailable,
          catalog.bulkIssueNoCover,
          catalog.bulkIssueReviewRequired,
          catalog.bulkMatchReasonExistingExternalId,
          catalog.bulkMatchReasonExactTitle,
          catalog.bulkMatchReasonSimilarTitle,
          catalog.bulkMatchReasonSameYear,
          catalog.bulkMatchReasonNearbyYear,
          catalog.bulkMatchReasonMatchingPlatform,
          catalog.bulkMatchReasonFirstCandidate,
          catalog.bulkMatchReasonOther,
        ];

        for (final message in messages) {
          expect(message, isNotEmpty);
          expect(message, isNot(contains('Exception')));
          expect(message, isNot(contains('{error}')));
        }
      }
    },
  );
}
