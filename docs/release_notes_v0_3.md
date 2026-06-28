# Backlog Vault v0.3.0-rc1

- Version: `0.3.0+5`
- Tag: `v0.3.0-rc1`
- Release line: `release/v0.3`
- Status: release candidate / prerelease

v0.3.0-rc1 packages the QR pairing and LAN connection UX on top of the stable v0.2 sync stack. It does not change the `.vaultsync` format, `.vaultpair` format, LAN sync protocol, LAN media transfer behavior, Drift schema, or backup schema.

## Highlights

- Everything from `v0.2.0`: local-first Windows + Android app, encrypted backups, deterministic sync foundation, `.vaultsync`, `.vaultpair`, manual LAN sync, and LAN media transfer by SHA-256 hash.
- QR for pairing invitations: shows/scans/pastes an encrypted pairing invitation wrapper.
- QR for LAN connection: shows/scans/pastes host/IP, port, session code, protocol version, and public group/key identifiers.
- Manual fallback remains available everywhere: `.vaultpair` file import/export, paste text, and manual IP/port/code entry.
- Android scanner support may request camera permission only when scanning QR.
- Windows does not require a camera; it can display QR codes and use paste/manual entry.
- QR does not replace encryption and does not add discovery, cloud, background sync, or auto-sync.

## Security and privacy

- Pairing QR carries a protected invitation; the sync group key is not visible in clear text.
- LAN QR carries connection metadata only. It does not contain the sync group key, passwords, `.vaultsync` payloads, provider credentials, backups, media, or library data.
- LAN sync still relies on the existing group key, challenge/proof, and group-encrypted `.vaultsync` exchange.
- Provider API keys, Client Secrets, bearer/access tokens, secure storage, and sync group keys remain excluded from backups and sync packages.
- The local SQLite database and media folder are still not encrypted at rest.

## Known limitations

- No automatic discovery or mDNS.
- No cloud transport.
- No background or automatic sync.
- No database encryption or media encryption at rest.
- No advanced visual field-by-field conflict-resolution UI yet.
- Conflicts are reported and skipped conservatively instead of being silently overwritten.
- Android can ask for camera permission when scanning QR.
- Android packages are locally signed for personal QA, not Play Store distribution.
- Clean release screenshots are still pending.

## Artifacts

Release candidate artifact names:

- `dist/BacklogVault-windows-x64-v0.3.0-rc1.zip`
- `dist/BacklogVault-android-v0.3.0-rc1.apk`

SHA-256:

- `BacklogVault-windows-x64-v0.3.0-rc1.zip`: `C6C6F57B4F6B3F5DF40D0B82C569D3928995CEE80DBF19FDD8F0D83FE745DE6B`
- `BacklogVault-android-v0.3.0-rc1.apk`: `8C68A1CE4A4CDCC3A2DDB24634F65EE60E7E4B5FAAEE955B275B431869957953`

Generated `build/`, `dist/`, APK, ZIP, logs, caches, `.secure` files, keystores, and secrets must stay out of Git.

Validation status is tracked in [qa_v0_3_checklist.md](qa_v0_3_checklist.md).
