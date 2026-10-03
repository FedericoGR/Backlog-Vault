# Backlog Vault library export format v2

Version 2 extends [version 1](library_export_format_v1.md). The format identifier
remains `backlog-vault-library-export`; `formatVersion` is now `2`.

Each `libraryEntries` item adds the authoritative personal record fields:

- `isCompleted`: boolean. False means pending; true means completed.
- `completedAt`: ISO-8601 UTC timestamp or null. Completion does not require a date.
- `hoursPlayed`: total recorded hours, or null when unknown (zero is distinct).
- `playedPlatformId`: platform ID or null, referencing the `platforms` collection.
- `personalRating` and `personalNotes` retain their existing types.

`status` remains the original legacy status for archival compatibility. It can
contradict `isCompleted` after editing and must not determine current state.
All legacy `playthroughs`, including soft-deleted rows, remain exported unchanged.
Consumers should use entry fields for current tracking and playthroughs only as
historical records. Do not sum them again or treat them as additional current records.
Version 1 readers must recognize version 2 before interpreting personal tracking;
version 1 documents retain their original lifecycle/playthrough semantics.

All other collections, ordering, timestamps, nulls, and soft-deletion semantics
remain as documented in version 1. This is an inspection/export format, not a
restore package or full media backup: local cover file bytes are not included.
Media descriptors and `hasLocalFile` do not substitute for copying those files.
