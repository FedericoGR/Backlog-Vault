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

  test('validates jpg, png and webp by bytes, not file extension', () async {
    final jpg = await storage.saveBytes(
      gameId: 'game-1',
      assetId: 'asset-jpg',
      bytes: _jpgBytes(),
    );
    final png = await storage.saveBytes(
      gameId: 'game-1',
      assetId: 'asset-png',
      bytes: _pngBytes(2),
    );
    final webp = await storage.saveBytes(
      gameId: 'game-1',
      assetId: 'asset-webp',
      bytes: _webpBytes(),
    );

    expect(jpg.mimeType, 'image/jpeg');
    expect(jpg.fileName, 'asset-jpg.jpg');
    expect(png.mimeType, 'image/png');
    expect(png.fileName, 'asset-png.png');
    expect(webp.mimeType, 'image/webp');
    expect(webp.fileName, 'asset-webp.webp');
  });

  test(
    'copies local files into media folder without depending on original path',
    () async {
      final source = File(
        '${tempDir.path}${Platform.pathSeparator}original.png',
      );
      await source.writeAsBytes(_pngBytes(3));

      final stored = await storage.copyLocalFile(
        gameId: 'game-1',
        assetId: 'asset-copy',
        sourcePath: source.path,
      );
      await source.delete();

      final copied = await storage.resolveFile(stored.localPath);
      expect(await copied.exists(), isTrue);
      expect(stored.localPath, 'media/games/game-1/asset-copy.png');
      expect(stored.localPath, isNot(source.path));
    },
  );

  test('rejects unsafe absolute or parent-relative media paths', () async {
    await expectLater(
      storage.resolveFile('../outside.png'),
      throwsA(isA<MediaException>()),
    );
    await expectLater(
      storage.resolveFile('C:/Users/Feder/secret.png'),
      throwsA(isA<MediaException>()),
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

Uint8List _jpgBytes() {
  return Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00]);
}

Uint8List _webpBytes() {
  return Uint8List.fromList([
    0x52,
    0x49,
    0x46,
    0x46,
    0x24,
    0x00,
    0x00,
    0x00,
    0x57,
    0x45,
    0x42,
    0x50,
  ]);
}
