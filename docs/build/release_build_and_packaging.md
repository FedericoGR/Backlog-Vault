# Release build and packaging

E6 provides repository-relative PowerShell scripts for Windows and Android.
They read `version` from `pubspec.yaml`, fail on command errors, never install
an APK, and keep all generated artifacts under ignored `build/` or `dist/`.

## Prerequisites

- Flutter 3.44.1 stable / Dart 3.12.1;
- Android SDK 36 for Android builds;
- Visual Studio Build Tools 2022 and Windows SDK for Windows builds;
- no external compressor is required.

There is no GitHub Actions workflow in the repository as of E6. The commands
below are the canonical CI-equivalent gate; no Sync job or release-publishing
automation exists.

## Build

Build both release platforms from clean generated state:

```powershell
.\tool\build_release.ps1
```

Use `-Target Windows`, `Android`, or `AndroidSplits` for a focused build.
`-SkipClean` and `-SkipCodeGeneration` are intended only when the caller has
already completed those exact steps in the same gate.

## Windows portable ZIP

```powershell
.\tool\package_windows.ps1
```

By default the script cleans, resolves packages, and creates a Windows release
build. `-SkipBuild` packages a release folder already validated in the current
gate. The ZIP contains exactly:

- `backlog_vault.exe`;
- every root release DLL;
- generated `native_assets.json` when present;
- the complete `data/` directory.

PDB, LIB, EXP, OBJ, logs, source, cache, and build intermediates fail
validation. Entries are sorted and receive a fixed ZIP timestamp; identical
release input therefore produces the same SHA-256. A sibling `.sha256` file is
written in `dist/`. The script validates entry count and forbidden extensions
before reporting success.

Flutter's Windows deployment documentation also requires a compatible Visual
C++ runtime. The current personal machines provide it through the installed
runtime/toolchain; a future public installer must either state that prerequisite
or bundle the officially redistributable runtime files.

## Android APKs

```powershell
.\tool\package_android.ps1
```

Default mode builds and packages universal plus `arm64-v8a`. Other modes are
`Universal`, `Split`, and `All`. `All` emits universal, armeabi-v7a, arm64-v8a,
and x86_64 APKs. The script creates a JSON manifest and SHA-256 list, but does
not call ADB or Flutter install.

E7 recommendation: physically validate and publish the arm64 APK for the
Motorola edge 40 pro, retaining universal as the simplest fallback. The other
splits remain build gates unless an actual supported device requires them.

## Symbols and obfuscation

E6 measured `--split-debug-info` and `--obfuscate` experimentally outside the
repository. Split debug information saves about 4.6% on arm64 but requires the
matching symbol file for every crash. Obfuscation saves only another 0.58% and
is not security. Neither option is enabled by the packaging script in E6;
adoption requires an explicit E7 retention/support decision.

## Measurement and hygiene

```powershell
.\tool\measure_artifacts.ps1
.\tool\check_repository_hygiene.ps1
.\tool\clean_workspace.ps1
```

`measure_artifacts.ps1` prints sizes and hashes and can write ignored JSON with
`-OutputJson dist/measurements.json`. The hygiene check fails on tracked
packages, local data, signing material, strong secret patterns, or personal
paths in scripts. Cleanup is dry-run until `-Apply` is supplied.

## Gate sequence

```powershell
flutter clean
flutter pub get
flutter gen-l10n
dart run build_runner build
flutter test test/architecture/offline_architecture_test.dart
flutter analyze
flutter test
flutter build windows --release
flutter build apk --release
flutter build apk --release --split-per-abi
.\tool\package_windows.ps1 -SkipBuild
.\tool\check_repository_hygiene.ps1
git diff --check
```

Extract the Windows ZIP to a clean directory outside the repository and run a
short launch/close smoke without user interaction. Preserve real AppData: if a
read-only launch cannot be established safely, record that limitation instead
of inventing a disposable profile or deleting application data.
