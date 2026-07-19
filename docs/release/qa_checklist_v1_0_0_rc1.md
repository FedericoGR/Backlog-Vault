# Backlog Vault Offline v1.0.0-rc1 QA checklist

Target: `v1.0.0-rc1`, app `1.0.0-rc1+6`, Drift schema 6, export format 1.
Only mark an item after testing the exact release artifact. Never put real
credentials, databases, logs, exports, or personal notes in the repository.

## Automated gate

- [x] Release version verifier.
- [x] Architecture checker (6/6).
- [x] `flutter analyze` clean.
- [x] Complete Flutter test suite (270/270).
- [x] Schema 5→6, schema-6 reopen, write/read, and `foreign_key_check` tests.
- [x] Empty and populated export, parsing, determinism, and privacy tests.
- [x] CSV parsing, mapping, preview, duplicates, and transactional import tests.
- [x] Windows release build and exact ZIP packaging.
- [x] Universal and split Android release builds.
- [x] Repository hygiene, secret, and artifact scans.

## Windows artifact

- [x] Exact published ZIP extracted outside the repository.
- [x] Runtime allowlist complete; no sources, tests, symbols, logs, DB, or export.
- [x] First open, close, and second open without crash.
- [x] Home, Library, views, filters, game detail, Statistics, and Settings open.
- [x] Mutating operations covered by tests; the real Windows profile remained read-only.
- [x] Responsive resize and system-selected light/dark behavior show no overflow.

## Android arm64 artifact

- [x] Motorola edge 40 pro reports `arm64-v8a` and remains authorized.
- [x] Installed in place with `adb install -r`; no uninstall, clear, or downgrade.
- [x] Package `dev.backlogvault.app`, versionName `1.0.0-rc1`, versionCode 6.
- [x] `firstInstallTime` preserved and `lastUpdateTime` advanced.
- [x] No declared camera permission or removed transport service.
- [x] First open has no crash, white screen, loop, or Drift error.
- [x] Library and existing data remain intact.
- [x] Empty profile: synthetic CSV preview/import and counts validated.
- [x] Search, filters, ordering, layouts, and one saved view validated.
- [x] Synthetic game detail/edit and playthrough create/edit persist.
- [x] Statistics reflect the synthetic dataset.
- [x] Optional metadata/cover surfaces handle missing credentials safely.
- [x] Settings exposes language, export, provider credentials, and offline status.
- [x] System theme behavior works; no separate appearance selector is implemented.
- [x] Package metadata reports the version; Settings has no version label.
- [x] Settings has no device transport, pairing, QR, LAN, backup, or restore.
- [x] JSON export parsed off-device; Unicode, relations, counts, and privacy pass.
- [x] Force-stop and second open preserve data and preferences without errors.
- [x] Filtered Android logs contain no blocking error or functional residue.

## Release publication

- [x] SHA-256 and sizes recorded for exactly three release candidates.
- [x] Final docs and completion report match observed evidence.
- [x] `release/v1` prepared for push and annotated tag `v1.0.0-rc1`.
- [x] `main` remains at the pre-release baseline.
- [x] Manual release body and exact asset set are prepared.
- [ ] GitHub prerelease published (GitHub CLI is unavailable in this environment).
