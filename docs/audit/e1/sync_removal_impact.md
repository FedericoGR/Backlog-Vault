# Impacto de retiro de Sync

E1 no elimina nada. Esta matriz define el alcance para E2 y separa código exclusivo, fronteras compartidas y datos persistidos.

## Magnitud

- Productivo: 24 archivos, 277.119 bytes, ~7.696 líneas no vacías en la medición inicial.
- Tests: 8 archivos, 181.145 bytes, ~5.132 líneas no vacías.
- Localización: 153 keys fuente `sync*` en cada ARB, más tres outputs generados.
- Persistencia: 6 tablas, 8 índices, device identity y group keys en OS secure storage.
- Integraciones: `main.dart`, settings, 7 repositorios funcionales, DB/schema, Android manifest, pubspec/lock, docs.

Orden: A protección/tests; B desacople compartido; C UI/bootstrap; D protocolos/código; E permisos/deps/l10n; F DB; G secure storage.

## Matriz de los 24 archivos productivos

| Path | Responsabilidad/dependencias | Dato persistido | Riesgo | Orden/destino | Cobertura actual |
|---|---|---|---|---|---|
| `application/sync_providers.dart` | compone DB, secure storage, media y todos los servicios | indirecto | crítico | D eliminar tras B/C | múltiples tests Sync |
| `data/canonical_json.dart` | JSON determinista + SHA para Sync | hash en oplog | medio | D eliminar; no confundir con backup | foundation/LAN |
| `data/encrypted_pairing_codec.dart` | cifra/descifra invitación | payload `.vaultpair` | alto | D eliminar | pairing |
| `data/encrypted_sync_package_codec.dart` | password/group encryption | `.vaultsync` | alto | D eliminar; cryptography sigue por backup | codec/manual |
| `data/lan_media_transfer_service.dart` | valida/transfiere covers y registra DB | MediaAssets/files + state Sync | crítico | D eliminar transporte, conservar MediaFileStorage | LAN service |
| `data/lan_sync_service.dart` | sockets, challenge/proof, host/client | red + package temporal | crítico | D eliminar | LAN service |
| `data/sync_change_applier.dart` | aplica cambios y upserts funcionales | 10 tablas + entity state | crítico | D sólo tras B y backup | foundation/manual |
| `data/sync_change_tracking.dart` | snapshots, diff, recorder, wrapper transaccional | SyncChanges/States/Tombstones | crítico | B reemplazar por `db.transaction`, luego D eliminar | foundation + repos tests |
| `data/sync_conflict_detector.dart` | preview/conflict/idempotencia | lee oplog/entity state | crítico | D eliminar | foundation/manual/LAN |
| `data/sync_device_identity.dart` | identity local y repo de dispositivo | DB + secure storage | alto | D código; G dato | pairing/foundation |
| `data/sync_group_management.dart` | grupos, devices, key store | DB + claves de grupo | crítico | D código; G claves después de F | pairing/LAN |
| `data/sync_package_builder.dart` | arma paquete desde oplog/vector | `.vaultsync` | alto | D eliminar | manual/foundation |
| `data/sync_package_file_service.dart` | picker/save `.vaultsync` | archivo elegido por usuario | medio | D eliminar; file_picker se conserva | manual |
| `data/sync_package_service.dart` | export/preview/apply coordinado | oplog/package | crítico | D eliminar | manual/LAN |
| `data/sync_pairing_file_service.dart` | picker/save `.vaultpair` | archivo elegido por usuario | medio | D eliminar | pairing |
| `data/sync_pairing_service.dart` | invitación/import pairing | grupo/device/key | alto | D/G | pairing |
| `data/sync_payload_sanitizer.dart` | redacción/validación payload | ninguno | medio | D eliminar; conservar core privacy redactor | foundation |
| `data/sync_qr_payload_codec.dart` | wrappers QR pairing/LAN | payload temporal | alto | D/E eliminar | QR codec |
| `domain/lan_sync_models.dart` | DTOs LAN/sesión/resultados | ninguno directo | alto | D eliminar | LAN |
| `domain/sync_models.dart` | entity types/operations/sources | enums serializados | crítico | D tras B | foundation/repos |
| `domain/sync_package_models.dart` | formato/protocolo `.vaultsync` | package v1 | alto | D eliminar | manual/LAN |
| `domain/sync_pairing_models.dart` | grupo/device/invitación | DB/file/QR | alto | D/G | pairing/QR |
| `presentation/manual_sync_section.dart` | UI Sync, QR, pairing, LAN, files | dispara todas las operaciones | alto | C eliminar | settings + manual flows |
| `presentation/sync_qr_scanner_page.dart` | cámara/mobile_scanner | ninguno | medio | C/E eliminar | scanner widget |

## Superficies externas al feature

| Superficie | Dependencia Sync | Destino |
|---|---|---|
| `lib/main.dart` | inicializa `syncFoundationReadyProvider` | C: bootstrap local simple |
| `settings_page.dart` | incrusta `ManualSyncSection` | C: retirar sección |
| `app_database.dart`, `tables.dart`, `.g.dart` | 6 tablas + 8 índices + schema 5 | F: migración segura/regeneración |
| 7 repositorios | `SyncAwareTransaction`, `SyncChangeSource/EntityType` | B: transacción Drift local |
| `app_en.arb`, `app_es.arb` | 153 keys Sync | E: borrar source keys y regenerar |
| Android manifest | CAMERA | E: retirar; INTERNET queda por metadata/media |
| `pubspec.yaml/lock` | QR/scanner | E: retirar deps sólo sin imports |
| docs/readmes | producto declara Sync | E: actualizar documentación activa; Git/bundle preservan historia |
| release notes/checklists | registro histórico | conservar, marcar históricas |

Los siete repositorios son: catalogs, games, Notion CSV import, saved library views, media, metadata y logical export/restore. Su data es funcional; sólo se retira el wrapper/metadata Sync.

## Exclusivo vs compartido

### Exclusivo de Sync

Los 24 archivos, seis tablas, ocho índices, `.vaultsync`, `.vaultpair`, group/device identity, QR, CAMERA, scanner, LAN sockets, challenge/proof, oplog, vectors, tombstones, entity hashes/conflicts y 153 keys.

### Compartido que se conserva

- `AppDatabase` y las 10 tablas funcionales.
- `MediaFileStorage`, hashes de media, selected cover y backup de media.
- file picker de CSV/backup/media.
- secure storage de RAWG/IGDB/SteamGridDB.
- `crypto`, `cryptography`, `archive`, `http`, `path_provider` según scope aprobado.
- `PrivacyRedactor`.
- export JSON/CSV y backup/restore; sólo pierden `SyncAwareTransaction`.

## Orden de retiro recomendado

1. A: fixture schema 5 con datos funcionales y Sync; backup cifrado + raw DB de desarrollo; tests counts/hash/FK.
2. B: crear una frontera transaccional local mínima o usar `AppDatabase.transaction`; migrar los siete repositorios y mantener todos sus tests verdes.
3. C: retirar inicialización de `main`, settings, scanner y UI QR/LAN.
4. D: retirar providers, servicios, codecs, modelos y tests por componente.
5. E: retirar keys ARB y regenerar; CAMERA; `qr_flutter`/`mobile_scanner`; actualizar docs activas.
6. F: migración candidata schema 6: índices y seis tablas, con verificaciones.
7. G: tras apertura exitosa post-migración, borrar exclusivamente device identity/group key prefix Sync.
8. Validar offline cold start, import/export, metadata sin keys/red, media, Windows y Android.

No se debe borrar `lib/features/sync/` como primer paso: rompería compilación y, peor, puede dejar mutaciones funcionales sin transacción o restore sin camino seguro.
