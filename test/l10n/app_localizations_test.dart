import 'package:backlog_vault/l10n/app_localizations_en.dart';
import 'package:backlog_vault/l10n/app_localizations_es.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Spanish catalogs expose the main application surfaces', () {
    final english = AppLocalizationsEn();
    final spanish = AppLocalizationsEs();

    expect(english.navigationLibrary, 'Library');
    expect(english.settingsTitle, 'Settings');
    expect(english.backupTitle, 'Data and backups');
    expect(english.bulkTitle, 'Import metadata');
    expect(english.syncExportPackage, 'Export change package');
    expect(english.syncImportPackage, 'Import change package');
    expect(english.syncCreateGroup, 'Connect another device');
    expect(english.syncExportInvitation, 'Create invitation file');
    expect(english.syncImportInvitation, 'Import invitation file');
    expect(english.syncGroupConfigured, 'Device ready to sync');
    expect(english.syncUxAdvancedTitle, 'Advanced options');
    expect(english.syncNoAutomaticSync, contains('does not synchronize'));
    expect(english.syncLanTitle, 'Sync over Wi-Fi');
    expect(english.syncLanStartSession, 'Start sync');
    expect(english.syncLanConnectSession, 'Join sync');
    expect(english.syncLanMediaNotice, contains('covers'));
    expect(english.syncShowPairingQr, 'Show invitation QR');
    expect(english.syncScanPairingQr, 'Scan invitation QR');
    expect(english.syncPastePairingCode, 'Paste invitation code');
    expect(english.syncShowLanQr, 'Show connection QR');
    expect(english.syncScanLanQr, 'Scan connection QR');
    expect(
      english.syncQrDoesNotReplaceEncryption,
      contains('does not replace'),
    );
    expect(english.syncQrNoPlaintextSecrets, contains('plaintext keys'));
    expect(english.syncPairingManualFallback, contains('.vaultpair'));
    expect(english.syncNoAutomaticDiscovery, contains('not available yet'));
    expect(english.syncLanResultMediaReceived(2), contains('2'));
    expect(english.syncLanInvalidSessionCode, contains('Incorrect code'));
    expect(english.syncLanGroupMismatch, contains('another sync group'));
    expect(english.syncLanKeyMismatch, contains('sync key'));
    expect(english.syncLanProtocolMismatch, contains('incompatible'));
    expect(english.syncLanPackageRejected, contains('damaged'));
    expect(english.syncLanConnectionInterrupted, contains('interrupted'));

    expect(spanish.navigationLibrary, 'Biblioteca');
    expect(spanish.settingsTitle, 'Ajustes');
    expect(spanish.backupTitle, 'Datos y backups');
    expect(spanish.bulkTitle, 'Importar metadata');
    expect(spanish.syncExportPackage, 'Exportar paquete de cambios');
    expect(spanish.syncImportPackage, 'Importar paquete de cambios');
    expect(spanish.syncCreateGroup, 'Conectar otro dispositivo');
    expect(spanish.syncExportInvitation, 'Crear invitación como archivo');
    expect(spanish.syncImportInvitation, 'Importar archivo de invitación');
    expect(spanish.syncGroupConfigured, 'Dispositivo listo para sincronizar');
    expect(spanish.syncUxAdvancedTitle, 'Opciones avanzadas');
    expect(spanish.syncNoAutomaticSync, contains('no sincroniza'));
    expect(spanish.syncLanTitle, 'Sincronizar por Wi-Fi');
    expect(spanish.syncLanStartSession, 'Iniciar sincronización');
    expect(spanish.syncLanConnectSession, 'Unirse a sincronización');
    expect(spanish.syncLanMediaNotice, contains('portadas'));
    expect(spanish.syncShowPairingQr, 'Mostrar QR de invitación');
    expect(spanish.syncScanPairingQr, 'Escanear QR de invitación');
    expect(spanish.syncPastePairingCode, 'Pegar código de invitación');
    expect(spanish.syncShowLanQr, 'Mostrar QR de conexión');
    expect(spanish.syncScanLanQr, 'Escanear QR de conexión');
    expect(spanish.syncQrDoesNotReplaceEncryption, contains('no reemplaza'));
    expect(spanish.syncQrNoPlaintextSecrets, contains('claves en claro'));
    expect(spanish.syncPairingManualFallback, contains('.vaultpair'));
    expect(spanish.syncNoAutomaticDiscovery, contains('todavía no'));
    expect(spanish.syncLanResultMediaReceived(2), contains('2'));
    expect(spanish.syncLanInvalidSessionCode, contains('Código incorrecto'));
    expect(spanish.syncLanGroupMismatch, contains('otro grupo'));
    expect(spanish.syncLanKeyMismatch, contains('clave de sincronización'));
    expect(spanish.syncLanProtocolMismatch, contains('incompatible'));
    expect(spanish.syncLanPackageRejected, contains('dañado'));
    expect(spanish.syncLanConnectionInterrupted, contains('interrumpió'));
  });
}
