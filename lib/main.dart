import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/backlog_vault_app.dart';
import 'features/sync/application/sync_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  unawaited(_initializeSyncFoundation(container));
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BacklogVaultApp(),
    ),
  );
}

Future<void> _initializeSyncFoundation(ProviderContainer container) async {
  try {
    await container.read(syncFoundationReadyProvider.future);
  } on Object {
    // The library remains usable if platform secure storage is temporarily
    // unavailable. A later mutation retries through SyncAwareTransaction.
  }
}
