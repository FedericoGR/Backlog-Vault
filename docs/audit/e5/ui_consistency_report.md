# E5 UI consistency report

Date: 2026-07-19. Scope: presentation-only refactor from `f314b61`.

## Shared rules applied

| Concern | Contract | Applied consumers |
|---|---|---|
| Page spacing | `BvPageScaffold` + `BvSpacing.page/pageCompact` | primary routed pages |
| Readable width | `BvLayout.readableContentWidth` (960) | Settings and CSV |
| Wide workspace | `BvLayout.wideContentWidth` (1200) | Home, Statistics and bulk metadata |
| Navigation | `BvBreakpoints.navigationRail` (840) | `AppShell` |
| Loading | `BvLoadingState(label:)` | library, home, game and statistics flows |
| Empty results | `BvEmptyState` with feature-owned title/message/action | library, providers and dashboards |
| Recoverable error | `BvErrorState` with safe localized copy and optional retry | library, home, game and statistics |
| In-progress action | `BvAsyncActionButton` | game save, CSV, bulk apply, export, metadata and media |
| Transient feedback | `BvFeedback.show` | library, game, metadata and Settings actions |
| Progress/cancel | `BvProgressPanel(cancelLabel:)` | bulk metadata workflow |

Spacing continues to use the compact 4/8/12/16/20/24/32 scale. Existing
`ColorScheme`, `BvThemeExtension`, radii and Material controls remain the visual
source of truth. E5 did not introduce another theme, package or design system.

## Screen results

- Shell: one width-based navigation rule replaces a duplicated numeric check.
- Library: table, gallery and compact list still consume one `LibraryViewModel`;
  toolbar, summary, sidebar, result states, dialogs and actions are separated.
- Game form: basic, personal, catalog and metadata/media sections remain in one
  form state; the save action is stable and cannot be submitted twice.
- Game detail/playthroughs: display sections, actions and form dialogs have
  distinct files while retaining the current ownership and navigation.
- Bulk metadata/media: options, preview, progress, confirmation and result are
  explicit stages. Candidate reasons and confirmation copy are localized; raw
  provider errors never reach the visible result.
- CSV: file, mapping, preview and result are private workflow steps with the
  parser/import contracts unchanged.
- Statistics: dashboard, breakdown and recent activity sections are separated
  and constrained to a wide readable body.
- Settings: appearance, language, data export, credentials and app information
  remain grouped. Sync, backup and restore stay absent.

## Feedback review

The baseline had ten direct `SnackBar` constructions. E5 leaves one construction
inside `BvFeedback`, which first hides the current message so one action cannot
produce stacked feedback. Picker cancellation remains a non-error. Destructive
dialogs stay local to the feature because their summary and typed confirmation
are behavior-specific. Seventeen `AlertDialog`s and one filter bottom sheet
remain, all scrollable or bounded by their owning surface.

## Localization and privacy

Functional shell titles, credential labels, external IDs, generic failures,
bulk score/reasons and bulk typed confirmation are supplied by EN/ES catalogs.
Provider/product names, persisted game-type values, numeric ratings and visual
separators are intentionally not translated as free UI copy. Presentation has
zero direct `error.toString()` calls and no stack trace or credential state.

## No behavioral change

Routes, ViewModels, validation, filters, saved views, CSV rules, export format,
metadata matching, cover storage, statistics calculations, schema and version
are unchanged. No dependency or feature was added.
