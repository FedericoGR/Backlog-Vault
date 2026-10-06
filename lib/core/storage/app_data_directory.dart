import 'dart:io';

import 'package:path_provider/path_provider.dart';

const portableUserDataDirectoryName = 'userdata';

/// Returns the directory that owns every persistent Backlog Vault file.
///
/// Windows builds are intentionally portable: data lives beside the executable
/// so moving the extracted application folder also moves the user's library.
/// Other platforms keep using their OS-managed application-support directory.
Future<Directory> getBacklogVaultDataDirectory() async {
  if (Platform.isWindows) {
    return getPortableWindowsDataDirectory();
  }
  return getApplicationSupportDirectory();
}

Directory getPortableWindowsDataDirectory({String? executablePath}) {
  final executable = File(executablePath ?? Platform.resolvedExecutable);
  return Directory(
    '${executable.parent.path}${Platform.pathSeparator}'
    '$portableUserDataDirectoryName',
  );
}
