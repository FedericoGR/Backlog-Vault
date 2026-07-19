# E7 final dependency map

The pubspec contains 16 direct runtime entries and 6 direct development entries.
All 22 have a productive consumer; no package is added, removed, or upgraded in
E7.

```text
Flutter app
├─ UI/localization: flutter, flutter_localizations, intl, data_table_2
├─ state/navigation: flutter_riverpod, go_router
├─ local data: drift, drift_flutter, uuid
├─ local files/preferences: path_provider, file_picker, shared_preferences
├─ optional providers: http, flutter_secure_storage, crypto
└─ development: build_runner, drift_dev, flutter_lints,
   flutter_test, mocktail, test
```

| Dependency group | Product responsibility | Release decision |
|---|---|---|
| Flutter/localizations/intl | Windows/Android UI and EN/ES copy | keep |
| Riverpod/router | state boundaries and navigation | keep |
| Drift/drift_flutter/uuid | schema-6 persistence, queries, stable IDs | keep |
| path_provider/file_picker/csv | managed covers, CSV selection/parsing, JSON destination | keep |
| data_table_2 | responsive library table | keep |
| http | explicit RAWG/IGDB/SteamGridDB requests | keep |
| secure storage/crypto | optional credentials and media SHA-256 | keep |
| shared_preferences | per-device language preference | keep |
| six dev packages | code generation, analysis, and tests | keep |

Generated plugin metadata contains only plugins required by these retained
features. There is no scanner, QR, barcode, ML Kit, camera, or local-network
transport dependency. The `file_picker` KGP warning is documented separately;
changing its version would expand the RC regression surface without fixing a
product defect.
