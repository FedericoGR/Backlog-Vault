import 'package:backlog_vault/app/theme.dart';
import 'package:backlog_vault/features/metadata/data/metadata_api_key_storage.dart';
import 'package:backlog_vault/features/settings/presentation/settings_page.dart';
import 'package:backlog_vault/features/sync/application/sync_providers.dart';
import 'package:backlog_vault/features/sync/domain/sync_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'settings page renders on narrow viewport without showing secrets',
    (tester) async {
      tester.view.physicalSize = const Size(420, 860);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            metadataApiKeyStorageProvider.overrideWithValue(
              _FakeMetadataApiKeyStorage(),
            ),
            syncFoundationReadyProvider.overrideWith(
              (ref) async => LocalDeviceInfo(
                id: '11111111-1111-4111-8111-111111111111',
                displayName: 'Test Windows device',
                platform: 'windows',
                createdAt: DateTime.utc(2026),
                status: SyncDeviceStatus.local,
              ),
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
      expect(find.text('Datos y backups'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Sincronización manual'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Exportar paquete de sincronización'), findsOneWidget);
      expect(find.text('Importar paquete de sincronización'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('RAWG'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('RAWG'), findsOneWidget);
      expect(find.textContaining('super-secret-rawg'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('IGDB / Twitch'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('IGDB / Twitch'), findsOneWidget);
      expect(find.textContaining('igdb-client-secret'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('SteamGridDB'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('SteamGridDB'), findsOneWidget);
      expect(find.textContaining('steamgrid-secret'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
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
