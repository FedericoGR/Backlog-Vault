# Backlog Vault

Backlog Vault is an offline personal videogame log for Windows and Android. Browse your games by year and keep one personal record with completion, hours, platform, rating, and notes. Your library and local covers stay on your device; there is no account, backend, cloud, or cross-device synchronization.

> Spanish documentation: [README.es.md](README.es.md)

Current release candidate: `v1.0.0-rc1` (`1.0.0-rc1+6`). It consolidates
Backlog Vault as an intentionally Offline product.

## What it does

- Annual poster gallery with year navigation, search, and simple completion, played-platform, and rating filters.
- One personal record per game: completed status, played year, optional completion date, hours, played platform, rating, and notes.
- Game details and yearly statistics for your personal gaming history.
- Manual game creation and editing, with catalog information kept separate from your personal record.
- Notion CSV import with mapping, preview, duplicate detection, and validation.
- Optional metadata from RAWG and IGDB.
- Optional covers from IGDB and SteamGridDB, plus local image import.
- Bulk metadata and cover matching with explicit preview and replacement controls.
- Local media storage using relative paths.
- Portable, human-readable JSON export of library data, including supported legacy records.
- System, light, dark, and OLED-friendly UI behavior.
- English and Spanish, with a per-device language selector.

## Offline privacy model

- No login and no Backlog Vault backend.
- The SQLite database and local media remain on each device.
- The local database and media are **not encrypted at rest**.
- On Windows, provider credentials are encrypted for the current user and
  stored inside `userdata`.
- RAWG keys, IGDB/Twitch credentials and tokens, and SteamGridDB keys are excluded from library exports.
- JSON exports contain library information but no image bytes, local paths, credentials, or automatic restore capability.
- The application does not open sockets, pair devices, scan QR codes, or exchange data with another Backlog Vault installation.
- External metadata and cover requests run only when the user explicitly invokes those optional capabilities.

See [install and portability](docs/install_and_portability.md) for the current data-transfer workflow.

## Installation

### Windows portable ZIP

1. Download or build `BacklogVault-windows-x64-portable-v1.0.0-rc1.zip`.
2. Extract the complete archive; do not run the executable from inside the ZIP.
3. Launch `backlog_vault.exe`.

The SQLite database, media, preferences, and encrypted credentials are stored
below `userdata` beside the application. Close Backlog Vault and copy the
complete extracted folder when moving or backing it up.

### Android APK

1. Download the arm64 APK for a compatible arm64 device, or use the larger
   universal APK as a fallback.
2. Allow installation from the local source when Android prompts you.
3. Install the APK and open Backlog Vault.

Current APKs are locally signed for personal installation and testing. They are not Play Store packages. Only perform an in-place update with the same package identity and a compatible signing key. Do not uninstall an installation that contains important data: uninstalling can remove app-local data, and JSON export is not an automatic restore format.

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

Run the clean release build and reproducible packaging helpers with:

```powershell
.\tool\build_release.ps1
.\tool\package_windows.ps1 -SkipBuild
.\tool\package_android.ps1 -Mode Arm64AndUniversal
.\tool\verify_release_candidate.ps1
.\tool\check_repository_hygiene.ps1
```

The Windows ZIP is built from an explicit runtime allowlist and is deterministic
for identical release input. Android packaging names and checksums universal
and per-ABI APKs; it never installs them. See the
[release build and packaging guide](docs/build/release_build_and_packaging.md).

Generated `build/`, `dist/`, APK, ZIP, and cache artifacts are intentionally excluded from Git.

## Metadata and cover setup

External providers are optional. Backlog Vault remains usable offline without credentials.

- **RAWG:** create a RAWG API key and save it under Settings.
- **IGDB:** create a Twitch application, then save its Client ID and Client Secret. The OAuth access token is renewed locally.
- **SteamGridDB:** create an API key and save it under Settings.

Never commit real keys, client secrets, bearer tokens, access tokens, `.secure` files, or keystores. Do not place them in tests, fixtures, logs, documentation, issues, or screenshots.

## Library export and portability

- **Settings → Library data → Export library** writes one pretty-printed UTF-8 JSON file.
- The document includes games, personal library entries, playthroughs, catalogs, relationships, saved views, applied metadata references, and descriptive media records.
- It excludes provider credentials, secure-storage values, local paths, image bytes, databases, caches, and historical Sync data.
- Local images are not embedded in the file.
- Backlog Vault does not import or restore this JSON during the current Offline cycle.

The export is intended for preservation, inspection, and user-controlled processing. It is not a complete device backup and does not promise recovery of local images or automatic migration to another installation. See the [format specification](docs/export/library_export_format_v1.md).

## Language

The app follows the device language by default. Go to **Settings → Language** and choose:

- System
- Español
- English

The preference is stored per device and is not part of the library database or JSON export.

## Offline product direction

Backlog Vault is intentionally offline. On Windows, portable storage keeps the database, media, preferences, and encrypted credentials beside the application. The JSON export is for preservation and user-controlled processing; it is not an automatic restore format and does not include local image bytes.

## Screenshots

Screenshots will be added after the bilingual Windows and Android UI pass is captured with a disposable library and no credentials. No synthetic screenshots are included.

## Project documentation

- [Install and portability](docs/install_and_portability.md)
- [Library export format v1](docs/export/library_export_format_v1.md)
- [Offline workflows](docs/product/offline_workflows.md)
- [v1.0.0-rc1 release notes](docs/release/release_notes_v1_0_0_rc1.md)
- [v1.0.0-rc1 QA checklist](docs/release/qa_checklist_v1_0_0_rc1.md)
- [v0.2 QA checklist](docs/qa_v0_2_checklist.md)
- [v0.2 release notes](docs/release_notes_v0_2.md)
- [v0.3 QA checklist](docs/qa_v0_3_checklist.md)
- [v0.3 release notes](docs/release_notes_v0_3.md)
- [Offline schema 5→6 migration](docs/migrations/offline_schema_5_to_6.md)
- [E2 completion report](docs/planning/e2_completion_report.md)
- [Release build and packaging](docs/build/release_build_and_packaging.md)
- [E6 size and cleanup results](docs/audit/e6/size_and_cleanup_results.md)

## License

No license has been selected yet. Until a license is added, the repository is not offered under an open-source license.
