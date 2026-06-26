# Backlog Vault v0.2 QA checklist

Use a disposable library or temporary test database. Never use real provider credentials in screenshots, fixtures, logs, or commits.

## v0.2.0-rc1 automated validation

Target: `v0.2.0-rc1`, version `0.2.0+4`.

Update these boxes only from the final validation run.

- [x] `flutter pub get`
- [x] `dart run build_runner build`
- [x] `flutter analyze`
- [x] `flutter test`
- [x] `flutter build windows`
- [x] `flutter build apk`
- [x] Windows ZIP generated
- [x] Android APK copied to `dist/`
- [x] Secret and artifact scan

## Core app smoke test

- [ ] App opens from a Windows release build without touching production data unexpectedly.
- [ ] APK installs or updates with the expected local signing identity.
- [ ] English and Spanish UI are available from Settings → Language.
- [ ] Light, dark, and OLED-friendly theme behavior still works.
- [ ] Create, edit, detail, table, gallery, list, filters, columns, and saved views still work.
- [ ] Home and Statistics render with populated and empty libraries.
- [ ] Notion CSV import reaches preview and result.
- [ ] RAWG/IGDB metadata dialogs work with test credentials only.
- [ ] IGDB/SteamGridDB/local cover flows work with test data only.
- [ ] Bulk metadata/cover import preserves protected personal fields.
- [ ] Plain and encrypted backups create successfully.
- [ ] Plain and encrypted restore create a safety backup and do not hard-delete media.
- [ ] Wrong encrypted-backup password fails without modifying data.

## Sync smoke test with disposable data

- [ ] `.vaultsync` password-mode export/import previews and applies safe changes.
- [ ] `.vaultpair` invitation creates a paired group on a second disposable install.
- [ ] Group-key `.vaultsync` works without asking for a password when the key exists.
- [ ] Leave group removes the local group key without deleting library data.
- [ ] LAN host shows IP, port, and short session code.
- [ ] LAN client connects with host/IP, port, and session code.
- [ ] LAN sync reports sent, received, applied, skipped, conflicts, pending media, and media byte counts.
- [ ] Same-field conflicts are reported and do not overwrite local data.
- [ ] Managed cover files transfer by SHA-256 hash over LAN.
- [ ] Corrupt, oversized, wrong-hash, unsupported, unknown, or unsafe-path media remains pending and does not create a broken selected cover.
- [ ] Repeating LAN sync does not duplicate changes or media assets.

## Release assertions

- [x] No account or backend is required.
- [x] No cloud transport is implemented.
- [x] No QR scanner is implemented.
- [x] No automatic discovery is implemented.
- [x] No background sync is implemented.
- [x] Provider credentials do not travel in backups or sync packages.
- [x] Sync group keys live in secure storage, not SQLite or backups.
- [x] Local DB and media are documented as not encrypted at rest.
- [x] Restore keeps soft-delete semantics and does not hard-delete media.
- [x] LAN media transfer is limited to app-managed cover/media files.
