import 'dart:io';

import 'package:backlog_vault/core/storage/app_data_directory.dart';
import 'package:test/test.dart';

void main() {
  test('portable Windows data directory sits beside the executable', () {
    final separator = Platform.pathSeparator;
    final executable = [
      'C:',
      'Portable Apps',
      'Backlog Vault',
      'backlog_vault.exe',
    ].join(separator);

    final directory = getPortableWindowsDataDirectory(
      executablePath: executable,
    );

    expect(
      directory.path,
      [
        'C:',
        'Portable Apps',
        'Backlog Vault',
        portableUserDataDirectoryName,
      ].join(separator),
    );
  });
}
