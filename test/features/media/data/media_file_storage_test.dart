import 'dart:io';
import 'dart:typed_data';

import 'package:backlog_vault/features/media/data/media_file_storage.dart';
import 'package:backlog_vault/features/media/domain/media_exception.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late MediaFileStorage storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('backlog_vault_media_');
    storage = MediaFileStorage(baseDirectoryLoader: () async => tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('saves media with relative private path and hash', () async {
    final result = await storage.saveBytes(
      gameId: 'game-1',
      assetId: 'asset-1',
      bytes: _pngBytes(1),
      originalFileName: 'cover.png',
    );

    expect(result.fileName, 'asset-1.png');
    expect(result.localPath, 'media/games/game-1/asset-1.png');
    expect(result.localPath, isNot(contains('Hades')));
    expect(result.mimeType, 'image/png');
    expect(result.hash, isNotEmpty);

    final file = await storage.resolveFile(result.localPath);
    expect(await file.exists(), isTrue);
  });

  test('rejects unsupported local media bytes', () async {
    await expectLater(
      storage.saveBytes(
        gameId: 'game-1',
        assetId: 'asset-1',
        bytes: Uint8List.fromList([1, 2, 3]),
        originalFileName: 'cover.txt',
      ),
      throwsA(
        isA<MediaException>().having(
          (error) => error.type,
          'type',
          MediaErrorType.unsupportedFormat,
        ),
      ),
    );
  });
}

Uint8List _pngBytes(int seed) {
  return Uint8List.fromList([
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    seed,
  ]);
}
