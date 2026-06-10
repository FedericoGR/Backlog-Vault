import 'dart:io';

import 'package:backlog_vault/core/database/app_database.dart';
import 'package:backlog_vault/core/database/database_providers.dart';
import 'package:backlog_vault/features/library/presentation/widgets/library_cover_thumbnail.dart';
import 'package:backlog_vault/features/media/data/media_file_storage.dart';
import 'package:backlog_vault/features/media/data/media_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp(
      'backlog_vault_cover_test_',
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('shows placeholder when there is no cover path', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LibraryCoverThumbnail(localPath: null, width: 64, height: 96),
        ),
      ),
    );

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  testWidgets('keeps placeholder when the local cover file is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          mediaFileStorageProvider.overrideWithValue(
            MediaFileStorage(baseDirectoryLoader: () async => tempDir),
          ),
        ],
        child: const MaterialApp(
          home: LibraryCoverThumbnail(
            localPath: 'media/games/g1/missing.png',
            width: 64,
            height: 96,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });
}
