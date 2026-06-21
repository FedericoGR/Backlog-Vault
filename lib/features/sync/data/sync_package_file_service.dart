import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../domain/sync_package_models.dart';

class SyncPackageFileService {
  const SyncPackageFileService();

  Future<String?> pickImportPath() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [syncPackageExtension],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.single.path;
  }

  Future<String?> pickSavePath({
    required String fileName,
    required String dialogTitle,
  }) {
    return FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const [syncPackageExtension],
    );
  }

  Future<List<int>> readBytes(String path) => File(path).readAsBytes();

  Future<void> writeBytes(String path, List<int> bytes) async {
    await File(path).writeAsBytes(bytes, flush: true);
  }
}
