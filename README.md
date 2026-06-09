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

## Fuera de alcance

- Notion API.
- Metadata automática.
- Providers externos como RAWG, IGDB, SteamGridDB o Steam.
- Covers descargados o cache de imágenes externas.
- Sync.
- SQLCipher.
- Backup/export.
- Tabla avanzada tipo Notion.
- Estadísticas.
- Recomendador.

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

## Nota de setup actual

El código usa el flujo estándar de Drift con generación por `build_runner`. Si `lib/core/database/app_database.g.dart` no existe todavía, generarlo antes de compilar.

La dependencia `drift_flutter` quedó en `^0.3.0` para evitar el conflicto con `drift >=2.32.0`.
