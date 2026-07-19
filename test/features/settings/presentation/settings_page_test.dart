import 'package:backlog_vault/app/theme/app_theme.dart';
import 'package:backlog_vault/features/import_export/library_export/application/library_export_controller.dart';
import 'package:backlog_vault/features/metadata/data/metadata_api_key_storage.dart';
import 'package:backlog_vault/features/settings/presentation/settings_page.dart';
import 'package:backlog_vault/l10n/app_localizations_en.dart';
import 'package:backlog_vault/l10n/app_localizations_es.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'settings stays coherent offline and never exposes credentials or Sync UI',
    (tester) async {
      tester.view.physicalSize = const Size(420, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            metadataApiKeyStorageProvider.overrideWithValue(
              _FakeMetadataApiKeyStorage(),
            ),
            libraryExportControllerProvider.overrideWithValue(
              const _FakeLibraryExportCommand(LibraryExportStatus.saved),
            ),
          ],
          child: MaterialApp(
            theme: buildBacklogVaultDarkTheme(),
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ajustes'), findsOneWidget);
      expect(find.text('Datos de la biblioteca'), findsOneWidget);
      expect(find.text('Exportar biblioteca'), findsOneWidget);
      expect(find.textContaining('Backup cifrado'), findsNothing);
      expect(find.textContaining('Restaur'), findsNothing);
      expect(find.textContaining('Password'), findsNothing);
      expect(find.text('Sincronización'), findsNothing);
      expect(find.textContaining('emparejad'), findsNothing);
      expect(find.textContaining('QR'), findsNothing);
      expect(find.textContaining('Wi-Fi'), findsNothing);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exportar biblioteca'));
      await tester.pump();
      expect(find.text('Biblioteca exportada correctamente.'), findsOneWidget);

      for (final section in ['RAWG', 'IGDB / Twitch', 'SteamGridDB']) {
        await tester.scrollUntilVisible(
          find.text(section),
          500,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(section), findsOneWidget);
      }
      expect(find.textContaining('super-secret-rawg'), findsNothing);
      expect(find.textContaining('igdb-client-secret'), findsNothing);
      expect(find.textContaining('steamgrid-secret'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  test('library export messages exist in English and Spanish', () {
    final en = AppLocalizationsEn();
    final es = AppLocalizationsEs();

    expect(en.settingsExportLibrary, 'Export library');
    expect(en.libraryExportSucceeded, 'Library exported successfully.');
    expect(en.libraryExportCancelled, 'No location was selected.');
    expect(en.libraryExportFailed, 'The library could not be exported.');
    expect(es.settingsExportLibrary, 'Exportar biblioteca');
    expect(es.libraryExportSucceeded, 'Biblioteca exportada correctamente.');
    expect(es.libraryExportCancelled, 'No se seleccionó una ubicación.');
    expect(es.libraryExportFailed, 'No se pudo exportar la biblioteca.');
  });
}

class _FakeLibraryExportCommand implements LibraryExportCommand {
  const _FakeLibraryExportCommand(this.status);

  final LibraryExportStatus status;

  @override
  Future<LibraryExportOutcome> execute() async {
    return switch (status) {
      LibraryExportStatus.saved => const LibraryExportOutcome.saved(
        'library.json',
      ),
      LibraryExportStatus.cancelled => const LibraryExportOutcome.cancelled(),
      LibraryExportStatus.failed => const LibraryExportOutcome.failed(),
    };
  }
}

class _FakeMetadataApiKeyStorage implements MetadataApiKeyStorage {
  @override
  Future<void> deleteAllExternalApiKeys() async {}

  @override
  Future<void> deleteIgdbAccessToken() async {}

  @override
  Future<void> deleteIgdbClientId() async {}

  @override
  Future<void> deleteIgdbClientSecret() async {}

  @override
  Future<void> deleteRawgApiKey() async {}

  @override
  Future<void> deleteSteamGridDbApiKey() async {}

  @override
  Future<IgdbCachedToken?> readIgdbAccessToken() async => null;

  @override
  Future<String?> readIgdbClientId() async => 'igdb-client-id';

  @override
  Future<String?> readIgdbClientSecret() async => 'igdb-client-secret';

  @override
  Future<String?> readRawgApiKey() async => 'super-secret-rawg';

  @override
  Future<String?> readSteamGridDbApiKey() async => 'steamgrid-secret';

  @override
  Future<void> saveIgdbAccessToken(IgdbCachedToken token) async {}

  @override
  Future<void> saveIgdbClientId(String clientId) async {}

  @override
  Future<void> saveIgdbClientSecret(String clientSecret) async {}

  @override
  Future<void> saveRawgApiKey(String apiKey) async {}

  @override
  Future<void> saveSteamGridDbApiKey(String apiKey) async {}
}
