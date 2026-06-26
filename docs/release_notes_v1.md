# Backlog Vault v0.1.0 RC3

Version: `0.1.0+3`
Tag: `v0.1.0-rc3`
Date: 2026-06-18

RC3 consolidates the repository on `main`, keeps `release/v1` as the RC line, and adds the bilingual application foundation required before secure PC ↔ Android sync work starts.

## Highlights

- English and Spanish through Flutter `gen_l10n` and ARB files.
- System language detection by default.
- Per-device selector: System, Español, English.
- Language preference stored outside SQLite with `shared_preferences`.
- Main navigation, Home, Library, Statistics, Settings, game forms/details, metadata, covers, bulk import, CSV import, privacy, and backup/restore localized.
- Existing persisted enum/status values and database schema remain unchanged.
- README rewritten in English with a complete Spanish companion.
- Install, QA, privacy, and secure-sync roadmap documentation updated.
- No sync implementation in this RC.

## Existing v0.1 features

- Offline SQLite/Drift library with soft delete.
- Table, gallery, and list layouts with saved views and filters.
- Notion CSV import with preview and duplicate handling.
- RAWG and IGDB metadata.
- IGDB, SteamGridDB, and local covers.
- Bulk metadata and cover workflow with explicit replacement controls.
- Local media with relative paths.
- Plain and encrypted backup/restore.
- Home and statistics dashboards.
- OLED-friendly dark theme.
- Windows portable and Android local-package builds.

## Privacy

- No account or backend.
- Local DB and media are not encrypted at rest.
- `.vaultbackup` is not encrypted.
- `.vaultbackup.enc` encrypts the complete backup with a password that is never stored.
- Provider credentials and tokens remain in secure storage and are excluded from backups/exports.

## Known limitations

- No automatic/background sync, QR discovery, or cloud transport. Manual paired LAN sync is available for local-network use.
- Restore is not a field-level merge.
- Provider/API error details can originate from provider or validation layers; generic user-facing failures are localized and secrets are redacted.
- Android packages are locally signed for personal testing, not store publication.
- Clean bilingual screenshots are still pending.

Validation status is tracked in [qa_v1_checklist.md](qa_v1_checklist.md).
