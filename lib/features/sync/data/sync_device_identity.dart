import 'dart:io' as io;

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../domain/sync_models.dart';

abstract interface class SyncIdentityStore {
  Future<String?> readDeviceId();

  Future<void> writeDeviceId(String deviceId);
}

class SecureSyncIdentityStore implements SyncIdentityStore {
  SecureSyncIdentityStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _deviceIdKey = 'sync.local.device_id';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> readDeviceId() => _storage.read(key: _deviceIdKey);

  @override
  Future<void> writeDeviceId(String deviceId) =>
      _storage.write(key: _deviceIdKey, value: deviceId);
}

class SyncDeviceRepository {
  const SyncDeviceRepository(this._db);

  final AppDatabase _db;

  Future<SyncDevice?> findById(String id) {
    return (_db.select(_db.syncDevices)
      ..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<List<SyncDevice>> localDevices() {
    return (_db.select(_db.syncDevices)
          ..where((row) => row.isLocal.equals(true))
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
        .get();
  }

  Future<void> replaceLocalIdentity({
    required String id,
    required String displayName,
    required String platform,
    required DateTime createdAt,
    required SyncDeviceStatus displacedStatus,
  }) {
    return _db.transaction(() async {
      await (_db.update(_db.syncDevices)
        ..where((row) => row.isLocal.equals(true))).write(
        SyncDevicesCompanion(
          isLocal: const Value(false),
          status: Value(displacedStatus.name),
        ),
      );
      final existing = await findById(id);
      final companion = SyncDevicesCompanion(
        id: Value(id),
        displayName: Value(displayName),
        platform: Value(platform),
        isLocal: const Value(true),
        status: Value(SyncDeviceStatus.local.name),
        createdAt: Value(createdAt),
      );
      if (existing == null) {
        await _db.into(_db.syncDevices).insert(companion);
      } else {
        await (_db.update(_db.syncDevices)
          ..where((row) => row.id.equals(id))).write(companion);
      }
    });
  }
}

class SyncDeviceIdentityService {
  SyncDeviceIdentityService({
    required SyncIdentityStore store,
    required SyncDeviceRepository repository,
    IdGenerator? ids,
    Clock clock = systemClock,
    String Function()? platformLoader,
  }) : _store = store,
       _repository = repository,
       _ids = ids ?? defaultIdGenerator,
       _clock = clock,
       _platformLoader = platformLoader ?? (() => io.Platform.operatingSystem);

  final SyncIdentityStore _store;
  final SyncDeviceRepository _repository;
  final IdGenerator _ids;
  final Clock _clock;
  final String Function() _platformLoader;
  Future<LocalDeviceInfo>? _identityFuture;

  Future<LocalDeviceInfo> ensureIdentity() async {
    final current = _identityFuture;
    if (current != null) return current;
    final future = _loadOrCreateIdentity();
    _identityFuture = future;
    try {
      return await future;
    } on Object {
      if (identical(_identityFuture, future)) _identityFuture = null;
      rethrow;
    }
  }

  Future<LocalDeviceInfo> _loadOrCreateIdentity() async {
    final stored = (await _store.readDeviceId())?.trim();
    final currentLocals = await _repository.localDevices();
    final platform = _platformLoader();

    if (stored != null && _isUuidV4(stored)) {
      final existing = await _repository.findById(stored);
      if (existing != null && existing.isLocal && currentLocals.length == 1) {
        return _toInfo(existing);
      }
      final createdAt = existing?.createdAt ?? _clock.now();
      await _repository.replaceLocalIdentity(
        id: stored,
        displayName: existing?.displayName ?? _defaultDisplayName(platform),
        platform: existing?.platform ?? platform,
        createdAt: createdAt,
        displacedStatus: SyncDeviceStatus.identityMismatch,
      );
      return LocalDeviceInfo(
        id: stored,
        displayName: existing?.displayName ?? _defaultDisplayName(platform),
        platform: existing?.platform ?? platform,
        createdAt: createdAt,
        status: SyncDeviceStatus.local,
      );
    }

    // A SQLite-only identity is not authoritative. Create a new installation
    // identity and retain the old public row as an explicit identity-loss audit.
    final id = _ids.newId();
    if (!_isUuidV4(id)) {
      throw StateError('Generated sync device identity is not a UUID v4.');
    }
    final now = _clock.now();
    await _store.writeDeviceId(id);
    await _repository.replaceLocalIdentity(
      id: id,
      displayName: _defaultDisplayName(platform),
      platform: platform,
      createdAt: now,
      displacedStatus: SyncDeviceStatus.identityLost,
    );
    return LocalDeviceInfo(
      id: id,
      displayName: _defaultDisplayName(platform),
      platform: platform,
      createdAt: now,
      status: SyncDeviceStatus.local,
    );
  }

  LocalDeviceInfo _toInfo(SyncDevice row) => LocalDeviceInfo(
    id: row.id,
    displayName: row.displayName,
    platform: row.platform,
    createdAt: row.createdAt,
    status: SyncDeviceStatus.values.firstWhere(
      (value) => value.name == row.status,
      orElse: () => SyncDeviceStatus.local,
    ),
  );

  String _defaultDisplayName(String platform) => switch (platform) {
    'windows' => 'Windows device',
    'android' => 'Android device',
    _ => 'Backlog Vault device',
  };

  bool _isUuidV4(String value) => RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  ).hasMatch(value);
}
