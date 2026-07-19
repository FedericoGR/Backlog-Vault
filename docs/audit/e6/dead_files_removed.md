# Dead files and workspace cleanup

E6 reviewed all tracked paths, source imports, tests, fixtures, documentation,
native runners, generated files, and the existing packaging script.

## Tracked source result

No productive Dart source, test, fixture, native resource, or active technical
document was demonstrably dead. Therefore E6 deletes zero tracked product files
and zero tests. In particular:

- provider JSON fixtures are consumed by parser/client tests and never ship;
- launcher PNGs and the Windows ICO are platform resources;
- historical E1-E5 audits, migrations, export format, ADRs, checksums, QA, and
  release notes remain useful evidence and are small;
- the vendored Windows secure-storage plugin is required by external provider
  credentials;
- generated Drift/localization/registrant files follow the documented policy.

The old `tool/package_windows.ps1` implementation was replaced in place. Its
unvalidated copy-all staging and non-deterministic `Compress-Archive` behavior
no longer remains; this is a build-script replacement, not product deletion.

## Generated candidates

The cleanup dry-run identified only ignored/reproducible output: `build/`,
`dist/`, `.dart_tool/`, `android/.gradle/`, `windows/flutter/ephemeral/`, and
Flutter plugin metadata. At the first E6 dry-run these occupied more than
2.1 GiB. They are removed only after final validation with the reviewed
`tool/clean_workspace.ps1 -Apply` allowlist.

No external bundle, AppData, database, export, cover, credential, SDK cache, or
the retained E1 diagnostic directories is targeted.
