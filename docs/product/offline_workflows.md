# Backlog Vault Offline workflows

Backlog Vault `v1.0.0-rc1` is a local-first library for Windows and Android.
It has no account, cloud service, device pairing, or background transport.
Normal library use does not require Internet.

## Library and local data

Games, personal library entries, playthroughs, catalogs, saved views, applied
metadata references, and media descriptions live in the local Drift database.
Covers selected or downloaded by the user live in the application-support media
folder. Theme and language are device preferences; optional provider
credentials live in OS secure storage. The database and media are not encrypted
at rest, so device-level protection remains important.

## CSV import

The Notion-compatible CSV flow is an explicit local import:

1. select a UTF-8 CSV through the OS picker;
2. review or adjust the detected column mapping;
3. inspect the preview, validation issues, and duplicate decisions;
4. confirm a single local transaction.

The importer supports comma and semicolon delimiters, Unicode, quoted values,
dates, status, rating, hours, genres, platforms, type, and notes. It creates
library data; it is not a database restore or a merge protocol.

## JSON export

Settings → Library data → Export library creates one pretty-printed UTF-8 JSON
document using `backlog-vault-library-export`, format version 1. The snapshot is
read-only and deterministically ordered. It includes the ten functional data
families and their relations, but excludes image bytes, local paths, databases,
credentials, secure-storage values, logs, and device identity.

There is deliberately no JSON import or restore. Local covers cannot be
recovered from the JSON. See the
[format specification](../export/library_export_format_v1.md).

## Optional metadata and covers

RAWG and IGDB metadata, and IGDB or SteamGridDB covers, run only after an
explicit user action. They require Internet and provider-specific credentials.
A local image may also be chosen as a cover. Backlog Vault remains fully usable
without any provider configured; credentials never enter the library export.

## Platform packages

The Windows ZIP must be fully extracted before running. Android provides a
smaller arm64 APK for compatible devices and a larger universal fallback.
Updates that must preserve local data are installed in place with the same
package identity and signing key; do not uninstall first.

## Deliberate limitations

- no cross-device synchronization, cloud storage, QR pairing, or LAN service;
- no complete backup/restore workflow and no JSON restore;
- no media packaging inside the JSON export;
- no automatic provider calls during startup or ordinary library navigation;
- no guarantee of recovery after OS app-data deletion or device loss.
