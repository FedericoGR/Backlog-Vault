# E6 size baseline before cleanup

Measured on 2026-07-19 from `codex/offline-e6-size-cleanup` at `323e533`,
after the E5 fast-forward and before removing any generated output, dependency,
asset, branch, or source file. No Android device was connected or used.

## Repository and workspace

| Metric | Files | Bytes |
|---|---:|---:|
| Complete repository directory | 8,513 | 2,499,850,391 |
| Working tree without `.git` | 7,961 | 2,497,972,153 |
| `.git` | 552 | 1,878,238 |
| Tracked files | 384 | 2,500,319 |
| Ignored/generated files | 7,582 | 2,495,471,834 |
| Untracked, non-ignored files | 0 | 0 |

The source is 0.10% of the workspace. Generated and ignored files account for
99.90%, so deleting source or rewriting history would be the wrong lever.

| Path | Files | Bytes |
|---|---:|---:|
| `lib/` | 186 | 1,395,339 |
| `test/` | 87 | 352,246 |
| `docs/` | 57 | 567,805 |
| `assets/` | 0 | 0 |
| `android/` | 44 | 10,503,425 |
| `windows/` | 65 | 273,512,614 |
| `tool/` | 1 | 2,742 |
| `.dart_tool/` | 648 | 429,127,612 |
| `build/` | 6,828 | 1,474,477,854 |
| `dist/` | 20 | 307,920,715 |
| `android/.gradle/` | 18 | 10,292,136 |
| `windows/flutter/ephemeral/` | 47 | 273,443,045 |
| `third_party/` | 8 | 51,665 |

## Git

`git count-objects -vH` reported 460 loose objects / 579.51 KiB and 1,777
packed objects / 1.10 MiB across 11 packs, with no garbage. Every local and
remote-tracking branch was already an ancestor of `main`; the E6 branch was
initially identical to `main`.

The top 50 tracked files and top 50 reachable historical blobs were inspected.
The current largest files are generated Drift (`343,125` bytes), the preserved
E1 inventory (`247,880` bytes), generated localization (`105,900` bytes), and
tests/source. The largest reachable historical blob is generated Drift at
`576,835` bytes. No APK, ZIP, DLL, EXE, database, keystore, or backup is tracked
in reachable history. Rewriting history has no material benefit.

## Release artifacts before E6 changes

| Artifact | Files | Bytes | SHA-256 |
|---|---:|---:|---|
| Windows Release folder | 15 | 35,667,270 | n/a (directory) |
| Windows baseline ZIP | 15 runtime files | 15,186,459 | `4666D64EF5C7EF1CD6CDBD37FACE6A46CD6F3EBBD77DD2045B73A30DD0BF9062` |
| Android universal APK | 1 | 67,324,009 | `4B980D24F4222143EF3D448880944C95894AE280175D0A0776EEDFD0DB4345EE` |
| Android armeabi-v7a APK | 1 | 21,382,540 | `6FE64E44E1877A88F85A3146BE9695AAEA74F45F86A20B46F45E7A25EDEC1660` |
| Android arm64-v8a APK | 1 | 23,697,690 | `A02F7C8978C86E322DF1A80CC94DB36A57451BBA9E3D163C3A00BB01AE52093D` |
| Android x86_64 APK | 1 | 25,134,447 | `F597E86A16A87DCDE9AC22E0B40CA8BAC4F832CF66E3FE075F4E20C1C6FA219C` |

The 206-byte `native_assets.json` explains the difference between the complete
15-file Windows folder measured here and the earlier 14-file E5 inventory.
It is generated runtime metadata and is retained.

### Windows composition

`flutter_windows.dll` is 21,284,352 bytes, `data/app.so` 9,749,392,
`sqlite3.dll` 1,667,072, Material Icons 1,645,184, `icudtl.dat` 862,304,
the secure-storage DLL 150,528, `backlog_vault.exe` 81,920, and `dartjni.dll`
72,192. The remaining shader/manifests/notices total less than 155 KiB. No
PDB, LIB, EXP, log, cache, or source file is in the Release folder.

### Android composition

The universal APK has 437 ZIP entries. Its 15 native libraries occupy
65,753,576 compressed bytes: Flutter engine, Dart AOT application, SQLite,
Dart JNI, and the DataStore shared counter across three ABIs. `classes.dex` is
1,897,888 bytes uncompressed; Flutter assets are 167,245 bytes uncompressed;
Android resources are 220,783 bytes. No scanner, barcode, Barhopper, ML Kit,
camera asset, or Sync/LAN component remains.

Official arm64 size analysis reports an approximately 8 MiB decompressed Dart
AOT symbol budget. The largest packages are Flutter (~3 MiB), Backlog Vault
(981 KiB), localizations (287 KiB), Drift (177 KiB), `intl` (107 KiB),
Riverpod (97 KiB), and `go_router` (77 KiB). The report and experiment symbols
are outside Git at `Backlog Vault Backups/e6-size-analysis/20260719-155317/`.

## Baseline conclusion

The measurable opportunities are: distribute the correct ABI, separate debug
symbols, make packaging deterministic, and remove generated workspace output.
There is no evidence supporting history rewriting, source deletion for size,
or removal of a functional native runtime file.
