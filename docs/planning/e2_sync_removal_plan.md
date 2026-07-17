# E2 — Plan de retiro de Sync

Estado: ejecutado en `codex/offline-e2-remove-sync`. Se conserva como trazabilidad
del orden y los gates definidos en E1; el resultado medido está en
`e2_completion_report.md`.

## Objetivo

Retirar Sync/QR/pairing/LAN y su persistencia sin perder ninguna fila/archivo funcional, manteniendo import/export, backup, metadata/media opcional y builds Windows/Android.

Rama propuesta: `codex/offline-e2-remove-sync`, creada desde el commit E1 aprobado.

## Fase 0 — Gates y fixtures

1. Verificar bundle/hash y working tree limpio.
2. Exportar snapshot Drift schema 5.
3. Crear fixture v5 con filas activas/soft-deleted en las 10 tablas, media y las 6 Sync.
4. Registrar counts, hashes lógicos, FKs y paths media.
5. Agregar tests cold start sin secure storage/Internet.

Gate: baseline 332 tests + nuevos tests verdes; backup/restore del fixture probado.

## Fase 1 — Desacoplar mutaciones funcionales

Reemplazar `SyncAwareTransaction` por una transacción Drift local en:

1. CatalogRepository.
2. GameRepository.
3. NotionCsvImportRepository.
4. SavedLibraryViewRepository.
5. MediaRepository.
6. MetadataRepository.
7. ExportRepository/restore.

Eliminar `SyncChangeSource`, `SyncEntityType`, changedFields y tracking sólo de esos paths; mantener atomicidad. Hacer commits pequeños por grupo y ejecutar tests de cada feature.

Gate: ninguna feature funcional importa Sync excepto wiring todavía activo; CRUD/import/restore siguen atómicos.

## Fase 2 — Bootstrap y UI

- `main.dart`: quitar provider container manual y foundation initialization; usar `ProviderScope`/bootstrap local.
- settings: retirar ManualSyncSection.
- retirar scanner/QR dialogs/actions.
- actualizar rutas si alguna navegación imperativa queda.

Gate: app inicia offline y ninguna superficie ofrece Sync/QR/LAN.

## Fase 3 — Protocolos e infraestructura

Retirar por grupos testeables:

1. QR codec/scanner/render.
2. LAN sync y LAN media transfer.
3. pairing services/codecs/files/models.
4. package services/codecs/files/models.
5. conflict/applier/builder/sanitizer/canonical JSON.
6. tracking, group/device identity y providers finales.

No borrar `MediaFileStorage`, backup encryption, privacy redactor ni shared pickers.

Gate: `rg features/sync` sólo en docs históricas/migration fixture; analyzer verde.

## Fase 4 — Dependencias, permisos y l10n

- retirar `qr_flutter` y `mobile_scanner` de pubspec/lock;
- retirar CAMERA Android;
- conservar INTERNET por providers opcionales;
- borrar 153 keys `sync*` de ambos ARB y regenerar l10n;
- actualizar README/guías activas; conservar release notes históricas;
- resolver KGP residual de file_picker sólo si el build lo exige, preferentemente en cambio separado.

Gate: APK no contiene Barhopper/modelos barcode/CAMERA.

## Fase 5 — DB schema 5→candidato 6

Precondición: cero imports/runtime Sync. En migración transaccional:

1. counts/hashes/FK pre.
2. drop 8 índices Sync.
3. drop `sync_entity_states`, `sync_states`, `sync_tombstones`, `sync_changes`, `sync_devices`, `sync_groups`.
4. no tocar las diez tablas funcionales.
5. FK/counts/hashes/schema post.

Gate: snapshots/migrateAndValidate + data integrity + apertura repetida Windows/Android.

## Fase 6 — Secure storage

Limpieza one-shot posterior a migración/open exitoso:

- device identity Sync;
- group keys con prefijo Sync.

Nunca `deleteAll`; preservar RAWG/IGDB/SteamGridDB. La app debe tolerar storage no disponible.

## Fase 7 — Validación final

- `flutter analyze`.
- suite completa; 332 tests previos como referencia, no como número obligatorio porque salen tests Sync y entran tests Offline/migration.
- builds release Windows/APK.
- smoke Windows/Android real.
- cold start sin red/keys.
- CRUD, soft delete, playthroughs, filters/views, CSV, JSON/backup/restore, metadata/media.
- medir repo, APK, Windows y plugins.

## Fuera de E2

Mover masivamente carpetas, dividir todas las pages, rediseñar UI, actualizar todas las dependencias, optimizar historial o decidir el futuro de Playthrough. Esas acciones pertenecen a E3/E4.

## Rollback

Antes de cada fase destructiva, commit green. Si falla código, revertir el commit de fase. Si falla migración sobre fixture, restaurar DB/media previa. Para usuario, backup cifrado + build previo compatible. No intentar downgrade automático.

## Definición de terminado

- cero Sync/QR/LAN activo;
- cero tablas/keys/permisos/deps exclusivos;
- todas las capacidades aprobadas preservadas;
- datos validados y backup restaurable;
- Windows/Android verdes;
- documentación y mediciones actualizadas;
- sin iniciar E3 en el mismo PR.
