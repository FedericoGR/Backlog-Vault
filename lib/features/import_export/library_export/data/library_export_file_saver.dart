import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final libraryExportFileSaverProvider = Provider<LibraryExportFileSaver>((ref) {
  return const FilePickerLibraryExportFileSaver();
});

abstract interface class LibraryExportFileSaver {
  Future<String?> save({required String fileName, required Uint8List bytes});
}

typedef SaveLibraryExportFile =
    Future<String?> Function({
      required String fileName,
      required Uint8List bytes,
    });

class FilePickerLibraryExportFileSaver implements LibraryExportFileSaver {
  const FilePickerLibraryExportFileSaver({
    SaveLibraryExportFile saveFile = _saveWithFilePicker,
  }) : _saveFile = saveFile;

  final SaveLibraryExportFile _saveFile;

  @override
  Future<String?> save({required String fileName, required Uint8List bytes}) {
    return _saveFile(fileName: fileName, bytes: bytes);
  }
}

Future<String?> _saveWithFilePicker({
  required String fileName,
  required Uint8List bytes,
}) {
  return FilePicker.saveFile(
    dialogTitle: 'Backlog Vault',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: const ['json'],
    bytes: bytes,
    lockParentWindow: true,
  );
}
