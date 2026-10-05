# Statistics and obsolete product cleanup

Base: `5b5534a`. No database migration or new tracking fields.

## Audit before editing

| Classification | Implementation |
| --- | --- |
| Active and useful | Annual gallery/search, personal game form/detail, catalog and media editing, library query, CSV import, export, bulk metadata tools, settings. |
| Active but obsolete | Global statistics KPIs, repeated status counts, rating distribution, genre ranking, data-quality counters, annual/completion-date dashboard, recent completions. The old year selector affected only a subsection and preferred the latest completion year. |
| Dormant product code | Home and its summary; legacy library workspace; table/list/layout switching; saved-view CRUD/providers/defaults; columns; advanced filters, sorting and summaries; selection actions; duplicate bulk-delete methods. |
| Compatibility | Drift tables and generated schema, all migration history, legacy status strings, Playthroughs and SavedViews rows, CSV status normalization, JSON export of historical records and raw view configuration. |

The router previously reached the annual gallery through an export in the
otherwise dormant legacy library file. It now imports the annual page directly.

## Final statistics

The default year is the current calendar year. Previous/next arrows and a year
dropdown match the library interaction. Choosing an empty year does not switch
to another year automatically.

All main metrics first select `playedYear == selectedYear` and count each
`libraryEntryId` once:

- Games: number of selected personal records.
- Finished: selected records with `isCompleted == true`, with no date required.
- Hours: sum of non-null `hoursPlayed`, including unfinished games. No entered
  hours is unavailable; an explicitly entered zero remains zero.
- Average rating: average of non-null `personalRating`; unavailable when none
  are rated.

Favorites shows at most five rated records, sorted by personal rating with
stable title/ID ties. Unrated records never receive a ranking.

Where I played counts records by `playedPlatformId` and displays the resolved
personal platform name. Catalog platform links do not affect these counts.
Unknown personal platforms are omitted; an empty section explains that no
platforms have been recorded.

No completion-by-month chart remains. No month is inferred from played year,
release date, creation date or update date. Unknown-year games remain accessible
through Games → No year.

## Removal and final reference audit

Removed Home, legacy library table/list modes, layout selectors, advanced
filters, column configuration, saved-view runtime models/CRUD/providers, bulk
selection and their obsolete tests. Removed the unused `data_table_2` dependency,
statistics quality/lifecycle/rating-distribution/monthly models and UI, and
unused product localization entries. Gallery appearance and annual navigation
remain intact; its unused selection/action parameters were removed.

Remaining matches have the following purposes:

- `Playthroughs`, `SavedViews`, `filterJson`, `sortJson`, `columnConfigJson`:
  schema/migration history and verbatim legacy export. No product UI reads or
  writes saved-view configuration. The export test checks opaque old and unknown
  JSON fields are preserved exactly, without normalizing old lifecycle values.
- Legacy `status` and lifecycle strings: database compatibility and supported
  CSV interpretation. Active records derive completion only from `isCompleted`.
- `GameStatus.pending` / `statusBacklog`: existing two-state domain/localization
  identifiers displaying “No terminado”; no backlog workflow.
- `/home`: a compatibility redirect to Games, without Home UI or providers.
- Missing metadata/cover/incomplete-field checks: bulk metadata tooling only.
  Those routes, capabilities and tests remain.
- “role playing”: catalog genre normalization, unrelated to tracking state.
- Backlog Vault names: application branding, storage paths and export format.
- Generated database references, historical docs and old-format test fixtures:
  compatibility or audit evidence, not active product dependencies.

An import/export/part graph rooted at `lib/main.dart` found no unreachable Dart
files left in `lib`. No dormant Home/table/list/saved-view product implementation
was retained. No persistent data, legacy table or migration was removed.

## Validation and commit boundaries

- `dart format` applied to changed Dart files.
- `flutter analyze`: no issues.
- `flutter test`: 286 passed, including unchanged v7/v8 migration tests, legacy
  multi-playthrough preservation, CSV import and export compatibility.
- Annual gallery/navigation and personal-record tests still pass.
- The 13 pre-existing portable-storage files were verified against their initial
  SHA-256 hashes and excluded from this commit.
