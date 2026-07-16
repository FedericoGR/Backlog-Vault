# Registro de riesgos Offline

Escala: probabilidad B/M/A; impacto B/M/A/C (crítico).

| Riesgo | Prob. | Impacto | Mitigación | Entregable | Validación |
|---|---|---|---|---|---|
| Pérdida de datos de usuario | M | C | backup cifrado + copia DB; migración transaccional | E2 | counts, hashes, restore real |
| Drop incorrecto de tablas funcionales | B | C | allowlist exacta de 6 tablas Sync | E2 | sqlite schema diff |
| Ruptura de migraciones 1→5→offline | M | C | snapshots Drift y tests por versión | E2 | `migrateAndValidate`, seed v5 |
| Eliminar infraestructura compartida | A | A | matriz Sync/shared; desacoplar antes de borrar | E2 | imports y tests por feature |
| Pérdida de covers | M | C | conservar MediaAssets/storage; backup con media | E2 | archivos/hash/selected cover |
| Pérdida de API keys | M | A | borrar sólo prefijos Sync, nunca keys metadata | E2 | lectura RAWG/IGDB/SGDB post-migración |
| Perder importadores/exportadores | M | A | conservar file_picker/csv/export repo; tests roundtrip | E2 | CSV import + JSON/backup export |
| Rama con commits no consolidados | B | A | baseline por ancestría + bundle | E1 | `--no-merged` vacío |
| Historial Git pesado | A local | M | medir; GC sólo aprobado | E4 | count-objects antes/después |
| Binarios históricos | B | M | scan de blobs/nombres; no filter-repo hoy | E1/E4 | top blobs y scan historia |
| Incompatibilidad Android | M | A | build/test dispositivo; permisos/deps mínimos | E2/E5 | APK + prueba Android real |
| Incompatibilidad Windows | M | A | conservar fork/storage/SQLite; package test | E2/E5 | build/ZIP portable y smoke test |
| Aumento de boilerplate | M | M | MVVM/use cases/interfaces selectivos | E3 | review de archivo/clase y LOC |
| Refactor demasiado grande | A | A | separar E2 retiro y E3 arquitectura | E2/E3 | PRs por fase, green baseline |
| Tests insuficientes | M | C | migración/integración Windows+Android | E2/E5 | coverage crítica y 332 como piso |
| Comentarios obsoletos | M | M | comentar decisiones/invariantes, no narración | E3 | doc review/grep Sync |
| Ruptura de localizaciones | A | A | borrar keys fuente y regenerar; tests ES/EN | E2 | gen-l10n + l10n tests |
| Regresión metadata | M | A | HTTP/keys opcionales aislados | E2/E3 | tests RAWG/IGDB offline/error |
| Regresión media | M | C | filesystem adapter y hashes | E2/E3 | save/select/delete/backup media |
| Regresión vistas guardadas | M | A | preservar SavedViews y JSON | E2 | roundtrip/filter/sort/columns |
| Ratings global/partida inconsistentes | M | M | decisión de source of truth; no fusionar | E3 | completion y statistics tests |
| FKs/huérfanos tras migración | B | C | `foreign_key_check`, counts y queries huérfanas | E2 | PRAGMA + queries explícitas |
| Secure storage no disponible | M | M | app funcional sin keys; errores tipados | E2/E3 | tests sin plugin/credenciales |
| Providers online rompen offline | M | A | ninguna llamada al arranque; capacidades opcionales | E3/E5 | cold start sin red/keys |
| KGP legacy rompe build futuro | M | A | retirar scanner; actualizar file_picker aislado | E2/E4 | build con Flutter objetivo |
| Reescritura Git accidental | B | C | prohibir force/filter; bundle externo | E1/E4 | refs/hashes y remote policy |

## Riesgos dominantes

Los tres riesgos que gobiernan E2 son: preservar datos/schema, no borrar infraestructura compartida y evitar un refactor simultáneo demasiado grande. La mitigación común es una secuencia corta y verificable: tests de migración → desacople transaccional → retiro UI/protocolos → drop DB → secure storage → builds reales.
