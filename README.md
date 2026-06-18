# Backlog Vault

Backlog Vault es una app personal local-first para gestionar un backlog de videojuegos. La Release Candidate v1 UI refresh queda preparada para uso local en Windows y Android, con biblioteca offline, metadata opcional, portadas locales, bulk import, backups normales/cifrados y empaquetado portable.

## Release Candidate v1

- Versión de app: `0.1.0+2`.
- Release tag objetivo: `v0.1.0-rc2`.
- Windows portable: generar con `.\tool\package_windows.ps1`; el ZIP final esperado queda en `dist/BacklogVault-windows-x64-v0.1.0-rc2.zip`.
- Android local: generar con `flutter build apk`; el APK final puede copiarse como `dist/BacklogVault-android-v0.1.0-rc2.apk`.
- Release notes: [docs/release_notes_v1.md](docs/release_notes_v1.md).
- Instalación y portabilidad: [docs/install_and_portability.md](docs/install_and_portability.md).
- Checklist QA v1: [docs/qa_v1_checklist.md](docs/qa_v1_checklist.md).

### Qué incluye RC2

- Refresh visual completo Nexus-inspired para Biblioteca, Detalle, Crear/Editar, Metadata, Covers, Home, Estadísticas, Ajustes, Backups e import flows.
- Design system oscuro reutilizable con panels, chips, cards, banners y estados consistentes.
- Stabilization responsive final para Windows desktop, desktop mediano y Android.

Limitaciones conocidas de v1: no hay sync automático, la DB SQLite local y la carpeta `media/` no están cifradas at-rest, el APK Android es para instalación personal con signing local/debug y las API keys deben configurarse por dispositivo.

## Alcance del Entregable 1

- App Flutter preparada para Windows y Android.
- Persistencia local con SQLite + Drift.
- State management con Riverpod.
- Navegación con go_router.
- Modelo mínimo:
  - `Game`: obra/juego canónico.
  - `LibraryEntry`: relación personal con ese juego.
  - `Playthrough`: partida o experiencia concreta.
- CRUD manual de juegos.
- Soft delete con `deletedAt`.
- Plataformas y géneros manuales.
- Playthrough básico.
- Cambio a estado completado creando o cerrando playthrough.
- Fechas visibles en formato `dd-MM-yyyy`.
- UI en español.
- Sin login y sin internet.

## Alcance del Entregable 2

- Importación desde CSV exportado de Notion.
- Selector nativo de archivo CSV.
- Parseo de headers y filas con soporte de comillas, comas y saltos de línea.
- Mapping editable de columnas.
- Preview antes de escribir en base.
- Normalización de fechas, duración, puntaje, estado, géneros y plataformas.
- Warnings y errores por fila.
- Detección básica de duplicados.
- Importación confirmada y transaccional.
- Resumen final de importación.

## Alcance del Entregable 3

- Tabla avanzada desktop para biblioteca con `data_table_2`.
- Lista responsive compacta para pantallas chicas.
- Búsqueda global por título, plataformas, géneros, tipo y notas.
- Filtros por estado, plataforma, género, puntaje, fechas, horas, tipo y datos faltantes.
- Ordenamiento por título, estado, puntaje, fecha de salida, fecha de completado, horas y actualización.
- Columnas visibles configurables con título obligatorio.
- Vistas default en memoria.
- Vistas custom persistidas localmente en `saved_views` con soft delete.
- Resumen/totales de la vista visible.

## Alcance del Entregable 4

- Ficha avanzada de juego con resumen y progreso.
- Acciones rápidas para marcar jugando, pausado, completado, abandonado o pendiente.
- Playthroughs mejorados:
  - crear;
  - editar;
  - soft-delete;
  - listar con estado, plataforma, fechas, horas, puntaje y notas.
- Resumen de horas totales, último completado, cantidad de playthroughs y partida activa/pausada.
- Operaciones de progreso transaccionales para mantener consistencia entre `LibraryEntry` y `Playthrough`.

## Alcance del Entregable 5

- Metadata automática opcional con provider RAWG.
- Configuración local de API key RAWG desde Ajustes.
- Guardado de API key mediante secure storage del sistema.
- Búsqueda de candidatos desde la ficha del juego.
- Preview/diff de metadata antes de aplicar.
- Aplicación selectiva de campos.
- Guardado de external IDs en `external_game_ids`.
- Creación/reuso de géneros y plataformas sin duplicar.
- Protección de datos manuales/personales: no se pisan estado, puntaje personal, notas ni playthroughs.

## Alcance del Entregable 6

- Covers/media local para juegos.
- Provider SteamGridDB para buscar portadas.
- Configuración local de API key SteamGridDB desde Ajustes.
- Guardado de API keys mediante secure storage del sistema.
- Selección manual de portada desde la ficha del juego.
- Carga manual desde archivo local.
- Descarga/copia controlada a la carpeta local de la app.
- Persistencia de media en `media_assets` con soft delete.
- Paths relativos y filenames por UUID/hash, sin usar títulos de juegos.
- Formatos aceptados: JPG/JPEG, PNG y WebP validados por firma de bytes.
- Visualización offline de portada guardada en la ficha.
- Miniaturas en lista mobile/cards y columna opcional de portada en tabla desktop.

## Alcance del Entregable 7

- Export JSON lógico completo de la biblioteca.
- Export CSV básico de biblioteca activa.
- Backups completos `.vaultbackup` como ZIP con:
  - `manifest.json`;
  - `data/library.json`;
  - `media/...`.
- Inclusión de `media_assets` y archivos media locales referenciados.
- Warnings si un archivo de media referenciado falta o no puede leerse.
- Validación de manifest, versión, checksums y rutas antes de restaurar.
- Restore completo con confirmación fuerte (`RESTAURAR`).
- Backup previo automático antes de restaurar.
- Restore conservador: upsert de filas del backup y soft-delete de filas actuales ausentes.
- Sin hard delete y sin borrar media actual durante restore.
- No exporta API keys ni secure storage.

## Alcance del Entregable 8A

- Backups cifrados opcionales `.vaultbackup.enc`.
- Restore de backups cifrados con password.
- Cifrado del ZIP completo del backup lógico existente.
- Formato cifrado versionado con header `BVE1`, PBKDF2-HMAC-SHA256 y AES-256-GCM.
- Backups normales `.vaultbackup` mantenidos por compatibilidad, pero siguen sin cifrar.
- Sección de privacidad en Ajustes con estado real:
  - DB local cifrada: no;
  - media local cifrada: no;
  - backups cifrados: disponible;
  - API keys externas: secure storage del sistema.
- Borrado centralizado de claves externas RAWG, IGDB y SteamGridDB.
- Redacción centralizada de API keys, bearer tokens, URLs sensibles y paths absolutos en mensajes visibles.

## Alcance del Entregable 11

- Provider IGDB como alternativa a RAWG para metadata de juegos.
- Configuración local de credenciales IGDB/Twitch desde Ajustes:
  - Client ID;
  - Client Secret.
- Guardado de credenciales y access token mediante secure storage del sistema.
- OAuth client credentials para obtener y cachear token con expiración.
- Selector de provider RAWG/IGDB en el diálogo de metadata.
- Búsqueda de candidatos IGDB y carga de detalle externo.
- Reutilización del preview/diff y aplicación selectiva existentes.
- Guardado de external IDs con `provider = igdb`.
- Redacción de `client_id`, `client_secret`, access tokens, refresh tokens, bearer tokens y headers sensibles.
- RAWG sigue disponible; IGDB no lo reemplaza ni lo elimina.

## Alcance del Entregable 12

- IGDB también puede usarse como fuente de portadas.
- El flujo de media permite elegir provider SteamGridDB o IGDB.
- Las portadas IGDB se descargan solo después de confirmación explícita.
- Las imágenes seleccionadas se guardan localmente mediante `media_assets`, con path relativo y sin usar títulos como filename.
- SteamGridDB sigue disponible; IGDB no lo reemplaza ni lo elimina.
- No hay bulk download automático de covers.

## Alcance del Entregable 13

- Importación masiva de metadata y covers desde la biblioteca.
- Botón "Importar metadata" en Biblioteca.
- Selector de provider RAWG/IGDB y alcance:
  - toda la biblioteca;
  - solo juegos sin metadata;
  - solo juegos sin portada;
  - solo juegos con campos incompletos.
- Scan con progreso y concurrencia limitada.
- Cálculo de confianza de matches.
- Solo los matches seguros quedan seleccionados por default.
- Matches probables o ambiguos requieren revisión explícita.
- Preview masivo antes de escribir en DB.
- Selección por juego, por campo y por cover.
- Aplicación confirmada con texto `APLICAR`.
- Metadata aplicada mediante el flujo existente de diff/apply.
- Covers faltantes guardados mediante `media_assets` y `MediaRepository`.
- No pisa estado, puntaje personal, notas, playthroughs, horas ni completados.
- No reemplaza covers existentes por default.
- Errores por juego no frenan todo el lote.
- No usa credenciales reales en tests ni fixtures.

## Fuera de alcance

- Notion API.
- Providers externos adicionales fuera de RAWG, IGDB y SteamGridDB.
- Galería visual completa.
- Bulk download automático de covers.
- Sync.
- SQLCipher.
- Cifrado de DB local.
- Cifrado de media local.
- Backup cloud.
- Scheduler automático de backups.
- Dashboard estadístico avanzado.
- Recomendador.
- Achievements/trophies.
- Session logs avanzados.

## Preparar el proyecto Flutter

Si las carpetas de plataforma todavía no existen, generarlas con:

```bash
flutter create --platforms=windows,android --project-name backlog_vault .
```

Luego instalar dependencias:

```bash
flutter pub get
```

Generar código de Drift:

```bash
dart run build_runner build
```

Nota: en versiones recientes de `build_runner`, `--delete-conflicting-outputs` puede estar ignorado o removido. Si tu instalación todavía lo soporta y hay conflictos de archivos generados, podés correr:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Correr en Windows

```bash
flutter run -d windows
```

## Empaquetar Windows portable

Generar build release y ZIP portable:

```powershell
.\tool\package_windows.ps1
```

El ZIP queda en `dist/` e incluye el contenido completo de `build/windows/x64/runner/Release`.

Notas de instalacion, actualizacion y portabilidad: [docs/install_and_portability.md](docs/install_and_portability.md).

## Preparar Android

Verificar entorno:

```bash
flutter doctor
```

Si `flutter doctor` informa pendientes de Android toolchain:

1. Instalar Android SDK Command-line Tools desde Android Studio / SDK Manager.
2. Aceptar licencias:

```bash
flutter doctor --android-licenses
```

3. Volver a correr:

```bash
flutter doctor
```

Correr en un dispositivo o emulador Android:

```bash
flutter run -d android
```

Generar APK local:

```bash
flutter build apk
```

El APK generado en E15 usa signing local/debug para instalacion personal. No es un paquete publicable en Play Store.

Checklist QA manual para Windows y Android: [docs/qa_v1_checklist.md](docs/qa_v1_checklist.md).

## Tests

```bash
flutter test
```

## Privacidad del SDK local

Para desactivar analytics de Flutter y Dart en la instalación local:

```bash
flutter --disable-analytics
dart --disable-analytics
```

## Metadata externa, media y API keys

La metadata externa y la búsqueda de portadas son opcionales. Sin API key de RAWG, credenciales IGDB/Twitch o API key de SteamGridDB, Backlog Vault sigue funcionando offline con la biblioteca local y las portadas ya guardadas.

Las API keys y credenciales se configuran desde Ajustes y se guardan localmente mediante `flutter_secure_storage`. No agregues claves reales, Client Secret, bearer tokens ni access tokens a README, tests, fixtures, logs, issues ni commits.

IGDB usa OAuth de Twitch con client credentials. El Client Secret y el access token se guardan en secure storage, no en SQLite, y no se incluyen en exports ni backups.

SteamGridDB e IGDB se usan solo cuando elegís buscar una portada. Backlog Vault no descarga portadas automáticamente para toda la biblioteca.

Las imágenes seleccionadas se copian a la carpeta de soporte de la app y la base SQLite guarda paths relativos. Los backups futuros deberán incluir tanto la DB como la carpeta `media/`.

Backlog Vault no referencia el path original del archivo que elegiste. Al cargar una portada local, la imagen se copia a la carpeta `media/` de la app y puede seguir funcionando aunque borres o muevas el archivo original. Las rutas absolutas o con `..` no se consideran válidas para resolver media local.

En Windows, el plugin `flutter_secure_storage_windows` está vendorizado en `third_party/` mediante `dependency_overrides` porque la versión compatible con `file_picker` requiere ATL (`atlstr.h`) en algunos toolchains. El parche local usa conversiones Win32 estándar para mantener `flutter build windows` funcionando.

## Backups y exportación

Desde Ajustes > Datos y backups podés:

- crear un backup completo `.vaultbackup`;
- crear un backup cifrado `.vaultbackup.enc`;
- restaurar un `.vaultbackup`;
- restaurar un `.vaultbackup.enc`;
- exportar JSON lógico;
- exportar CSV básico.

El formato `.vaultbackup` no está cifrado. Puede contener nombres de juegos, notas personales, estados, playthroughs, external IDs, rutas relativas de media y archivos de portadas. No incluye API keys de RAWG/SteamGridDB, credenciales IGDB/Twitch, access tokens ni valores de secure storage.

El formato `.vaultbackup.enc` cifra el backup completo con una password usando una librería criptográfica mantenida. La password no se guarda en la app: si la perdés, el archivo cifrado no se puede recuperar. El backup cifrado tampoco incluye API keys, credenciales IGDB/Twitch, access tokens ni secure storage.

La restauración es completa y conservadora: no hace merge avanzado ni resolución campo por campo. Antes de restaurar, la app crea automáticamente un backup previo. Los registros actuales que no existan en el backup se marcan con `deletedAt`; no se eliminan físicamente. Los archivos de media actuales no se borran durante restore.

En E8A la DB SQLite local y la carpeta `media/` siguen sin cifrado at-rest. Para mover o compartir datos sensibles, usá `.vaultbackup.enc`; para protección del dispositivo, usá también las protecciones del sistema operativo.

## Nota de setup actual

El código usa el flujo estándar de Drift con generación por `build_runner`. Si `lib/core/database/app_database.g.dart` no existe todavía, generarlo antes de compilar.

La dependencia `drift_flutter` quedó en `^0.3.0` para evitar el conflicto con `drift >=2.32.0`.
