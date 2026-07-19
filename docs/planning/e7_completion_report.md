# E7 completion report — Backlog Vault Offline v1.0.0-rc1

Date: 2026-07-19. Initial branch/commit: `main` at
`4e23c635f0c8c5b44a80e43975da35a5bf134e84`. Release branch:
`release/v1`, created directly from that baseline. `main` was not modified or
merged after branch creation.

## Release definition and commits

- Application: `1.0.0-rc1+6`; Android package `dev.backlogvault.app`.
- Drift schema: 6. JSON export format: 1.
- No obfuscation and no `--split-debug-info`.
- Android distribution: tested arm64-v8a APK plus universal fallback. The
  armeabi-v7a and x86_64 split outputs were validation-only.
- Commits before final documentation:
  - `8b42e6f chore: prepare Backlog Vault Offline v1.0.0 rc1`
  - `355de5a fix: stabilize offline release candidate`
  - `928c47a fix: preserve imported playthrough start dates`
- No feature, schema, export-format, model, provider, or dependency upgrade was
  introduced.

The final inventory reviews all 415 tracked release files in
`docs/audit/e7/final_repository_file_review.csv`. Architecture, dependency,
database, privacy, residue, risk, packaging, and documentation paths were
reviewed. Active Sync/pairing/QR/LAN/camera/complex-backup surfaces are absent;
historical names remain only where migration, privacy redaction, absence tests,
or audit history require them.

## Bugs found and fixed

1. Flutter's split-per-ABI build derived arm64 versionCode 2006. Release
   packaging now builds the published arm64-only candidate without split
   versioning, retaining the required versionCode 6; the split remains a
   validation-only output.
2. Home supplied localized count arguments in the wrong order. The ordering
   was corrected and covered by a widget regression.
3. Editing an imported playthrough with no start date defaulted the field to
   today, which could reject an otherwise valid earlier completion date. The
   dialog now preserves null for existing records and a widget regression
   covers the case.

No general refactor or backup/restore work was performed.

## Automated validation

- Release version verifier: pass (`1.0.0-rc1+6`, schema 6, export format 1,
  artifact naming contract).
- Architecture checker: 6/6.
- `dart format --output=none --set-exit-if-changed lib test`: 252 files,
  0 changed.
- `flutter analyze`: pass, no issues.
- `flutter test`: 270/270 pass.
- Targeted migration/export/import gate: 38/38 pass.
- Migration fixture: schema 5→6, ten functional tables preserved, six retired
  tables and eight indexes absent, empty `foreign_key_check`, write/read and
  schema-6 reopen pass.
- JSON export: empty and populated documents, deterministic order, UTF-8,
  parse, relations, summary, and privacy pass.
- CSV import: parsing, mapping, preview, duplicate policy, and transactional
  behavior pass.
- Windows release, universal Android release, and all three Android split
  builds: pass.
- Known non-blocking warnings: `file_picker 11.0.2` legacy KGP, false-positive
  Cupertino font warning, external `dartdoc 9.0.4`, and transient Gradle/build
  cleanup messages documented separately.

## Final artifacts

| Artifact | Bytes | SHA-256 | QA |
|---|---:|---|---|
| `dist/BacklogVault-windows-x64-v1.0.0-rc1.zip` | 15,186,708 | `65E2F4183CAC54896AE8D946AFA2B422A9BC6C699ABFA248777DAFD2849E2E67` | extracted exact ZIP; 14-file runtime allowlist; first/second launch |
| `dist/BacklogVault-android-arm64-v1.0.0-rc1.apk` | 23,920,702 | `11EF0CFC0D32200C97CD535E2494FDFBE6720A43004A65560654E5AE3A3784F2` | installed and tested physically |
| `dist/BacklogVault-android-universal-v1.0.0-rc1.apk` | 67,324,013 | `FF3CAB6BDB94B99B345F0D0FB3B6FFBA39B261F4352BA59E47B8563D73F0977D` | package/version/signature inspected; build validated |

The Windows ZIP contains only its 14 runtime files. Its two JSON files are
Flutter runtime manifests, not library exports. No source, test, symbol, log,
database, or user export is packaged. A real Windows profile was therefore
navigated read-only; its database SHA-256 remained
`4BD04D9B5FBED08CA9670211C91B5DC5689537DD50502208125CBF083F011AC2`.
Full visual navigation was completed on the immediately preceding candidate;
the exact final ZIP then passed extraction plus first/second launch. The only
intervening source fix affects the playthrough dialog and is covered by its
widget regression.

The three final files are preserved locally under ignored `dist/`. Later
Android validation rebuilds produced the same package/version/ABI contract but
different bytes because APK signing/container metadata is not deterministic;
they did not replace the exact physically tested candidates.

## Android physical QA

- Device: Motorola edge 40 pro, Android 16/API 36, `arm64-v8a`, device
  `ZY22GT5X4X`, Android user 0.
- Before: `0.3.0+5`; after: `1.0.0-rc1+6`.
- `firstInstallTime`: `2026-06-27 14:09:52`, preserved.
- Final `lastUpdateTime`: `2026-07-19 20:23:11`.
- In-place command: `adb install -r` on the exact arm64 candidate; result
  `Success`. No uninstall, clear, downgrade, root, or private-DB access.
- Signing certificate SHA-256 remained
  `D67FF1C782DBA5151EBE841205268DDDFF9606108364BED952878102654F2343`.
- Declared permissions are Internet and the app-scoped dynamic-receiver
  permission. Camera is absent. No removed transport service is packaged or
  started.
- First final open: cold start completed in 379 ms with no crash, white screen,
  loop, Drift error, missing table, foreign-key error, camera request, socket,
  or Sync service.
- Second final open after force-stop: cold start completed in 301 ms; data,
  saved view, language, and system theme remained available with no error.

The initial profile was confirmed empty, so the external synthetic QA dataset
was used: four games, four library entries, two imported playthroughs, mixed
states/platforms/genres, Unicode, dates, ratings, hours, and synthetic notes.
Its CSV is 633 bytes with SHA-256
`9FA5E8AD49232851EF3D4DC6D8D38DEBC2C2AAD73063572A8EF967BE752B3A08`;
the external checklist is 694 bytes with SHA-256
`54304E66109D8A6250A039F8B7ADD52AF235EB487280B9F44FC9B5DCC4B8ABCC`.
Nothing from that folder is tracked.

CSV preview/import, table/list/gallery, search, filtering, ordering, the saved
view `QA_Completados`, detail navigation, a synthetic game edit, existing
playthrough edit, new playthrough creation, persistence, and statistics were
validated. Final visible statistics were four games and 17.0 hours. Optional
metadata and cover actions without credentials returned controlled localized
guidance and did not crash.

Settings retained language, JSON export, optional provider credentials, and
the Offline surface. It contains no Sync, pairing, QR, LAN, complex backup, or
restore. Theme follows the operating-system setting; no separate appearance
selector exists. Version was verified from package metadata because Settings
has no version label. No feature was added to change either limitation.

The exported synthetic JSON was saved outside the repository, is 16,114 bytes,
and has SHA-256
`F9874A4BF331EA487220A567B4DF2F20421A67DBE3908B10CC6662C894588C3B`.
It parsed as `backlog-vault-library-export`, formatVersion 1, with 4 games,
4 entries, 3 playthroughs, 1 saved view, complete catalog relations, Unicode,
and zero orphan relations. It contains no credential, personal path, image
bytes, database, or retired transport payload.

Filtered logs from the final first and second opens contain zero blocking or
relevant warning matches for AndroidRuntime/FATAL, FlutterError, overflow,
Drift/database/foreign key/missing table, secure storage, file picker,
permission, socket, Sync, or camera. Synthetic QA data remains on the device
by design; no destructive cleanup was used.

## Release, privacy, and publication

Repository hygiene, artifact, personal-path, and strong-secret scans pass.
No APK, ZIP, database, log, environment file, signing material, external CSV,
or exported JSON is tracked. `dist/` is ignored. The external E6 safety bundle
was preserved and reverified at SHA-256
`2D84A094720ED4431C86ABE11A6DC39B27913DB6C396BF4B8833818C2A310DBF`.

The annotated tag `v1.0.0-rc1` is reserved for the final documentation commit
on `release/v1`; the branch and tag are to be pushed without merging `main`.
The public notes and exact three-asset set are ready for a GitHub prerelease.
GitHub CLI is not installed, so no tool will be installed and no credential
will be invented for automatic publication.

Android release builds use the existing compatible debug signing identity.
That allowed the required in-place update, but it is unsuitable as an
unreviewed public production signing policy. Before stable `v1.0.0`, select a
protected production signing approach and explicitly plan how existing
debug-signed installations preserve/export their local data when changing
keys. Stable promotion should otherwise reuse this RC commit, repeat the
affected platform smoke, produce new checksums, and only then merge/tag.
