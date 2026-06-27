# Backlog Vault

Backlog Vault is an offline-first videogame backlog manager for Windows and Android. It keeps your library, personal notes, playthroughs, metadata, and covers on your own device. There is no account, backend, or automatic cloud sync.

> Spanish documentation: [README.es.md](README.es.md)

Current stable release: `v0.2.0` (`0.2.0+4`).

## What it does

- Library views: responsive table, gallery, and list.
- Search, advanced filters, sorting, configurable columns, and saved views.
- Manual game creation and editing with soft-delete behavior.
- Notion CSV import with mapping, preview, duplicate detection, and validation.
- Optional metadata from RAWG and IGDB.
- Optional covers from IGDB and SteamGridDB, plus local image import.
- Bulk metadata and cover matching with explicit preview and replacement controls.
- Local media storage using relative paths.
- Regular `.vaultbackup` and encrypted `.vaultbackup.enc` backups.
- Password-encrypted `.vaultsync` change packages with preview, deduplication, and conservative conflict handling.
- Password-encrypted `.vaultpair` invitations for manual device pairing and reusable group-key `.vaultsync` packages.
- Manual local-network sync for paired devices using a temporary host/client session.
- QR helpers for pairing invitations and LAN connection details, with manual file/text/IP fallback.
- Conservative backup restore with an automatic pre-restore backup.
- Home dashboard and library statistics.
- System, light, dark, and OLED-friendly UI behavior.
- English and Spanish, with a per-device language selector.

## Local-first privacy model

- No login and no Backlog Vault backend.
- The SQLite database and local media remain on each device.
- The local database and media are **not encrypted at rest yet**.
- Encrypted backups are available and should be used when a backup leaves the device.
- Provider credentials are stored with the operating system's secure storage.
- RAWG keys, IGDB/Twitch credentials and tokens, and SteamGridDB keys are excluded from backups and exports.
- Manual encrypted change packages and local-network sync for paired devices are available.
- Manual device pairing enables reusable group-key packages and manual LAN sessions with hash-verified managed cover transfer. QR can simplify invitation import and LAN connection entry, but it does not enable automatic, background, cloud, or discovery.
- The random 256-bit sync group key is stored only in each paired device's operating-system secure storage and never enters library backups.

See [install and portability](docs/install_and_portability.md) for the current data-transfer workflow.

## Installation

### Windows ZIP

1. Download or build the Windows ZIP for the desired stable release.
2. Extract the complete archive; do not run the executable from inside the ZIP.
3. Launch `backlog_vault.exe`.

The portable application folder is separate from the OS-managed app data folder. Create an encrypted backup before replacing binaries or moving to a new machine.

### Android APK

1. Download or build the APK.
2. Allow installation from the local source when Android prompts you.
3. Install the APK and open Backlog Vault.

Current APKs are locally signed for personal installation and testing. They are not Play Store packages. Updating with an APK signed by a different key may require uninstalling the old package, so create an encrypted backup first. Uninstalling can remove app-local data.

## Build from source

Expected toolchain:

- Flutter 3.44.1 stable
- Dart 3.12.1
- Windows desktop and Android toolchains configured through `flutter doctor`

```powershell
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter build windows
flutter build apk
```

Create a local Windows portable archive with:

```powershell
.\tool\package_windows.ps1 -SkipBuild -ReleaseLabel v0.2.0
```

Generated `build/`, `dist/`, APK, ZIP, and cache artifacts are intentionally excluded from Git.

## Metadata and cover setup

External providers are optional. Backlog Vault remains usable offline without credentials.

- **RAWG:** create a RAWG API key and save it under Settings.
- **IGDB:** create a Twitch application, then save its Client ID and Client Secret. The OAuth access token is renewed locally.
- **SteamGridDB:** create an API key and save it under Settings.

Never commit real keys, client secrets, bearer tokens, access tokens, `.secure` files, or keystores. Do not place them in tests, fixtures, logs, documentation, issues, or screenshots.

## Backup and portability

- `.vaultbackup` contains the logical library and media but is not encrypted.
- `.vaultbackup.enc` encrypts the complete backup with a user-provided password.
- `.vaultsync` is a separate encrypted change package. It is not a complete backup and does not contain media file bytes by itself; paired LAN sync can transfer managed cover files separately by hash.
- `.vaultpair` is a temporary password-encrypted invitation that carries the group key needed to pair another device. It contains no library, media, or provider credentials.
- Passwords are never stored. Losing one makes its encrypted backup or `.vaultsync` package unrecoverable.
- Restore is complete and conservative: current records absent from the backup are soft-deleted, not physically erased.
- Provider credentials and secure-storage values never travel in backups.

Use `.vaultbackup.enc` for full migration, disaster recovery, or copying the complete library with media. Use `.vaultpair` to establish a shared group key, then `.vaultsync` files or **Settings → Sync → Local network sync** to exchange library changes without typing a password each time. Password-mode `.vaultsync` remains available. Pairing invitations expire after 24 hours; share the file and temporary password through separate trusted channels. Pairing QR carries the encrypted invitation payload, never the group key in clear text. LAN sync requires both devices on the same local network and a host IP, port, and session code; the LAN QR carries only those connection details plus public group/key identifiers, not the group key or library data. Conflicts are reported and skipped. LAN sync also transfers app-managed cover files by SHA-256 hash when the sender has the file and the receiver can verify its bytes. Configure provider credentials separately on each device.

## Language

The app follows the device language by default. Go to **Settings → Language** and choose:

- System
- Español
- English

The preference is stored per device and is not part of the library database or backups.

## Sync roadmap

Manual password packages, paired-group packages, paired LAN sync sessions, LAN cover transfer by hash, and QR helpers for pairing/LAN connection UX are implemented. They require no account, backend, or cloud. Manual LAN sync requires both devices on the same local network and uses a temporary host/client session.

- v0.1.x: stabilization, bilingual UI, backup/restore hardening.
- v0.2 foundation: deterministic change tracking and manual encrypted PC ↔ Android sync packages.
- Manual `.vaultpair` pairing with the sync key in secure storage, plus QR display/scan/paste helpers for encrypted pairing invitations.
- Manual LAN transport for paired devices using IP, port, and a short session code, plus QR display/scan/paste helpers for connection details.
- Media addressed by hash and transferred over paired LAN sync without creating broken cover references.
- Visible, conservative conflict resolution with no silent destructive merge.
- Automatic discovery, background sync, and advanced visual conflict-resolution UI remain future work.
- No cloud dependency in the first sync stage.
- Optional cloud transport with end-to-end encryption only as a later possibility.

The technical proposal is in [docs/sync_roadmap.md](docs/sync_roadmap.md).

## Screenshots

Screenshots will be added after the bilingual Windows and Android UI pass is captured with a disposable library and no credentials. No synthetic screenshots are included.

## Project documentation

- [Install and portability](docs/install_and_portability.md)
- [v0.2 QA checklist](docs/qa_v0_2_checklist.md)
- [v0.2 release notes](docs/release_notes_v0_2.md)
- [Secure sync roadmap](docs/sync_roadmap.md)
- [QR sync notes](docs/qr_sync_notes.md)

## License

No license has been selected yet. Until a license is added, the repository is not offered under an open-source license.
