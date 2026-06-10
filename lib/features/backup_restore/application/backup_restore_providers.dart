import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/backup_file_picker_service.dart';

final backupFilePickerServiceProvider = Provider<BackupFilePickerService>((
  ref,
) {
  return const BackupFilePickerService();
});
