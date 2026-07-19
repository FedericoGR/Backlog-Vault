import 'package:file_picker/file_picker.dart';

class LocalCoverPickerService {
  const LocalCoverPickerService();

  /// Returns null when the user cancels the native picker.
  Future<String?> pickImagePath() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: false,
    );
    final path = result?.files.single.path?.trim();
    return path == null || path.isEmpty ? null : path;
  }
}
