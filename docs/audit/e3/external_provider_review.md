# E3 external provider review

Backlog Vault remains fully usable without credentials and without Internet.
The providers below run only after an explicit user action. E3 does not remove
or redesign them.

Counts are approximate productive Dart files directly dedicated to each
integration; shared models, UI, tests, and generated files are excluded.

| Provider/capability | Function | Main dependency | Credentials | Approx. files | Duplication/advantage | Maintenance and weight | Recommendation |
|---|---|---|---|---:|---|---|---|
| RAWG | Search and fetch game metadata | `http`, metadata repository | API key in secure storage | 2 | Broad catalog; overlaps IGDB search/details | Small Dart/HTTP surface; external API contract | maintain |
| IGDB metadata | Search/details and external IDs | `http`, shared IGDB auth | Twitch Client ID/Secret and cached token in secure storage | 3 plus auth | Rich metadata; overlaps RAWG but also feeds IGDB covers | More auth/error handling and token lifecycle | consolidate after E4 |
| Twitch auth | Obtain/cache IGDB OAuth token | `http`, secure storage | Client ID, Client Secret, access token | 1 auth client plus storage methods | Required only by IGDB capabilities | Highest credential-maintenance cost; little binary weight | maintain while IGDB remains |
| SteamGridDB | Search grid/cover artwork | `http`, media repository | API key in secure storage | 2 | Strong cover-specific catalog; overlaps IGDB covers | Separate API/client and fixtures; small binary impact | decision pending after usage evidence |
| IGDB covers | Cover candidates from IGDB | IGDB auth and `http` | Reuses IGDB credentials/token | 1 | Reuses metadata ecosystem and avoids another key | Coupled to IGDB auth but little additional code | maintain/consolidate with IGDB metadata |
| Local covers | User-selected local images and managed cache | `file_picker`, `path_provider`, `crypto` | none | 2 core storage/repository paths plus UI | Essential offline fallback; no provider dependency | Filesystem lifecycle and hash integrity are important | maintain |

## Shared infrastructure

- `MetadataApiKeyStorage` keeps RAWG, IGDB/Twitch, and SteamGridDB values in OS
  secure storage. None are read by the library exporter.
- `http` remains justified by optional metadata and cover actions.
- `crypto` remains justified by functional media hashing after backup removal.
- `file_picker` remains justified by CSV import, local covers, and JSON export.
- `path_provider` remains justified by local media storage.

## Duplication and future direction

RAWG and IGDB both provide search/details. IGDB and SteamGridDB both provide
cover candidates. This duplication gives fallback choice but multiplies API
contracts, credentials, fixtures, error mapping, and Settings copy. No reliable
usage/quality measurement currently justifies deleting one.

Recommended sequence after E3:

1. E4: isolate provider contracts and shared auth/storage boundaries without
   changing the visible provider set.
2. E5: measure match quality, credential friction, failure rate, and usage with
   disposable/test data.
3. Decide whether RAWG or IGDB is the primary metadata provider and whether
   SteamGridDB's cover quality justifies its separate key.
4. Keep local covers regardless; they are the only fully offline acquisition
   path.
