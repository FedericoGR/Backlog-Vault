import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../domain/backup_models.dart';
import 'export_repository.dart';

typedef BackupBaseDirectoryLoader = Future<Directory> Function();

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(exportRepository: ref.watch(exportRepositoryProvider));
});

class BackupService {
  BackupService({
    required ExportRepository exportRepository,
    BackupBaseDirectoryLoader? baseDirectoryLoader,
    IdGenerator? ids,
    Clock clock = systemClock,
  }) : _exportRepository = exportRepository,
       _baseDirectoryLoader =
           baseDirectoryLoader ?? getApplicationSupportDirectory,
       _ids = ids ?? defaultIdGenerator,
       _clock = clock;

  final ExportRepository _exportRepository;
  final BackupBaseDirectoryLoader _baseDirectoryLoader;
  final IdGenerator _ids;
  final Clock _clock;

  Future<ExportResult> exportJson() async {
    return ExportResult(
      fileName: _timestampedFileName('backlog-vault-export', 'json'),
      bytes: await _exportRepository.exportLogicalJsonBytes(),
      warnings: const [],
    );
  }

  Future<ExportResult> exportCsv() async {
    return ExportResult(
      fileName: _timestampedFileName('backlog-vault-library', 'csv'),
      bytes: await _exportRepository.exportActiveLibraryCsvBytes(),
      warnings: const [],
    );
  }

  Future<ExportResult> createBackup() async {
    final logicalExport = await _exportRepository.exportLogical();
    final libraryJson = _prettyJson(logicalExport.toJson());
    final libraryChecksum = sha256.convert(utf8.encode(libraryJson)).toString();
    final mediaCollection = await _collectMediaFiles(logicalExport);
    final warnings = mediaCollection.warnings;
    final manifest = BackupManifest(
      appName: backupAppName,
      backupFormatVersion: backupFormatVersion,
      backupId: _ids.newId(),
      createdAt: _clock.now(),
      appSchemaVersion: logicalExport.schemaVersion,
      sourcePlatform: Platform.operatingSystem,
      mediaIncluded: mediaCollection.files.isNotEmpty,
      counts: logicalExport.toCounts(mediaFiles: mediaCollection.files.length),
      libraryJsonSha256: libraryChecksum,
      warnings: warnings,
    );

    final archive =
        Archive()
          ..addFile(
            ArchiveFile.string('manifest.json', _prettyJson(manifest.toJson())),
          )
          ..addFile(ArchiveFile.string('data/library.json', libraryJson));
    for (final file in mediaCollection.files) {
      archive.addFile(ArchiveFile.bytes(file.archivePath, file.bytes));
    }

    return ExportResult(
      fileName: _timestampedFileName('backlog-vault', 'vaultbackup'),
      bytes: ZipEncoder().encodeBytes(archive),
      warnings: warnings,
    );
  }

  Future<BackupPreview> previewBackup(List<int> bytes) async {
    final package = BackupPackageReader().read(bytes);
    return BackupPreview(
      manifest: package.manifest,
      checksumValid: true,
      warnings: package.manifest.warnings,
    );
  }

  Future<RestoreResult> restoreBackup(
    List<int> bytes, {
    required String confirmation,
  }) async {
    if (confirmation.trim() != 'RESTAURAR') {
      throw const BackupException(
        'Para restaurar tenés que confirmar escribiendo RESTAURAR.',
      );
    }

    final package = BackupPackageReader().read(bytes);
    final preRestoreBackup = await createBackup();
    final preRestorePath = await _writePreRestoreBackup(preRestoreBackup.bytes);
    final createdMediaFiles = <File>[];

    try {
      await _restoreMediaFiles(package.mediaFiles, createdMediaFiles);
      await _exportRepository.restoreLogical(package.logicalExport);
      return RestoreResult(
        restoredCounts: package.logicalExport.toCounts(
          mediaFiles: package.mediaFiles.length,
        ),
        preRestoreBackupPath: preRestorePath,
        warnings: package.manifest.warnings,
      );
    } catch (_) {
      await _cleanupCreatedMediaFiles(createdMediaFiles);
      rethrow;
    }
  }

  Future<_MediaCollection> _collectMediaFiles(
    LogicalLibraryExport logicalExport,
  ) async {
    final files = <_MediaFile>[];
    final warnings = <BackupWarning>[];
    final seenPaths = <String>{};
    final base = await _baseDirectoryLoader();

    for (final row in logicalExport.mediaAssets) {
      final localPath = row['localPath'];
      if (localPath is! String || localPath.trim().isEmpty) continue;
      if (!_isSafeRelativePath(localPath) || !localPath.startsWith('media/')) {
        warnings.add(
          BackupWarning(
            code: 'unsafe_media_path',
            message: 'Se omitió un archivo de media con ruta no válida.',
            path: localPath,
          ),
        );
        continue;
      }
      if (!seenPaths.add(localPath)) continue;

      final file = _resolveRelativeFile(base, localPath);
      if (!await file.exists()) {
        warnings.add(
          BackupWarning(
            code: 'missing_media_file',
            message: 'No se encontró un archivo de media referenciado.',
            path: localPath,
          ),
        );
        continue;
      }
      try {
        files.add(
          _MediaFile(archivePath: localPath, bytes: await file.readAsBytes()),
        );
      } on FileSystemException {
        warnings.add(
          BackupWarning(
            code: 'unreadable_media_file',
            message: 'No se pudo leer un archivo de media referenciado.',
            path: localPath,
          ),
        );
      }
    }

    return _MediaCollection(files: files, warnings: warnings);
  }

  Future<String> _writePreRestoreBackup(List<int> bytes) async {
    final base = await _baseDirectoryLoader();
    final directory = Directory(
      '${base.path}${Platform.pathSeparator}backups${Platform.pathSeparator}pre-restore',
    );
    await directory.create(recursive: true);
    final file = File(
      '${directory.path}${Platform.pathSeparator}${_timestampedFileName('backlog-vault-pre-restore', 'vaultbackup')}',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> _restoreMediaFiles(
    Map<String, List<int>> mediaFiles,
    List<File> createdMediaFiles,
  ) async {
    final base = await _baseDirectoryLoader();
    for (final entry in mediaFiles.entries) {
      final localPath = entry.key;
      if (!_isSafeRelativePath(localPath) || !localPath.startsWith('media/')) {
        throw const BackupException(
          'El backup contiene una ruta de media insegura.',
        );
      }
      final destination = _resolveRelativeFile(base, localPath);
      if (await destination.exists()) continue;

      await destination.parent.create(recursive: true);
      final temp = File('${destination.path}.restore-tmp');
      await temp.writeAsBytes(entry.value, flush: true);
      await temp.rename(destination.path);
      createdMediaFiles.add(destination);
    }
  }

  Future<void> _cleanupCreatedMediaFiles(List<File> files) async {
    for (final file in files) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } on FileSystemException {
        // Best-effort cleanup. La DB sigue siendo la fuente de verdad.
      }
    }
  }
}

class DecodedBackupPackage {
  const DecodedBackupPackage({
    required this.manifest,
    required this.logicalExport,
    required this.mediaFiles,
  });

  final BackupManifest manifest;
  final LogicalLibraryExport logicalExport;
  final Map<String, List<int>> mediaFiles;
}

class BackupPackageReader {
  DecodedBackupPackage read(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    for (final file in archive) {
      if (!_isSafeArchivePath(file.name)) {
        throw const BackupException(
          'El backup contiene una ruta insegura y fue rechazado.',
        );
      }
    }

    final manifestFile = archive.findFile('manifest.json');
    final libraryFile = archive.findFile('data/library.json');
    if (manifestFile == null || libraryFile == null) {
      throw const BackupException(
        'El backup no contiene manifest.json y data/library.json.',
      );
    }

    final manifest = BackupManifest.fromJson(
      jsonDecode(utf8.decode(manifestFile.content)) as Map<String, Object?>,
    );
    _validateManifest(manifest);

    final libraryJson = utf8.decode(libraryFile.content);
    final computedChecksum =
        sha256.convert(utf8.encode(libraryJson)).toString();
    if (computedChecksum != manifest.libraryJsonSha256) {
      throw const BackupException(
        'El checksum de data/library.json no coincide.',
      );
    }

    final logicalExport = LogicalLibraryExport.fromJsonString(libraryJson);
    if (logicalExport.schemaVersion > supportedBackupSchemaVersion) {
      throw const BackupException(
        'El backup requiere una versión más nueva de Backlog Vault.',
      );
    }

    final mediaFiles = <String, List<int>>{};
    for (final file in archive) {
      if (!file.isFile) continue;
      if (!file.name.startsWith('media/')) continue;
      if (!_isSafeRelativePath(file.name)) {
        throw const BackupException(
          'El backup contiene una ruta de media insegura.',
        );
      }
      mediaFiles[file.name] = file.content;
    }

    return DecodedBackupPackage(
      manifest: manifest,
      logicalExport: logicalExport,
      mediaFiles: mediaFiles,
    );
  }

  void _validateManifest(BackupManifest manifest) {
    if (manifest.appName != backupAppName) {
      throw const BackupException(
        'El archivo no es un backup de Backlog Vault.',
      );
    }
    if (manifest.backupFormatVersion != backupFormatVersion) {
      throw const BackupException(
        'La versión del formato de backup no es compatible.',
      );
    }
    if (manifest.appSchemaVersion > supportedBackupSchemaVersion) {
      throw const BackupException(
        'El backup usa un schema más nuevo que esta app.',
      );
    }
  }
}

class _MediaCollection {
  const _MediaCollection({required this.files, required this.warnings});

  final List<_MediaFile> files;
  final List<BackupWarning> warnings;
}

class _MediaFile {
  const _MediaFile({required this.archivePath, required this.bytes});

  final String archivePath;
  final List<int> bytes;
}

String _timestampedFileName(String prefix, String extension) {
  final now = DateTime.now();
  final stamp =
      '${now.year.toString().padLeft(4, '0')}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}-'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}';
  return '$prefix-$stamp.$extension';
}

String _prettyJson(Map<String, Object?> json) {
  return const JsonEncoder.withIndent('  ').convert(json);
}

File _resolveRelativeFile(Directory base, String localPath) {
  var path = base.path;
  for (final part in localPath.split('/')) {
    if (part.isEmpty) continue;
    path = '$path${Platform.pathSeparator}$part';
  }
  return File(path);
}

bool _isSafeArchivePath(String path) {
  if (path == 'manifest.json' || path == 'data/library.json') return true;
  return path.startsWith('media/') && _isSafeRelativePath(path);
}

bool _isSafeRelativePath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) return false;
  if (trimmed.startsWith('/') || trimmed.startsWith(r'\')) return false;
  if (trimmed.contains(':')) return false;
  if (trimmed.contains(r'\')) return false;
  return !trimmed.split('/').any((part) => part.isEmpty || part == '..');
}
