# Dead and redundant code removed in E4

- data-layer `platformsProvider` and `genresProvider` replaced by mapped catalog
  application providers;
- data-layer library row and custom-view providers moved to application;
- independent table/layout Notifiers replaced by one `LibraryViewModel`;
- playthrough save/update/delete methods removed from `GameRepository`;
- IGDB cover mapper removed from the HTTP provider file;
- direct FilePicker and filesystem access removed from media presentation;
- direct secure-storage orchestration removed from Settings;
- direct repository orchestration removed from Library, CSV import, Statistics,
  bulk metadata and Games presentation;
- Drift-generated `Game`, `LibraryEntry`, `Playthrough`, catalog and media rows
  removed from presentation state.

No compatibility aliases, global barrels, commented code or empty folders were
left behind. No functional table, field, export member or provider capability
was removed.
