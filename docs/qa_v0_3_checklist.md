# Backlog Vault v0.3 QA checklist

Use a disposable library or temporary test database. Never use real provider credentials in screenshots, fixtures, logs, or commits.

## v0.3.0-rc1 automated validation

Target: `v0.3.0-rc1`, version `0.3.0+5`.

- [x] `flutter pub get`
- [x] `dart run build_runner build`
- [x] `flutter analyze`
- [x] `flutter test`
- [x] `flutter build windows`
- [x] `flutter build apk`
- [x] Windows ZIP generated
- [x] Android APK copied to `dist/`
- [x] Checksums generated

## QR sync smoke test with disposable data

- [ ] Settings → Sync shows QR actions in the device-connection flow.
- [ ] Pairing QR can be shown from a paired/source device.
- [ ] Pairing QR can be scanned or pasted on the receiving device.
- [ ] Pairing file fallback `.vaultpair` still works.
- [ ] Pairing QR does not expose the group key, provider credentials, library data, backups, media, or passwords in clear text.
- [ ] LAN host still shows IP, port, and short session code.
- [ ] LAN host can show a LAN connection QR.
- [ ] LAN client can scan or paste a LAN connection QR.
- [ ] LAN manual IP/port/code fallback remains visible and usable.
- [ ] LAN QR fills only connection fields and does not bypass group-key authentication.
- [ ] Scanner permission denial shows a controlled fallback on Android.
- [ ] Windows does not require a camera.

## Regression smoke test

- [ ] `.vaultsync` password mode still previews and applies safe changes.
- [ ] `.vaultsync` group mode still works for paired devices.
- [ ] LAN sync still applies safe changes idempotently.
- [ ] LAN media transfer by SHA-256 hash still resolves managed covers without broken references.
- [ ] Conflicts are reported and do not silently overwrite local data.
- [ ] Plain and encrypted backups still create successfully.
- [ ] Plain and encrypted restore create a safety backup and preserve soft-delete semantics.
- [ ] English and Spanish UI are available from Settings → Language.

## Release assertions

- [x] No discovery automático / automatic discovery is implemented.
- [x] No cloud transport is implemented.
- [x] No background sync is implemented.
- [x] No DB encryption or media encryption at rest was added.
- [x] `.vaultsync`, `.vaultpair`, LAN sync, media transfer, Drift schema, and backup schema are unchanged for this RC.
- [x] QR is a UX helper over existing encrypted pairing and LAN flows.
