# E2 — Reporte de retirada de Sync y migración Offline

Fecha de cierre técnico: 2026-07-17.

## Resultado ejecutivo

E2 transforma el producto activo en una aplicación offline de un solo
dispositivo. Se retiraron Sync, pairing, grupos, QR/scanner, protocolos de
paquetes, LAN, transferencia LAN de media, tracking/conflictos y todas sus
superficies. Biblioteca, juegos, entradas, playthroughs, catálogos, vistas,
metadata, media local, estadísticas, CSV, exportación y backup/restore siguen
presentes.

La rama parte exactamente de `codex/offline-e1-audit` en
`347d828215a9f6e77201c5a9c7ea69369713cdaa`. La rama de trabajo es
`codex/offline-e2-remove-sync`; no se hizo merge a `main`, tag, release, cambio
de versión ni limpieza/rewrite de Git.

La separación de commits se ajustó a dos unidades verdes: un commit funcional
atómico para código/config/tests y un commit documental. Separar schema,
repositorios y eliminación de tests en commits intermedios habría dejado
estados que no compilaban porque las interfaces retiradas se usaban de manera
transversal.

## Preservación y baseline

El bundle histórico externo se volvió a verificar:

- ruta: `C:\Users\Feder\Documents\Backlog Vault Backups\pre-offline-refactor\20260716-1613\backlog-vault-pre-offline-20260716-1613.bundle`;
- tamaño: 741.091 bytes;
- SHA-256: `ebacf65e90e07a9d1959cc333b8d32bc5acac88cc26693e0ce36991f3f1916ee`;
- `git bundle verify`: válido, historia completa y 29 referencias.

Baseline funcional E1, antes de modificar código:

- Flutter 3.44.1 / Dart 3.12.1;
- `flutter analyze`: 0 issues;
- `flutter test`: 332/332;
- Windows release: 36.684.220 bytes (34,98 MiB);
- APK universal: 86.280.143 bytes (82,28 MiB);
- warning Android KGP: `file_picker` y `mobile_scanner`.

No se abrió, copió ni modificó una base real. Todos los datos usados para la
migración son sintéticos y temporales.

## Cambio de persistencia

El schema físico pasa de 5 a 6. Se preservan estas diez tablas y todos sus
campos funcionales:

1. `games`
2. `library_entries`
3. `platforms`
4. `library_entry_platforms`
5. `genres`
6. `game_genres`
7. `playthroughs`
8. `saved_views`
9. `external_game_ids`
10. `media_assets`

Se eliminan seis tablas exclusivas:

1. `sync_entity_states`
2. `sync_states`
3. `sync_tombstones`
4. `sync_changes`
5. `sync_devices`
6. `sync_groups`

Se eliminan ocho índices exclusivos:

1. `idx_sync_devices_group_status`
2. `idx_sync_devices_single_local`
3. `idx_sync_changes_entity`
4. `idx_sync_changes_mutation`
5. `idx_sync_changes_origin`
6. `idx_sync_tombstones_entity`
7. `idx_sync_state_peer`
8. `idx_sync_entity_state_entity`

El documento lógico de exportación/backup permanece en versión 4: su contenido
funcional no dependía del schema físico de Sync.

El fixture `schema_v5_fixture.dart` contiene las 16 tablas, los ocho índices,
relaciones, opcionales, soft deletes, metadata y una ruta de portada. Counts
funcionales validados antes/después:

| Tabla | v5 | v6 |
|---|---:|---:|
| `games` | 2 | 2 |
| `library_entries` | 2 | 2 |
| `platforms` | 1 | 1 |
| `library_entry_platforms` | 1 | 1 |
| `genres` | 1 | 1 |
| `game_genres` | 1 | 1 |
| `playthroughs` | 2 | 2 |
| `saved_views` | 1 | 1 |
| `external_game_ids` | 1 | 1 |
| `media_assets` | 1 | 1 |

Dos tests nuevos cubren migración completa, integridad referencial, lectura y
escritura, reapertura idempotente y fallo controlado de un schema 5 incompleto.
La especificación operativa y rollback están en
`docs/migrations/offline_schema_5_to_6.md`.

## Repositorios y atomicidad local

Los siete componentes funcionales desacoplados son:

1. `CatalogRepository`
2. `GameRepository`
3. `NotionCsvImportRepository`
4. `SavedLibraryViewRepository`
5. `MediaRepository`
6. `MetadataRepository`
7. `ExportRepository`

La abstracción final es `AppDatabase.transaction` de Drift usada directamente.
No se añadió una interfaz genérica sustituta. Se preservaron los límites
transaccionales, timestamps, soft deletes y validaciones; ya no se generan
oplog, envelopes, hashes ni tombstones de Sync.

## Secure storage

La limpieza posterior a una apertura/migración satisfactoria admite sólo:

- la clave exacta `sync.local.device_id`;
- claves con el prefijo inequívoco `sync.group.key.`.

Es idempotente, no usa `deleteAll()` y redacta los errores. Tres tests prueban
el borrado selectivo, la preservación y la repetición/fallo seguro. Permanecen
intactas las credenciales RAWG, IGDB Client ID/Secret y SteamGridDB, además de
cualquier clave desconocida.

## Código, tests y localización

- archivos productivos de `lib/features/sync/` eliminados: 24;
- archivos de test Sync eliminados: 8;
- casos retirados en esos archivos: 79;
- casos Sync retirados de Settings: 2;
- tests agregados: 5 (2 migración + 3 secure storage);
- cálculo final: 332 − 81 + 5 = 256;
- archivos `_test.dart`: 68 → 62;
- claves exclusivas retiradas: 153 EN y 153 ES, sin borrar claves no Sync.

Justificación de cada archivo de test eliminado:

| Archivo | Casos | Objeto retirado |
|---|---:|---|
| `encrypted_sync_package_codec_test.dart` | 5 | codec `.vaultsync` |
| `lan_sync_service_test.dart` | 21 | host/cliente LAN y media LAN |
| `manual_sync_package_test.dart` | 13 | export/import manual de paquetes |
| `sync_foundation_test.dart` | 22 | tracking, oplog, conflictos y transacciones Sync |
| `sync_pairing_test.dart` | 10 | pairing, grupos y `.vaultpair` |
| `sync_qr_payload_codec_test.dart` | 6 | payloads QR |
| `sync_schema_migration_test.dart` | 1 | creación histórica de schema Sync 4→5 |
| `sync_qr_scanner_page_test.dart` | 1 | scanner retirado |

Ningún test funcional fue eliminado para obtener verde. Backup/restore perdió
únicamente las preparaciones/asserts de tablas ya inexistentes. Settings y l10n
se reorientaron a comprobar el producto offline y la ausencia de UI retirada.

## Dependencias, permisos y binarios

Se retiraron `qr_flutter` 4.1.0 y `mobile_scanner` 7.2.0; el lock también dejó de
resolver el paquete transitivo `qr` 3.0.2. Se conservaron `crypto`, `archive`,
`file_picker`, `http` y `flutter_secure_storage` porque tienen usos
funcionales.

Android ya no declara `CAMERA`. Conserva `INTERNET` para RAWG/IGDB/
SteamGridDB y el permiso dinámico privado generado por Android. El APK contiene
437 entradas y cero coincidencias para Barhopper, barcode, scanner, ML Kit o
sus modelos. Las bibliotecas nativas restantes por ABI son Flutter, app,
SQLite, Dart JNI y el contador compartido de DataStore.

Medición release comparable:

| Output | Baseline | E2 | Diferencia |
|---|---:|---:|---:|
| APK universal | 86.280.143 B / 82,28 MiB | 68.127.549 B / 64,97 MiB | −18.152.594 B / −21,04 % |
| Windows Release | 36.684.220 B / 34,98 MiB | 35.962.602 B / 34,30 MiB | −721.618 B / −1,97 % |
| EXE Windows | 81.920 B | 81.920 B | sin cambio |

El registrant Windows final sólo carga `flutter_secure_storage_windows`. Sus
binarios funcionales son `backlog_vault.exe`, `flutter_windows.dll`,
`sqlite3.dll`, `dartjni.dll` y el DLL de secure storage.

## Validación final

Ejecutada desde `flutter clean`:

| Gate | Resultado |
|---|---|
| `flutter pub get` | correcto |
| `dart run build_runner build --delete-conflicting-outputs` | correcto; 0 outputs pendientes |
| `flutter gen-l10n` | correcto, EN/ES regenerados |
| `flutter analyze` | 0 issues |
| `flutter test` | 256/256, 39,48 s |
| tests focalizados | 99/99 (migración, storage, siete repositorios/capacidades, Settings, import, metadata/media y backup) |
| `flutter build windows --release` | correcto, 74,97 s |
| `flutter build apk --release` | correcto, 118,38 s |
| inspección APK | sin scanner/modelos/CAMERA |

Warnings no bloqueantes:

- `build_runner` informa que `--delete-conflicting-outputs` fue retirado y lo
  ignora; la generación terminó correctamente;
- Android mantiene el warning KGP de `file_picker`; el warning equivalente de
  `mobile_scanner` desapareció;
- el build informa que no encontró la familia CupertinoIcons, no utilizada en
  el resultado funcional, y tree-shakea MaterialIcons;
- `pub get` informa 35 versiones más nuevas incompatibles con las constraints;
  las actualizaciones generales pertenecen a E4.

Una repetición demasiado inmediata de `flutter test` encontró temporalmente
`sqlite3.dll` bloqueado por el proceso anterior y Flutter produjo un crash log.
No fue un fallo de test: se esperó la liberación, se retiró sólo el log local y
las ejecuciones serializadas posteriores finalizaron 256/256 y 99/99.

## Residuos y privacidad

La búsqueda obligatoria no encontró capacidades activas. Las coincidencias
permitidas quedan clasificadas así:

- SQL de `app_database.dart`: nombres exactos requeridos para borrar schema 5;
- `offline_secure_storage_cleanup.dart`: allowlist exacta de limpieza heredada;
- fixture/tests: creación del origen 5 y asserts de ausencia;
- `docs/audit/e1/`, plan E2, migración y este reporte: historia técnica;
- release notes/checklists históricos: registro de releases anteriores, no
  documentación activa; se conservaron deliberadamente junto con Git/bundle;
- `privacy_redactor.dart`: patrones defensivos de secretos heredados; no crean,
  leen ni conservan claves;
- `async`, `SynchronousFuture`, `readAsStringSync`, `_syncItemIncluded` y
  `std::ios::sync_with_stdio`: falsos positivos léxicos sin relación con Sync.

El secret scan no incorpora ni revela valores. No hay nuevas credenciales,
bases reales, backups reales, payloads reales, `.env`, keystores, APK, ZIP ni
logs versionados. Las credenciales externas sólo se referencian por nombres de
clave y permanecen en secure storage.

## Documentación

Actualizados: README EN/ES, instalación/portabilidad, arquitectura actual,
ADR-001, scope offline, plan revisado, plan de peso y plan E2. Creados: guía de
migración y este reporte. Eliminados como documentación activa exclusiva:
`docs/qr_sync_notes.md` y `docs/sync_roadmap.md`.

## Android real y pendiente

`flutter devices` detectó únicamente Windows, Chrome y Edge; `adb devices -l`
no mostró dispositivos Android. El APK es `dev.backlogvault.app`, versionName
`0.3.0`, versionCode `5`, minSdk 24 y targetSdk 36. No se instaló el APK, no se
desinstaló nada, no se limpió data y no se ejecutó una migración sobre datos
reales. Por tanto, el único gate manual antes del merge es un smoke/update
in-place en un Android con recuperación segura, siguiendo la guía de migración.

## Alcance confirmado y próximo paso

E2 no movió masivamente carpetas, no aplicó MVVM general, no simplificó
Game/LibraryEntry/Playthrough, no reemplazó export/backup, no cambió la versión
`0.3.0+5` y no agregó features.

Recomendación exacta para E3: después de aprobar E2 y completar o aceptar el
gate Android, abrir un entregable separado y comenzar por un único slice de
Library (ViewModel para tabla/galería/filtros/vistas guardadas), manteniendo
comportamiento y separando movimientos de cambios conductuales. No ejecutar ese
slice dentro de esta rama.
