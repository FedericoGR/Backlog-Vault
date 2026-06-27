import 'package:backlog_vault/app/theme.dart';
import 'package:backlog_vault/features/metadata/data/metadata_api_key_storage.dart';
import 'package:backlog_vault/features/settings/presentation/settings_page.dart';
import 'package:backlog_vault/features/sync/application/sync_providers.dart';
import 'package:backlog_vault/features/sync/domain/sync_models.dart';
import 'package:backlog_vault/features/sync/domain/sync_package_models.dart';
import 'package:backlog_vault/features/sync/domain/sync_pairing_models.dart';
import 'package:backlog_vault/features/sync/presentation/manual_sync_section.dart';
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
            syncPairingStateProvider.overrideWith(
              (ref) async => _pairingState(),
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

  testWidgets('manual sync export rejects mismatched passwords safely', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncFoundationReadyProvider.overrideWith(
            (ref) async => LocalDeviceInfo(
              id: '11111111-1111-4111-8111-111111111111',
              displayName: 'Test Windows device',
              platform: 'windows',
              createdAt: DateTime.utc(2026),
              status: SyncDeviceStatus.local,
            ),
          ),
          syncPairingStateProvider.overrideWith((ref) async => _pairingState()),
        ],
        child: MaterialApp(
          theme: buildBacklogVaultDarkTheme(),
          home: const Scaffold(
            body: SingleChildScrollView(child: ManualSyncSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final exportButton = find.widgetWithText(
      FilledButton,
      'Exportar paquete de sincronización',
    );
    await tester.ensureVisible(exportButton);
    await tester.pumpAndSettle();
    await tester.tap(exportButton);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    await tester.enterText(find.byType(TextField).first, 'test password one');
    await tester.enterText(find.byType(TextField).last, 'test password two');
    await tester.tap(
      find
          .widgetWithText(FilledButton, 'Exportar paquete de sincronización')
          .last,
    );
    await tester.pumpAndSettle();

    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    expect(
      tester
          .widgetList<EditableText>(find.byType(EditableText))
          .every((field) => field.obscureText),
      isTrue,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data?.contains('test password one') ?? false),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'manual sync shows paired LAN actions without future-feature claims',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncFoundationReadyProvider.overrideWith(
              (ref) async => _localDevice(),
            ),
            syncPairingStateProvider.overrideWith(
              (ref) async => _pairingState(configured: true),
            ),
          ],
          child: MaterialApp(
            theme: buildBacklogVaultDarkTheme(),
            home: const Scaffold(
              body: SingleChildScrollView(child: ManualSyncSection()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Grupo de sincronización configurado'), findsOneWidget);
      expect(find.text('Grupo: Test group'), findsOneWidget);
      expect(
        find.text('Dispositivos emparejados conocidos: 1'),
        findsOneWidget,
      );
      expect(
        find.text('Exportar invitación de emparejamiento'),
        findsOneWidget,
      );
      expect(find.text('Mostrar QR de invitación'), findsOneWidget);
      expect(find.text('Escanear QR de pairing'), findsOneWidget);
      expect(find.text('Pegar código de pairing'), findsOneWidget);
      expect(find.text('Exportar con clave de grupo'), findsOneWidget);
      expect(find.text('Importar desde grupo emparejado'), findsOneWidget);
      expect(find.text('Salir del grupo de sincronización'), findsOneWidget);
      expect(find.text('Sync por red local'), findsOneWidget);
      expect(find.text('Iniciar sesión LAN'), findsOneWidget);
      expect(find.text('Conectarse a sesión LAN'), findsOneWidget);
      expect(find.text('Escanear QR de conexión LAN'), findsOneWidget);
      expect(find.text('Sincronizar ahora'), findsNothing);
      expect(find.text('Discovery automático'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

LocalDeviceInfo _localDevice() => LocalDeviceInfo(
  id: '11111111-1111-4111-8111-111111111111',
  displayName: 'Test Windows device',
  platform: 'windows',
  createdAt: DateTime.utc(2026),
  status: SyncDeviceStatus.local,
);

SyncPairingState _pairingState({bool configured = false}) {
  final device = _localDevice();
  return SyncPairingState(
    localDevice: SyncPackageDevice(
      deviceId: device.id,
      displayName: device.displayName,
      platform: device.platform,
    ),
    group:
        configured
            ? SyncGroupInfo(
              id: '22222222-2222-4222-8222-222222222222',
              displayName: 'Test group',
              keyId: '33333333-3333-4333-8333-333333333333',
              protocolVersion: 1,
              status: 'active',
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            )
            : null,
    pairedDeviceCount: configured ? 1 : 0,
    hasGroupKey: configured,
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
