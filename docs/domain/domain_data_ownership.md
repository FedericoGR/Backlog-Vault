# Domain data ownership

E4 confirms the functional model without changing Drift schema 6 or merging
entities. Generated Drift rows stay inside data; presentation consumes explicit
read models (`GameDetails`, `LibraryEntryDetails`, `PlaythroughDetails`).

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

## Compatibility and future migration debt

1. E4 keeps completion/pause/resume transitions atomic in the game repository
   and moves independent playthrough CRUD to `PlaythroughRepository`.
2. `LibraryEntry.personalRating` remains the global rating and
   `Playthrough.rating` explicitly as a run rating.
3. Total hours and completion summaries remain calculated from non-deleted
   playthroughs.
4. Any future removal or consolidation of persisted duplicate fields requires a
   separately approved migration and export compatibility plan.
5. E5 may clarify labels visually but must preserve these ownership rules.
