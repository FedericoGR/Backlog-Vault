# Backlog Vault v1 Release Candidate RC2

Version: `0.1.0+2`

Tag objetivo: `v0.1.0-rc2`

Date: 2026-06-18

Backlog Vault v1 RC is a local-first personal game backlog manager for Windows and Android. It is intended for personal use with explicit backup/restore workflows instead of cloud sync.

## Highlights

- Nexus-inspired UI refresh completo:
  - biblioteca en tabla / galería / lista con catálogo visual;
  - sidebar de filtros desktop y modal mobile;
  - ficha de juego, formularios y dialogs de metadata/covers alineados al mismo design system;
  - polish visual para Home, Estadísticas, Ajustes, Backups, Import CSV y Bulk Metadata.

- Offline library with SQLite/Drift persistence.
- Manual game management with soft delete.
- CSV import from Notion exports with preview and validation.
- Advanced library table, gallery view, saved views, filters, sorting and configurable columns.
- Game detail with status, personal rating, notes, playthroughs, progress and local cover.
- Metadata providers:
  - RAWG.
  - IGDB with Twitch OAuth client credentials.
- Cover providers:
  - SteamGridDB.
  - IGDB covers.
  - Local image file import.
- Bulk metadata and cover import with preview, confidence, controlled replacements and strong confirmation.
- Local media storage under app support using relative paths.
- Backup/export/restore:
  - logical JSON export;
  - CSV export;
  - `.vaultbackup`;
  - encrypted `.vaultbackup.enc`.
- Privacy hardening:
  - provider credentials in secure storage;
  - redaction of secrets and sensitive paths in visible errors;
  - external API keys are not exported or backed up.
- OLED dark theme using system theme mode.
- Windows portable ZIP packaging.
- Android APK build for personal installation/testing.

## Final RC Artifacts

Expected local artifact paths after packaging:

- `dist/BacklogVault-windows-x64-v0.1.0-rc2.zip`
- `dist/BacklogVault-android-v0.1.0-rc2.apk`

The `dist/` directory is ignored by Git. Artifacts are generated locally and are not committed.

## Install Notes

See [install_and_portability.md](install_and_portability.md).

Short version:

- Windows: extract the ZIP and run `backlog_vault.exe`.
- Android: install the APK manually on a test device.
- Before updating or moving devices, create a `.vaultbackup.enc` from Settings > Datos y backups.

## Privacy And Data

- `.vaultbackup.enc` is encrypted with a user-provided password.
- `.vaultbackup` is not encrypted.
- The local SQLite database and media folder are not encrypted at rest in v1.
- RAWG keys, SteamGridDB keys, IGDB Client Secret and IGDB access tokens are stored in secure storage and are not included in exports/backups.
- There is no automatic sync. Move data between devices with `.vaultbackup` or `.vaultbackup.enc`.

## Known Limitations

- Android APK is locally/debug signed for personal installation/testing, not a Play Store release.
- No cloud backup or automatic sync.
- No DB encryption or media encryption at rest.
- No automatic provider credential migration between devices.
- External metadata and cover search require user-provided provider credentials.
- Restore is complete/conservative, not an advanced merge workflow.
- Flutter currently prints a non-blocking Android build warning for a plugin that still applies the Kotlin Gradle Plugin path.

## Validation Status

Automated RC validation is tracked in [qa_v1_checklist.md](qa_v1_checklist.md).
