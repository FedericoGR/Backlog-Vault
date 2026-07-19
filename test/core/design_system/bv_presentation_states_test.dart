import 'package:backlog_vault/app/theme/app_theme.dart';
import 'package:backlog_vault/core/design_system/bv_async_action_button.dart';
import 'package:backlog_vault/core/design_system/bv_error_state.dart';
import 'package:backlog_vault/core/design_system/bv_feedback.dart';
import 'package:backlog_vault/core/design_system/bv_progress_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('error and progress actions use owner-provided localized copy', (
    tester,
  ) async {
    var retries = 0;
    var cancels = 0;

    await tester.pumpWidget(
      _host(
        ListView(
          children: [
            BvErrorState(
              title: 'Could not load',
              message: 'Try again safely.',
              retryLabel: 'Retry now',
              onRetry: () => retries++,
            ),
            BvProgressPanel(
              title: 'Working',
              cancelLabel: 'Stop safely',
              onCancel: () => cancels++,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Retry now'));
    await tester.tap(find.text('Stop safely'));

    expect(retries, 1);
    expect(cancels, 1);
    expect(find.text('Reintentar'), findsNothing);
    expect(find.text('Cancelar'), findsNothing);
  });

  testWidgets('async action prevents double submit and announces progress', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var submits = 0;

    await tester.pumpWidget(
      _host(
        BvAsyncActionButton(
          label: 'Save game',
          icon: Icons.save_outlined,
          onPressed: () => submits++,
          busy: true,
          busyLabel: 'Saving game',
        ),
      ),
    );

    await tester.tap(find.text('Save game'));

    expect(submits, 0);
    expect(find.bySemanticsLabel('Saving game'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('shared states tolerate narrow width and large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _host(
        const BvErrorState(
          title: 'A recoverable operation failed',
          message: 'No technical details are shown and this message may wrap.',
        ),
        textScaler: const TextScaler.linear(2),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('A recoverable operation failed'), findsOneWidget);
  });

  testWidgets('feedback replaces the previous transient message', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        Builder(
          builder:
              (context) => FilledButton(
                onPressed: () {
                  BvFeedback.show(context, 'First');
                  BvFeedback.show(context, 'Second');
                },
                child: const Text('Run'),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Run'));
    await tester.pump();

    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

Widget _host(Widget child, {TextScaler? textScaler}) {
  return MaterialApp(
    theme: buildBacklogVaultTheme(),
    home: Builder(
      builder:
          (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: textScaler ?? TextScaler.noScaling),
            child: Scaffold(body: Center(child: child)),
          ),
    ),
  );
}
