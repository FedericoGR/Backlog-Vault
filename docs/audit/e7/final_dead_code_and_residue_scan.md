# E7 dead code and retired-residue scan

The final scan covers productive Dart, platform configuration, pubspec/lock,
tests, scripts, and documentation classification. Generic substring `sync`
also matches Dart `async` and Windows `std::ios::sync_with_stdio`; those are
false positives.

## Retired surface classification

| Match family | Active product result | Allowed occurrences |
|---|---|---|
| device transport, pairing, QR, LAN, sockets | absent | privacy redactor keeps legacy secret-name patterns so accidental values remain redactable; tests assert absence |
| `.vaultsync` / `.vaultpair` | not produced or consumed | architecture/export privacy tests and historical docs only |
| camera/scanner/barcode/ML Kit | absent | no productive/config/dependency match |
| complex backup/restore/encryption/password flow | absent | documentation explains the limitation; architecture absence tokens |
| six historical Sync tables/eight indexes | not declared or recreated | schema-5 fixture and the one-way 5→6 drop migration |
| legacy secure keys | no active transport use | exact cleanup allowlist and redaction tests only |

Precise productive/dependency searches found zero `ServerSocket`,
`mobile_scanner`, `qr_flutter`, `CAMERA`, `cryptography`, or `PBKDF2` matches.
The table-name matches in product code are exclusively `DROP ... IF EXISTS`
statements executed for schema 5→6. No removed route, service, provider, ARB
key, native plugin, manifest permission, or packaging input was found.

## Dead code and repository residue

- `flutter analyze` and the full test suite are the executable dead/reference
  checks; no analyzer finding remains.
- All direct dependencies have productive imports or SDK/build consumers.
- No tracked APK, ZIP, database, log, secure file, environment file, keystore,
  symbols package, QA CSV, or QA JSON is permitted.
- Generated Drift/localization/platform registrant files have tracked inputs and
  an explicit regeneration policy.
- Historical E1–E6 audits may name retired behavior for traceability; they are
  not product guidance and do not link from an active route.

Decision: retain the migration fixture, exact cleanup allowlist, privacy
redaction patterns, and absence tests. Deleting them would reduce migration or
privacy coverage rather than remove functional residue.
