# Backlog Vault Offline v1.0.0-rc1 QA checklist

Target: `v1.0.0-rc1`, app `1.0.0-rc1+6`, Drift schema 6, export format 1.
Only mark an item after testing the exact release artifact. Never put real
credentials, databases, logs, exports, or personal notes in the repository.

## Automated gate

- [ ] Release version verifier.
- [ ] Architecture checker (6/6).
- [ ] `flutter analyze` clean.
- [ ] Complete Flutter test suite.
- [ ] Schema 5→6, schema-6 reopen, write/read, and `foreign_key_check` tests.
- [ ] Empty and populated export, parsing, determinism, and privacy tests.
- [ ] CSV parsing, mapping, preview, duplicates, and transactional import tests.
- [ ] Windows release build and exact ZIP packaging.
- [ ] Universal and split Android release builds.
- [ ] Repository hygiene, secret, and artifact scans.

## Windows artifact

- [ ] Exact published ZIP extracted outside the repository.
- [ ] Runtime allowlist complete; no sources, tests, symbols, logs, DB, or export.
- [ ] First open, close, and second open without crash.
- [ ] Home, Library, views, filters, game detail, Statistics, and Settings open.
- [ ] Mutating operations are tested only against a disposable profile.
- [ ] Responsive resize and EN/ES/OLED preferences show no overflow.

## Android arm64 artifact

- [ ] Motorola edge 40 pro reports `arm64-v8a` and remains authorized.
- [ ] Installed in place with `adb install -r`; no uninstall, clear, or downgrade.
- [ ] Package `dev.backlogvault.app`, versionName `1.0.0-rc1`, versionCode 6.
- [ ] `firstInstallTime` preserved and `lastUpdateTime` advanced.
- [ ] No declared camera permission or removed transport service.
- [ ] First open has no crash, white screen, loop, or Drift error.
- [ ] Library and existing data remain intact.
- [ ] Empty profile: synthetic CSV preview/import and counts validated.
- [ ] Search, filters, ordering, layouts, and one saved view validated.
- [ ] Synthetic game detail/edit and playthrough create/edit persist.
- [ ] Statistics reflect the synthetic dataset.
- [ ] Optional metadata/cover surfaces handle missing credentials safely.
- [ ] Settings exposes appearance, language, export, and provider credentials.
- [ ] Settings has no device transport, pairing, QR, LAN, backup, or restore.
- [ ] JSON export parsed off-device; Unicode, relations, counts, and privacy pass.
- [ ] Force-stop and second open preserve data and preferences without errors.
- [ ] Filtered Android logs contain no blocking error or functional residue.

## Release publication

- [ ] SHA-256 and sizes recorded for exactly three published artifacts.
- [ ] Final docs and completion report match observed evidence.
- [ ] `release/v1` clean, pushed, and tagged `v1.0.0-rc1`.
- [ ] `main` remains at the pre-release baseline.
- [ ] GitHub release is a prerelease, not latest stable.
