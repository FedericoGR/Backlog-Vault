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
    'tool/verify_release_candidate.ps1',
    'tool/generate_final_repository_review.ps1',
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

  test('release candidate version and artifact names are canonical', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      pubspec,
      contains(RegExp(r'^version: 1\.0\.0-rc2\+7$', multiLine: true)),
    );

    final versions =
        File('lib/core/version/app_versions.dart').readAsStringSync();
    expect(versions, contains("appVersionName = '1.0.0-rc2'"));

    final common = File('tool/release_common.ps1').readAsStringSync();
    final android = File('tool/package_android.ps1').readAsStringSync();
    final windows = File('tool/package_windows.ps1').readAsStringSync();
    expect(common, contains('Get-BacklogVaultVersion'));
    expect(
      android,
      contains('BacklogVault-android-\$architecture-v\$Version.apk'),
    );
    expect(
      android,
      contains('"--target-platform", "android-arm64"'),
      reason: 'the published arm64 APK must retain the pubspec versionCode',
    );
    expect(android, contains('"arm64-v8a-split" { "arm64-split" }'));
    expect(
      windows,
      contains('BacklogVault-windows-x64-portable-v\$artifactVersion.zip'),
    );
  });
}
