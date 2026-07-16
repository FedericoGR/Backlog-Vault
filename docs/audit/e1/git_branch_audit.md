# Auditoría de ramas y baseline

## Estado inicial

- Rama: `release/v0.3`
- HEAD: `badbaa8cf1dfcf7de9affa74a5bcdee7391286c1`
- Working tree: limpio.
- Remote: `origin https://github.com/FedericoGR/Backlog-Vault.git`.
- Referencias remotas contrastadas con `git ls-remote`: coincidían con los tracking refs locales.
- Tags: `v0.1.0-rc1`, `v0.1.0-rc2`, `v0.1.0-rc3`, `v0.2.0-rc1`, `v0.2.0`, `v0.3.0-rc1`.

Se usaron `merge-base`, logs simétricos, `git cherry`, `branch --merged/--no-merged` y `diff --stat`. Todas las ramas locales y remotas resultaron merged/ancestros de `release/v0.3`; `--no-merged` quedó vacío.

## Matriz de heads únicos

“Detrás” cuenta commits hasta `release/v0.3`; “exclusivos” cuenta commits no contenidos en el baseline.

| Rama/ref | HEAD | Último commit | Base probable | Detrás | Exclusivos | Contenida | Contenido/decisión futura |
|---|---|---|---|---:|---:|---|---|
| `release/v0.3` / origin | `badbaa8` | 2026-06-28 | `codex/qr-qa-artifact-refresh` | 0 | 0 | sí | Baseline canónico; conservar/tag histórico. |
| `codex/qr-qa-artifact-refresh` / origin | `84a47f6` | 2026-06-28 | `main` | 1 | 0 | sí | Versionado QA (`pubspec`); referencia histórica. |
| `main`, `codex/qr-pairing-lan-ux` / origin | `78d52fe` | 2026-06-28 | merge de QR + Sync UX | 2 | 0 | sí | Código QR/LAN y tests; ya integrado. |
| `codex/sync-ux-simplification` / origin | `24e186d` | 2026-06-28 | `release/v0.2` | 5 | 0 | sí | UX Sync; integrado por merge `bd48b63`. |
| `release/v0.2` / origin | `1b8971c` | 2026-06-27 | `codex/lan-media-transfer` | 6 | 0 | sí | Release estable Sync; conservar/tag histórico. |
| `origin/codex/lan-media-transfer` | `6de1b12` | 2026-06-26 | `codex/lan-sync-hardening` | 9 | 0 | sí | Transferencia media; integrado. |
| `origin/codex/lan-sync-hardening` | `a0a31ca` | 2026-06-25 | `codex/lan-sync-now` | 11 | 0 | sí | Hardening LAN; integrado. |
| `origin/codex/lan-sync-now` | `6a13c17` | 2026-06-25 | `codex/sync-device-pairing` | 12 | 0 | sí | LAN manual; integrado. |
| `origin/codex/sync-device-pairing` | `b326e01` | 2026-06-25 | encrypted package | 13 | 0 | sí | Pairing; integrado. |
| `origin/codex/encrypted-manual-sync-package` | `5c2aed9` | 2026-06-22 | sync foundation | 15 | 0 | sí | `.vaultsync`; integrado. |
| `origin/codex/sync-foundation` | `8a445a7` | 2026-06-19 | `release/v1` | 17 | 0 | sí | Oplog/conflictos/schema 5; integrado. |
| `release/v1` / origin | `b9e9eff` | 2026-06-18 | foundation inicial | 19 | 0 | sí | Base bilingüe pre-Sync; referencia v0.1. |

Los refs locales duplicados no representan líneas diferentes: `main` y `codex/qr-pairing-lan-ux` apuntan al mismo commit; sus equivalentes `origin/*` coinciden.

## Comparaciones relevantes

### `main` vs `release/v0.3`

- Merge-base: `78d52fe` (`main`).
- Conteo izquierda/derecha: `0 / 2`.
- Commits adicionales: `84a47f6` y `badbaa8`.
- Diff: 8 archivos, 131 inserciones, 3 eliminaciones.
- Único cambio no documental: `pubspec.yaml` cambia de versión hacia `0.3.0+5`; no hay código funcional adicional fuera de `main`.

### `release/v0.2` vs `main`

- Merge-base: `1b8971c`.
- Conteo: `0 / 4`.
- Agrega QR scanner/payload, UI QR/LAN, permiso CAMERA, dependencias y tests; no pierde la línea Sync previa.

### `release/v1` vs `release/v0.2`

- Merge-base: `b9e9eff`.
- Conteo: `0 / 13`.
- Agrega toda la foundation Sync, pairing, LAN, media y schema 5, además de correcciones en repositorios funcionales. Volver a `release/v1` perdería cambios funcionales y migraciones.

## Baseline canónico

Se selecciona `release/v0.3` @ `badbaa8` porque:

1. Es descendiente de todas las ramas encontradas.
2. Incluye el código funcional, correcciones, migraciones y tests más recientes.
3. Conserva schema 5, backup lógico 4 y protocolo 1, necesarios para retirar Sync controladamente.
4. No depende de archivos no commiteados; el árbol inicial era limpio.
5. Coincide con tag/artefactos RC1 verificados y preservados externamente.
6. Evita cherry-picks o merges innecesarios y reduce el riesgo de omitir cambios no relacionados con Sync.

## Clasificación y estrategia futura

- Conservar: `release/v0.3`, tags, `main` y releases hasta que exista un Offline Release estable.
- Mantener como referencia histórica: ramas Sync/LAN/QR ya integradas.
- Integrar ahora: nada; la integración ya existe por ancestría.
- Archivar/eliminar más adelante: ramas codex antiguas sólo después del Offline Release y con aprobación explícita.
- Reescritura: no recomendada con la evidencia actual; no hay binarios/secrets alcanzables que la justifiquen.

## Plan exacto al comenzar E2

1. Verificar nuevamente que el bundle y su SHA-256 estén disponibles.
2. Obtener aprobación del baseline y del ADR.
3. Crear `codex/offline-e2-remove-sync` desde el commit de E1 en `codex/offline-e1-audit`.
4. No mergear ni cherry-pickear ninguna rama histórica: todos sus commits ya están contenidos.
5. Ejecutar el retiro incremental descrito en [e2_sync_removal_plan.md](../../planning/e2_sync_removal_plan.md).
6. Mantener `release/v0.3`, `main`, ramas y tags sin cambios durante E2.
7. Consolidar hacia `main` sólo mediante revisión/PR posterior y aprobación; no forma parte de E1.
