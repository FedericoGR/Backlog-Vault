import 'package:backlog_vault/app/theme.dart';
import 'package:backlog_vault/core/design_system/bv_chip.dart';
import 'package:backlog_vault/core/design_system/bv_empty_state.dart';
import 'package:backlog_vault/core/design_system/bv_error_state.dart';
import 'package:backlog_vault/core/design_system/bv_loading_state.dart';
import 'package:backlog_vault/core/design_system/bv_page_scaffold.dart';
import 'package:backlog_vault/core/design_system/bv_panel.dart';
import 'package:backlog_vault/core/design_system/bv_section.dart';
import 'package:backlog_vault/core/design_system/bv_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('design system renders in $brightness', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme:
              brightness == Brightness.dark
                  ? buildBacklogVaultDarkTheme()
                  : buildBacklogVaultTheme(),
          home: const _ComponentPreview(),
        ),
      );

      expect(find.text('Panel'), findsOneWidget);
      expect(find.text('Juegos'), findsOneWidget);
      expect(find.text('Completado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('page scaffold keeps base components usable on small viewport', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildBacklogVaultDarkTheme(),
        home: const _ComponentPreview(),
      ),
    );

    expect(find.text('Design system'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ComponentPreview extends StatelessWidget {
  const _ComponentPreview();

  @override
  Widget build(BuildContext context) {
    return BvPageScaffold(
      title: 'Design system',
      body: ListView(
        children: const [
          BvPanel(
            child: BvSection(
              title: 'Panel',
              subtitle: 'Superficie oscura por capas',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  BvStatCard(label: 'Juegos', value: '51'),
                  BvChip(label: 'Completado', tone: BvChipTone.primary),
                  BvChip(label: 'Warning', tone: BvChipTone.warning),
                  BvChip(label: 'Error', tone: BvChipTone.danger),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: BvEmptyState(
              title: 'Sin resultados',
              message: 'Probá ajustar los filtros.',
            ),
          ),
          SizedBox(height: 12),
          BvErrorState(message: 'Mensaje de error de prueba.'),
          SizedBox(height: 12),
          SizedBox(height: 120, child: BvLoadingState()),
        ],
      ),
    );
  }
}
