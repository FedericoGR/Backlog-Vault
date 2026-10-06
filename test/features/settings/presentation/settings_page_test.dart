import 'package:backlog_vault/app/theme/app_theme.dart';
import 'package:backlog_vault/features/import_export/library_export/application/library_export_controller.dart';
import 'package:backlog_vault/features/metadata/data/metadata_api_key_storage.dart';
import 'package:backlog_vault/features/settings/presentation/settings_page.dart';
import 'package:backlog_vault/features/settings/application/app_language.dart';
import 'package:backlog_vault/l10n/app_localizations_en.dart';
import 'package:backlog_vault/l10n/app_localizations_es.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'disclosed credentials preserve save delete security and language actions',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final storage = _FakeMetadataApiKeyStorage();
      final container = ProviderContainer(
        overrides: [
          metadataApiKeyStorageProvider.overrideWithValue(storage),
          appLanguageProvider.overrideWith(_MemoryLanguage.new),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildBacklogVaultDarkTheme(),
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final old in ['SQLite', 'Drift', 'README', 'commits', 'Pendiente']) {
        expect(find.textContaining(old), findsNothing);
      }
      for (final provider in ['RAWG', 'IGDB / Twitch', 'SteamGridDB']) {
        final section = find.byKey(ValueKey('settings-$provider'));
        await tester.ensureVisible(section);
        await tester.tap(find.text(provider));
        await tester.pumpAndSettle();
        final fields = find.descendant(
          of: section,
          matching: find.byType(TextField),
        );
        expect(fields, findsNWidgets(provider == 'IGDB / Twitch' ? 2 : 1));
        for (var i = 0; i < fields.evaluate().length; i++) {
          expect(tester.widget<TextField>(fields.at(i)).obscureText, isTrue);
          await tester.enterText(fields.at(i), 'synthetic-secret');
        }
        final save = find.descendant(
          of: section,
          matching: find.text('Guardar'),
        );
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        for (final field in tester.widgetList<TextField>(fields)) {
          expect(field.controller!.text, isEmpty);
        }
        final delete = find.descendant(
          of: section,
          matching: find.text('Borrar'),
        );
        await tester.tap(delete);
        await tester.pumpAndSettle();
        expect(
          find.descendant(of: section, matching: find.text('Sin configurar')),
          findsOneWidget,
        );
        for (var i = 0; i < fields.evaluate().length; i++) {
          await tester.enterText(fields.at(i), 'synthetic-secret');
        }
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(provider));
        await tester.tap(find.text(provider));
        await tester.pumpAndSettle();
      }
      for (final operation in [
        'saveRawgApiKey',
        'deleteRawgApiKey',
        'saveIgdbClientId',
        'saveIgdbClientSecret',
        'deleteIgdbClientId',
        'deleteIgdbClientSecret',
        'deleteIgdbAccessToken',
        'saveSteamGridDbApiKey',
        'deleteSteamGridDbApiKey',
      ]) {
        expect(storage.operations, contains(operation));
      }
      final language = find.byType(
        DropdownButtonFormField<AppLanguagePreference>,
      );
      for (final engineeringCopy in [
        'README',
        'commits',
        'tests',
        'logs',
        'secure storage',
      ]) {
        expect(find.textContaining(engineeringCopy), findsNothing);
      }
      await tester.ensureVisible(language);
      await tester.tap(language);
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();
      expect(
        container.read(appLanguageProvider).value,
        AppLanguagePreference.english,
      );
      await tester.ensureVisible(find.text('Borrar todas las claves'));
      await tester.tap(find.text('Borrar todas las claves'));
      await tester.pumpAndSettle();
      expect(storage.operations, isNot(contains('deleteAllExternalApiKeys')));
      await tester.tap(find.text('Borrar claves'));
      await tester.pumpAndSettle();
      expect(storage.operations, contains('deleteAllExternalApiKeys'));
      expect(tester.takeException(), isNull);
    },
  );
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

      expect(find.text('AJUSTES'), findsOneWidget);
      expect(find.text('Datos de la biblioteca'), findsOneWidget);
      expect(find.text('Exportar biblioteca'), findsOneWidget);
      expect(find.textContaining('Backup cifrado'), findsNothing);
      expect(find.textContaining('Restaur'), findsNothing);
      expect(find.textContaining('Password'), findsNothing);
      expect(find.text('Sincronización'), findsNothing);
      expect(find.textContaining('emparejad'), findsNothing);
      expect(find.textContaining('QR'), findsNothing);
      expect(find.textContaining('Wi-Fi'), findsNothing);

      await tester.ensureVisible(find.text('Exportar biblioteca'));
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

class _MemoryLanguage extends AppLanguageController {
  @override
  Future<AppLanguagePreference> build() async => AppLanguagePreference.spanish;
  @override
  Future<void> setPreference(AppLanguagePreference preference) async {
    state = AsyncData(preference);
  }
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
  final operations = <String>[];
  @override
  Future<void> deleteAllExternalApiKeys() async {
    operations.add('deleteAllExternalApiKeys');
  }

  @override
  Future<void> deleteIgdbAccessToken() async {
    operations.add('deleteIgdbAccessToken');
  }

  @override
  Future<void> deleteIgdbClientId() async {
    operations.add('deleteIgdbClientId');
  }

  @override
  Future<void> deleteIgdbClientSecret() async {
    operations.add('deleteIgdbClientSecret');
  }

  @override
  Future<void> deleteRawgApiKey() async {
    operations.add('deleteRawgApiKey');
  }

  @override
  Future<void> deleteSteamGridDbApiKey() async {
    operations.add('deleteSteamGridDbApiKey');
  }

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
  Future<void> saveIgdbClientId(String clientId) async {
    operations.add('saveIgdbClientId');
  }

  @override
  Future<void> saveIgdbClientSecret(String clientSecret) async {
    operations.add('saveIgdbClientSecret');
  }

  @override
  Future<void> saveRawgApiKey(String apiKey) async {
    operations.add('saveRawgApiKey');
  }

  @override
  Future<void> saveSteamGridDbApiKey(String apiKey) async {
    operations.add('saveSteamGridDbApiKey');
  }
}
