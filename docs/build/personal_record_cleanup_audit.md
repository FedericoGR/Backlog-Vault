# Personal record cleanup following 79de28f

## Audit before edits

Commit 79de28f already made LibraryEntry authoritative for saves, imports,
completion dates, hours and ratings, and introduced the transactional v7
migration. Those changes are retained. This cleanup does not change schema 7.

### A: required compatibility

- Database Playthroughs definition/generated mappings, schema migration SQL and
  schema fixtures/tests: preserve physical history and deterministic upgrades.
- LibraryEntries.status: preserved legacy value, never a source of current state.
- JSON export v2 playthrough collection and legacy status: archival compatibility,
  including deleted records. Local cover file bytes are not exported.
- Parsing old saved status filters and CSV status tokens: normalize to the two
  active states at the boundary. Old saved playthrough columns are ignored.
- Role-playing genre aliases: catalog genre vocabulary, unrelated to lifecycle.

### B: active or unreachable obsolete product code

- Detail history/cards/count and GameProgressSummary still load playthroughs.
- Library query still loads all playthroughs to expose an optional count column.
- CompletionFormModel/dialog is a second personal editing flow; old lifecycle
  methods and transition helpers remain, despite mapping to pending.
- GameStatus still exposes seven states, including CSV preview labels.
- Home retains unused playing/paused counters and lists.
- Statistics still has an unused playthrough query/provider/model/argument;
  platform breakdown and missing-platform counts incorrectly use catalog links.
- Unreachable PlaythroughFormModel/status/editor/repository, import playthrough
  helpers, and CSV created-playthrough counts/labels remain.

## Cleanup scope

Remove B; keep A. Use one personal form and boolean completion authority in read
models. Detail keeps its existing composition after removing obsolete sections
and actions. Catalog platforms remain separate from the personally played
platform; personal platform labels resolve by playedPlatformId, including
historical platform rows. Statistics use the personal platform and entry fields.
No database rows or schema definitions are removed. Portable-storage changes
present before this task remain outside the commit.


## Verification

- `dart format`: all changed Dart files formatted.
- `flutter analyze`: no issues found.
- `flutter test`: 289 tests passed, including all existing schema/migration tests.
- Regression coverage includes pending/completed creation, both state changes,
  editing/clearing the five optional personal values, all legacy status values,
  retained legacy rows and export, independent catalog/played platforms, and
  completed form preload/save (including an archived played platform).
- Widget tests confirm no history/lifecycle controls or duplicate personal fields.
- The 13 pre-existing portable-storage files match their pre-task SHA-256 values
  and are excluded from this commit. Schema/migration definitions and migration
  tests are unchanged by this cleanup.
