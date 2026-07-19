# E4 architecture refactor summary

Date: 2026-07-18. Branch: `codex/offline-e4-architecture-refactor`.

## Outcome

E4 applied the approved feature-first, pragmatic MVVM and
Repository/Service architecture without changing visible behavior, Drift
schema 6, version `0.3.0+5`, or library export format version 1.

- Presentation has zero imports of feature `data/`, Drift/database,
  `dart:io`, FilePicker, HTTP, or secure storage.
- Drift rows are mapped to `LibraryGameDetails` read models before reaching UI.
- Library table/filter/sort/columns/layout state has one mutable source in
  `LibraryViewModel`.
- Game form, detail/playthrough, catalogs, bulk metadata, media search, CSV
  import, credentials and statistics expose application-level boundaries.
- Playthrough persistence moved out of `GameRepository` into its owned
  repository.
- Local cover picking and image bytes are isolated from presentation.
- Credential UI state exposes only presence booleans, never secret values.
- An architecture test enforces the critical dependency rules and absence of
  removed product modules.

## Baseline and final code metrics

| Metric | E4 baseline | After refactor |
|---|---:|---:|
| Files under `lib/` | 147 | 156 |
| Dart files under `lib/` | 145 | 154 |
| Provider-bearing files | 22 | 27 |
| Repository files | 9 | 10 |
| Service files (`*_service.dart`) | 1 | 2 |
| Presentation Dart files | 13 | 13 |
| ViewModel classes | 0 explicit | 8 |
| Forbidden presentation imports | 12 source files | 0 |
| Tests | 246 | 257 |

The additional files are boundaries, read models and targeted tests. No package
dependency was added or removed.

## Moves and extractions

- `app/backlog_vault_app.dart` → `app/bootstrap/backlog_vault_app.dart`.
- router and shell → `app/routing/`.
- theme → `app/theme/`.
- independent library table/layout providers → one `library_view_model.dart`.
- playthrough CRUD → `playthroughs/data/playthrough_repository.dart`.
- IGDB cover mapper → media domain.
- FilePicker use → media data service.
- generated Drift details → application read models.

## Deliberate limits

E4 did not perform the visual decomposition assigned to E5. Large page files
therefore remain, even though their persistence/infrastructure coordination is
now outside presentation. No deep dependency or artifact-size optimization was
attempted; that remains E6 scope.
