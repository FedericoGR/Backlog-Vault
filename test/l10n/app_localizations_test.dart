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
    expect(english.syncExportPackage, 'Export sync package');
    expect(english.syncImportPackage, 'Import sync package');
    expect(english.syncCreateGroup, 'Create sync group');
    expect(english.syncExportInvitation, 'Export pairing invitation');
    expect(english.syncNoAutomaticSync, contains('does not synchronize'));

    expect(spanish.navigationLibrary, 'Biblioteca');
    expect(spanish.settingsTitle, 'Ajustes');
    expect(spanish.backupTitle, 'Datos y backups');
    expect(spanish.bulkTitle, 'Importar metadata');
    expect(spanish.syncExportPackage, 'Exportar paquete de sincronización');
    expect(spanish.syncImportPackage, 'Importar paquete de sincronización');
    expect(spanish.syncCreateGroup, 'Crear grupo de sincronización');
    expect(
      spanish.syncExportInvitation,
      'Exportar invitación de emparejamiento',
    );
    expect(spanish.syncNoAutomaticSync, contains('no sincroniza'));
  });
}
