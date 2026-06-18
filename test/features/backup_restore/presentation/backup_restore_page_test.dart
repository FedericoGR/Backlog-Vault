import 'package:backlog_vault/app/theme.dart';
import 'package:backlog_vault/features/backup_restore/presentation/backup_restore_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('backup restore page stays readable on narrow viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildBacklogVaultDarkTheme(),
          home: const BackupRestorePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Datos y backups'), findsOneWidget);
    expect(find.text('Backup completo'), findsOneWidget);
    expect(find.text('Backup cifrado'), findsOneWidget);
    expect(find.textContaining('.vaultbackup no está cifrado'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Restauración y reemplazo lógico'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Restauración y reemplazo lógico'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
