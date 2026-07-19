# E4 completion report — Offline architecture refactor

Date: 2026-07-18.

## Git and scope

- Initial branch: `codex/offline-e3-simplify-product` at `366de4b`.
- E3 was fast-forwarded and pushed to `main`; canonical main became `366de4b`.
- E4 branch: `codex/offline-e4-architecture-refactor`.
- No feature, schema migration, version bump, tag, release or E5 work was
  introduced.
- E4 is intentionally not merged to `main`.

## Product invariants

- version: `0.3.0+5`;
- Drift physical schema: 6;
- export identifier: `backlog-vault-library-export`;
- export `formatVersion`: 1;
- JSON export and Notion CSV import behavior preserved;
- Sync and complex backup/restore remain absent;
- Windows and Android remain supported.

## Architecture delivered

- `app/` split into bootstrap, routing and theme.
- Feature presentation consumes application/domain only.
- `LibraryViewModel` owns table configuration, layout and saved-view commands.
- `GameFormViewModel` coordinates catalog resolution, game save, completion and
  optional cover.
- `GameDetailViewModel` coordinates progress and playthrough actions.
- `CatalogController` maps Drift catalogs to `CatalogItem`.
- `PlaythroughRepository` owns per-run CRUD.
- `BulkMetadataImportViewModel`, `MetadataSearchViewModel` and
  `MediaSearchViewModel` isolate provider workflows.
- `NotionCsvImportViewModel` coordinates picker/parser/preview/import.
- `ExternalCredentialsViewModel` exposes presence-only credential state.
- Statistics and library queries are exposed through application providers.

The selective use cases retained are justified by batch planning/application,
metadata diff/application, CSV preview/import, game form multi-repository save,
and export serialization/save coordination. No interface was added solely for
layer symmetry; existing provider/media/storage contracts remain because they
have real alternate implementations or test fakes.

## Tests and checker

- Baseline: 246 tests.
- Final: 257 tests; 11 added, 0 deleted.
- Added: five architecture rules, two credential ViewModel tests, two game form
  ViewModel tests and two media ViewModel/cancellation tests.
- Full suite result: 257/257.
- Analyze: clean.
- Architecture checker: clean.
- Existing migration, export, CSV, metadata, media, saved-view, statistics,
  settings and localization regressions remain green.

## Metrics

- `lib/`: 156 files, 154 Dart files.
- repository files: 10; service files: 2; explicit ViewModel classes: 8.
- presentation infrastructure violations: 0.
- dependencies added/removed: none.
- Main manual hotspots were reduced or kept stable; E5 retains their visual
  decomposition, documented in `docs/audit/e4/remaining_hotspots.md`.

## Final validation

- `flutter clean`: completed in 2.09 s. Windows reported that one previous
  `build/` entry was temporarily locked; the command still completed, generated
  state was recreated, and both subsequent release builds passed.
- `flutter pub get`: completed in 3.23 s; no dependency was changed.
- build_runner: completed in 61.54 s with 410 outputs; the current tool reports
  that `--delete-conflicting-outputs` is obsolete and ignores it.
- `flutter gen-l10n`: completed in 1.57 s.
- architecture checker: 5/5 in 10.81 s.
- `flutter analyze`: clean in 9.06 s.
- `flutter test`: 257/257 in 31.39 s.
- Windows release build: passed in 53.83 s; 14-file bundle, 35,667,064 bytes
  (`backlog_vault.exe`: 81,920 bytes).
- Android release build: passed in 95.57 s; APK 67,307,545 bytes, SHA-256
  `8E8BB6EECF49421401FF0A698FAD796E735E73A24F125A201A361B6AB5E7FF22`.
- secret scan: clean. No tracked or untracked APK, archive, database, log,
  keystore, certificate or environment artifact was found. The 29 generic
  keyword matches were reviewed as secure-storage identifier constants or
  explicit test fixtures; no credential value is stored in Git.
- Windows QA: non-destructive release launch smoke passed; the process remained
  stable for eight seconds and closed normally.
- Android QA: not run. No Android target was attached (`flutter devices` only
  exposed Windows and browsers) and `adb` was unavailable in `PATH`; no install
  or device mutation was attempted.

Known non-blocking toolchain warnings remain: 35 packages have newer versions
outside current constraints, `file_picker` still applies the legacy Android
Kotlin Gradle plugin, and the Android build reports a missing Cupertino icon
font while completing successfully. None was introduced or expanded by E4.

## Remaining debt

- E5: split visual hotspots and perform final UI/comment quality pass.
- A future schema-specific decision would be required to remove duplicated
  persisted semantics; E4 only centralizes current reads/writes.
- E6: dependency, size, assets, Git history and packaging optimization.

No E5 implementation was started.
