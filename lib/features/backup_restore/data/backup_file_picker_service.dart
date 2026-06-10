import 'dart:io';

import 'package:file_picker/file_picker.dart';

class BackupFilePickerService {
  const BackupFilePickerService();

  Future<String?> pickBackupPath() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['vaultbackup'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.single.path;
  }

  Future<String?> pickEncryptedBackupPath() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['enc'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.single.path;
  }

  Future<String?> pickSavePath({
    required String fileName,
    required List<String> allowedExtensions,
  }) {
    return FilePicker.saveFile(
      dialogTitle: 'Guardar archivo',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
  }

  Future<List<int>> readBytes(String path) {
    return File(path).readAsBytes();
  }

  Future<void> writeBytes(String path, List<int> bytes) async {
    await File(path).writeAsBytes(bytes, flush: true);
  }
}
