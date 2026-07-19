# Official size optimization research

Research date: 2026-07-19. Only official Flutter, Android, Git, and package
maintainer sources are used for decisions.

| Source | Recommendation | Applicability and risk | E6 decision |
|---|---|---|---|
| [Flutter: measuring app size](https://docs.flutter.dev/perf/app-size) | Measure release output with `--analyze-size`; stores and ABI filtering change user download size. | Directly applicable. Analysis builds differ from normal builds, so compare like with like. | Analyze one arm64 release and retain the report outside Git. |
| [Flutter: Android deployment](https://docs.flutter.dev/deployment/android) | `--split-per-abi` avoids shipping native binaries for other CPUs. | High value for direct APK distribution; wrong ABI would make an APK unusable. | Build and checksum all three variants; recommend arm64 plus universal for E7. |
| [Flutter: Dart obfuscation](https://docs.flutter.dev/deployment/obfuscate) | `--obfuscate` requires `--split-debug-info`; preserve the matching symbols. It is not encryption or secret protection. | Increases support/storage complexity and can affect code relying on runtime names. | Measure, but do not adopt automatically. |
| [Flutter: Windows build/distribution](https://docs.flutter.dev/platform-integration/windows/building) | A ZIP needs the EXE, all release DLLs, and the complete `data` directory; Visual C++ runtime availability must also be handled. | Removing a generated runtime file can break startup. | Package an explicit, validated runtime allowlist and document the prerequisite. |
| [Android APK Analyzer](https://developer.android.com/studio/debug/apk-analyzer) | Inspect compressed/raw contributions and the merged manifest; APKs are ZIP containers. | Read-only and reproducible. | Measure ZIP entries and native libraries; do not add third-party binary compressors. |
| [Android app-size guidance](https://developer.android.com/topic/performance/reduce-apk-size) | Remove only unused resources; understand APK structure before changing packaging. | Android lint cannot prove dynamic Flutter assets unused. | Keep launcher resources; remove no asset without consumer and hash evidence. |
| [Git `gc`](https://git-scm.com/docs/git-gc) | Normal GC packs revisions and preserves referenced objects/reflogs subject to standard retention. | Safe after a verified full bundle; aggressive pruning is unnecessary. | Run normal `git gc`, never `--prune=now`, reflog expiration, or history rewriting. |
| [`file_picker` changelog](https://pub.dev/packages/file_picker/changelog) | 11.0.2 is the latest stable release; 12 is prerelease. | The installed stable still triggers Flutter's legacy-KGP warning; changing to a beta would add migration risk. | Keep pinned 11.0.2 for CSV, JSON export, and local covers; revisit with E7/toolchain compatibility evidence. |

## Experiments

The normal arm64 split is 23,697,690 bytes. A single-target analysis build is
23,920,698 bytes and is not used as a distribution comparison. A normal arm64
build with split debug information is 22,609,978 bytes, a reduction of
1,087,712 bytes (4.59%) from the ordinary split, with a 4,369,696-byte symbol
file stored externally. Adding obfuscation produces 22,478,906 bytes, only
131,072 bytes (0.58%) smaller than split-debug-info alone, and produces a
4,369,648-byte symbol file plus an ELF/DWARF warning.

Decision: `--split-debug-info` is a credible E7 option if its symbol-retention
procedure is accepted. Obfuscation is not adopted in E6: its incremental gain
is too small for the support cost and it must not be presented as security.

## ABI recommendation

The Motorola edge 40 pro class is a modern 64-bit ARM device; therefore the
E7 physical QA artifact should be `arm64-v8a`. Retain a universal APK alongside
it for simple fallback/unknown compatible devices. The three-way split remains
a reproducibility gate, not the recommended public artifact set.
