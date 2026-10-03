# Backlog Vault library export format v1

This documents the legacy format. Current exports use [version 2](library_export_format_v2.md).

## Purpose

The library export is a readable, portable snapshot of Backlog Vault data. It
is intended for preservation, inspection, and user-controlled processing. It
is not a database dump, backup package, Sync payload, or restore format.

Files use this portable name:

`backlog-vault-library-YYYYMMDD-HHmmss.json`

The timestamp is UTC, the document is pretty-printed UTF-8 JSON, and the file
is selected through the operating system document picker.

## Identification and compatibility

Every document begins with:

```json
{
  "format": "backlog-vault-library-export",
  "formatVersion": 1
}
```

Consumers must use both fields. `formatVersion` belongs only to this export
contract; it is independent from Drift schema 6 and from the retired logical
backup schema 4. Version 1 is additive only by explicit future specification.
Backlog Vault does not import or restore this format during the current Offline
cycle.

## Top-level structure

```text
format
formatVersion
exportedAt
appVersion
sourcePlatform
summary
games
libraryEntries
playthroughs
platforms
genres
libraryEntryPlatforms
gameGenres
savedViews
metadata
media
```

- `exportedAt` is ISO-8601 UTC.
- `appVersion` is the version name without the build number.
- `sourcePlatform` is `windows` or `android`.
- `summary` contains the count of every exported collection.
- All entity and relation collections are ordered by stable ID.
- Stable database IDs and explicit relation IDs are preserved.
- Soft-deleted rows are included with `deletedAt` so the snapshot represents
  the complete functional history stored locally.
- Optional scalar fields appear as JSON `null` where that clarifies absence.
- Status and type values use their stable persisted string names.

## Included data

### `games`

Work/catalog data: ID, title, sort title, release date, type, timestamps, and
soft-delete timestamp.

### `libraryEntries`

Personal relationship to a game: ID, game ID, library status, personal rating,
personal notes, timestamps, and soft-delete timestamp.

### `playthroughs`

Individual experiences: ID, library-entry and optional platform IDs, status,
start/completion dates, hours, per-playthrough rating and notes, timestamps,
and soft-delete timestamp.

### Catalogs and relations

- `platforms`: ID, name, optional short name, timestamps.
- `genres`: ID, name, timestamps.
- `libraryEntryPlatforms`: explicit entry/platform relation and primary flag.
- `gameGenres`: explicit game/genre relation.

### `savedViews`

ID, name, existing filter/sort/column JSON strings, timestamps, and
soft-delete timestamp.

### `metadata`

Applied external references from `ExternalGameIds`: provider, external ID,
optional slug/URL/matched title, game relation, timestamps, and soft-delete
timestamp. Provider credentials and OAuth tokens are never included.

### `media`

Descriptive `MediaAsset` information only: media/game IDs, kind, source,
provider, external ID, remote source URL, MIME type, dimensions, functional
hash, selection flag, attribution, timestamps, and a boolean indicating that
the local record references a managed file.

The JSON exports library information. Local images are not included inside the
file. Local paths and filenames are also omitted.

## Excluded data and privacy

The exporter never reads or serializes:

- RAWG API keys;
- IGDB Client ID, Client Secret, or Twitch access tokens;
- SteamGridDB API keys;
- secure-storage values, passwords, bearer tokens, or historical group keys;
- absolute or relative local media paths;
- image bytes, base64, binary files, or caches;
- SQLite files, logs, device recovery state, or unnecessary device identity;
- retired Sync tables, packages, tombstones, changes, groups, or devices.

Remote source URLs and descriptive hashes may be included because they are
functional media metadata. They must not contain credentials.

## Determinism and consistency

The repository reads all ten functional table families inside one Drift read
transaction and performs no N+1 relation lookups. Collections are ordered by
ID before serialization. For the same database state and export timestamp, the
UTF-8 content is identical. Between two exports of an unchanged database, only
`exportedAt` and the derived filename are expected to change.

## Small synthetic example

```json
{
  "format": "backlog-vault-library-export",
  "formatVersion": 1,
  "exportedAt": "2026-07-17T18:30:45.000Z",
  "appVersion": "1.0.0-rc1",
  "sourcePlatform": "windows",
  "summary": {
    "games": 1,
    "libraryEntries": 1,
    "playthroughs": 0,
    "platforms": 0,
    "genres": 0,
    "libraryEntryPlatforms": 0,
    "gameGenres": 0,
    "savedViews": 0,
    "metadata": 0,
    "media": 0
  },
  "games": [
    {
      "id": "game-1",
      "title": "Example Game",
      "sortTitle": null,
      "releaseDate": null,
      "type": "game",
      "createdAt": "2026-01-01T00:00:00.000Z",
      "updatedAt": "2026-01-01T00:00:00.000Z",
      "deletedAt": null
    }
  ],
  "libraryEntries": [
    {
      "id": "entry-1",
      "gameId": "game-1",
      "status": "backlog",
      "personalRating": null,
      "personalNotes": null,
      "createdAt": "2026-01-01T00:00:00.000Z",
      "updatedAt": "2026-01-01T00:00:00.000Z",
      "deletedAt": null
    }
  ],
  "playthroughs": [],
  "platforms": [],
  "genres": [],
  "libraryEntryPlatforms": [],
  "gameGenres": [],
  "savedViews": [],
  "metadata": [],
  "media": []
}
```

## Limitations

- No import, merge, preview, or restore is provided.
- Local images and other binary media cannot be recovered from the JSON.
- Settings such as language/theme and external credentials are device-local.
- The format does not guarantee complete device recovery or migration between
  installations.
