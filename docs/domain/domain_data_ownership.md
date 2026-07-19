# Domain data ownership

E3 documents the current meaning of the functional model without changing
Drift schema 6 or merging entities. Generated Drift rows still cross some
layer boundaries; moving them behind stable domain contracts belongs to E4.

## Game

`Game` represents the work or catalog item:

- title and sort title;
- release date;
- content type;
- general descriptive metadata applied from external providers;
- genre relations and media associated with the work.

It does not own personal status, personal rating, personal notes, hours, or a
specific playthrough state.

## LibraryEntry

`LibraryEntry` represents the user's relationship to a `Game`:

- global library state (`backlog`, playing, completed, etc.);
- personal rating of the work as a whole;
- general personal notes;
- inclusion timestamps and soft delete;
- platform relations and primary-platform preference.

For current behavior, `LibraryEntry.personalRating` is the source of truth for
the rating displayed in library rows. It is a global evaluation, not the rating
of one run.

## Playthrough

`Playthrough` represents one concrete attempt or experience:

- start and completion dates;
- hours played;
- per-attempt status;
- optional per-attempt rating and notes;
- optional platform;
- timestamps and soft delete.

It remains separate so multiple runs, platforms, histories, and statistics are
preserved.

## Current duplication and source-of-truth rules

| Concern | Current source of truth | Other representation | Preserve now |
|---|---|---|---|
| Global library status | `LibraryEntry.status` | individual `Playthrough.status` | both; coordinate transitions |
| Global personal rating | `LibraryEntry.personalRating` | `Playthrough.rating` per run | both; do not auto-collapse |
| Hours | sum of active/non-deleted playthrough hours in read models | each `Playthrough.hoursPlayed` | calculate, do not persist aggregate |
| Completion date | playthrough completion history/read-model selection | `LibraryEntry` has no completion field | keep calculated behavior |
| General notes | `LibraryEntry.personalNotes` | `Playthrough.notes` for a run | labels/intent remain distinct |
| Platform | entry/platform relation and primary flag | optional playthrough platform | both contexts are valid |

`LibraryGameRow`, progress summaries, and statistics are calculated read models.
They must not become new persisted sources of truth without measured need.

## Export behavior

The library JSON preserves `Game`, `LibraryEntry`, and `Playthrough` separately,
including stable IDs, relation IDs, timestamps, optional fields, and soft
deletes. It does not infer or rewrite one entity from another and never updates
the database.

## Recommendation for E4/E5

1. Encapsulate the existing completion/pause/resume workflow in one selective
   application use case that coordinates entry and playthrough invariants in a
   single transaction.
2. Keep `LibraryEntry.personalRating` as the global rating and label
   `Playthrough.rating` explicitly as a run rating.
3. Keep total hours and completion summaries calculated from playthroughs.
4. Add transition tests before moving Drift types behind domain models.
5. Preserve current UI and export behavior while boundaries move; do not mix
   that refactor with a schema migration.
