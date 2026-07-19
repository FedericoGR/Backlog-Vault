# E5 completion report — presentation, UX and code quality

Date: 2026-07-19.

## Git consolidation

- Initial branch: `codex/offline-e4-architecture-refactor` at `f314b61`.
- E4 checker 5/5, analyze and 257/257 tests passed before consolidation.
- `main` advanced by fast-forward from `366de4b` to `f314b61`; post-merge
  checker/analyze/tests passed and `origin/main` is aligned at `f314b61`.
- E5 branch: `codex/offline-e5-presentation-quality`, created from that main.
- Implementation commits before this report:
  - `a5aae9e refactor: simplify responsive presentation`;
  - `818d475 test: strengthen responsive and accessibility coverage`.
- This report is committed as `docs: document offline presentation refactor`.
  The E5 branch is pushed, but is intentionally not merged to `main`.

## Scope and invariants

E5 changed presentation composition, visual contracts, safe copy, public API
documentation and widget/architecture coverage. It added no feature or
dependency and did not modify repositories, queries, business rules, routes,
schema, import/export behavior, provider behavior or storage.

- app version: `0.3.0+5`;
- Drift schema: 6;
- library export `formatVersion`: 1;
- Sync and complex backup/restore: absent;
- E6: not started.

## Audit coverage

The inventory covers shell/navigation, Home, library table/gallery/list,
filters, saved views, game create/edit/detail, playthroughs, CSV import, JSON
export, metadata, media/covers, bulk metadata, statistics, Settings,
credentials, loading/empty/error/progress states, dialogs and the filter sheet.
Each surface records its ViewModel, states, width behavior, findings and applied
decision in `docs/audit/e5/presentation_inventory.md`.

## Presentation structure

Baseline presentation contained 13 Dart files and 10,534 lines. Final
presentation contains 40 files and 10,087 lines: 27 cohesive private files were
extracted while total presentation code decreased by 447 lines (4.2%). No file
was moved or renamed; extraction uses `part` only to keep page-owned helpers
private. No widget was deleted solely to reduce line count.

| Owner | E4 | E5 shell | Resulting responsibility |
|---|---:|---:|---|
| Library page | 1,808 | 345 | state/coordination; toolbar, results, filters and actions extracted |
| Library catalog widgets | 754 | 28 | private library root; summary/grid/list/sidebar extracted |
| Bulk metadata | 1,763 | 499 | stage coordination; options, preview, confirmation and result extracted |
| Game form | 1,502 | 631 | one form state; sections and optional metadata extracted |
| Game detail | 1,324 | 161 | async page shell; sections/actions/playthrough dialogs extracted |
| Statistics | 682 | 94 | provider/page shell; dashboard/breakdowns/recent extracted |
| Metadata dialog | 639 | 411 | async dialog state; result/diff widgets extracted |
| CSV import | 567 | 188 | workflow shell; four private steps extracted |
| Settings | 548 | 308 | state/actions; grouped sections extracted |
| Media dialog | 499 | 330 | async dialog state; candidate grid extracted |

Residual manual hotspots are justified in
`docs/audit/e5/remaining_presentation_hotspots.md`; generated files are excluded.

## Shared visual contracts

Created with multiple consumers:

- `BvAsyncActionButton`: stable label, disabled busy state, progress semantics
  and double-submit prevention;
- `BvFeedback`: one transient message per explicit action;
- `BvLayout`: 960 px readable content, 1200 px wide content, 720 px dialog,
  48 px touch target and 24 px icon constants.

Existing `BvSpacing`, `BvRadii`, `ColorScheme`, `BvThemeExtension`, panels,
surfaces, chips, banners and page scaffold remain the design vocabulary.
`BvBreakpoints` centralizes mobile 600, navigation rail 840, library 900,
detail 920 and desktop 1200. Layout is chosen from constraints, not OS identity.

Loading, empty, recoverable error, progress/cancel and in-progress actions now
require feature-owned localized copy. The baseline ten direct snackbar
constructions became one implementation in `BvFeedback`. Feature dialogs stay
local because their contents and confirmation rules differ.

## Responsive and interaction improvements

- Shell switches between bottom navigation and labeled rail at one breakpoint.
- Library preserves one `LibraryViewModel` while selecting wide table/sidebar,
  gallery or compact lazy list by width.
- Forms, detail, CSV, bulk, statistics and Settings use readable bounds and
  wrapping/single-column compositions already covered by widget tests.
- Potentially large library and media collections remain lazy and now carry
  stable game/asset keys.
- No shortcut was added. Standard Material Tab, Enter/Space, Escape, focus,
  hover, mouse scroll and touch behavior is preserved.
- Icon-only controls expose tooltips; shared states pass at 320×640 with text
  scale 2 and primary pages have narrow/wide no-overflow coverage.

## Localization, feedback and privacy

- 28 EN/ES ARB keys added; 0 keys removed.
- Added safe generic game/playthrough/CSV/bulk failures, credential labels,
  external-ID formatting, localized bulk score/reasons/issues and typed bulk
  confirmation.
- Removed technical `{error}` placeholders from the existing metadata cover and
  bulk preview messages without removing their keys.
- Baseline direct `error.toString()` references in presentation: 19. Final: 0.
- Baseline direct snackbar constructions: 10. Final: 1 shared implementation.
- Functional hardcoded bulk keywords/score: removed. Provider proper names,
  persisted domain values, numeric choices and separators remain intentional.
- Public/code documentation: 55 `///` lines added, 0 removed; TODO/FIXME: 0.
- A sixth architecture rule prevents presentation from rendering raw exception
  strings. Credential ViewModel state remains presence-only.

## Tests and checker

- Baseline: 257 tests.
- Final: 263/263; 6 added, 0 deleted.
- Added four shared-state tests: localized retry/cancel, async double-submit and
  busy semantics, narrow/large-text overflow, and single feedback replacement.
- Added one localization privacy test and one architecture rule.
- Existing library, form, detail, bulk, CSV, metadata, media, statistics,
  Settings, schema migration, export and domain regressions remain green.
- Architecture checker: 6/6 in 9.75 s.
- `flutter analyze`: clean in 10.67 s.
- Full suite: 263/263 in 51.01 s.

## Final build validation

- `dart format`: 251 files checked, 0 changed, 1.94 s.
- `flutter clean`: exit 0, 2.81 s; retained the known Windows locked-build
  warning before subsequent builds recreated all output successfully.
- `flutter pub get`: 2.94 s; dependency manifests unchanged.
- build_runner: 444 outputs in 69.42 s; the current tool ignores the obsolete
  `--delete-conflicting-outputs` option.
- localization generation: 1.93 s.
- Windows release: 14 files, 35,667,064 bytes; executable 81,920 bytes;
  63.48 s.
- Android release: 67,324,009 bytes; SHA-256
  `4B980D24F4222143EF3D448880944C95894AE280175D0A0776EEDFD0DB4345EE`;
  128.04 s.
- `git diff --check`: clean.

Baseline size was 35,667,064 bytes on Windows and 67,307,545 bytes for the APK.
The 16,464-byte APK increase is consistent with added bilingual copy and no new
dependency/asset. No size reduction was expected from source-file division.

## dart doc

`dart doc` and `dart doc --dry-run` both abort in bundled `dartdoc 9.0.4`
during `DocumentationComment._stripDocImports` with the same internal
`RangeError (0..9089: 9202)`. The failure was reproduced in a fresh minimal
Flutter package containing one documented widget, so it is independent of
Backlog Vault source/comments. Analyzer reports no documentation diagnostic.
This toolchain defect must be rerun after a Flutter/Dart hotfix or explicitly
waived before merge; no dependency or SDK change was made inside E5.

## QA

- Automated Windows-width and Android-width widget QA passed, including
  navigation, library layouts, long text, forms, detail, provider dialogs, CSV,
  bulk, statistics and Settings.
- Manual Windows QA was not run because the project exposes no supported
  disposable AppData profile and the task forbids risking real AppData.
- Physical Android QA was not run: `flutter devices` listed Windows and web
  only, and full-path ADB listed no device. No APK was installed and no device
  state was changed. Physical QA is a gate before an eventual E5 merge, not a
  blocker for the implementation branch.

## Warnings and secret scan

Known non-blocking warnings remain: 35 packages have newer incompatible
versions, build_runner's obsolete flag, `file_picker` legacy KGP, missing
Cupertino icon font, and the transient Windows build handle. The dartdoc crash
is classified separately as a reproducible toolchain limitation.

Targeted secret-assignment scan found 0 candidate files. No tracked or
untracked APK, archive, DB, log, environment file, keystore, certificate or key
artifact exists. `gitleaks` is not installed, so the scan used Git/regex and
artifact inventory. Generated build output remains ignored.

## Documentation and final state

Created the required presentation inventory, consistency report, accessibility
review, residual-hotspot report, 184-row repository inventory, responsive
guidelines, component guidelines, UX glossary and this completion report.
Updated current architecture, target folder structure and code/comment policy.
README, installation and Settings user documentation were not changed because
no user-facing capability, installation step or Settings behavior changed.

After the documentation commit and push, the branch is clean and aligned with
`origin/codex/offline-e5-presentation-quality`; `main` remains `f314b61`. E5 is
not merged, tagged or released. No branch was deleted and E6 was not started.

## Exact E6 recommendation

Start E6 only after approving the E5 toolchain/physical-QA gates. From the
eventual merged main, first measure dependency tree, assets and per-platform
binary composition; then remove only proven-unused dependencies/resources with
regression tests and before/after Windows/APK sizes. Do not touch schema 6,
export format 1 or the presentation behavior established here.

# Decisiones que requieren aprobación de Federico

- Aprobar el crash reproducible de `dartdoc 9.0.4` como limitación del toolchain
  o exigir una actualización controlada de Flutter/Dart y un rerun antes del
  merge de E5.
- Proveer/aprobar un perfil descartable para QA manual Windows y conectar el
  Motorola con un perfil confirmado para QA físico Android antes del merge.
