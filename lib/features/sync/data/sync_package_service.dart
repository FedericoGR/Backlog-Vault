import 'dart:convert';

import '../../../core/time/clock.dart';
import '../domain/sync_package_models.dart';
import '../domain/sync_pairing_models.dart';
import 'canonical_json.dart';
import 'encrypted_sync_package_codec.dart';
import 'sync_change_applier.dart';
import 'sync_conflict_detector.dart';
import 'sync_group_management.dart';
import 'sync_package_builder.dart';
import 'sync_payload_sanitizer.dart';

class SyncPackageService {
  const SyncPackageService({
    required SyncPackageBuilder builder,
    required EncryptedSyncPackageCodec codec,
    required SyncConflictDetector conflictDetector,
    required SyncChangeApplier changeApplier,
    CanonicalJson serializer = canonicalJson,
    SyncPayloadSanitizer sanitizer = syncPayloadSanitizer,
    SyncGroupKeyResolver? groupKeys,
    Clock clock = systemClock,
  }) : _builder = builder,
       _codec = codec,
       _conflictDetector = conflictDetector,
       _changeApplier = changeApplier,
       _serializer = serializer,
       _sanitizer = sanitizer,
       _groupKeys = groupKeys,
       _clock = clock;

  final SyncPackageBuilder _builder;
  final EncryptedSyncPackageCodec _codec;
  final SyncConflictDetector _conflictDetector;
  final SyncChangeApplier _changeApplier;
  final CanonicalJson _serializer;
  final SyncPayloadSanitizer _sanitizer;
  final SyncGroupKeyResolver? _groupKeys;
  final Clock _clock;

  Future<SyncPackageExportResult> export({required String password}) async {
    final document = await _builder.build();
    final safeJson = _sanitizer.sanitizeMap(document.toJson());
    final clearBytes = utf8.encode(_serializer.encode(safeJson));
    final encrypted = await _codec.encrypt(clearBytes, password);
    return SyncPackageExportResult(
      fileName: _fileName(_clock.now().toUtc()),
      bytes: encrypted,
      changeCount: document.changes.length,
    );
  }

  Future<SyncImportPreview> preview(
    List<int> bytes, {
    required String password,
  }) async {
    final document = await _decode(bytes, password);
    return _conflictDetector.preview(document);
  }

  Future<SyncImportResult> applySafeChanges(
    List<int> bytes, {
    required String password,
  }) async {
    final document = await _decode(bytes, password);
    return _changeApplier.apply(document);
  }

  Future<SyncPackageExportResult> exportWithGroupKey() async {
    final resolver = _requireGroupResolver();
    final key = await resolver.requireActiveGroupKey();
    final document = await _builder.build();
    final safeJson = _sanitizer.sanitizeMap(document.toJson());
    final clearBytes = utf8.encode(_serializer.encode(safeJson));
    final encrypted = await _codec.encryptWithGroupKey(
      clearBytes,
      groupId: key.groupId,
      keyId: key.keyId,
      groupKey: key.bytes,
    );
    return SyncPackageExportResult(
      fileName: _fileName(_clock.now().toUtc()),
      bytes: encrypted,
      changeCount: document.changes.length,
    );
  }

  Future<SyncImportPreview> previewWithGroupKey(List<int> bytes) async {
    final document = await _decodeWithGroupKey(bytes);
    return _conflictDetector.preview(document);
  }

  Future<SyncImportResult> applySafeChangesWithGroupKey(List<int> bytes) async {
    final resolver = _requireGroupResolver();
    final document = await _decodeWithGroupKey(bytes);
    final result = await _changeApplier.apply(document);
    await resolver.registerPeer(document.fromDevice);
    return result;
  }

  Future<SyncPackageDocument> _decode(List<int> bytes, String password) async {
    final clear = await _codec.decrypt(bytes, password);
    return _decodeClear(clear);
  }

  Future<SyncPackageDocument> _decodeWithGroupKey(List<int> bytes) async {
    final resolver = _requireGroupResolver();
    final info = _codec.inspect(bytes);
    if (info.keyMode != SyncPackageKeyMode.group) {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
    final key = await resolver.requireActiveGroupKey();
    if (info.groupId != key.groupId) {
      throw const SyncPairingException(SyncPairingFailure.groupMismatch);
    }
    if (info.keyId != key.keyId) {
      throw const SyncPairingException(SyncPairingFailure.keyIdMismatch);
    }
    final clear = await _codec.decryptWithGroupKey(
      bytes,
      expectedGroupId: key.groupId,
      expectedKeyId: key.keyId,
      groupKey: key.bytes,
    );
    return _decodeClear(clear);
  }

  SyncGroupKeyResolver _requireGroupResolver() {
    final resolver = _groupKeys;
    if (resolver == null) {
      throw const SyncPairingException(SyncPairingFailure.noGroup);
    }
    return resolver;
  }

  SyncPackageDocument _decodeClear(List<int> clear) {
    try {
      final decoded = jsonDecode(utf8.decode(clear));
      if (decoded is! Map<String, Object?>) {
        throw const SyncPackageException('Invalid sync package payload.');
      }
      final safe = _sanitizer.sanitizeMap(decoded);
      if (_serializer.encode(safe) != _serializer.encode(decoded)) {
        throw const SyncPackageException(
          'The sync package contains unsafe local or secret data.',
        );
      }
      return SyncPackageDocument.fromJson(decoded);
    } on SyncPackageException {
      rethrow;
    } on Object {
      throw const SyncPackageException('Invalid sync package payload.');
    }
  }

  String _fileName(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return 'BacklogVault-sync-'
        '${value.year}${two(value.month)}${two(value.day)}-'
        '${two(value.hour)}${two(value.minute)}${two(value.second)}.'
        '$syncPackageExtension';
  }
}
