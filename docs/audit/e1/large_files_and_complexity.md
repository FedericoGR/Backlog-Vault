# Archivos grandes y complejidad

## Conteos

Líneas físicas del CSV (incluyen líneas en blanco):

| Umbral | Todos los archivos | Producción `lib/` no generado | Tests |
|---|---:|---:|---:|
| > 300 | 53 | 35 | 11 |
| > 500 | 31 | 19 | 6 |
| > 1.000 | 14 | 5 | 4 |

Los generados Drift/l10n no se consideran deuda de diseño aunque sean los archivos más grandes. Los ARB de 739 líneas requieren organización de keys, no división arbitraria que rompa gen-l10n.

## Hotspots prioritarios

| Path | Señal | Problema | División/destino sugerido | Riesgo | Tests requeridos |
|---|---:|---|---|---|---|
| `library/presentation/game_list_page.dart` | 1.809 líneas; builds de 190/213/178 líneas | tabla, galería, selección, filtros, vistas, dialogs y mutaciones | `LibraryViewModel`; widgets table/gallery/filter/saved-view/action bar | alto | filtros/sort, selección masiva, vistas guardadas, rutas, golden/layout |
| `bulk_metadata_import_page.dart` | 1.777; varios builds 142–207 | wizard, escaneo, edición de plan, cover picker y apply | ViewModel + steps/widgets por fase | alto | plan/diff/apply, cancelación, errores providers, widget por step |
| `game_form_page.dart` | 1.522; `build` 344, `_save` 77 | estado de formulario, metadata/media y persistencia en widget | `GameFormViewModel`, sections y dialogs | alto | create/edit, validación, metadata opcional, cover, offline |
| `manual_sync_section.dart` | 1.414; 41 métodos | todas las UX Sync/QR/LAN/pairing en un State | eliminar en E2, no refactorizar antes | alto | mantener tests hasta retiro; luego tests de ausencia |
| `game_detail_page.dart` | 1.324; múltiples builds 70–119 | carga, progreso, playthrough, media, metadata, dialogs | `GameDetailViewModel` + panels/actions | alto | progreso, playthroughs, cover, edit/delete, empty/error |
| `lan_sync_service.dart` | 922; `_handleHostRequest` 266, `_connectAndSync` 169 | transporte, handshake, package y resultado mezclados | eliminar E2; no invertir en nueva abstracción salvo seams de retiro | alto | LAN tests existentes hasta retiro |
| `lan_media_transfer_service.dart` | 869; 40 métodos | protocolo, validación, storage, DB y conflictos | eliminar parte Sync; conservar `MediaFileStorage` | alto | traversal, hash, MIME, missing cover |
| `sync_change_tracking.dart` | 773; `capture` 157 | snapshot, diff, recorder y transaction wrapper | desacoplar wrapper; eliminar tracking | crítico | transacciones locales equivalentes y rollback |
| `library_catalog_widgets.dart` | 754 | varias composiciones catálogo en un archivo | widgets por layout/card/row | medio | layout Windows/Android, overflow, acciones |
| `export_repository.dart` | 741; 36 métodos | export, restore, upsert y soft-delete de 10 entidades | separar logical export/restore; mantener transacción local | crítico | roundtrip, soft delete, counts, schema, backup |
| `game_repository.dart` | 730; 28 métodos | games, entries, catalogs joins y playthroughs | `GameRepository` + `PlaythroughRepository`; use case para complete | crítico | CRUD, progress, complete, bulk delete, migrations |
| `statistics_page.dart` | 683 | pantalla y muchos panels/charts | ViewModel + widgets por métrica | medio | cálculo aislado, empty/error y layout |
| `metadata_search_dialog.dart` | 629 | búsqueda, detalle, diff, apply y media | workflow/ViewModel + results/diff widgets | alto | providers, auth, diff/apply, offline/error |
| `settings_page.dart` | 582 | idioma, cuatro credenciales y Sync | retirar sección Sync; extraer credential controllers | alto | keys selectivas, idioma, ausencia Sync |
| `backup_restore_page.dart` | 556 | export/restore/password/confirms | ViewModel y dialogs reutilizables | alto | passwords, preview, confirmación, rollback |
| `media_search_dialog.dart` | 515 | búsqueda, local file, download/save | ViewModel; filesystem adapter | alto | provider, picker, invalid media, save/select |

## Métricas de métodos/clases

La medición AST usó el `analyzer` ya presente, sin instalar tooling:

- `GameFormPage.build`: 344 líneas.
- `_buildBacklogVaultTheme`: 294; cohesionable por color schemes/components.
- `LanSyncService._handleHostRequest`: 266.
- `BulkMetadataImport _apply`: 146, nesting 4.
- `LibraryStatisticsCalculator.calculate`: 135, nesting 3; buen candidato a subcálculos puros.
- `SyncConflictDetector.preview`: 84, nesting 7; mayor nesting detectado.
- Clases: Manual Sync 41 métodos; LAN media 40; ExportRepository 36; GameRepository 28; LanSyncService 24; MediaRepository/IgdbApiClient 19.

Los archivos de tests con `main()` gigantes agrupan muchos casos. No es deuda funcional inmediata, pero pueden dividirse por escenario al tocar cada área; los tests Sync se mantienen intactos hasta que su código salga.

## Responsabilidades y duplicación

- Pages llaman repositories y encadenan pasos async; el estado loading/error/result se repite localmente.
- Siete repositorios repiten envoltorio `SyncAwareTransaction`, source y changed-fields.
- `ExportRepository` repite upsert/soft-delete por entidad; conviene helpers internos tipados, sin un generic repository global.
- Formularios/importadores repiten normalización de strings, ratings y fechas; centralizar sólo reglas idénticas en domain.
- Metadata y media comparten auth/key storage de IGDB de forma que crea ciclos de ownership.
- Serializaciones de backup y Sync se parecen pero tienen semánticas distintas; no fusionarlas antes de retirar Sync.
- Se usa `AsyncValue.when` correctamente, pero falta un screen-state/Notifier para operaciones mutables de larga duración.

## Orden de refactor

1. E2: eliminar Sync y desacoplar transacciones, sin “embellecer” código que desaparecerá.
2. E3: extraer ViewModels de library, game form/detail, bulk import, settings y backup.
3. E3: dividir repositories por aggregate real, empezando games/playthroughs y export/restore.
4. E3: romper ciclos feature/l10n y media/metadata.
5. E4: revisar tests grandes y helpers comunes sólo después de estabilidad.

Los umbrales son señales, no reglas automáticas. Un archivo largo generado o declarativo puede ser correcto; una clase corta con dos responsabilidades puede no serlo.
