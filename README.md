# Backlog Vault

Backlog Vault es una app personal local-first para gestionar un backlog de videojuegos. Este repositorio contiene el Entregable 1: base offline funcional con Flutter, Drift, Riverpod y go_router.

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

## Fuera de alcance

- Notion API.
- Providers externos adicionales como IGDB o Steam.
- Galería visual completa.
- Bulk download automático de covers.
- Sync.
- SQLCipher.
- Backup/export.
- Estadísticas.
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

La metadata externa y la búsqueda de portadas son opcionales. Sin API key de RAWG o SteamGridDB, Backlog Vault sigue funcionando offline con la biblioteca local y las portadas ya guardadas.

Las API keys se configuran desde Ajustes y se guardan localmente mediante `flutter_secure_storage`. No agregues claves reales a README, tests, fixtures, logs, issues ni commits.

SteamGridDB se usa solo cuando elegís buscar una portada. Backlog Vault no descarga portadas automáticamente para toda la biblioteca.

Las imágenes seleccionadas se copian a la carpeta de soporte de la app y la base SQLite guarda paths relativos. Los backups futuros deberán incluir tanto la DB como la carpeta `media/`.

Backlog Vault no referencia el path original del archivo que elegiste. Al cargar una portada local, la imagen se copia a la carpeta `media/` de la app y puede seguir funcionando aunque borres o muevas el archivo original. Las rutas absolutas o con `..` no se consideran válidas para resolver media local.

En Windows, el plugin `flutter_secure_storage_windows` está vendorizado en `third_party/` mediante `dependency_overrides` porque la versión compatible con `file_picker` requiere ATL (`atlstr.h`) en algunos toolchains. El parche local usa conversiones Win32 estándar para mantener `flutter build windows` funcionando.

## Nota de setup actual

El código usa el flujo estándar de Drift con generación por `build_runner`. Si `lib/core/database/app_database.g.dart` no existe todavía, generarlo antes de compilar.

La dependencia `drift_flutter` quedó en `^0.3.0` para evitar el conflicto con `drift >=2.32.0`.
