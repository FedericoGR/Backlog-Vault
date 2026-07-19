# E6 completion report — Offline workspace and package cleanup

Date: 2026-07-19. Version remains `0.3.0+5`; Drift schema remains 6 and library
export remains format 1. E6 adds no product feature and performs no Android
installation or physical-device QA.

## Branch and recovery boundary

- E5 `323e533` was fast-forwarded to `main`, validated, and pushed before E6.
- E6 branch: `codex/offline-e6-size-cleanup`, created from `323e533`.
- Full verified backup before branch deletion:
  `Backlog Vault Backups/pre-e6-branch-consolidation/20260719-154735/`.
- Bundle: `backlog-vault-pre-e6-consolidation-20260719-154735.bundle`,
  1,028,633 bytes, SHA-256
  `2D84A094720ED4431C86ABE11A6DC39B27913DB6C396BF4B8833818C2A310DBF`.
- Verification: complete history, 38 refs, all six historical tags included;
  the earlier E1 bundle is untouched.

All local and origin branch tips were proved ancestors of `main` with zero
unique commits before E6 diverged. Deletion is deferred until E6 is on and
pushed from `main`; results are appended after that operation. No rebase,
force-push, history rewrite, tag creation, tag deletion, or release occurs.

## Audits and implementation

- Direct dependencies: 16 runtime entries (including two Flutter SDK entries)
  plus 6 development entries; all retained with productive consumers.
- Lock graph: 133 packages.
- Plugin records: 7 Android and 5 Windows; all required transitively or
  directly. Windows release compiles secure storage plus JNI/native assets.
- Source assets: five Android launcher PNGs (4,181 bytes) and one Windows ICO
  (33,772 bytes); no custom Flutter asset directory or font.
- Removed tracked product files, tests, dependencies, plugins, and assets: 0.
- Added/replaced release tooling: clean aggregate build, deterministic Windows
  package, Android universal/split packaging, artifact measurement, workspace
  cleanup, repository hygiene, and shared safety helpers.
- Added five release-script regression tests. Suite total is 268.
- `.gitignore` now anchors root generated directories and excludes packages,
  symbols, local data, exports, signing material, logs, and secrets without
  hiding `docs/build/`.

## Artifact results

| Artifact | Bytes | SHA-256 |
|---|---:|---|
| Windows Release folder | 35,667,064 / 14 files | directory |
| Windows deterministic ZIP | 15,186,576 | `AB19AD4EFF549E14D151E0DCEA3767C25F643FEAF7BC644578A658A00C067D77` |
| Android universal | 67,324,009 | `5CC486EE14BDAADEF5DA71B6D37D6776410F21EA7E15F2852066B8C5E913C6FB` |
| Android arm64-v8a | 23,697,690 | checksum manifest generated; final value refreshed post-merge |
| Android armeabi-v7a | 21,382,540 | checksum manifest generated; final value refreshed post-merge |
| Android x86_64 | 25,134,447 | checksum manifest generated; final value refreshed post-merge |

The Windows ZIP was produced twice from identical release input and both size
and hash matched. It excludes PDB, LIB, EXP, object files, logs, sources,
caches, databases, exports, symbols, and old packages.

## Clean ZIP smoke

The final ZIP was extracted into a fresh directory under the Windows temporary
folder, outside the repository. The 14-file package launched and remained
running during the observation window. Because the hidden window did not exit
within the first `CloseMainWindow()` wait, a standard `WM_CLOSE` message was
posted to its top-level windows; the application then exited normally without
process termination. The temporary extraction was removed.

The real Windows SQLite file retained its exact 2,084,864-byte length,
`2026-07-19T02:57:01.6893086Z` write time, and SHA-256
`4BD04D9B5FBED08CA9670211C91B5DC5689537DD50502208125CBF083F011AC2`.
No WAL, SHM, or preferences file was created, and the secure-storage file kept
its original length and timestamp. The smoke therefore confirms package
completeness without modifying real data.

## Validation evidence

- clean bootstrap: `flutter clean`, `flutter pub get`, localization generation,
  and Drift/build-runner generation passed;
- architecture checker: 6/6;
- `flutter analyze`: clean;
- `flutter test`: 268/268;
- Windows release build: passed;
- universal and all three split APK builds: passed;
- PowerShell parser: all release scripts passed;
- deterministic package and clean ZIP smoke: passed;
- repository hygiene/strong-secret scan: passed;
- `git diff --check`: passed (only Windows line-ending notices);
- generated workspace cleanup: passed after stopping tooling and using
  `flutter clean` for a transient locked Gradle lint cache;
- Android device, ADB, APK install, and E7 work: not used or started.

Measured final-gate times were 17.25 seconds for analysis, 36.17 seconds for
268 tests, 82.57 seconds for the post-clean Windows build, 163.83 seconds for
the successful universal APK build, and 39.84 seconds for all split APKs.

## Warnings and incidents

`file_picker 11.0.2` remains the latest stable version and emits Flutter's
legacy Kotlin Gradle Plugin warning. A missing-Cupertino-font warning is a
toolchain false positive: the package is not declared or imported, and the APK
contains only the 12,644-byte tree-shaken Material font. Both are non-blocking.

The first universal APK attempt failed before output because Windows held a
generated Android lint-cache JAR open. After stopping the Gradle daemon and
running `flutter clean`, the single controlled retry passed. The same cache
briefly blocked the final cleanup; the reviewed fallback (`flutter clean`, then
the cleanup allowlist) removed all generated output. No source, external data,
or Android installation was involved.

## Merge status

E6 merge, branch deletion, normal Git GC, final source-only metrics, and pushes
are recorded in the final documentation update after the post-merge gate.
