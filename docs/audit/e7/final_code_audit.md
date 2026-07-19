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

No stable feature code was reformatted or refactored for aesthetics. The only
application constant change is the approved version name; schema 6, export
format 1, models, and behavior remain unchanged.
