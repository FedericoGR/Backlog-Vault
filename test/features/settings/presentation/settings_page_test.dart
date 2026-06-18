import 'package:backlog_vault/app/theme.dart';
import 'package:backlog_vault/features/metadata/data/metadata_api_key_storage.dart';
import 'package:backlog_vault/features/settings/presentation/settings_page.dart';
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
        find.text('SteamGridDB'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('RAWG'), findsOneWidget);
      expect(find.text('IGDB / Twitch'), findsOneWidget);
      expect(find.text('SteamGridDB'), findsOneWidget);
      expect(find.textContaining('super-secret-rawg'), findsNothing);
      expect(find.textContaining('igdb-client-secret'), findsNothing);
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
