import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/media_exception.dart';

typedef MediaBaseDirectoryLoader = Future<Directory> Function();

class StoredMediaFile {
  const StoredMediaFile({
    required this.localPath,
    required this.fileName,
    required this.mimeType,
    required this.hash,
  });

  final String localPath;
  final String fileName;
  final String mimeType;
  final String hash;
}

class MediaFileStorage {
  MediaFileStorage({MediaBaseDirectoryLoader? baseDirectoryLoader})
    : _baseDirectoryLoader =
          baseDirectoryLoader ?? getApplicationSupportDirectory;

  final MediaBaseDirectoryLoader _baseDirectoryLoader;

  Future<StoredMediaFile> saveBytes({
    required String gameId,
    required String assetId,
    required Uint8List bytes,
  }) async {
    final detectedMimeType = _detectMimeType(bytes);
    if (!_isSupportedMimeType(detectedMimeType)) {
      throw const MediaException(
        'El formato de imagen no está soportado.',
        type: MediaErrorType.unsupportedFormat,
      );
    }
    final safeMimeType = detectedMimeType!;

    final extension = _extensionForMimeType(safeMimeType);
    final fileName = '$assetId.$extension';
    final localPath = 'media/games/$gameId/$fileName';
    final destination = await resolveFile(localPath);
    final directory = destination.parent;
    final hash = sha256.convert(bytes).toString();

    try {
      await directory.create(recursive: true);
      final temp = File('${destination.path}.tmp');
      await temp.writeAsBytes(bytes, flush: true);
      if (await destination.exists()) {
        await destination.delete();
      }
      await temp.rename(destination.path);
    } on FileSystemException {
      throw const MediaException(
        'No se pudo guardar la imagen localmente.',
        type: MediaErrorType.fileSystem,
      );
    }

    return StoredMediaFile(
      localPath: localPath,
      fileName: fileName,
      mimeType: safeMimeType,
      hash: hash,
    );
  }

  Future<StoredMediaFile> copyLocalFile({
    required String gameId,
    required String assetId,
    required String sourcePath,
  }) async {
    try {
      final source = File(sourcePath);
      final bytes = await source.readAsBytes();
      return saveBytes(
        gameId: gameId,
        assetId: assetId,
        bytes: Uint8List.fromList(bytes),
      );
    } on MediaException {
      rethrow;
    } on FileSystemException {
      throw const MediaException(
        'No se pudo leer el archivo local seleccionado.',
        type: MediaErrorType.fileSystem,
      );
    }
  }

  Future<File> resolveFile(String localPath) async {
    if (_isUnsafeRelativePath(localPath)) {
      throw const MediaException(
        'La ruta local de la imagen no es válida.',
        type: MediaErrorType.fileSystem,
      );
    }
    final base = await _baseDirectoryLoader();
    final segments = localPath.split('/').where((part) => part.isNotEmpty);
    var path = base.path;
    for (final segment in segments) {
      path = '$path${Platform.pathSeparator}$segment';
    }
    return File(path);
  }
}

bool _isUnsafeRelativePath(String localPath) {
  final trimmed = localPath.trim();
  if (trimmed.isEmpty) return true;
  if (trimmed.startsWith('/') || trimmed.startsWith(r'\')) return true;
  if (trimmed.contains(':')) return true;
  if (trimmed.contains(r'\')) return true;
  return trimmed.split('/').any((part) => part == '..');
}

String? _detectMimeType(Uint8List bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF) {
    return 'image/jpeg';
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0D &&
      bytes[5] == 0x0A &&
      bytes[6] == 0x1A &&
      bytes[7] == 0x0A) {
    return 'image/png';
  }
  if (bytes.length >= 12 &&
      ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
      ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == 'WEBP') {
    return 'image/webp';
  }
  return null;
}

bool _isSupportedMimeType(String? mimeType) {
  return mimeType == 'image/jpeg' ||
      mimeType == 'image/png' ||
      mimeType == 'image/webp';
}

String _extensionForMimeType(String mimeType) {
  return switch (mimeType) {
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/webp' => 'webp',
    _ => 'img',
  };
}
