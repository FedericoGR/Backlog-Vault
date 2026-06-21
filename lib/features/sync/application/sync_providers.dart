import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/encrypted_sync_package_codec.dart';
import '../data/sync_change_applier.dart';
import '../data/sync_change_tracking.dart';
import '../data/sync_conflict_detector.dart';
import '../data/sync_device_identity.dart';
import '../data/sync_package_builder.dart';
import '../data/sync_package_file_service.dart';
import '../data/sync_package_service.dart';
import '../domain/sync_models.dart';

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
  );
});

final syncPackageFileServiceProvider = Provider<SyncPackageFileService>((ref) {
  return const SyncPackageFileService();
});
