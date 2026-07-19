# E3 completion report — Simplificación funcional del producto Offline

Fecha de cierre: 2026-07-17

## Resultado

E3 queda completo en `codex/offline-e3-simplify-product`. Backlog Vault conserva la biblioteca local, la importación CSV, los providers opcionales, covers, media local y los modelos separados `Game`, `LibraryEntry` y `Playthrough`. El backup/restore complejo fue retirado del producto activo y reemplazado por una única exportación JSON de sólo lectura, sin restore.

No se cambió la versión (`0.3.0+5`), el schema Drift físico (`6`) ni la arquitectura general. No se inició E4, no se modificó `main`, y no se creó tag ni release.

## Baseline y rama

- Rama inicial: `main`.
- Commit inicial: `ef7ab0605d4cde12f87a46a1ddfd03568d56d1f8` (`docs: complete Android offline migration smoke test`).
- Rama de trabajo: `codex/offline-e3-simplify-product`.
- Bundle histórico E1: preservado en la ubicación externa auditada; no se modificó ni eliminó.
- Flutter: `3.44.1`.
- Dart: `3.12.1`.
- Baseline: analyze limpio, `256/256` tests, Windows release correcto y APK release correcto.

Entrega Git:

- `6ff3f67 feat: add portable offline library export`;
- `2004129 refactor: remove legacy backup and restore`;
- `docs: document simplified offline product` (este reporte y documentación asociada);
- destino: `origin/codex/offline-e3-simplify-product`;
- `main` permanece sin modificar por E3.

## Exportación JSON

- `format`: `backlog-vault-library-export`.
- `formatVersion`: `1`.
- Nombre: `backlog-vault-library-YYYYMMDD-HHmmss.json`.
- Codificación: UTF-8, JSON válido y pretty printed.
- Snapshot: una transacción Drift de lectura para obtener una vista coherente.
- Orden: colecciones ordenadas por ID para que el contenido sea determinista salvo `exportedAt`.
- Origen: `appVersion` y `sourcePlatform` (`windows` o `android`).
- Resumen: counts por colección.

El documento exporta:

- juegos;
- entradas personales de biblioteca;
- playthroughs;
- plataformas y géneros;
- relaciones entrada-plataforma y juego-género;
- vistas guardadas;
- identificadores/metadata externa funcional;
- metadata descriptiva de media;
- estados, ratings, horas, fechas, notas, opcionales y soft deletes.

El documento excluye:

- claves RAWG, IGDB/Twitch y SteamGridDB;
- tokens, passwords, secure storage y credenciales;
- datos o tablas Sync;
- paths locales absolutos o privados;
- bytes/base64 de imágenes;
- SQLite, logs, cachés y datos innecesarios del dispositivo.

La sección `media` conserva sólo información descriptiva y una señal de existencia local. No incluye `localPath`, nombre de archivo ni contenido binario; por lo tanto, el JSON no promete restaurar imágenes locales.

No se agregó importación ni restore del JSON. La importación CSV sigue siendo un flujo separado.

## Guardado multiplataforma

El flujo construye el documento, lo serializa, genera bytes UTF-8 y entrega esos bytes a `FilePicker.saveFile`. La cancelación tiene un resultado propio y no se muestra como error; los errores reales se registran redactados y la UI recibe un mensaje genérico localizado.

El bug legado quedó documentado, no reparado: con `file_picker 11.0.2`, Android exige `bytes` en `saveFile`; el backup anterior no los proporcionaba y transformaba el `ArgumentError` en un mensaje genérico. El export nuevo resuelve correctamente esa incompatibilidad al proporcionar siempre los bytes, tanto al contrato Windows como al Android.

## Backup/restore retirado

Se eliminaron siete archivos productivos exclusivos:

- `backup_restore_providers.dart`;
- `backup_file_picker_service.dart`;
- `backup_service.dart`;
- `encrypted_backup_codec.dart`;
- `export_repository.dart` legado;
- `backup_models.dart`;
- `backup_restore_page.dart`.

También se retiraron la ruta de navegación, UI, copy EN/ES, password, cifrado, ZIP, manifest, packaging de media, preview, merge, overwrite y transacción de restore. No quedaron clases productivas huérfanas ni una superficie activa oculta.

## Tests y localización

- Archivos de tests exclusivos eliminados: `3`.
- Casos de backup/restore eliminados: `22`.
- Casos nuevos/agregados: `12`.
- Total final: `246/246`.
- Claves ARB eliminadas: `50` por locale.
- Claves ARB agregadas: `6` por locale.

La cobertura nueva verifica contrato, fecha UTC, app/plataforma, resumen, export vacío y complejo, opcionales, Unicode, saltos de línea, fechas, ratings, horas, soft deletes, IDs, relaciones, orden determinista, JSON/UTF-8, privacidad, nombre portable, guardado con bytes en Windows/Android, éxito, cancelación, error controlado y UI/localización EN/ES.

Se conservaron y reejecutaron las suites de CSV, DB/migraciones, metadata, media, vistas guardadas y playthroughs.

## Dependencias y peso

Dependencias directas eliminadas:

- `archive`;
- `cryptography`.

También desapareció `posix`, que sólo era transitiva de esa funcionalidad. Se conservaron `crypto` para hashing funcional de media, `file_picker`, `csv`, `flutter_secure_storage`, `http`, `path_provider` y el resto de dependencias necesarias para importación, providers, media y filesystem compartido.

- Dependencias runtime directas: `18` → `16`.
- Archivos trackeados: `325` antes; el resultado neto se mantiene en `325` al reemplazar archivos retirados por exportador, tests y documentación.
- Windows release: `35.962.808` → `35.634.502` bytes (`-328.306`).
- APK release: `68.127.549` → `67.291.161` bytes (`-836.388`).
- Plugins nativos: sin cambios funcionales; se mantienen los requeridos por picker, lifecycle, secure storage, JNA/JNI, paths y preferences.

No se realizó optimización profunda; la reducción es el efecto natural de retirar backup/restore.

## Providers externos y dominio

RAWG, IGDB/Twitch, SteamGridDB, covers de IGDB y covers locales se preservaron. La aplicación continúa funcionando offline y sin credenciales. La auditoría recomienda mantenerlos en E3 y evaluar consolidación de contratos/caché, ownership de credenciales y reducción de duplicación en E4/E5 antes de considerar retiros.

La responsabilidad funcional quedó documentada así:

- `Game`: datos de la obra y metadata descriptiva general.
- `LibraryEntry`: relación y preferencias personales del usuario.
- `Playthrough`: una partida/experiencia concreta.

Las duplicaciones actuales de rating, horas, fechas, notas y estados se preservan. E4/E5 debe definir fuentes de verdad y agregados antes de cualquier cambio de schema o migración.

## Validaciones finales

- `flutter clean`: la limpieza lógica se completó, aunque Windows informó dos veces que un handle externo impedía borrar completamente `build`; `pub get`, generación y ambos builds posteriores regeneraron los artefactos correctamente.
- `flutter pub get`: correcto.
- `dart run build_runner build --delete-conflicting-outputs`: correcto; el runner informó que el flag ya no requiere acción adicional.
- Generación de localizaciones: correcta.
- `flutter analyze`: limpio.
- `flutter test`: `246/246`.
- Suites focalizadas: `115/115`.
- `flutter build windows --release`: correcto.
- `flutter build apk --release`: correcto.
- Warning de dependencias: aviso conocido de KGP de `file_picker`, `CupertinoIcons` y paquetes con versiones nuevas incompatibles; ninguno bloquea E3.

## QA Windows

No se abrió el binario release contra el perfil Windows real porque no se verificó un perfil descartable separado y el gate prohíbe arriesgar datos reales. El contrato Windows se validó mediante fake del saver, incluyendo selección, bytes escritos y contenido parseable. Settings, localización e importación CSV se cubrieron por widget/integration tests. Esta es una limitación de QA manual, no una falla funcional observada.

## QA Android real

- Dispositivo: Motorola edge 40 pro.
- Device ID: `ZY22GT5X4X`.
- Android: `16` / API `36`.
- Usuario Android: `0`.
- Package: `dev.backlogvault.app`.
- Versión antes/después: `0.3.0`.
- versionCode antes/después: `5`.
- `firstInstallTime`: `2026-06-27 14:09:52` (preservado).
- `lastUpdateTime` anterior: `2026-07-17 16:13:29`.
- `lastUpdateTime` E3: `2026-07-17 17:20:11`.
- Perfil confirmado antes de instalar: `0` juegos, `0` entradas, `0` playthroughs, sin datos reales inesperados.
- APK: `build/app/outputs/flutter-apk/app-release.apk`.
- Tamaño APK: `67.291.161` bytes.
- SHA-256 APK: `C5044283065F1DE887BFE9C054380579A4C5DE3678400C1B2232BFC0A43F0E92`.
- Certificado SHA-256: coincidió con el APK previamente instalado.
- Instalación: `adb install -r`, salida `Success`; update in-place sin uninstall, downgrade ni limpieza de datos.
- Permiso `CAMERA`: ausente.

Primera apertura:

- arranque correcto;
- biblioteca vacía preservada;
- Settings mostró `Exportar biblioteca` y no mostró backup/restore complejo ni Sync;
- selector DocumentsUI abierto de forma controlada;
- destino confirmado mediante interacción humana puntual;
- archivo guardado correctamente usando bytes.

Export Android validado fuera del repositorio:

- archivo: `backlog-vault-library-20260717-202127.json`, conservado en una carpeta externa al repositorio;
- tamaño: `6.103` bytes;
- SHA-256: `5B8D2840063361585F82A82A78461622B87CFF7B8B4C7E58FAB3194EF49128FA`;
- `format`: correcto;
- `formatVersion`: `1`;
- `appVersion`: `0.3.0`;
- `sourcePlatform`: `android`;
- biblioteca: `0` juegos, `0` entradas, `0` playthroughs, `0` vistas, `0` metadata y `0` media;
- catálogos semilla: `12` plataformas y `13` géneros;
- JSON: válido, UTF-8 y no vacío;
- privacidad: sin credenciales, secure storage, paths privados, bytes/base64 ni nombres de tablas Sync.

Segunda apertura:

- arranque correcto sobre la misma DB;
- biblioteca continuó vacía;
- Settings mantuvo la única exportación JSON;
- no reaparecieron backup/restore ni Sync;
- no hubo solicitudes de cámara ni sockets/servicios Sync.

Logcat del proceso mostró dos warnings no bloqueantes de `AHardwareBuffer` en cada arranque. No se encontraron errores Drift, migration, database, foreign key, `no such table`, secure storage, FATAL/AndroidRuntime, cámara, sockets ni operaciones sobre tablas Sync. No se guarda logcat completo en Git.

## Secret scan y residuos

- Ningún JSON real exportado está dentro del repositorio ni trackeado.
- Ningún backup real, APK, ZIP, log, DB, keystore o `.env` está trackeado.
- No se agregaron credenciales ni valores con forma de secretos.
- Las rutas de perfil agregadas aparecen únicamente como marcadores sintéticos en tests de privacidad y demuestran la exclusión; no corresponden a usuarios reales.
- Las menciones restantes de backup/restore aparecen en auditorías/historial, documentación de retirada, limitaciones o tests de ausencia.
- `archive`/`cryptography` no tienen imports productivos ni entradas directas de dependencia.

## Recomendación exacta para E4

Iniciar E4 desde este baseline sólo después de aprobación: aplicar el layout feature-first y MVVM pragmático de manera incremental, comenzando por definir ownership y fuentes de verdad entre `Game`, `LibraryEntry` y `Playthrough`, y consolidar interfaces de providers/credenciales sin cambiar schema ni comportamiento hasta contar con tests de caracterización. No reintroducir restore, Sync ni una arquitectura paralela.

# Decisiones que requieren aprobación de Federico

Ninguna decisión nueva. E3 no reabre decisiones ya aprobadas.
