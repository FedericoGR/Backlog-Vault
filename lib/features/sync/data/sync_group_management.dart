import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../core/version/app_versions.dart';
import '../domain/sync_models.dart';
import '../domain/sync_package_models.dart';
import '../domain/sync_pairing_models.dart';
import 'sync_change_tracking.dart';
import 'sync_device_identity.dart';

abstract interface class SyncGroupKeyStore {
  Future<void> save(String keyId, List<int> keyBytes);

  Future<List<int>?> read(String keyId);

  Future<void> delete(String keyId);
}

class SecureSyncGroupKeyStore implements SyncGroupKeyStore {
  SecureSyncGroupKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _prefix = 'sync.group.key.';
  final FlutterSecureStorage _storage;

  @override
  Future<void> save(String keyId, List<int> keyBytes) {
    _validate(keyId, keyBytes);
    return _storage.write(key: '$_prefix$keyId', value: base64Encode(keyBytes));
  }

  @override
  Future<List<int>?> read(String keyId) async {
    _validateKeyId(keyId);
    final encoded = await _storage.read(key: '$_prefix$keyId');
    if (encoded == null) return null;
    try {
      final bytes = base64Decode(encoded);
      if (bytes.length != 32) return null;
      return bytes;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> delete(String keyId) {
    _validateKeyId(keyId);
    return _storage.delete(key: '$_prefix$keyId');
  }

  void _validate(String keyId, List<int> bytes) {
    _validateKeyId(keyId);
    if (bytes.length != 32) {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
  }

  void _validateKeyId(String keyId) {
    if (!_uuidV4.hasMatch(keyId)) {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
  }
}

abstract interface class SyncGroupKeyResolver {
  Future<SyncGroupKeyMaterial> requireActiveGroupKey();

  Future<void> registerPeer(SyncPackageDevice device);
}

class SyncGroupManager implements SyncGroupKeyResolver {
  SyncGroupManager({
    required AppDatabase database,
    required SyncGroupKeyStore keyStore,
    required SyncDeviceIdentityService identityService,
    required SyncFoundationInitializer initializer,
    IdGenerator? ids,
    Clock clock = systemClock,
    Random? random,
  }) : _db = database,
       _keyStore = keyStore,
       _identityService = identityService,
       _initializer = initializer,
       _ids = ids ?? defaultIdGenerator,
       _clock = clock,
       _random = random ?? Random.secure();

  static const activeStatus = 'active';
  static const leftStatus = 'left';

  final AppDatabase _db;
  final SyncGroupKeyStore _keyStore;
  final SyncDeviceIdentityService _identityService;
  final SyncFoundationInitializer _initializer;
  final IdGenerator _ids;
  final Clock _clock;
  final Random _random;

  Future<SyncPairingState> state() async {
    final device = await _ensureReady();
    final group = await _activeGroup();
    if (group == null) {
      return SyncPairingState(
        localDevice: _deviceInfo(device),
        group: null,
        pairedDeviceCount: 0,
        hasGroupKey: false,
      );
    }
    final count =
        await (_db.selectOnly(_db.syncDevices)
              ..addColumns([_db.syncDevices.id.count()])
              ..where(
                _db.syncDevices.syncGroupId.equals(group.id) &
                    _db.syncDevices.isLocal.equals(false) &
                    _db.syncDevices.status.equals(SyncDeviceStatus.paired.name),
              ))
            .map((row) => row.read(_db.syncDevices.id.count()) ?? 0)
            .getSingle();
    return SyncPairingState(
      localDevice: _deviceInfo(device),
      group: _groupInfo(group),
      pairedDeviceCount: count,
      hasGroupKey: await _keyStore.read(group.keyId!) != null,
    );
  }

  Future<SyncGroupInfo> createGroup(String displayName) async {
    final device = await _ensureReady();
    final name = displayName.trim();
    if (name.isEmpty || name.length > 100) {
      throw const SyncPairingException(SyncPairingFailure.invalidInvitation);
    }
    if (await _activeGroup() != null) {
      throw const SyncPairingException(SyncPairingFailure.existingGroup);
    }
    final groupId = _newUuid();
    final keyId = _newUuid();
    final keyBytes = List<int>.generate(32, (_) => _random.nextInt(256));
    final now = _clock.now().toUtc();
    await _keyStore.save(keyId, keyBytes);
    try {
      await _db.transaction(() async {
        await _db
            .into(_db.syncGroups)
            .insert(
              SyncGroupsCompanion.insert(
                id: groupId,
                displayName: name,
                protocolVersion: syncProtocolVersion,
                keyId: Value(keyId),
                status: activeStatus,
                createdAt: now,
                updatedAt: now,
              ),
            );
        await _attachLocalDevice(device.id, groupId, now);
      });
    } on Object {
      await _keyStore.delete(keyId);
      rethrow;
    }
    return SyncGroupInfo(
      id: groupId,
      displayName: name,
      keyId: keyId,
      protocolVersion: syncProtocolVersion,
      status: activeStatus,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> importInvitation(PairingInvitation invitation) async {
    final device = await _ensureReady();
    if (invitation.isExpiredAt(_clock.now())) {
      throw const SyncPairingException(SyncPairingFailure.invitationExpired);
    }
    final active = await _activeGroup();
    if (active != null && active.id != invitation.group.groupId) {
      throw const SyncPairingException(SyncPairingFailure.existingGroup);
    }
    if (active != null && active.keyId != invitation.group.keyId) {
      throw const SyncPairingException(SyncPairingFailure.keyIdMismatch);
    }
    final existingKey = await _keyStore.read(invitation.group.keyId);
    if (existingKey != null &&
        !_constantTimeEquals(existingKey, invitation.group.groupKey)) {
      throw const SyncPairingException(SyncPairingFailure.keyIdMismatch);
    }
    await _keyStore.save(invitation.group.keyId, invitation.group.groupKey);
    try {
      await _db.transaction(() async {
        final now = _clock.now().toUtc();
        await _db
            .into(_db.syncGroups)
            .insertOnConflictUpdate(
              SyncGroupsCompanion.insert(
                id: invitation.group.groupId,
                displayName: invitation.group.displayName,
                protocolVersion: syncProtocolVersion,
                keyId: Value(invitation.group.keyId),
                status: activeStatus,
                createdAt: invitation.createdAt,
                updatedAt: now,
              ),
            );
        await _attachLocalDevice(device.id, invitation.group.groupId, now);
        await _upsertPeer(
          invitation.inviterDevice,
          invitation.group.groupId,
          now,
        );
      });
    } on Object {
      if (existingKey == null) {
        await _keyStore.delete(invitation.group.keyId);
      } else {
        await _keyStore.save(invitation.group.keyId, existingKey);
      }
      rethrow;
    }
  }

  Future<void> leaveGroup() async {
    await _ensureReady();
    final group = await _activeGroup();
    if (group == null || group.keyId == null) {
      throw const SyncPairingException(SyncPairingFailure.noGroup);
    }
    await _keyStore.delete(group.keyId!);
    final now = _clock.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.syncGroups)
        ..where((row) => row.id.equals(group.id))).write(
        SyncGroupsCompanion(
          status: const Value(leftStatus),
          updatedAt: Value(now),
        ),
      );
      await (_db.update(_db.syncDevices)..where(
        (row) => row.syncGroupId.equals(group.id) & row.isLocal.equals(false),
      )).write(
        SyncDevicesCompanion(
          status: Value(SyncDeviceStatus.revoked.name),
          revokedAt: Value(now),
        ),
      );
      await (_db.update(_db.syncDevices)..where(
        (row) => row.syncGroupId.equals(group.id) & row.isLocal.equals(true),
      )).write(const SyncDevicesCompanion(syncGroupId: Value(null)));
      await (_db.update(_db.syncStates)
        ..where((row) => row.id.equals('local'))).write(
        SyncStatesCompanion(
          syncGroupId: const Value(null),
          peerDeviceId: const Value(null),
          updatedAt: Value(now),
        ),
      );
    });
  }

  @override
  Future<SyncGroupKeyMaterial> requireActiveGroupKey() async {
    await _ensureReady();
    final group = await _activeGroup();
    if (group == null || group.keyId == null) {
      throw const SyncPairingException(SyncPairingFailure.noGroup);
    }
    final key = await _keyStore.read(group.keyId!);
    if (key == null) {
      throw const SyncPairingException(SyncPairingFailure.keyMissing);
    }
    return SyncGroupKeyMaterial(
      groupId: group.id,
      keyId: group.keyId!,
      bytes: key,
    );
  }

  @override
  Future<void> registerPeer(SyncPackageDevice device) async {
    final local = await _ensureReady();
    if (device.deviceId == local.id) return;
    final group = await _activeGroup();
    if (group == null) {
      throw const SyncPairingException(SyncPairingFailure.noGroup);
    }
    await _upsertPeer(device, group.id, _clock.now().toUtc());
  }

  Future<LocalDeviceInfo> _ensureReady() async {
    final device = await _identityService.ensureIdentity();
    await _initializer.initialize(device);
    return device;
  }

  Future<SyncGroup?> _activeGroup() {
    return (_db.select(_db.syncGroups)
          ..where((row) => row.status.equals(activeStatus))
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .getSingleOrNull();
  }

  Future<void> _attachLocalDevice(
    String deviceId,
    String groupId,
    DateTime now,
  ) async {
    await (_db.update(_db.syncDevices)
      ..where((row) => row.id.equals(deviceId))).write(
      SyncDevicesCompanion(syncGroupId: Value(groupId), pairedAt: Value(now)),
    );
    await (_db.update(_db.syncStates)
      ..where((row) => row.id.equals('local'))).write(
      SyncStatesCompanion(syncGroupId: Value(groupId), updatedAt: Value(now)),
    );
  }

  Future<void> _upsertPeer(
    SyncPackageDevice device,
    String groupId,
    DateTime now,
  ) {
    return _db
        .into(_db.syncDevices)
        .insertOnConflictUpdate(
          SyncDevicesCompanion.insert(
            id: device.deviceId,
            syncGroupId: Value(groupId),
            displayName: device.displayName,
            platform: device.platform,
            status: SyncDeviceStatus.paired.name,
            createdAt: now,
            pairedAt: Value(now),
            lastSeenAt: Value(now),
          ),
        );
  }

  SyncPackageDevice _deviceInfo(LocalDeviceInfo device) => SyncPackageDevice(
    deviceId: device.id,
    displayName: device.displayName,
    platform: device.platform,
  );

  SyncGroupInfo _groupInfo(SyncGroup group) => SyncGroupInfo(
    id: group.id,
    displayName: group.displayName,
    keyId: group.keyId!,
    protocolVersion: group.protocolVersion,
    status: group.status,
    createdAt: group.createdAt,
    updatedAt: group.updatedAt,
  );

  String _newUuid() {
    final value = _ids.newId();
    if (!_uuidV4.hasMatch(value)) {
      throw StateError('Generated sync group identifier is not a UUID v4.');
    }
    return value;
  }
}

final _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

bool _constantTimeEquals(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  var difference = 0;
  for (var index = 0; index < left.length; index++) {
    difference |= left[index] ^ right[index];
  }
  return difference == 0;
}
