# Annual game log: commit 1 after f57fac8

## Audit before editing

| Behavior | Previous owner and behavior |
| --- | --- |
| Initial route | `app_router.dart` already opened `/`, the library. |
| Main navigation | `AppShell` exposed Home, Library, Statistics and Settings. |
| Home | `HomePage` and `library_home_summary.dart` presented activity and metadata-quality shortcuts. |
| Library | `GameListPage` assembled the toolbar, filter sidebar, active chips, summaries and bulk selection. |
| Layout | `LibraryViewModel` started in table mode and supported table/gallery/list. |
| Views and columns | `SavedLibraryViewRepository`, `LibraryTableState` and toolbar dialogs controlled saved filters, sorting and column configuration. |
| Advanced filtering | `LibraryFilterState` and `LibraryTableProcessor` supported status, catalog platforms/genres, ratings, hours, release/completion dates and missing-data filters. |
| Annual filtering | A saved-view preset used completion-date ranges; unfinished undated games could not belong to a year. |
| Cards | `LibraryCatalogCard` displayed catalog platforms, genres, release/completion date and several badges. |
| Personal dates | Schema 7 provided `completedAt`, creation/update timestamps and historical playthrough dates. None represented an independent personal log year. |
| Existing tests | Library page tests exercised database controls; widget tests covered gallery/list responsiveness, navigation and personal fields. Migration tests covered schemas 1/2/3/5/6 to the current schema. |

## Product behavior

- The app opens Games, with Games / Statistics / Settings navigation. `/home`
  redirects to Games.
- The normal library shows a year selector (previous/next, available years and
  always-accessible No year), title search, Add game and the gallery.
- It starts in the current local calendar year. Search and selected year survive
  a visit to Add/Edit/Detail during the same app session. Old saved views do not
  constrain this gallery.
- Cards show cover, title, optional personal rating/hours, a subtle finished/not
  finished label and optional personally played platform. No catalog platforms,
  genres, release dates, bulk controls or presentation settings are exposed.

## Played-year semantics and preservation

Schema 8 adds nullable `LibraryEntry.playedYear`. Migration runs in the existing
upgrade transaction, using the year decoded from `LibraryEntry.completedAt`
(the same local date semantics used by Drift in the app). It does this even if
`isCompleted` is false, and includes soft-deleted entries. No release date,
created/updated timestamp or ambiguous historical data supplies a year.
Entries without a completion date remain null. No prior field or historical
row is changed by the v8 step.

The year is independent from completion after migration. New manual records
default to the gallery's selected year (or current year on a direct Add route).
Adding from No year proposes an empty year. One optional year field is added to
the existing personal form to assign, change or clear it; editing preloads and
preserves the persisted year, including null. This is the only form adaptation.
Changing a completion date does not overwrite an explicitly assigned log year.
Existing CSV imports initialize it from the imported completion date or null.
JSON export v2 includes the additive `playedYear` field and still includes legacy
playthrough records; it is still not a backup of local media bytes.

## Deliberately dormant

Home, `LegacyLibraryPage` (the old workspace), table/list widgets, saved-view
repositories, advanced filters, column configuration, summaries and bulk
controls remain available in source for the later cleanup. None are connected
to normal library navigation. Their stored data and regression tests remain.
No new lifecycle or playthrough flow was added. Detail and Statistics layouts
are unchanged; shared state labels now say Finished / Not finished.

## Commit boundary

The pre-existing portable-storage work is excluded. `app_database.dart` is the
only shared file: this commit stages only the v8 migration, while preserving its
pre-existing portable connection changes in the working tree. Other unrelated
files are checked against their pre-task hashes.

## Verification

- `dart format` applied to task Dart files.
- `flutter analyze`: no issues.
- `flutter test`: 300 tests passed, including every previous migration test,
  v8 backfill/preservation/rollback, annual navigation/search, mobile and desktop
  layout, personal card values and played-year persistence/export.
- No local user database, credentials, covers or `dist` artifacts were modified.
