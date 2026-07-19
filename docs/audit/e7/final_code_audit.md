# E7 final code audit

Scope: every file listed by the final `git ls-files`, with the per-file result
in `final_repository_file_review.csv`. The audit combines path/category
inventory, import-boundary checks, targeted residue searches, generated-file
policy, tests, build output inspection, privacy scans, and manual review of the
release-critical database/export/packaging paths.

## Result

- Product source remains feature-first: app/bootstrap/routing/theme, shared
  core, and feature presentation/application/domain/data boundaries.
- The six objective architecture rules pass: core does not import features;
  presentation avoids Drift, filesystem, HTTP, secure storage, and data layers;
  presentation does not render raw exception strings; data does not import
  presentation; non-visual feature dependencies are acyclic; removed modules
  remain absent.
- No ViewModel/application file uses `BuildContext`; visual context use remains
  in widgets and routing shells.
- `app_database.g.dart` and localization outputs are correctly identified as
  generated and regenerated from tracked inputs.
- Release scripts are repository-relative, read the version from `pubspec.yaml`,
  never install Android, and validate explicit artifact names and allowlists.
- No critical TODO/FIXME was found. The two toolchain template TODO comments in
  platform build files are upstream scaffolding, not unfinished product logic.

## Changes made by the audit

- Replaced obsolete top-level v1 RC3 documents that described the retired
  product with canonical `docs/release/` documentation.
- Removed personal-machine examples from active historical documentation and
  changed privacy-test paths to synthetic users.
- Centralized RC version invariants in `tool/verify_release_candidate.ps1` and
  added release-script regression coverage.
- Corrected active product/install/build/export documentation for
  `1.0.0-rc1+6` and the arm64/universal strategy.
- Corrected two QA-discovered presentation defects without changing product
  scope: the Home localized count arguments now follow the ARB contract, and
  editing an imported playthrough whose start date is absent preserves that
  absence instead of inventing the current date. Both have widget regressions.
- Corrected Android candidate packaging so the recommended arm64-only APK is a
  non-split build with versionCode 6. Flutter's validation-only ABI split keeps
  its derived code 2006 and is deliberately not the published arm64 asset.

No stable feature code was reformatted or refactored for aesthetics. Product
changes are limited to the approved version name and those two observed bug
fixes. Schema 6, export format 1, models, and product scope remain unchanged.

The final executable gate is 270/270 tests, architecture checker 6/6, clean
analysis, Windows and Android release builds, and physical Android QA of the
exact arm64 candidate.
