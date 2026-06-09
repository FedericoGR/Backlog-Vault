import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class PickedCsvFile {
  const PickedCsvFile({
    required this.name,
    required this.sizeBytes,
    required this.bytes,
  });

  final String name;
  final int sizeBytes;
  final Uint8List bytes;
}

class CsvFilePickerService {
  const CsvFilePickerService();

  Future<PickedCsvFile?> pickCsvFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final bytes = file.bytes ?? await _readPath(file.path);
    if (bytes == null) {
      throw const FileSystemException(
        'No se pudo leer el archivo seleccionado.',
      );
    }

    return PickedCsvFile(name: file.name, sizeBytes: file.size, bytes: bytes);
  }

  Future<Uint8List?> _readPath(String? path) async {
    if (path == null) return null;
    return File(path).readAsBytes();
  }
}
