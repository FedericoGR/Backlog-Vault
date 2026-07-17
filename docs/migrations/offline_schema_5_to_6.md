# Migración offline de schema 5 a 6

## Propósito

Backlog Vault Offline conserva todos los datos funcionales locales y elimina
únicamente la persistencia exclusiva de la sincronización retirada. La
migración se ejecuta al abrir una base con `PRAGMA user_version = 5`; una base
que ya está en 6 abre normalmente y no vuelve a migrarse.

No existe downgrade automático. Antes de actualizar una instalación real debe
existir un backup recuperable y debe conservarse el build anterior compatible.

## Datos preservados

Las siguientes diez tablas no se reconstruyen ni se borran:

| Tabla | Datos funcionales |
|---|---|
| `games` | juegos, IDs y soft deletes |
| `library_entries` | biblioteca, estado, rating y notas |
| `platforms` | catálogo local de plataformas |
| `library_entry_platforms` | relaciones entrada–plataforma |
| `genres` | catálogo local de géneros |
| `game_genres` | relaciones juego–género |
| `playthroughs` | sesiones, progreso y soft deletes |
| `saved_views` | filtros, orden y columnas guardadas |
| `external_game_ids` | referencias de metadata externa |
| `media_assets` | covers/media, rutas locales y hashes funcionales |

La migración no toca archivos de media. RAWG, IGDB y SteamGridDB siguen siendo
integraciones opcionales y sus credenciales no forman parte del schema Drift.

## Objetos retirados

Se eliminan ocho índices exclusivos en este orden:

1. `idx_sync_devices_group_status`
2. `idx_sync_devices_single_local`
3. `idx_sync_changes_entity`
4. `idx_sync_changes_mutation`
5. `idx_sync_changes_origin`
6. `idx_sync_tombstones_entity`
7. `idx_sync_state_peer`
8. `idx_sync_entity_state_entity`

Luego se eliminan seis tablas, primero las dependientes y después sus padres:

1. `sync_entity_states`
2. `sync_states`
3. `sync_tombstones`
4. `sync_changes`
5. `sync_devices`
6. `sync_groups`

## Guardas y fallo seguro

Antes de cualquier `DROP`, la migración comprueba por nombre que existan las
diez tablas funcionales y ejecuta `PRAGMA foreign_key_check`. Repite ambas
validaciones después de retirar los objetos de Sync. Drift ejecuta el upgrade
dentro de su migración de apertura: una excepción impide completar el cambio de
versión.

Una base 5 incompleta o con relaciones inválidas produce un `StateError`
genérico. El error no se captura ni se oculta en el bootstrap y no se intenta
reparar o borrar información automáticamente.

## Fixture sintético y cobertura

`test/fixtures/schema_v5_fixture.dart` crea el schema físico 5 completo sin
datos reales. Sus counts funcionales antes y después son:

| Tabla | Antes | Después |
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

El fixture contiene filas activas y soft-deleted, valores opcionales,
relaciones, dos playthroughs, una vista guardada, metadata externa, una portada
local y filas en cada tabla retirada. El test de integración valida:

- schema/user version 5→6;
- counts, IDs, contenido y relaciones;
- soft deletes, playthroughs, vista, metadata y ruta de media;
- presencia de las diez tablas y ausencia de seis tablas/ocho índices;
- `PRAGMA foreign_key_check` sin resultados;
- lectura y escritura posterior;
- cierre y reapertura en 6 sin una segunda migración;
- rechazo controlado de un schema 5 incompleto antes de borrar datos.

## Limpieza posterior de secure storage

Sólo después de abrir la base satisfactoriamente se ejecuta una limpieza
idempotente con esta allowlist histórica exacta:

- clave `sync.local.device_id`;
- prefijo inequívoco `sync.group.key.`.

No se usa `deleteAll()` ni coincidencias genéricas. Se preservan explícitamente
las credenciales de RAWG, IGDB y SteamGridDB, además de claves desconocidas. Si
secure storage no está disponible, el inicio continúa y se reporta un error
técnico redactado, sin valores sensibles.

## Recuperación y QA de una instalación real

Los tests sólo usan bases temporales sintéticas. Para validar una instalación
Android real:

1. comprobar package, versión y firma;
2. asegurar una vía real de recuperación de base y media;
3. instalar in-place sin desinstalar, limpiar datos ni hacer downgrade;
4. abrir y comprobar biblioteca, counts, Settings y covers sin editar datos;
5. detenerse y preservar datos/logs redactados ante cualquier error.

Si esas condiciones no pueden garantizarse, la migración real debe quedar como
gate manual previo al merge; el build y los tests automatizados no autorizan a
arriesgar una biblioteca existente.
