# Inventario del repositorio

Snapshot: `badbaa8` antes de agregar documentación E1. El inventario exhaustivo está en [repository_file_inventory.csv](repository_file_inventory.csv); este documento resume su lectura.

## Cobertura

Se procesaron los 327 paths devueltos por `git ls-files`. Cada fila incluye path, extensión, bytes, líneas físicas, categoría, feature, layer, condición de generado, responsabilidad, imports/dependencias, dependientes locales, problemas, decisión, destino, tests, riesgo y notas.

| Categoría | Archivos | Bytes |
|---|---:|---:|
| source | 168 | 1.181.858 |
| test | 88 | 524.243 |
| generated | 8 | 849.217 |
| native Android | 19 | 13.854 |
| native Windows | 15 | 68.104 |
| vendored | 8 | 51.665 |
| documentation | 14 | 53.238 |
| configuration | 5 | 35.047 |
| migration | 1 | 2.993 |
| script | 1 | 2.742 |

`assets/` no existe. Los únicos assets trackeados son iconos launcher Android y Windows. `tool/` contiene sólo `package_windows.ps1`; no hay configuración CI/CD trackeada.

## Decisiones del CSV

| Decisión | Archivos |
|---|---:|
| mantener | 238 |
| eliminar en E2 | 32 |
| dividir | 14 |
| mover | 2 |
| simplificar | 11 |
| revisar manualmente | 8 |
| generado, no editar | 8 |
| documentar | 14 |

Los 32 candidatos a eliminar son estrictamente `lib/features/sync/` y `test/features/sync/`. Las referencias integradas en `main.dart`, settings, manifest, pubspec, l10n y repositorios se marcan para simplificar, no para borrar el archivo completo.

## Generados

| Archivo/grupo | Fuente | Política |
|---|---|---|
| `lib/core/database/app_database.g.dart` | `app_database.dart`, `tables.dart`, Drift | Regenerar; no editar a mano. Actualmente trackeado. |
| `lib/l10n/app_localizations*.dart` | `app_en.arb`, `app_es.arb`, `l10n.yaml` | Regenerar con Flutter gen-l10n; actualmente trackeados. |
| `windows/flutter/generated_plugin_registrant.*` | Flutter plugins | Regenerar; mantener como parte del runner. |
| `windows/flutter/generated_plugins.cmake` | Flutter plugins | Regenerar; mantener como parte del runner. |
| `.metadata` | Flutter tooling | Configuración generada; no editar a mano. |

La política de tracking de generados no debe cambiar durante E2: hacerlo a la vez agregaría ruido y riesgo. Puede revisarse después con CI capaz de regenerarlos de forma reproducible.

## Lectura estructural

- `lib/`: app, core, l10n y 12 features; 173 archivos/1,94 MiB en el working tree.
- `test/`: 88 archivos/511,96 KiB; 332 tests ejecutados.
- `android/` y `windows/`: runner y build config; los outputs efímeros están ignorados.
- `third_party/flutter_secure_storage_windows/`: fork vendorizado usado por `dependency_overrides`; requiere política de ownership.
- `docs/`: documentación de releases y Sync; conservar historia, retirar instrucciones activas obsoletas sólo cuando E2 elimine el producto Sync.
- `dist/`: ignorado, 228,68 MiB; RC y QA más staging Windows. No está en Git.

## Hallazgos archivo por archivo que gobiernan el plan

- `lib/main.dart`: bootstrap global de Sync; simplificar en E2.
- Repositorios de catalogs, games, CSV import, saved views, media, metadata y export/restore: acoplados a `SyncAwareTransaction`; desacoplar antes de borrar Sync.
- Presentación: páginas grandes coordinan repositories y lógica; extraer ViewModels después de E2.
- `library_cover_thumbnail.dart`: usa `dart:io` directamente; mover acceso a filesystem detrás de un adapter.
- `domain_localizations.dart`: l10n importa dominios de varias features y esas features vuelven a importar l10n; dividir para romper ciclos.
- `library_game_details.dart`: agregado basado en filas Drift ubicado en application y consumido por otras features; mover a un boundary de dominio estable.
- `third_party/flutter_secure_storage_windows`: no eliminar junto con Sync mientras existan credenciales opcionales de metadata.

## Calidad del inventario

Las dependencias se derivaron de imports Dart resueltos y los dependientes del grafo inverso. Para archivos no Dart se documentó la toolchain principal. “No direct test import located” no significa ausencia de cobertura indirecta; señala que no existe un import de test directo al archivo. Las decisiones son propuestas de auditoría, no cambios aplicados.
