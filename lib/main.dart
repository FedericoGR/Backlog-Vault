import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/backlog_vault_app.dart';
import 'core/database/database_providers.dart';
import 'core/storage/offline_secure_storage_cleanup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await _completeOfflineMigration(container);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BacklogVaultApp(),
    ),
  );
}

Future<void> _completeOfflineMigration(ProviderContainer container) async {
  final database = container.read(appDatabaseProvider);
  await database.customSelect('SELECT 1').getSingle();
  try {
    await container.read(offlineSecureStorageCleanupProvider).run();
  } on OfflineSecureStorageCleanupException catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'offline migration cleanup',
      ),
    );
  }
}
