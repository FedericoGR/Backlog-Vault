import 'package:backlog_vault/app/theme.dart';
import 'package:backlog_vault/features/import_export/notion_csv/presentation/import_notion_csv_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('import csv page renders step flow on small viewport', (
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
          home: const ImportNotionCsvPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Importar CSV de Notion'), findsOneWidget);
    expect(find.text('Paso 1'), findsOneWidget);
    expect(find.text('Elegir archivo'), findsOneWidget);
    expect(find.text('Seleccionar CSV'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
