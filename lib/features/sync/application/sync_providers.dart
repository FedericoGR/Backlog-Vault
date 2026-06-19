import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../data/sync_change_tracking.dart';
import '../data/sync_device_identity.dart';
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
