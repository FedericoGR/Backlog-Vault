# Backlog Vault

Backlog Vault is an offline videogame backlog manager for Windows and Android. It keeps your library, personal notes, playthroughs, metadata, and covers on your own device. There is no account, backend, cloud, device pairing, or cross-device synchronization.

> Spanish documentation: [README.es.md](README.es.md)

Current historical release candidate: `v0.3.0-rc1` (`0.3.0+5`). The active development branch has removed its historical synchronization feature without changing the version yet.

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
- Conservative backup restore with an automatic pre-restore backup.
- Home dashboard and library statistics.
- System, light, dark, and OLED-friendly UI behavior.
- English and Spanish, with a per-device language selector.

## Offline privacy model

- No login and no Backlog Vault backend.
- The SQLite database and local media remain on each device.
- The local database and media are **not encrypted at rest yet**.
- Encrypted backups are available and should be used when a backup leaves the device.
- Provider credentials are stored with the operating system's secure storage.
- RAWG keys, IGDB/Twitch credentials and tokens, and SteamGridDB keys are excluded from backups and exports.
- The application does not open sockets, pair devices, scan QR codes, or exchange data with another Backlog Vault installation.
- External metadata and cover requests run only when the user explicitly invokes those optional capabilities.

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

Historical artifacts may still use `-ReleaseLabel v0.3.0-rc1`; E2 does not create a new release or change the app version.

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
- Backup passwords are never stored. Losing one makes its encrypted backup unrecoverable.
- Restore is complete and conservative: current records absent from the backup are soft-deleted, not physically erased.
- Provider credentials and secure-storage values never travel in backups.

Use `.vaultbackup.enc` for full migration, disaster recovery, or copying the complete library with media. Move the backup through a channel you control and configure optional provider credentials separately on the destination device.

## Language

The app follows the device language by default. Go to **Settings → Language** and choose:

- System
- Español
- English

The preference is stored per device and is not part of the library database or backups.

## Offline product direction

Backlog Vault is intentionally single-device and offline. Portability is provided by explicit local JSON/backup export and conservative restore, not by synchronization protocols. Historical Sync implementation remains available through Git and the external pre-refactor bundle.

## Screenshots

Screenshots will be added after the bilingual Windows and Android UI pass is captured with a disposable library and no credentials. No synthetic screenshots are included.

## Project documentation

- [Install and portability](docs/install_and_portability.md)
- [v0.2 QA checklist](docs/qa_v0_2_checklist.md)
- [v0.2 release notes](docs/release_notes_v0_2.md)
- [v0.3 QA checklist](docs/qa_v0_3_checklist.md)
- [v0.3 release notes](docs/release_notes_v0_3.md)
- [Offline schema 5→6 migration](docs/migrations/offline_schema_5_to_6.md)
- [E2 completion report](docs/planning/e2_completion_report.md)

## License

No license has been selected yet. Until a license is added, the repository is not offered under an open-source license.
