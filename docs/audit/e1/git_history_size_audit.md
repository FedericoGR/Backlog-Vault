# Auditoría de tamaño e historia Git

## Estado de objetos

`git count-objects -vH`:

- objetos sueltos: 22.050 / 55,33 MiB;
- objetos en pack: 1.744 / 1,02 MiB, 10 packs;
- garbage: 0;
- prune-packable: 0.

Los refs alcanzan 1.737 objetos únicos, 753 blobs y 10.780.006 bytes de blobs sin comprimir (10.964.687 bytes incluyendo trees/commits). `git fsck --unreachable --no-reflogs` enumeró 22.057 entradas: 15.685 blobs, 6.370 trees y 2 commits. Esto demuestra que el `.git` local está inflado por objetos sueltos/reflogs o capturas locales, no por la historia publicada. No se podó nada.

El bundle completo de 29 refs ocupa sólo 741.091 bytes y fue verificado, evidencia adicional de que los refs alcanzables comprimen bien.

## Top 50 blobs alcanzables de toda la historia

Un mismo path aparece varias veces porque se listan versiones históricas distintas.

| # | Bytes | Hash corto | Path |
|---:|---:|---|---|
| 1 | 576.835 | `4f56d889` | `lib/core/database/app_database.g.dart` |
| 2 | 343.125 | `94cfe645` | `lib/core/database/app_database.g.dart` |
| 3 | 287.678 | `34cd6d91` | `lib/core/database/app_database.g.dart` |
| 4 | 248.578 | `b042c044` | `lib/core/database/app_database.g.dart` |
| 5 | 223.031 | `1b115397` | `lib/core/database/app_database.g.dart` |
| 6 | 134.837 | `f4badaa2` | `lib/l10n/app_localizations.dart` |
| 7 | 131.873 | `c6fde99f` | `lib/l10n/app_localizations.dart` |
| 8 | 130.274 | `2fbfcd1f` | `lib/l10n/app_localizations.dart` |
| 9 | 127.726 | `1cfef75e` | `lib/l10n/app_localizations.dart` |
| 10 | 126.271 | `e538cd8e` | `lib/l10n/app_localizations.dart` |
| 11 | 125.030 | `7b3bdc73` | `lib/l10n/app_localizations.dart` |
| 12 | 118.890 | `ebef3d61` | `lib/l10n/app_localizations.dart` |
| 13 | 112.118 | `48040331` | `lib/l10n/app_localizations.dart` |
| 14 | 105.422 | `be19f54c` | `lib/l10n/app_localizations.dart` |
| 15 | 63.877 | `f1b4e170` | `lib/l10n/app_localizations_es.dart` |
| 16 | 62.684 | `73566b2e` | `lib/features/library/presentation/game_list_page.dart` |
| 17 | 62.607 | `16064742` | `lib/features/bulk_metadata_import/presentation/bulk_metadata_import_page.dart` |
| 18 | 62.377 | `6da325b8` | `lib/l10n/app_localizations_es.dart` |
| 19 | 61.478 | `9b01bfb2` | `lib/features/library/presentation/game_list_page.dart` |
| 20 | 61.380 | `ba62b74b` | `lib/l10n/app_localizations_en.dart` |
| 21 | 61.354 | `f540ed33` | `lib/l10n/app_localizations_es.dart` |
| 22 | 60.511 | `fb64977c` | `lib/features/bulk_metadata_import/presentation/bulk_metadata_import_page.dart` |
| 23 | 60.503 | `73d29675` | `lib/features/bulk_metadata_import/presentation/bulk_metadata_import_page.dart` |
| 24 | 60.200 | `d817be99` | `lib/features/library/presentation/game_list_page.dart` |
| 25 | 60.066 | `6697b1de` | `lib/l10n/app_localizations_es.dart` |
| 26 | 59.988 | `c3a4c678` | `lib/l10n/app_localizations_en.dart` |
| 27 | 59.764 | `ecf77fa8` | `lib/features/library/presentation/game_list_page.dart` |
| 28 | 59.304 | `5db44287` | `lib/features/bulk_metadata_import/presentation/bulk_metadata_import_page.dart` |
| 29 | 59.194 | `b4469566` | `lib/l10n/app_localizations_es.dart` |
| 30 | 59.071 | `4cc12551` | `lib/features/library/presentation/game_list_page.dart` |
| 31 | 59.012 | `39d29108` | `lib/l10n/app_localizations_en.dart` |
| 32 | 58.466 | `2fe8e0e1` | `lib/l10n/app_localizations_es.dart` |
| 33 | 57.835 | `a38f7096` | `lib/l10n/app_localizations_en.dart` |
| 34 | 57.204 | `dee477dc` | `lib/features/games/presentation/game_form_page.dart` |
| 35 | 57.013 | `3adc3d95` | `lib/l10n/app_localizations_en.dart` |
| 36 | 56.346 | `8465b9ac` | `lib/l10n/app_localizations_en.dart` |
| 37 | 56.197 | `7fbd358c` | `lib/features/games/presentation/game_form_page.dart` |
| 38 | 55.119 | `2d177920` | `lib/l10n/app_localizations_es.dart` |
| 39 | 54.743 | `09097755` | `lib/features/games/presentation/game_form_page.dart` |
| 40 | 53.211 | `095955c3` | `lib/l10n/app_localizations_en.dart` |
| 41 | 52.150 | `930155d8` | `test/features/sync/data/lan_sync_service_test.dart` |
| 42 | 51.865 | `2d193cf8` | `lib/features/library/presentation/game_list_page.dart` |
| 43 | 51.684 | `f45f338d` | `lib/features/library/presentation/game_list_page.dart` |
| 44 | 51.174 | `e3252af6` | `lib/l10n/app_localizations_es.dart` |
| 45 | 50.013 | `26c3480c` | `lib/features/library/presentation/game_list_page.dart` |
| 46 | 49.791 | `96ec35ba` | `lib/features/library/presentation/game_list_page.dart` |
| 47 | 49.708 | `b6a57ec5` | `lib/l10n/app_localizations_en.dart` |
| 48 | 49.639 | `259abbd5` | `lib/features/sync/presentation/manual_sync_section.dart` |
| 49 | 49.079 | `275e8319` | `lib/features/sync/presentation/manual_sync_section.dart` |
| 50 | 49.076 | `9e2c1603` | `lib/features/library/presentation/game_list_page.dart` |

## Binarios y datos históricos

El recorrido de nombres de toda la historia sólo encontró binarios visuales esperados:

- cinco PNG launcher Android;
- `windows/runner/resources/app_icon.ico`.

No se encontraron APK, ZIP, EXE, DLL, PDB, `.so`, DB/SQLite, keystore, backups ni paquetes `.vaultsync`/`.vaultpair` trackeados en commits alcanzables.

## Secretos e información sensible

El scan por contenido e historia, sin imprimir valores, no encontró private keys ni patrones de tokens AWS/GitHub/OpenAI. No hay archivos de credenciales históricos. Las coincidencias actuales son storage-key identifiers, valores dummy de tests y paths personales deliberados en `privacy_redactor_test.dart`. Clasificación: dummy/documentación/falso positivo; ningún hallazgo real confirmado.

## Recomendación

- E1: no hacer nada destructivo, cumplido.
- Después del Offline Release: un `git gc` normal/local podría recuperar gran parte de los objetos sueltos, previa nueva copia y aprobación.
- `git filter-repo`: no recomendado con la evidencia actual; el historial alcanzable es pequeño y no contiene binarios/secrets problemáticos.
- Reescribir y force-push sólo tendría sentido si un scan futuro encuentra un secreto real o un blob grande alcanzable. Ese no es el caso hoy.
