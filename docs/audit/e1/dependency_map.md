# Mapa de dependencias actual

## Runtime principal

```mermaid
flowchart LR
  UI["Flutter widgets"] --> Router["go_router"]
  UI --> State["Riverpod"]
  State --> Repos["Repositories"]
  Repos --> Drift["Drift / drift_flutter"]
  Drift --> SQLite["sqlite3 + JNI"]
  Repos --> SyncTx["SyncAwareTransaction"]
  SyncTx --> SyncTables["6 tablas Sync"]
  Metadata["Metadata/media opcional"] --> HTTP["http"]
  Metadata --> Secrets["flutter_secure_storage"]
  Files["CSV / backup / media"] --> Picker["file_picker"]
  Files --> Paths["path_provider"]
  Backup["Backup"] --> Archive["archive"]
  Backup --> Crypto["crypto + cryptography"]
  Sync["Sync / pairing / LAN"] --> QR["qr_flutter + mobile_scanner"]
  Sync --> Crypto
  Sync --> Picker
  Sync --> Secrets
```

## Features y acoplamientos

Las aristas se calcularon resolviendo imports locales. `core` no importa features, lo cual es correcto. Los problemas están entre features y entre presentation/data.

```mermaid
flowchart TD
  App["app"] --> Library
  App --> Games
  App --> ImportExport["import_export"]
  App --> Backup["backup_restore"]
  App --> Statistics
  App --> Settings
  Games <--> Library
  Games <--> Metadata
  Games <--> Media
  Media <--> Metadata
  Media <--> Sync
  Settings --> Sync
  ImportExport --> Library
  ImportExport --> Playthroughs
  Bulk["bulk_metadata_import"] --> Library
  Bulk --> Metadata
  Bulk --> Media
  Bulk --> Sync
  Statistics --> Library
  Statistics --> Playthroughs
  L10n["l10n"] --> Library
  L10n --> Metadata
  L10n --> ImportExport
  Library --> L10n
  Metadata --> L10n
  ImportExport --> L10n
```

Los ciclos arquitectónicos relevantes son:

- games ↔ library: aggregates/domains en library, mutaciones en games y páginas library llamando `GameRepository`;
- games ↔ metadata/media: dialogs y modelos cruzan límites de feature;
- media ↔ metadata: media reutiliza auth/client/key storage de metadata, y metadata presenta media;
- media ↔ Sync: Sync transfiere media y `MediaRepository` registra cambios Sync;
- l10n ↔ varias features: `domain_localizations.dart` importa enums de features y las vistas importan l10n.

No se demostró un ciclo de import file-to-file que impida compilar; son ciclos de ownership/feature que vuelven frágiles los cambios.

## Repositorios acoplados a Sync

```mermaid
flowchart LR
  SyncAware["SyncAwareTransaction"] --> CatalogRepo
  SyncAware --> GameRepo
  SyncAware --> CsvRepo
  SyncAware --> SavedViewsRepo
  SyncAware --> MediaRepo
  SyncAware --> MetadataRepo
  SyncAware --> ExportRepo
  CatalogRepo --> DB[(Drift)]
  GameRepo --> DB
  CsvRepo --> DB
  SavedViewsRepo --> DB
  MediaRepo --> DB
  MetadataRepo --> DB
  ExportRepo --> DB
```

Esta es la razón por la que E2 no puede empezar borrando `lib/features/sync/`: primero hay que reemplazar la frontera transaccional en esos siete repositorios.

## Nativo

```mermaid
flowchart TB
  APK["APK universal 82,28 MiB"] --> ABI1["armeabi-v7a"]
  APK --> ABI2["arm64-v8a"]
  APK --> ABI3["x86_64"]
  ABI1 --> FlutterSO["Flutter + app.so"]
  ABI2 --> FlutterSO
  ABI3 --> FlutterSO
  ABI1 --> Scanner["Barhopper / ML"]
  ABI2 --> Scanner
  ABI3 --> Scanner
  ABI1 --> Sqlite["SQLite/JNI"]
  ABI2 --> Sqlite
  ABI3 --> Sqlite
```

La reducción de APK depende principalmente de retirar scanner/QR y de la estrategia ABI, no de mover archivos Dart.
