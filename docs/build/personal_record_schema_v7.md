# Personal record migration (schema 7)

LibraryEntries owns completion, optional completion date, optional hours,
optional played platform, rating and notes. Product states are pending and
completed. The legacy status column and Playthroughs table are retained;
application writes never update legacy playthroughs. CSV import writes one
personal record per imported game without creating a playthrough.

## Migration rules

All upgrades run in one transaction, including intermediate older migrations.
Four columns are added without rebuilding or dropping the legacy tables.
Completion is true for legacy completed status or any non-deleted completed
playthrough. The date is the maximum completion date of those playthroughs.
Hours sum all non-deleted playthrough hours (including pending/paused/dropped),
with null if no hours were recorded. Zero stays zero.

For latest completed playthrough, order by completed_at descending (null dates
last), updated_at descending, then id ascending. Played platform comes from
that row; if null, from the latest non-deleted playthrough ordered by updated_at
descending then id ascending; if still null, from a non-deleted primary platform
link ordered by updated_at descending then id ascending. Otherwise it is null.
The latest row is selected before reading its platform or rating: the migration
does not search older rows for non-null values.

Existing personal rating wins. Only a null rating falls back to the latest
completed playthrough's rating. Notes, legacy status, timestamps, deletion
markers, and every legacy playthrough field remain unchanged. Soft-deleted
entries are migrated too. Foreign keys are checked before committing. Migration
failure rolls back both new columns and backfilled values; reopening v7 never
runs the backfill again. Schema 7 must not be opened by older app binaries.

## Application and export

Library rows, game details, summaries, yearly statistics and filters use the
personal record. Existing controls are reused with pending/completed options.
Completion dates can be cleared. Historical playthroughs are read-only and
remain available in the details and v2 JSON export. Old saved status filters
are interpreted as pending/completed without rewriting their stored JSON.
Yearly hours use the total hours of completed personal records dated that year;
undated completions count in the total, not an invented calendar year.

The JSON export is not a media backup; copy local cover files separately.
The distributed app and user data in dist are not migrated by development tests.
