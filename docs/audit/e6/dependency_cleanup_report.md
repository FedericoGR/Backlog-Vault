# Dependency cleanup report

Audited on 2026-07-19 with import searches, `flutter pub deps --style=compact`,
`dart pub outdated`, generated plugin metadata, registrants, and release output.
The lock contains 133 packages. The pubspec has 16 direct runtime entries
(including the two Flutter SDK entries) and 6 direct development entries.

## Runtime dependencies

| Dependency | Productive evidence | Native/build impact | Decision |
|---|---|---|---|
| `flutter` | application and UI foundation | Flutter engine/runtime | keep |
| `flutter_localizations` | generated EN/ES delegates | Flutter SDK | keep |
| `drift` | 30 imports; DB/repositories/tests | Dart AOT + SQLite graph | keep; schema-critical |
| `drift_flutter` | database bootstrap | pulls platform DB support | keep |
| `flutter_riverpod` | 56 imports | Dart only | keep |
| `go_router` | 14 imports | Dart/Flutter only | keep |
| `intl` | 4 imports plus localization | Dart only | keep |
| `path_provider` | managed media storage | platform plugin graph/JNI | keep |
| `uuid` | ID generator | Dart only | keep |
| `file_picker` 11.0.2 | CSV, JSON save, local covers; 4 productive imports | Android plugin and Tika/Kotlin; current KGP warning | keep; latest stable, required feature |
| `csv` | Notion CSV parser | Dart only | keep |
| `data_table_2` | library table and tests | Dart/Flutter only | keep |
| `http` | 18 metadata/media imports | network code, no native plugin | keep for optional providers |
| `flutter_secure_storage` | external credential repository | Android and Windows native plugin | keep |
| `crypto` | managed-media SHA-256 | Dart only; also transitively used | keep |
| `shared_preferences` | language preference | platform plugins | keep |

All direct runtime packages have current productive consumers. E6 therefore
removes zero direct dependencies: deleting any would change a preserved feature
or platform build. This is a valid cleanup result, not a missed optimization.

## Development dependencies

`build_runner` and `drift_dev` generate the tracked Drift output;
`flutter_lints` drives analysis; `flutter_test`, `mocktail`, and `test` are all
used by the 263-test suite. All six remain. No package update is made because
E6 forbids a broad SDK/dependency update and none is required for packaging.

## Plugins

Generated metadata lists seven Android plugin records: `file_picker`, lifecycle,
secure storage, `jni`, `jni_flutter`, path provider, and shared preferences.
Six register native plugin classes; path provider selects its backend through
JNI/native assets. Windows lists five platform records, but the release builds
only secure-storage as a plugin DLL and JNI as an FFI/native-asset dependency.
All are transitively required by a retained direct dependency.

No `mobile_scanner`, QR, Barhopper, barcode, ML Kit, camera, LAN, or Sync plugin
is present. There is no unnecessary native plugin left to remove.

## Cupertino warning

`cupertino_icons` is not declared, no source/test imports it, and searches of
the direct package sources found no `CupertinoIcons` consumer. Android's icon
tree-shaker still reports a missing Cupertino font on some builds, while the
APK contains only the 12,644-byte tree-shaken Material font. Adding the full
Cupertino font would increase rather than reduce the package. The warning is
classified as a non-blocking Flutter/toolchain false positive; no dependency
or font is added.

## Updates deferred

`dart pub outdated` reports newer resolvable Drift, Riverpod, path provider,
UUID, and generator versions. `file_picker` 11.0.2 is the current stable
version; 12 is prerelease. Updates are deferred because they do not prove a
size benefit and would enlarge the regression surface. The legacy KGP warning
is recorded for E7/toolchain planning.
