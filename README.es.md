# Backlog Vault

Backlog Vault es un gestor offline de backlog de videojuegos para Windows y Android. La biblioteca, notas personales, partidas, metadata y portadas quedan en el dispositivo. No requiere cuenta, backend, cloud, pairing ni sincronización entre dispositivos.

> Documentación principal en inglés: [README.md](README.md)

Release candidate histórico: `v0.3.0-rc1` (`0.3.0+5`). La rama activa retira su sincronización histórica sin cambiar todavía la versión.

## Funcionalidades

- Biblioteca responsive en tabla, galería y lista.
- Búsqueda, filtros avanzados, orden, columnas configurables y vistas guardadas.
- Creación y edición manual con borrado lógico.
- Importación de CSV de Notion con mapping, preview, detección de duplicados y validaciones.
- Metadata opcional desde RAWG e IGDB.
- Portadas opcionales desde IGDB y SteamGridDB, además de archivos locales.
- Importación masiva de metadata y covers con preview y reemplazos explícitos.
- Media local almacenada con paths relativos.
- Exportación JSON portable y legible de todos los datos de la biblioteca.
- Home y estadísticas de biblioteca.
- Tema claro/oscuro con diseño OLED-friendly.
- Español e inglés con selector por dispositivo.

## Privacidad offline

- No hay login ni backend de Backlog Vault.
- SQLite y la media quedan en cada dispositivo.
- La DB y la media local **no están cifradas at rest**.
- Las credenciales de providers se guardan en el secure storage del sistema.
- Claves RAWG, credenciales y tokens IGDB/Twitch, y claves SteamGridDB no se incluyen en la exportación.
- El JSON contiene información de biblioteca, pero no bytes de imágenes, paths locales, credenciales ni restore automático.
- La aplicación no abre sockets, empareja dispositivos, escanea QR ni intercambia datos con otra instalación de Backlog Vault.
- Metadata y covers externos sólo consultan Internet cuando el usuario invoca explícitamente esas capacidades opcionales.

## Instalación

### Windows ZIP

Extraé el ZIP completo y ejecutá `backlog_vault.exe`. La carpeta portable de la app no es la carpeta de datos administrada por el sistema; no borres esa carpeta al reemplazar binarios.

### Android APK

Instalá el APK local aceptando el permiso de origen cuando Android lo solicite. Los APK actuales usan firma local para uso personal y QA; no son paquetes de Play Store. Actualizá sólo in-place con el mismo package y una firma compatible. No desinstales una instalación con datos importantes: el uninstall puede borrar AppData y el JSON no es un formato de restore automático.

## Compilar desde source

Toolchain esperado: Flutter 3.44.1 stable y Dart 3.12.1.

```powershell
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter build windows
flutter build apk
```

Para generar el ZIP portable local:

```powershell
.\tool\package_windows.ps1 -SkipBuild -ReleaseLabel v0.2.0
```

Los artefactos históricos pueden usar `-ReleaseLabel v0.3.0-rc1`; E2 no crea un release ni cambia la versión.

`build/`, `dist/`, APKs, ZIPs y cachés no se versionan.

## Configurar metadata y covers

Los providers son opcionales; la app sigue funcionando offline sin credenciales.

- **RAWG:** guardá una API key de RAWG en Ajustes.
- **IGDB:** creá una aplicación de Twitch y guardá Client ID + Client Secret. El access token se renueva localmente.
- **SteamGridDB:** guardá una API key de SteamGridDB en Ajustes.

Nunca commitees claves, client secrets, bearer/access tokens, archivos `.secure` ni keystores reales. Tampoco los uses en tests, fixtures, logs, documentación, issues o screenshots.

## Exportación de biblioteca y portabilidad

- **Ajustes → Datos de la biblioteca → Exportar biblioteca** genera un único JSON UTF-8 con formato legible.
- Incluye juegos, entradas personales, playthroughs, catálogos, relaciones, vistas guardadas, referencias de metadata y registros descriptivos de media.
- Excluye credenciales, secure storage, paths locales, bytes de imágenes, bases, cachés y datos históricos de Sync.
- Las imágenes locales no se incluyen dentro del archivo.
- Backlog Vault no importa ni restaura este JSON durante el ciclo Offline actual.

La exportación sirve para conservar, consultar o procesar tus datos. No es un backup completo del dispositivo y no promete recuperar imágenes ni migrar automáticamente otra instalación. Consultá la [especificación del formato](docs/export/library_export_format_v1.md).

## Idioma

La app detecta el idioma del sistema por default. En **Ajustes → Idioma** podés elegir Sistema, Español o English. La preferencia se guarda por dispositivo y no entra en SQLite ni en el JSON exportado.

## Dirección Offline

Backlog Vault es intencionalmente offline y de un solo dispositivo. Portabilidad significa un JSON explícito y legible, no sincronización, restore, packaging de media ni recuperación del dispositivo. Las implementaciones históricas de Sync y backup/restore permanecen sólo en Git y en el bundle externo previo al refactor.

## Screenshots

La sección queda preparada. Se agregarán capturas reales de Windows y Android usando una biblioteca descartable y sin credenciales.

## Documentación

- [Instalación y portabilidad](docs/install_and_portability.md)
- [Formato de exportación de biblioteca v1](docs/export/library_export_format_v1.md)
- [Checklist QA v0.2](docs/qa_v0_2_checklist.md)
- [Notas v0.2](docs/release_notes_v0_2.md)
- [Checklist QA v0.3](docs/qa_v0_3_checklist.md)
- [Notas v0.3](docs/release_notes_v0_3.md)
- [Migración Offline schema 5→6](docs/migrations/offline_schema_5_to_6.md)
- [Reporte de finalización E2](docs/planning/e2_completion_report.md)

## Licencia

Todavía no se seleccionó una licencia. Hasta agregarla, el repositorio no se ofrece bajo una licencia open source.
