# Backlog Vault Offline v1.0.0-rc1

Backlog Vault is now consolidated as an intentionally Offline personal game
library for Windows and Android. No account or Backlog Vault cloud is required.

## Highlights

- Local library with responsive table, gallery, and list layouts.
- Search, filters, sorting, configurable columns, and saved views.
- Separate game, library-entry, and playthrough histories.
- Notion-compatible CSV import with mapping, preview, validation, and duplicate
  handling.
- Readable JSON library export, format version 1.
- Optional RAWG/IGDB metadata and IGDB/SteamGridDB/local covers.
- Home dashboard and statistics.
- English and Spanish, plus system-selected light/dark themes with an
  OLED-friendly dark palette.
- Portable Windows x64 ZIP.
- Recommended Android arm64 APK and a universal fallback APK.

## Offline consolidation

The experimental synchronization surface has been removed. The former complex
backup/restore flow has been replaced by a simple, human-readable JSON export.
The active app does not pair devices, expose QR or LAN workflows, or run a
Backlog Vault transport service.

## Updating from 0.3.0+5

Install the compatible package in place. Do not uninstall first if local data
must be preserved. The package identity remains `dev.backlogvault.app`, and
Drift upgrades schema 5 to schema 6 when needed while preserving the ten
functional table families. Existing schema-6 installations simply reopen.

## Limitations

- No device synchronization or cloud storage.
- No JSON import or restore.
- Local image bytes are not included in the JSON export.
- Remote metadata and covers are optional and require Internet plus the
  provider's credentials.
- The arm64 APK requires an arm64-compatible Android device; use the larger
  universal APK only as a compatibility fallback.
- APKs are locally signed personal-distribution packages, not Play Store
  releases.
