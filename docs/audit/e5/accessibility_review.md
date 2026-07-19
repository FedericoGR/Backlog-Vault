# E5 basic accessibility review

This is a focused engineering review, not a WCAG certification.

## Verified in code and tests

- Standard Material buttons, menus, fields, navigation rail/bar and dialogs
  preserve focus, keyboard activation, hover and platform semantics.
- Icon-only actions under `app/`, `core/design_system/` and feature
  presentation expose tooltips; the code audit found no unlabelled
  `IconButton` construction.
- `BvAsyncActionButton` announces a localized busy label, disables activation
  while busy and keeps a stable visual label.
- `BvErrorState` and `BvProgressPanel` accept localized retry/cancel labels;
  actions are not rendered with an incomplete callback/label pair.
- `BvErrorState` scrolls vertically when large text and a short viewport cannot
  fit the content.
- Shared states pass a 320×640 widget test at text scale 2 without overflow.
- App shell tests cover 390 px bottom navigation and 1366 px navigation rail.
- Existing library tests cover wide table/sidebar, medium layout switching,
  narrow row actions and long selection titles without overflow.
- Game form/detail, CSV, bulk, metadata, media, statistics and Settings widget
  tests exercise their primary compositions.
- Shared touch/layout constants document 48 px as the minimum target and 24 px
  as the standard icon size. Standard Material controls provide these targets.

## Image semantics

Local cover thumbnails remain bounded and provide a visual fallback. Candidate
images are part of selectable cards whose surrounding title/action conveys the
meaning; decorative gradients/check marks do not add duplicate spoken content.

## Keyboard and mouse

No custom shortcut was added: standard Tab, Shift+Tab, Enter and Space behavior
is retained, and Escape remains owned by Flutter dialogs. Lists and grids use
standard scrollables. This avoids an untested shortcut or a platform-only flow.

## Remaining manual checks

- Screen-reader traversal and spoken cover context on physical Android.
- Windows high-contrast themes outside the application's supported theme set.
- Full keyboard traversal of every long form and every provider dialog.
- Extreme translations or text scale above 2 on all screens.

These are QA depth items, not known defects. Physical Android QA remains a gate
when no confirmed disposable profile is available.
