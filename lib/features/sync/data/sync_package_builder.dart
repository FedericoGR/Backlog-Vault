import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../core/version/app_versions.dart';
import '../domain/sync_package_models.dart';
import 'canonical_json.dart';
import 'sync_change_tracking.dart';
import 'sync_device_identity.dart';
import 'sync_payload_sanitizer.dart';

class SyncPackageBuilder {
  SyncPackageBuilder({
    required AppDatabase database,
    required SyncDeviceIdentityService identityService,
    required SyncFoundationInitializer initializer,
    IdGenerator? ids,
    Clock clock = systemClock,
    CanonicalJson serializer = canonicalJson,
    SyncPayloadSanitizer sanitizer = syncPayloadSanitizer,
  }) : _db = database,
       _identityService = identityService,
       _initializer = initializer,
       _ids = ids ?? defaultIdGenerator,
       _clock = clock,
       _serializer = serializer,
       _sanitizer = sanitizer;

  final AppDatabase _db;
  final SyncDeviceIdentityService _identityService;
  final SyncFoundationInitializer _initializer;
  final IdGenerator _ids;
  final Clock _clock;
  final CanonicalJson _serializer;
  final SyncPayloadSanitizer _sanitizer;

  Future<SyncPackageDocument> build() async {
    final device = await _identityService.ensureIdentity();
    await _initializer.initialize(device);
    final state =
        await (_db.select(_db.syncStates)
          ..where((row) => row.id.equals('local'))).getSingle();
    final changeRows =
        await (_db.select(_db.syncChanges)..orderBy([
          (row) => OrderingTerm.asc(row.createdAt),
          (row) => OrderingTerm.asc(row.originDeviceId),
          (row) => OrderingTerm.asc(row.originCounter),
        ])).get();
    final tombstoneRows =
        await (_db.select(_db.syncTombstones)..orderBy([
          (row) => OrderingTerm.asc(row.entityType),
          (row) => OrderingTerm.asc(row.entityId),
        ])).get();
    final entityStateRows =
        await (_db.select(_db.syncEntityStates)..orderBy([
          (row) => OrderingTerm.asc(row.entityType),
          (row) => OrderingTerm.asc(row.entityId),
        ])).get();
    final mediaRows =
        await (_db.select(_db.mediaAssets)
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm.asc(row.id)]))
            .get();

    return SyncPackageDocument(
      packageId: _ids.newId(),
      formatVersion: syncPackageFormatVersion,
      syncProtocolVersion: syncProtocolVersion,
      createdAt: _clock.now().toUtc(),
      fromDevice: SyncPackageDevice(
        deviceId: device.id,
        displayName: device.displayName,
        platform: device.platform,
      ),
      exportedVector: _intMap(state.seenVectorJson),
      changes: changeRows.map(_change).toList(growable: false),
      tombstones: tombstoneRows
          .map(
            (row) => SyncPackageTombstone(
              entityType: row.entityType,
              entityId: row.entityId,
              deleteChangeId: row.deleteChangeId,
              originDeviceId: row.originDeviceId,
              originCounter: row.originCounter,
              causalContext: _intMap(row.causalContextJson),
              lastContentHash: row.lastContentHash,
              deletedAt: row.deletedAt,
              retainUntil: row.retainUntil,
            ),
          )
          .toList(growable: false),
      entityStates: entityStateRows
          .map(
            (row) => SyncPackageEntityState(
              entityType: row.entityType,
              entityId: row.entityId,
              fieldVersions: _stringMap(row.fieldVersionsJson),
              entityVector: _intMap(row.entityVectorJson),
              lastChangeId: row.lastChangeId,
              contentHash: row.contentHash,
              isDeleted: row.isDeleted,
            ),
          )
          .toList(growable: false),
      mediaManifest: mediaRows
          .map(
            (row) => SyncMediaManifestEntry(
              mediaAssetId: row.id,
              gameId: row.gameId,
              hash: row.hash,
              kind: row.kind,
              source: row.source,
              provider: row.provider,
              externalId: row.externalId,
              fileName: _sanitizer.sanitize(row.fileName)! as String,
              mimeType: row.mimeType,
              width: row.width,
              height: row.height,
              isSelected: row.isSelected,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ),
          )
          .toList(growable: false),
      warnings: [if (mediaRows.isNotEmpty) 'media_files_not_included'],
    );
  }

  SyncPackageChange _change(SyncChange row) {
    final changedFields = _stringList(row.changedFieldsJson)..sort();
    final payload = _sanitizer.sanitizeMap(_objectMap(row.payloadJson));
    final snapshot = _sanitizer.sanitizeMap(_objectMap(row.snapshotJson));
    final causalContext = _intMap(row.causalContextJson);
    final content = <String, Object?>{
      'causalContext': causalContext,
      'changedFields': changedFields,
      'entityId': row.entityId,
      'entityType': row.entityType,
      'operation': row.operation,
      'originCounter': row.originCounter,
      'originDeviceId': row.originDeviceId,
      'payload': payload,
      'snapshot': snapshot,
      'source': row.source,
    };
    return SyncPackageChange(
      changeId: row.changeId,
      originDeviceId: row.originDeviceId,
      originCounter: row.originCounter,
      mutationId: row.mutationId,
      mutationSequence: row.mutationSequence,
      entityType: row.entityType,
      entityId: row.entityId,
      operation: row.operation,
      changedFields: changedFields,
      payload: payload,
      snapshot: snapshot,
      causalContext: causalContext,
      source: row.source,
      contentHash: _serializer.sha256Hex(content),
      createdAt: row.createdAt,
    );
  }

  Map<String, Object?> _objectMap(String source) {
    final decoded = jsonDecode(source);
    if (decoded is Map<String, Object?>) return decoded;
    if (decoded is Map) return Map<String, Object?>.from(decoded);
    throw const SyncPackageException('Stored sync change is invalid.');
  }

  Map<String, int> _intMap(String source) {
    final decoded = _objectMap(source);
    return decoded.map((key, value) {
      if (value is num) return MapEntry(key, value.toInt());
      throw const SyncPackageException('Stored sync vector is invalid.');
    });
  }

  Map<String, String> _stringMap(String source) {
    final decoded = _objectMap(source);
    return decoded.map((key, value) {
      if (value is String) return MapEntry(key, value);
      throw const SyncPackageException('Stored sync state is invalid.');
    });
  }

  List<String> _stringList(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const SyncPackageException('Stored sync field list is invalid.');
    }
    return decoded.map((value) {
      if (value is String) return value;
      throw const SyncPackageException('Stored sync field list is invalid.');
    }).toList();
  }
}
