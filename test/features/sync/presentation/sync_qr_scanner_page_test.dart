import 'dart:io';

import 'package:backlog_vault/features/sync/presentation/sync_qr_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('scanner page keeps manual fallback on non-Android platforms', (
    tester,
  ) async {
    if (Platform.isAndroid) return;

    await tester.pumpWidget(
      const MaterialApp(
        home: SyncQrScannerPage(
          title: 'Scan QR',
          unavailableMessage: 'Paste the code manually.',
        ),
      ),
    );

    expect(find.text('Scan QR'), findsOneWidget);
    expect(find.text('Paste the code manually.'), findsOneWidget);
    expect(find.byType(SyncQrScannerPage), findsOneWidget);
  });
}
