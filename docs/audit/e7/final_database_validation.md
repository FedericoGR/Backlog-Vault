# E7 final database validation

## Contract

- Drift schema: 6.
- Functional tables: 10 (`games`, `library_entries`, `platforms`,
  `library_entry_platforms`, `genres`, `game_genres`, `playthroughs`,
  `saved_views`, `external_game_ids`, `media_assets`).
- Historical transport tables: 6 absent after schema 5→6.
- Historical transport indexes: 8 absent after schema 5→6.
- Foreign keys remain enabled on every open.

The migration validates the ten functional names and
`PRAGMA foreign_key_check` before any drop, removes only the retired objects,
then repeats both checks. Drift performs the upgrade transactionally. It does
not rebuild functional tables, rewrite IDs, modify media files, or touch
provider credentials.

## Automated evidence

The schema-5 integration fixture contains active and soft-deleted rows, two
playthroughs, platform/genre relations, one saved view, external metadata, one
local-media record, and rows in every retired table. Tests assert:

- user version 5→6 and preservation of exact functional counts/IDs/values;
- removal of all six historical tables and eight indexes;
- empty `foreign_key_check` before continued reads/writes;
- successful insert after migration;
- close and reopen at schema 6 without repeating migration;
- safe rejection of an incomplete schema 5 before destructive statements;
- older schema 1/2/3 upgrade paths still preserve their supported data.

The generated Drift schema declares the same ten tables and explicit
references for entry→game, entry-platform→entry/platform,
game-genre→game/genre, playthrough→entry/optional platform,
external-ID→game, and media→game.

## Physical evidence

The Android release gate records version/install times, first opening logs,
visible library state, a force-stop/reopen, and the absence of Drift, missing
table, and foreign-key errors. It does not use root, extract the private DB, or
modify the DB outside normal app behavior. This is indirect runtime evidence
for an already-schema-6 installation and direct migration evidence only when
the installed profile is still schema 5.
