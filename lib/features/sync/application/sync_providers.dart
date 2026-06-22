import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/encrypted_sync_package_codec.dart';
import '../data/encrypted_pairing_codec.dart';
import '../data/sync_change_applier.dart';
import '../data/sync_change_tracking.dart';
import '../data/sync_conflict_detector.dart';
import '../data/sync_device_identity.dart';
import '../data/sync_group_management.dart';
import '../data/sync_pairing_file_service.dart';
import '../data/sync_pairing_service.dart';
import '../data/sync_package_builder.dart';
import '../data/sync_package_file_service.dart';
import '../data/sync_package_service.dart';
import '../domain/sync_models.dart';
import '../domain/sync_pairing_models.dart';

final syncIdentityStoreProvider = Provider<SyncIdentityStore>((ref) {
  return SecureSyncIdentityStore();
});

final syncDeviceRepositoryProvider = Provider<SyncDeviceRepository>((ref) {
  return SyncDeviceRepository(ref.watch(appDatabaseProvider));
});

final syncDeviceIdentityServiceProvider = Provider<SyncDeviceIdentityService>((
  ref,
) {
  return SyncDeviceIdentityService(
    store: ref.watch(syncIdentityStoreProvider),
    repository: ref.watch(syncDeviceRepositoryProvider),
  );
});

final syncGroupKeyStoreProvider = Provider<SyncGroupKeyStore>((ref) {
  return SecureSyncGroupKeyStore();
});

final logicalLibrarySnapshotReaderProvider =
    Provider<LogicalLibrarySnapshotReader>((ref) {
      return LogicalLibrarySnapshotReader(ref.watch(appDatabaseProvider));
    });

final syncSnapshotDifferProvider = Provider<SyncSnapshotDiffer>((ref) {
  return const SyncSnapshotDiffer();
});

final syncChangeRecorderProvider = Provider<SyncChangeRecorder>((ref) {
  return SyncChangeRecorder(ref.watch(appDatabaseProvider));
});

final syncFoundationInitializerProvider = Provider<SyncFoundationInitializer>((
  ref,
) {
  return SyncFoundationInitializer(
    database: ref.watch(appDatabaseProvider),
    snapshotReader: ref.watch(logicalLibrarySnapshotReaderProvider),
    differ: ref.watch(syncSnapshotDifferProvider),
    recorder: ref.watch(syncChangeRecorderProvider),
  );
});

final syncAwareTransactionProvider = Provider<SyncAwareTransaction>((ref) {
  return SyncAwareTransaction(
    database: ref.watch(appDatabaseProvider),
    identityService: ref.watch(syncDeviceIdentityServiceProvider),
    initializer: ref.watch(syncFoundationInitializerProvider),
    snapshotReader: ref.watch(logicalLibrarySnapshotReaderProvider),
    differ: ref.watch(syncSnapshotDifferProvider),
    recorder: ref.watch(syncChangeRecorderProvider),
  );
});

final syncFoundationReadyProvider = FutureProvider<LocalDeviceInfo>((
  ref,
) async {
  final device =
      await ref.watch(syncDeviceIdentityServiceProvider).ensureIdentity();
  await ref.watch(syncFoundationInitializerProvider).initialize(device);
  return device;
});

final syncGroupManagerProvider = Provider<SyncGroupManager>((ref) {
  return SyncGroupManager(
    database: ref.watch(appDatabaseProvider),
    keyStore: ref.watch(syncGroupKeyStoreProvider),
    identityService: ref.watch(syncDeviceIdentityServiceProvider),
    initializer: ref.watch(syncFoundationInitializerProvider),
  );
});

final syncPairingStateProvider = FutureProvider<SyncPairingState>((ref) {
  return ref.watch(syncGroupManagerProvider).state();
});

final encryptedPairingCodecProvider = Provider<EncryptedPairingCodec>((ref) {
  return EncryptedPairingCodec();
});

final syncPairingServiceProvider = Provider<SyncPairingService>((ref) {
  return SyncPairingService(
    groupManager: ref.watch(syncGroupManagerProvider),
    codec: ref.watch(encryptedPairingCodecProvider),
  );
});

final syncPairingFileServiceProvider = Provider<SyncPairingFileService>((ref) {
  return const SyncPairingFileService();
});

final encryptedSyncPackageCodecProvider = Provider<EncryptedSyncPackageCodec>((
  ref,
) {
  return EncryptedSyncPackageCodec();
});

final syncPackageBuilderProvider = Provider<SyncPackageBuilder>((ref) {
  return SyncPackageBuilder(
    database: ref.watch(appDatabaseProvider),
    identityService: ref.watch(syncDeviceIdentityServiceProvider),
    initializer: ref.watch(syncFoundationInitializerProvider),
  );
});

final syncConflictDetectorProvider = Provider<SyncConflictDetector>((ref) {
  return SyncConflictDetector(
    database: ref.watch(appDatabaseProvider),
    snapshotReader: ref.watch(logicalLibrarySnapshotReaderProvider),
  );
});

final syncChangeApplierProvider = Provider<SyncChangeApplier>((ref) {
  return SyncChangeApplier(
    database: ref.watch(appDatabaseProvider),
    transaction: ref.watch(syncAwareTransactionProvider),
    conflictDetector: ref.watch(syncConflictDetectorProvider),
  );
});

final syncPackageServiceProvider = Provider<SyncPackageService>((ref) {
  return SyncPackageService(
    builder: ref.watch(syncPackageBuilderProvider),
    codec: ref.watch(encryptedSyncPackageCodecProvider),
    conflictDetector: ref.watch(syncConflictDetectorProvider),
    changeApplier: ref.watch(syncChangeApplierProvider),
    groupKeys: ref.watch(syncGroupManagerProvider),
  );
});

final syncPackageFileServiceProvider = Provider<SyncPackageFileService>((ref) {
  return const SyncPackageFileService();
});
