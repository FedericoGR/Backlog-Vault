# E5 presentation inventory

Baseline date: 2026-07-19. Baseline commit: `f314b61`.

## Baseline

- 154 Dart files under `lib/`; 13 presentation Dart files and 10,534
  presentation lines.
- architecture checker: 5/5; analyze: clean; tests: 257/257.
- Windows release bundle: 35,667,064 bytes (14 files).
- Android release APK: 67,307,545 bytes; SHA-256
  `4161858718DF5A4CCE7E68EFFCD56031DA27611061F9A741A40745FE66BFF213`.
- visible hardcoded-string candidates: 22. Proper names, numeric rating values,
  separators and the product name account for 18; four shared/error labels need
  localization or redaction review.
- TODO/FIXME under `lib/` and `test/`: 0.
- direct visual-value candidates: 230. Most are legitimate one-off dimensions,
  but repeated page paddings and dialog constraints should use the existing
  tokens.
- feedback surfaces: 17 `AlertDialog`s, one modal bottom sheet and 10
  `SnackBar` constructions. The baseline contains 19 direct
  `error.toString()` references in presentation; some are redacted but none is
  an acceptable localized UI contract.

Known baseline warnings are unchanged: 35 packages have newer incompatible
versions, build_runner ignores `--delete-conflicting-outputs`, Windows can keep
one previous build handle open, `file_picker` uses legacy KGP, and the Android
build reports the absent Cupertino icon font.

## Screens and workflows

| Surface | Path / ViewModel | Main widgets and states | Desktop / mobile | Findings | Decision |
|---|---|---|---|---|---|
| Shell and navigation | `app/routing/app_shell.dart`; router only | `NavigationRail`, `NavigationBar`, routed child | rail at 840 px; bottom navigation below | breakpoint duplicated instead of using `BvBreakpoints`; standard controls already provide keyboard/focus | centralize breakpoint; retain routes and behavior |
| Home | `library/presentation/home_page.dart`; `libraryHomeSummaryProvider` | hero, counters, activity sections, quick panel, loading/error/empty | wrapping cards and one-column fallback | coherent and already small enough; private widgets have one responsibility | maintain; adopt safe shared error state |
| Library workspace | `library/presentation/game_list_page.dart`; `LibraryViewModel`, row/catalog providers | toolbar, saved views, active filters, summary, selection, table, grid/list, dialogs | table/sidebar on wide windows; list/sheet on narrow screens | 1,808-line hotspot; page, toolbar, table, dialogs and feedback share one file; raw load error exposed | divide into page, toolbar, results, filters and actions; preserve state source |
| Library catalog layouts | `library/presentation/widgets/library_catalog_widgets.dart` | summary/selection, gallery cards, compact list, sidebar | lazy grid/list with width-aware actions | 754 lines and four unrelated visual groups | divide by summary, grid, list and filter sidebar |
| Game create/edit | `games/presentation/game_form_page.dart`; `GameFormViewModel` | basic data, personal library data, catalogs, completion, metadata, cover, submit | responsive field grid and scrollable form | 1,502 lines; embedded metadata workflow and field components obscure page state; submit error leaks exception text | divide metadata preview and cohesive form sections; safe feedback and double-submit coverage |
| Game detail | `games/presentation/game_detail_page.dart`; `GameDetailViewModel` | header, cover, work data, personal data, progress, playthroughs, notes, dialogs | wide cover/content split; stacked narrow layout | 1,324 lines; display sections, action coordination and two forms are mixed; two raw errors exposed | divide page, sections, action helpers and playthrough dialogs |
| Playthrough forms | embedded in game detail; `GameDetailViewModel` | completion/edit dialogs, dates, hours, rating, platform, notes | scrollable dialogs | correct ownership and validation; dialog code dominates detail page | extract as a cohesive detail-library part; preserve semantics |
| Notion CSV import | `import_export/notion_csv/presentation/import_notion_csv_page.dart`; `NotionCsvImportViewModel` | file, mapping, preview, result, confirmation, warning/error | step content scrolls on narrow viewport | 567 lines; step widgets are cohesive but crowded in page | divide workflow shell from file/mapping/preview/result steps |
| Library JSON export | Settings action; `LibraryExportController` | explanation, progress, success/cancel/error | same action on both targets | single action already simple; snackbar patterns duplicated | keep behavior; use one feedback helper |
| Metadata search | `metadata/presentation/metadata_search_dialog.dart`; `MetadataSearchViewModel` | provider/query, candidate list, diff preview, confirmation, loading/error | constrained scrollable dialog | 639 lines; state and visual result components can be separated; exception is already mapped by feature copy | divide dialog controller from candidates/diff/error widgets |
| Cover/media search | `media/presentation/media_search_dialog.dart`; `MediaSearchViewModel` | provider/query, current/candidates, lazy grid, local picker, loading/error | responsive grid, fixed dialog actions | 499 lines; state and candidate rendering mixed | divide dialog controller from candidate/grid/error widgets |
| Bulk metadata/media | `bulk_metadata_import/presentation/bulk_metadata_import_page.dart`; `BulkMetadataImportViewModel` | scope/options, progress, preview filters/items, cover selection, confirmation, result/errors | wrapping options, lazy lists and scrollable dialogs | 1,763-line hotspot; four real stages coexist; repeated badges/summary pills | divide into options, progress/preview, confirmation and result components; preserve batching/cancellation |
| Statistics | `statistics/presentation/statistics_page.dart`; statistics providers | hero, summary cards, status/rating/quality/year/category/recent sections | wraps cards; list-based narrow fallback | 682 lines; coherent calculations remain outside UI, but dashboard sections clutter page | divide dashboard shell, breakdowns and recent/stat visuals |
| Settings | `settings/presentation/settings_page.dart`; `ExternalCredentialsViewModel`, export/language providers | overview, appearance/language, data/export, credentials, app/privacy | max-width panels and wrapping shortcuts | 548 lines; credential forms and general panels share page; proper names are intentionally not localized | divide page actions from overview/configuration widgets; unify feedback safely |
| Shared loading/empty/error/progress | `core/design_system/bv_*_state.dart` | centered loading, differentiated empty content, error/retry panel, progress/cancel | bounded content and compact-height handling | retry/cancel/default labels are hardcoded Spanish; public contracts lack documentation | require localized labels where actions exist; add docs, semantics and tests |

## Cross-cutting observations

- All feature presentation imports satisfy the E4 boundary: no Drift,
  filesystem, HTTP, secure storage or infrastructure services.
- Library filters and layout survive navigation because `LibraryViewModel` is
  the single source of mutable state; E5 must not duplicate it in widgets.
- Lists/grids used for potentially large collections are lazy. No clear query
  inefficiency requires repository changes.
- Standard Material buttons, fields, navigation and menus already provide
  Enter/Space, focus and hover behavior. Tooltips exist on most icon-only
  actions; tests need to enforce the critical ones.
- Empty library and no filtered results are already distinct. Provider missing
  credentials, external failure and local failure also have distinct copy in
  their owning flows.
- Dialogs are generally scrollable, but maximum width/height and narrow-screen
  padding are not centrally documented.

The audit authorizes only presentation decomposition, token reuse, safe copy,
basic semantics and focused performance improvements. It does not authorize a
new workflow, route, domain rule, schema change or external dependency.

## Applied outcome

- Presentation was divided into 40 Dart files and 10,087 lines, from 13 files
  and 10,534 lines. The added files are cohesive parts of an owning Dart
  library, not new public feature APIs.
- The former 1,808-line library page is now a 345-line state/coordination shell.
  Its toolbar, result layouts, filters and actions are independently named.
- Game form, game detail, bulk metadata, CSV, metadata, media, statistics and
  Settings were divided by real visual stage or section. The remaining large
  parts are recorded separately and were not split mechanically.
- `BvAsyncActionButton`, `BvFeedback` and `BvLayout` have multiple real
  consumers. Shared loading/error/progress contracts now require localized
  copy from the owner.
- Direct raw exception rendering in presentation is 0. A sixth architecture
  check prevents it from returning. Snackbar construction is centralized in
  `BvFeedback`; feature-owned dialogs remain explicit because their content and
  confirmation rules differ.
- Potentially large library and media collections remain lazy and now use
  stable keys for game/asset identity. No repository/query behavior changed.
