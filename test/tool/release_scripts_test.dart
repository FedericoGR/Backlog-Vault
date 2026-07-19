import 'dart:io';

import 'package:test/test.dart';

void main() {
  final requiredScripts = <String>[
    'tool/build_release.ps1',
    'tool/package_windows.ps1',
    'tool/package_android.ps1',
    'tool/measure_artifacts.ps1',
    'tool/clean_workspace.ps1',
    'tool/check_repository_hygiene.ps1',
  ];

  test('release scripts are repository-relative and never install Android', () {
    for (final path in requiredScripts) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'missing $path');
      final source = file.readAsStringSync();
      expect(source, isNot(contains(RegExp(r'[A-Za-z]:\\Users\\'))));
      expect(source, isNot(contains('adb install')));
      expect(source, isNot(contains('flutter install')));
    }
  });

  test('workspace cleanup is dry-run unless Apply is explicit', () {
    final source = File('tool/clean_workspace.ps1').readAsStringSync();
    expect(source, contains(r'[switch]$Apply'));
    expect(source, contains(r'if ($Apply)'));
    expect(source, contains('No files were removed'));
  });

  test('Windows packaging validates runtime and writes a checksum', () {
    final source = File('tool/package_windows.ps1').readAsStringSync();
    expect(source, contains('ZipArchive'));
    expect(source, contains('1980, 1, 1'));
    expect(source, contains('SHA-256'));
    expect(source, contains("'.pdb'"));
  });

  test('repository hygiene scans risky binary and data extensions', () {
    final source = File('tool/check_repository_hygiene.ps1').readAsStringSync();
    for (final extension in <String>[
      '.apk',
      '.zip',
      '.db',
      '.sqlite',
      '.keystore',
      '.symbols',
    ]) {
      expect(source, contains(extension));
    }
  });

  test('root build output ignore does not hide build documentation', () {
    final source = File('.gitignore').readAsStringSync();
    expect(source, contains('/build/'));
    expect(source, isNot(contains(RegExp(r'^build/$', multiLine: true))));
    expect(File('docs/build/generated_files_policy.md').existsSync(), isTrue);
  });
}
