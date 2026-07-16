# Arquitectura actual reconstruida

## Entrada, app y routing

`main.dart` crea `ProviderContainer`, dispara `syncFoundationReadyProvider` sin await y monta `UncontrolledProviderScope`. `BacklogVaultApp` observa idioma/router y configura MaterialApp con temas system/light/OLED. `appRouterProvider` define ShellRoute con home, library, statistics, bulk metadata, game create/detail/edit, Notion CSV, settings y backups. Sync no tiene ruta: vive dentro de settings y empuja scanner/dialogs imperativamente.

```mermaid
flowchart LR
  Main["main.dart"] --> SyncInit["syncFoundationReadyProvider"]
  Main --> Scope["Riverpod ProviderContainer"]
  Scope --> App["BacklogVaultApp"]
  App --> Router["GoRouter / AppShell"]
  Router --> Screens["Home · Library · Games · Stats · Settings · Import/Backup"]
```

## Flujo UI → estado → DB

```mermaid
flowchart LR
  View["ConsumerWidget/Page"] --> Provider["Riverpod Provider/StreamProvider"]
  View --> RepoDirect["ref.read(repositoryProvider)"]
  Provider --> Repo["Repository"]
  RepoDirect --> Repo
  Repo --> SyncTx["SyncAwareTransaction"]
  SyncTx --> Drift[("AppDatabase / Drift")]
  Drift --> Streams["watch() streams"]
  Streams --> Provider
```

Hay buen uso de streams/providers para lecturas, pero las views disparan repositories y coordinan workflows. No existe una capa ViewModel consistente. `GameListPage`, `GameFormPage`, `GameDetailPage` y bulk import concentran estado, validación, dialogs y commands.

## Persistencia

`AppDatabase` declara 16 tablas y migraciones 1→5. Repositories acceden directamente a tablas/companions. `LibraryGameDetails` y otros application models contienen filas Drift generadas, por lo que schema y UI no están totalmente aislados.

Repositories principales: Game (incluye playthrough), Catalog, LibraryQuery, SavedViews, Metadata, Media, Statistics, Notion CSV y Export/Restore. Los siete mutadores listados en el audit Sync dependen del wrapper Sync.

## Metadata

```mermaid
flowchart LR
  Form["GameForm / MetadataDialog"] --> MP["metadata providers/use cases"]
  MP --> RAWG["RawgApiClient"]
  MP --> IGDB["IgdbAuth + IgdbApiClient"]
  RAWG --> HTTP["http.Client"]
  IGDB --> HTTP
  IGDB --> Keys["SecureMetadataApiKeyStorage"]
  RAWG --> Keys
  MP --> Diff["BuildMetadataDiff"]
  Diff --> Apply["MetadataRepository.apply"]
  Apply --> SyncTx["SyncAwareTransaction"]
  SyncTx --> DB[("Games · Catalogs · ExternalGameIds")]
```

Metadata es opcional por diseño, pero settings administra credenciales directamente. El app no debe disparar auth/network durante cold start Offline.

## Media

```mermaid
flowchart LR
  Dialog["MediaSearchDialog / Game views"] --> Providers["SteamGridDB + IGDB MediaProvider"]
  Providers --> HTTP["HTTP clients"]
  Providers --> Keys["metadata key storage"]
  Dialog --> Local["file_picker / File"]
  HTTP --> Repo["MediaRepository"]
  Local --> Repo
  Repo --> Storage["MediaFileStorage / path_provider"]
  Repo --> DB[("MediaAssets")]
  Repo --> SyncTx["Sync change tracking"]
  Thumbnail["LibraryCoverThumbnail"] --> FileIO["dart:io File"]
```

`LibraryCoverThumbnail` accede directamente a File en presentation. Media reutiliza componentes internos de metadata, generando acoplamiento bidireccional.

## Importación/exportación/backup

```mermaid
flowchart TD
  CSVUI["ImportNotionCsvPage"] --> Picker["CsvFilePicker"]
  Picker --> Parser["CsvParser / normalizers / preview"]
  Parser --> Import["NotionCsvImportRepository"]
  Import --> SyncTx["SyncAwareTransaction"]
  SyncTx --> DB[("10 tablas funcionales")]
  BackupUI["BackupRestorePage"] --> Backup["BackupService"]
  Backup --> Export["ExportRepository"]
  Export --> DB
  Backup --> Zip["archive + media files"]
  Backup --> Enc["cryptography password encryption"]
  Backup --> Output["JSON / CSV / .vaultbackup(.enc)"]
```

El logical export v4 cubre las diez entidades funcionales y media, no Sync. Esta separación es valiosa para migrar.

## Sync actual

```mermaid
flowchart TD
  Settings["Settings / ManualSyncSection"] --> Pair["Pairing file/text/QR"]
  Settings --> Manual[".vaultsync file"]
  Settings --> LAN["LAN host/client + QR"]
  Pair --> PairCodec["EncryptedPairingCodec"]
  PairCodec --> Keys["OS secure group key"]
  LAN --> Challenge["challenge/proof/session code"]
  Manual --> Package["PackageBuilder/Codec/Service"]
  LAN --> Package
  Package --> Preview["ConflictDetector"]
  Preview --> Apply["ChangeApplier"]
  Apply --> Functional[("functional tables")]
  Apply --> SyncDB[("oplog/vectors/tombstones/entity state")]
  LAN --> Media["LAN Media Transfer"]
  Media --> MediaStorage["MediaFileStorage + MediaAssets"]
  Mutations["7 functional repositories"] --> Track["SyncAwareTransaction"]
  Track --> SyncDB
```

No hay cloud, discovery automático ni background sync implementado; sí hay protocolos propios manuales y LAN activos.

## Dependencias incorrectas/circulares

- core→features: no detectado.
- presentation→data: frecuente; pages importan repos/providers concretos.
- presentation→filesystem: thumbnail y media/QR surfaces.
- games↔library, games↔metadata/media, media↔metadata, media↔sync y l10n↔features.
- Sync provider global compone demasiadas responsabilidades.
- Repositories mutadores tienen dos responsabilidades: dominio/persistencia + tracking Sync.
- `domain_localizations.dart` invierte dependencia desde l10n hacia features.
- No hay barrels globales problemáticos; el problema es import directo y ownership.

## Testabilidad

Hay 332 tests fuertes en data/domain/widget y DB in-memory, pero no directorio `integration_test/`. Páginas con workflows extensos requieren pumps/mocks complejos. Drift migrations tienen tests actuales, incluido v4→v5 Sync, pero no snapshots generados para una migración destructiva futura.
