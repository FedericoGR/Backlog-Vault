import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide Uint8List;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../sync/application/sync_providers.dart';
import '../../sync/data/sync_change_tracking.dart';
import '../../sync/domain/sync_models.dart';
import '../domain/media_asset_models.dart';
import '../domain/media_exception.dart';
import 'media_file_storage.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository(
    ref.watch(appDatabaseProvider),
    storage: ref.watch(mediaFileStorageProvider),
    httpClient: ref.watch(mediaDownloadHttpClientProvider),
    sync: ref.watch(syncAwareTransactionProvider),
  );
});

final mediaDownloadHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final mediaFileStorageProvider = Provider<MediaFileStorage>((ref) {
  return MediaFileStorage();
});

class MediaRepository {
  MediaRepository(
    this._db, {
    required MediaFileStorage storage,
    http.Client? httpClient,
    IdGenerator? ids,
    Clock clock = systemClock,
    Duration downloadTimeout = const Duration(seconds: 20),
    SyncAwareTransaction? sync,
  }) : _storage = storage,
       _httpClient = httpClient ?? http.Client(),
       _ids = ids ?? defaultIdGenerator,
       _clock = clock,
       _downloadTimeout = downloadTimeout,
       _sync = sync ?? SyncAwareTransaction.disabled(_db);

  final AppDatabase _db;
  final MediaFileStorage _storage;
  final http.Client _httpClient;
  final IdGenerator _ids;
  final Clock _clock;
  final Duration _downloadTimeout;
  final SyncAwareTransaction _sync;

  Future<MediaAsset?> selectedCoverForGame(String gameId) {
    return ((_db.select(_db.mediaAssets)
          ..where((table) => table.gameId.equals(gameId))
          ..where((table) => table.kind.equals(MediaAssetKind.cover.name))
          ..where((table) => table.isSelected.equals(true))
          ..where((table) => table.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull());
  }

  Future<List<MediaAsset>> coversForGame(String gameId) {
    return ((_db.select(_db.mediaAssets)
          ..where((table) => table.gameId.equals(gameId))
          ..where((table) => table.kind.equals(MediaAssetKind.cover.name))
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get());
  }

  Future<MediaAsset> saveRemoteCover({
    required String gameId,
    required ExternalMediaAsset asset,
  }) async {
    await _requireGame(gameId);
    final existing = await _activeByProviderExternalId(
      provider: asset.providerId,
      externalId: asset.externalId,
    );
    if (existing != null) {
      if (existing.gameId != gameId) {
        throw const MediaException(
          'Ese asset externo ya está vinculado a otro juego.',
          type: MediaErrorType.conflict,
        );
      }
      if (await _isStoredFileUsable(existing)) {
        await _selectAsset(existing.id, gameId);
        return _requireSelectedUsableCover(gameId);
      }
      await _softDeleteBrokenAsset(existing);
    }

    final assetId = _ids.newId();
    final bytes = await _download(asset.remoteUrl);
    final stored = await _storage.saveBytes(
      gameId: gameId,
      assetId: assetId,
      bytes: bytes,
    );
    final existingWithHash = await _activeByHash(
      gameId: gameId,
      hash: stored.hash,
    );
    if (existingWithHash != null) {
      if (await _isStoredFileUsable(existingWithHash)) {
        await _deleteStoredFileIfExists(stored.localPath);
        await _selectAsset(existingWithHash.id, gameId);
        return _requireSelectedUsableCover(gameId);
      }
      await _softDeleteBrokenAsset(existingWithHash);
    }

    try {
      return await _insertAndSelect(
        MediaAssetsCompanion.insert(
          id: assetId,
          gameId: gameId,
          kind: asset.kind.name,
          source: _sourceForProvider(asset.providerId).name,
          provider: Value(asset.providerId),
          externalId: Value(asset.externalId),
          remoteUrl: Value(asset.remoteUrl),
          localPath: stored.localPath,
          fileName: stored.fileName,
          mimeType: Value(stored.mimeType),
          width: Value(asset.width),
          height: Value(asset.height),
          hash: Value(stored.hash),
          isSelected: const Value(true),
          attribution: Value(asset.attribution),
          createdAt: _clock.now(),
          updatedAt: _clock.now(),
        ),
      );
    } catch (_) {
      await _deleteStoredFileIfExists(stored.localPath);
      rethrow;
    }
  }

  Future<MediaAsset> saveLocalCover({
    required String gameId,
    required String sourcePath,
  }) async {
    await _requireGame(gameId);
    final assetId = _ids.newId();
    final stored = await _storage.copyLocalFile(
      gameId: gameId,
      assetId: assetId,
      sourcePath: sourcePath,
    );
    final existing = await _activeByHash(gameId: gameId, hash: stored.hash);
    if (existing != null) {
      await _deleteStoredFileIfExists(stored.localPath);
      await _selectAsset(existing.id, gameId);
      return (await selectedCoverForGame(gameId))!;
    }

    try {
      return await _insertAndSelect(
        MediaAssetsCompanion.insert(
          id: assetId,
          gameId: gameId,
          kind: MediaAssetKind.cover.name,
          source: MediaAssetSource.local.name,
          localPath: stored.localPath,
          fileName: stored.fileName,
          mimeType: Value(stored.mimeType),
          hash: Value(stored.hash),
          isSelected: const Value(true),
          createdAt: _clock.now(),
          updatedAt: _clock.now(),
        ),
      );
    } catch (_) {
      await _deleteStoredFileIfExists(stored.localPath);
      rethrow;
    }
  }

  Future<void> softDelete(String mediaAssetId) {
    return _sync.run(
      source: SyncChangeSource.manual,
      action: (_) async {
        final now = _clock.now();
        final asset =
            await ((_db.select(_db.mediaAssets)
                  ..where((table) => table.id.equals(mediaAssetId))
                  ..where((table) => table.deletedAt.isNull()))
                .getSingleOrNull());
        if (asset == null) return;
        await (_db.update(_db.mediaAssets)
          ..where((table) => table.id.equals(mediaAssetId))).write(
          MediaAssetsCompanion(
            isSelected: const Value(false),
            updatedAt: Value(now),
            deletedAt: Value(now),
          ),
        );
        await _touchGame(asset.gameId, now);
      },
    );
  }

  Future<File> resolveLocalFile(String localPath) {
    return _storage.resolveFile(localPath);
  }

  Future<Uint8List> _download(String url) async {
    try {
      final response = await _httpClient
          .get(Uri.parse(url))
          .timeout(_downloadTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const MediaException(
          'No se pudo descargar la imagen seleccionada.',
          type: MediaErrorType.network,
        );
      }
      return Uint8List.fromList(response.bodyBytes);
    } on MediaException {
      rethrow;
    } on TimeoutException {
      throw const MediaException(
        'La descarga de la imagen tardó demasiado.',
        type: MediaErrorType.timeout,
      );
    } on SocketException {
      throw const MediaException(
        'No se pudo descargar la imagen. Revisá tu conexión a internet.',
        type: MediaErrorType.network,
      );
    } on FormatException {
      throw const MediaException(
        'La URL de imagen no es válida.',
        type: MediaErrorType.unexpectedResponse,
      );
    } on http.ClientException {
      throw const MediaException(
        'No se pudo descargar la imagen.',
        type: MediaErrorType.network,
      );
    }
  }

  Future<MediaAsset> _insertAndSelect(MediaAssetsCompanion companion) {
    return _sync.run(
      source: SyncChangeSource.manual,
      action: (_) async {
        final now = _clock.now();
        final existingWithHash = await _activeByHash(
          gameId: companion.gameId.value,
          hash: companion.hash.value,
        );
        if (existingWithHash != null) {
          if (!await _isStoredFileUsable(existingWithHash)) {
            await (_db.update(_db.mediaAssets)
              ..where((table) => table.id.equals(existingWithHash.id))).write(
              MediaAssetsCompanion(
                isSelected: const Value(false),
                updatedAt: Value(now),
                deletedAt: Value(now),
              ),
            );
          } else {
            await (_db.update(_db.mediaAssets)
                  ..where(
                    (table) => table.gameId.equals(companion.gameId.value),
                  )
                  ..where(
                    (table) => table.kind.equals(MediaAssetKind.cover.name),
                  )
                  ..where((table) => table.deletedAt.isNull()))
                .write(
                  MediaAssetsCompanion(
                    isSelected: const Value(false),
                    updatedAt: Value(now),
                  ),
                );
            await (_db.update(_db.mediaAssets)
              ..where((table) => table.id.equals(existingWithHash.id))).write(
              MediaAssetsCompanion(
                isSelected: const Value(true),
                updatedAt: Value(now),
              ),
            );
            await _touchGame(companion.gameId.value, now);
            return _requireSelectedUsableCover(companion.gameId.value);
          }
        }

        await (_db.update(_db.mediaAssets)
              ..where((table) => table.gameId.equals(companion.gameId.value))
              ..where((table) => table.kind.equals(MediaAssetKind.cover.name))
              ..where((table) => table.deletedAt.isNull()))
            .write(
              MediaAssetsCompanion(
                isSelected: const Value(false),
                updatedAt: Value(now),
              ),
            );
        await _db.into(_db.mediaAssets).insert(companion);
        await _touchGame(companion.gameId.value, now);
        return _requireSelectedUsableCover(companion.gameId.value);
      },
    );
  }

  Future<void> _selectAsset(String mediaAssetId, String gameId) {
    return _sync.run(
      source: SyncChangeSource.manual,
      action: (_) async {
        final now = _clock.now();
        await (_db.update(_db.mediaAssets)
              ..where((table) => table.gameId.equals(gameId))
              ..where((table) => table.kind.equals(MediaAssetKind.cover.name))
              ..where((table) => table.deletedAt.isNull()))
            .write(
              MediaAssetsCompanion(
                isSelected: const Value(false),
                updatedAt: Value(now),
              ),
            );
        await (_db.update(_db.mediaAssets)
          ..where((table) => table.id.equals(mediaAssetId))).write(
          MediaAssetsCompanion(
            isSelected: const Value(true),
            updatedAt: Value(now),
          ),
        );
        await _touchGame(gameId, now);
      },
    );
  }

  Future<MediaAsset> _requireSelectedUsableCover(String gameId) async {
    final selected = await selectedCoverForGame(gameId);
    if (selected == null || !await _isStoredFileUsable(selected)) {
      throw const MediaException(
        'La portada se guardó, pero no se pudo resolver el archivo local.',
        type: MediaErrorType.fileSystem,
      );
    }
    return selected;
  }

  Future<bool> _isStoredFileUsable(MediaAsset asset) async {
    try {
      final file = await _storage.resolveFile(asset.localPath);
      return await file.exists() && await file.length() > 0;
    } on FileSystemException {
      return false;
    } on MediaException {
      return false;
    }
  }

  Future<void> _softDeleteBrokenAsset(MediaAsset asset) {
    return _sync.run(
      source: SyncChangeSource.manual,
      action: (_) async {
        final now = _clock.now();
        await (_db.update(_db.mediaAssets)
          ..where((table) => table.id.equals(asset.id))).write(
          MediaAssetsCompanion(
            isSelected: const Value(false),
            updatedAt: Value(now),
            deletedAt: Value(now),
          ),
        );
        await _touchGame(asset.gameId, now);
      },
    );
  }

  Future<Game> _requireGame(String gameId) async {
    final game =
        await ((_db.select(_db.games)
              ..where((table) => table.id.equals(gameId))
              ..where((table) => table.deletedAt.isNull()))
            .getSingleOrNull());
    if (game == null) {
      throw const MediaException(
        'No se encontró el juego.',
        type: MediaErrorType.notFound,
      );
    }
    return game;
  }

  Future<MediaAsset?> _activeByProviderExternalId({
    required String provider,
    required String externalId,
  }) {
    return ((_db.select(_db.mediaAssets)
          ..where((table) => table.provider.equals(provider))
          ..where((table) => table.externalId.equals(externalId))
          ..where((table) => table.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull());
  }

  Future<MediaAsset?> _activeByHash({
    required String gameId,
    required String? hash,
  }) {
    if (hash == null || hash.isEmpty) return Future.value(null);
    return ((_db.select(_db.mediaAssets)
          ..where((table) => table.gameId.equals(gameId))
          ..where((table) => table.hash.equals(hash))
          ..where((table) => table.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull());
  }

  Future<void> _touchGame(String gameId, DateTime now) async {
    await (_db.update(_db.games)..where(
      (table) => table.id.equals(gameId),
    )).write(GamesCompanion(updatedAt: Value(now)));
  }

  MediaAssetSource _sourceForProvider(String providerId) {
    return switch (providerId) {
      'igdb' => MediaAssetSource.igdb,
      'steamgriddb' => MediaAssetSource.steamgriddb,
      _ => MediaAssetSource.steamgriddb,
    };
  }

  Future<void> _deleteStoredFileIfExists(String localPath) async {
    try {
      final file = await _storage.resolveFile(localPath);
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Best-effort cleanup only; the DB remains the source of truth.
    }
  }
}
