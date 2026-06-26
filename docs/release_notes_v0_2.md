# Backlog Vault v0.2.0 RC1

Version: `0.2.0+4`  
Tag: `v0.2.0-rc1`  
Release line: `release/v0.2`

v0.2.0-rc1 is the first sync-focused release candidate for Backlog Vault. It keeps the local-first Windows + Android app model from v0.1 and adds secure manual PC ↔ Android sync workflows without requiring an account, backend, cloud service, QR scanner, automatic discovery, or background sync.

The build number is `+4` so Android can update installations from the previous `0.1.0+3` RC in place without uninstalling or deleting local data.

## Highlights

- Deterministic sync foundation with stable local device identity, sync schema, operation log, tombstones, causal state, and canonical hashing.
- Encrypted `.vaultsync` change packages for manual file-based sync with preview, deduplication, idempotent apply, and conservative conflict handling.
- Manual `.vaultpair` pairing invitations protected by a temporary password.
- Persistent 256-bit sync group key stored only in platform secure storage.
- Group-key `.vaultsync` mode so paired devices can exchange packages without entering a password every time.
- Manual LAN sync for paired devices using host IP, port, and a short session code.
- LAN session authentication with HMAC-SHA256 proofs derived from the sync group key; the group key never travels over the network.
- LAN cover/media transfer by SHA-256 hash for app-managed cover files.
- Media validation before activation: JPEG, PNG, and WebP bytes only, with path, size, count, and hash checks.
- Conflicts are reported and skipped rather than silently overwritten.

## Existing app features carried forward

- Offline SQLite/Drift library with soft delete.
- Responsive table, gallery, and list layouts with filters, saved views, and configurable columns.
- Manual game creation/editing and detail pages.
- Notion CSV import with preview and validation.
- RAWG and IGDB metadata.
- IGDB, SteamGridDB, and local covers.
- Bulk metadata and cover workflows with preview and replacement controls.
- Plain `.vaultbackup` and encrypted `.vaultbackup.enc` backup/restore.
- Home dashboard and statistics.
- Light/dark/OLED-friendly UI.
- English and Spanish via Flutter localization.

## Sync formats

- `.vaultbackup`: complete logical backup with media, not encrypted.
- `.vaultbackup.enc`: complete encrypted backup for migration/recovery.
- `.vaultsync`: encrypted package of sync changes; not a complete backup.
- `.vaultpair`: encrypted pairing invitation carrying the sync group key for a new paired device.

## Security and privacy

- No account, backend, or cloud dependency.
- Provider API keys, Client Secrets, bearer/access tokens, secure storage, and sync group keys are excluded from backups and sync packages.
- The sync group key is random 256-bit material stored only in platform secure storage.
- LAN is treated as untrusted: library payloads are still encrypted and authenticated before transport.
- The local SQLite database and media folder are still not encrypted at rest.
- If secure storage is erased or a device leaves the group, that device must be paired again.

## Known limitations

- No QR scanner.
- No automatic discovery/mDNS.
- No cloud transport.
- No background or automatic sync.
- No advanced visual conflict-resolution UI yet.
- Standalone `.vaultsync` files do not carry media bytes; media transfer is available during paired LAN sync.
- Media cleanup/compaction for orphaned files is not implemented.
- Android packages are locally signed for personal QA, not Play Store distribution.
- Clean release screenshots are still pending.

## Artifacts

Expected local artifact names:

- `dist/BacklogVault-windows-x64-v0.2.0-rc1.zip`
- `dist/BacklogVault-android-v0.2.0-rc1.apk`

Generated `build/`, `dist/`, APK, ZIP, logs, caches, `.secure` files, keystores, and secrets must stay out of Git.

Validation status is tracked in [qa_v0_2_checklist.md](qa_v0_2_checklist.md).
