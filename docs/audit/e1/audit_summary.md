# E1 — Resumen ejecutivo de auditoría Offline

Fecha de auditoría: 2026-07-16 (America/Buenos_Aires)

Baseline inspeccionado: `release/v0.3` @ `badbaa8cf1dfcf7de9affa74a5bcdee7391286c1`

Rama documental: `codex/offline-e1-audit`

Alcance: preservación, medición, análisis y documentación. No se modificó código productivo.

## Resultado ejecutivo

`release/v0.3` es el baseline canónico recomendado. Contiene a `main` y a todas las ramas locales/remotas de Sync, LAN, pairing y QR. Ninguna rama encontrada tiene commits fuera de su historia. Los dos commits que separan `main` de `release/v0.3` son el ajuste de versión `0.3.0+5` y documentación/checksums de RC1; el código funcional acumulado está contenido y el árbol inicial estaba limpio.

La arquitectura objetivo recomendada es **feature-first + MVVM pragmático + Repository/Service**, con use cases sólo cuando coordinan repositorios, encapsulan una transacción/regla compleja o se reutilizan. Se rechaza Clean Architecture estricta para este tamaño porque multiplicaría interfaces, DTOs, mappers y archivos sin un beneficio proporcional. La decisión se desarrolla en [ADR-001](../../architecture/ADR-001-offline-architecture.md).

El peso no está en el código: 327 archivos trackeados ocupan 2,65 MiB, mientras el directorio completo ocupa 2,08 GiB. `build/`, `.dart_tool/`, outputs efímeros de Windows y `dist/` explican casi todo. En Android, `mobile_scanner` incorpora Barhopper y modelos ML; junto con el APK universal de tres ABI es la principal oportunidad de reducción de paquete al retirar QR.

## Preservación histórica

- Carpeta: `C:\Users\Feder\Documents\Backlog Vault Backups\pre-offline-refactor\20260716-1613`
- Bundle: `backlog-vault-pre-offline-20260716-1613.bundle`
- SHA-256: `ebacf65e90e07a9d1959cc333b8d32bc5acac88cc26693e0ce36991f3f1916ee`
- `git bundle verify`: correcto; 29 refs y “complete history”.
- Release notes: v0.1, v0.2 y v0.3, más checksums RC1.
- APK RC1: 86.280.143 bytes; SHA-256 `8c68a1ce4a4cdcc3a2ddb24634f65ee60e7e4b5faaee955b275b431869957953`.
- ZIP Windows RC1: 15.274.466 bytes; SHA-256 `c6c6f57b4f6b3f5df40d0b82c569d3928995cee80dbf19fdd8f0d83fe745de6b`.
- Ambos artefactos copiados coinciden con `docs/checksums_v0_3_0_rc1.txt`; los originales no fueron modificados.

## Git y consolidación

- Estado inicial: `release/v0.3`, HEAD `badbaa8`, árbol limpio.
- Estado final esperado: `codex/offline-e1-audit`, sólo documentación E1.
- Ramas: 7 locales y 13 heads en `origin`; 6 tags.
- Todas las ramas están contenidas en `release/v0.3`; commits exclusivos respecto del baseline: cero.
- `main` está 2 commits detrás; `release/v0.2`, 6; `release/v1`, 19.
- E2 debe nacer del commit documental de E1 y no debe mergear ramas antiguas: ya están consolidadas por ancestría.
- No se borraron ramas/tags ni se reescribió historia. Véase [auditoría de ramas](git_branch_audit.md).

## Baseline funcional

Entorno: Flutter 3.44.1 stable, Dart 3.12.1, Windows 10.0.22631.6199. `flutter devices` detectó Windows, Chrome y Edge; no había dispositivo/emulador Android conectado. El APK compila, pero el smoke test Android real queda como gate de E2/E5.

| Operación | Resultado | Duración aproximada |
|---|---:|---:|
| `flutter pub get` | exit 0; sin diff trackeado | 7,40 s |
| `flutter analyze` | 0 issues, 0 warnings, exit 0 | 19,48 s de pared; 13,6 s Flutter |
| `flutter test` | 332/332, 0 fallos, 0 skipped | 34,37 s reporter |
| `flutter build windows --release` | exit 0 | 14,55 s |
| `flutter build apk --release` | exit 0 | 8,24 s en repetición `--no-pub` |

El build Android avisa que `file_picker` y `mobile_scanner` todavía aplican Kotlin Gradle Plugin; una versión futura de Flutter exigirá Built-in Kotlin. No se corrigió ni actualizó nada en E1.

## Tamaños

| Medida | Tamaño |
|---|---:|
| Repositorio completo | 2.231.651.784 bytes (2,08 GiB) |
| Working tree sin `.git` | 2.172.453.342 bytes (2,02 GiB) |
| `.git` | 59.198.442 bytes (56,46 MiB) |
| Archivos trackeados | 2.782.961 bytes (2,65 MiB) |
| Archivos ignorados | 2.169.670.381 bytes (2,02 GiB) |
| `build/` | 1,22 GiB |
| `.dart_tool/` | 315,77 MiB |
| `windows/` (incluye ephemeral) | 260,84 MiB |
| `dist/` | 228,68 MiB |
| `lib/` | 1,94 MiB |
| `test/` | 511,96 KiB |
| APK release | 86.280.143 bytes (82,28 MiB) |
| Windows Release completo | 36.684.220 bytes (34,98 MiB) |
| EXE launcher | 81.920 bytes (80 KiB) |
| ZIP Windows RC1 | 15.274.466 bytes (14,57 MiB) |

La historia alcanzable suma 10.780.006 bytes de blobs sin comprimir y no contiene APK, ZIP, EXE, DLL ni bases de datos; sólo iconos PNG/ICO. Los 55,33 MiB de objetos sueltos locales y 22.057 entradas reportadas como no alcanzables al ignorar reflogs explican el `.git` actual. No se ejecutó GC.

## Inventario y complejidad

- Archivos inventariados: 327.
- Archivos fuente: 168.
- Generados: 8.
- Tests/fixtures: 88.
- Candidatos `eliminar en E2`: 32 (24 Sync productivos + 8 tests Sync).
- Candidatos `mover`/`dividir`/`fusionar`: 16 (14 dividir, 2 mover, 0 fusionar).
- El inventario exhaustivo procesable está en [repository_file_inventory.csv](repository_file_inventory.csv).
- Hotspots: `app_database.g.dart` (generado, 576.835 bytes), `game_list_page.dart` (~1.809 líneas físicas), `bulk_metadata_import_page.dart` (~1.760), `game_form_page.dart` (~1.530), `manual_sync_section.dart` (~1.425) y `game_detail_page.dart` (~1.330).
- Clases no generadas con mayor superficie: `ManualSyncSection` 41 métodos, `LanMediaTransferService` 40, `ExportRepository` 36 y `GameRepository` 28.

## Arquitectura actual y Sync

El flujo dominante es UI → providers Riverpod → repositorios → Drift. Las páginas no importan Drift de forma generalizada, pero varias importan repositorios/data directamente y coordinan reglas extensas. `library_cover_thumbnail.dart` accede a `dart:io` desde presentación. Siete repositorios funcionales están acoplados a `SyncAwareTransaction`; `main.dart` inicializa Sync al arrancar.

Alcance medido de Sync:

- 24 archivos productivos, 7.696 líneas no vacías medidas inicialmente y 277.119 bytes.
- 8 archivos de tests, 5.132 líneas no vacías y 181.145 bytes.
- 153 claves fuente de localización con prefijo `sync` por idioma.
- 6 tablas, 8 índices explícitos y schema físico 5.
- Secure storage para identity y claves de grupo.
- QR, cámara, pairing, `.vaultpair`, `.vaultsync`, LAN, challenge/proof, transferencia de media, oplog, tombstones, hashes, conflictos y codecs.
- Dependencias exclusivas candidatas: `qr_flutter` y `mobile_scanner`; dependencias compartidas que no deben borrarse en bloque: `file_picker`, `flutter_secure_storage`, `crypto`, `cryptography`, `http` y filesystem/media.

El retiro debe desacoplar primero los repositorios funcionales, luego apagar bootstrap/UI y protocolos, y recién después migrar DB y limpiar sólo las claves seguras de Sync. Véase [impacto de retiro](sync_removal_impact.md).

## Datos y dominio

- Schema físico confirmado: 5.
- Backup lógico: 4.
- Protocolo Sync: 1.
- 10 tablas funcionales y 6 exclusivas de Sync.
- No hay triggers. Las FKs funcionales usan el comportamiento por defecto; las columnas Sync no declaran FKs Drift.
- Recomendación: mantener separados `Game` (obra), `LibraryEntry` (relación/preferencias del usuario) y `Playthrough` (intento/partida). No fusionar ni eliminar `Playthrough` en E1/E2; aclarar después la semántica entre rating global y rating por partida.
- Próximo schema candidato: 6, por monotonicidad, sujeto a aprobar el alcance exacto de E2 y a generar snapshots/tests de migración antes de tocar datos.

## Dependencias y peso de builds

El lock contiene 140 paquetes: 20 dependencias directas main, 6 directas dev y 112 transitivas. `flutter pub outdated --no-dev-dependencies --no-transitive` detectó 6 directas actualizables en lock; no se actualizaron. El APK universal contiene tres ABI. Barhopper de `mobile_scanner` suma aproximadamente 13,45 MiB sin comprimir, más modelos ML; por eso retirar QR/cámara tendrá impacto real. Reordenar carpetas o adoptar MVVM casi no reducirá binarios por sí solo.

## Secretos y privacidad

El scan read-only del working tree e historia no halló private keys, patrones AWS/GitHub/OpenAI, `.env`, keystores, bases reales, backups reales, `.vaultsync`/`.vaultpair` reales ni binarios de usuario trackeados. Las coincidencias fueron nombres de claves de secure storage, passwords/tokens dummy de tests, el fixture sintético `igdb_token.json` y paths personales deliberados en el test del redactor. No se incluyó ningún valor completo en los reportes.

## Confirmaciones de E1

- No se cambió funcionalidad, UI, comportamiento, schema, versión, dependencias ni código productivo.
- No se eliminó Sync, QR, LAN, tablas, permisos ni secure storage.
- No se hizo merge a `main`, release, GC, filter-repo, force push ni borrado de refs.
- La única salida a commitear pertenece a `docs/audit/`, `docs/architecture/` y `docs/planning/`.
- Mensaje de commit previsto: `docs: audit repository and define offline architecture`.

## Recomendación exacta para E2

Tras aprobación, crear `codex/offline-e2-remove-sync` desde el commit de E1. Primero agregar pruebas de migración schema 5 y de preservación funcional; después reemplazar `SyncAwareTransaction` por transacciones Drift locales en los siete repositorios; retirar bootstrap/UI; eliminar protocolos/QR/LAN y dependencias exclusivas; migrar las seis tablas; limpiar sólo claves Sync tras validación; y cerrar con analyze, 332 tests como piso, nuevos tests de migración y builds Windows/Android. No mezclar este trabajo con el gran refactor de carpetas.

# Decisiones que requieren aprobación de Federico

1. Aprobar `release/v0.3` @ `badbaa8` como baseline final de consolidación.
2. Aprobar feature-first + MVVM pragmático + Repository/Service como arquitectura objetivo.
3. Mantener `Playthrough` como entidad separada y definir en un ciclo posterior la semántica de sus ratings.
4. Elegir exportación simple JSON solamente o JSON + CSV.
5. Mantener backup/restore cifrado completo o simplificarlo después de E2.
6. Mantener ambos providers de metadata (RAWG e IGDB) y ambos de covers (SteamGridDB e IGDB), o reducir el conjunto.
7. Autorizar más adelante un GC local normal; no se recomienda reescribir historia con `filter-repo` según la evidencia actual.
8. Definir la versión del primer Offline Release.
