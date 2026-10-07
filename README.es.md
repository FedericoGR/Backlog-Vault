# Backlog Vault

Backlog Vault es un registro personal de videojuegos offline para Windows y Android. Permite recorrer los juegos por año y guardar un único registro personal con estado de finalización, horas, plataforma, puntaje y notas. La biblioteca y las portadas locales quedan en el dispositivo; no requiere cuenta, backend, cloud ni sincronización entre dispositivos.

> Documentación principal en inglés: [README.md](README.md)

Release candidate actual: `v1.0.0-rc2` (`1.0.0-rc2+7`). Consolida
Backlog Vault como producto intencionalmente Offline.

## Funcionalidades

- Galería anual de portadas con navegación por año, búsqueda y filtros simples por finalización, plataforma jugada y puntaje.
- Un registro personal por juego: estado, año jugado, fecha opcional de finalización, horas, plataforma jugada, puntaje y notas.
- Detalles y estadísticas anuales de tu historial personal de juegos.
- Creación y edición manual, con la información del catálogo separada del registro personal.
- Importación de CSV de Notion con mapping, preview, detección de duplicados y validaciones.
- Metadata opcional desde RAWG e IGDB.
- Portadas opcionales desde IGDB y SteamGridDB, además de archivos locales.
- Importación masiva de metadata y covers con preview y reemplazos explícitos.
- Media local almacenada con paths relativos.
- Exportación JSON portable y legible de los datos de biblioteca, incluidos los registros heredados compatibles.
- Tema claro/oscuro con diseño OLED-friendly.
- Español e inglés con selector por dispositivo.

## Privacidad offline

- No hay login ni backend de Backlog Vault.
- SQLite y la media quedan en cada dispositivo.
- La DB y la media local **no están cifradas at rest**.
- En Windows, las credenciales de providers se cifran con el usuario actual y
  se guardan dentro de `userdata`.
- Claves RAWG, credenciales y tokens IGDB/Twitch, y claves SteamGridDB no se incluyen en la exportación.
- El JSON contiene información de biblioteca, pero no bytes de imágenes, paths locales, credenciales ni restore automático.
- La aplicación no abre sockets, empareja dispositivos, escanea QR ni intercambia datos con otra instalación de Backlog Vault.
- Metadata y covers externos sólo consultan Internet cuando el usuario invoca explícitamente esas capacidades opcionales.

## Instalación

### Windows ZIP portable

Extraé el ZIP completo y ejecutá `backlog_vault.exe`. La base SQLite, portadas,
preferencias y credenciales quedan dentro de `userdata`, junto a la aplicación.
Para moverla o respaldarla, cerrá Backlog Vault y copiá la carpeta completa.

### Android APK

Instalá el APK en un dispositivo compatible. El RC actual usa firma debug para
uso personal y QA; no es un paquete de Play Store. Actualizá la app in-place
con el mismo package y una firma compatible. No desinstales una instalación con
datos importantes: el uninstall puede borrar AppData y el JSON no es un formato
de restore automático.

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

Para ejecutar el build limpio y los helpers reproducibles de packaging:

```powershell
.\tool\build_release.ps1
.\tool\package_windows.ps1 -SkipBuild
.\tool\package_android.ps1 -Mode Arm64AndUniversal
.\tool\verify_release_candidate.ps1
.\tool\check_repository_hygiene.ps1
```

El ZIP Windows usa una allowlist de runtime y es determinista para el mismo
build. Android nombra y calcula checksums de APK universal y por ABI; nunca los
instala. Consultá la
[guía de build y packaging](docs/build/release_build_and_packaging.md).

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

Backlog Vault funciona offline. En Windows, el almacenamiento portable mantiene la base, la media, las preferencias y las credenciales cifradas junto a la aplicación. La exportación JSON sirve para conservar y procesar los datos; no restaura la aplicación automáticamente ni incluye los bytes de las imágenes locales.

## Screenshots

La sección queda preparada. Se agregarán capturas reales de Windows y Android usando una biblioteca descartable y sin credenciales.

## Documentación

- [Instalación y portabilidad](docs/install_and_portability.md)
- [Formato de exportación de biblioteca v1](docs/export/library_export_format_v1.md)
- [Flujos Offline](docs/product/offline_workflows.md)
- [Notas v1.0.0-rc2](docs/release/release_notes_v1_0_0_rc2.md)
- [Checklist QA v1.0.0-rc1](docs/release/qa_checklist_v1_0_0_rc1.md)
- [Checklist QA v0.2](docs/qa_v0_2_checklist.md)
- [Notas v0.2](docs/release_notes_v0_2.md)
- [Checklist QA v0.3](docs/qa_v0_3_checklist.md)
- [Notas v0.3](docs/release_notes_v0_3.md)
- [Migración Offline schema 5→6](docs/migrations/offline_schema_5_to_6.md)
- [Reporte de finalización E2](docs/planning/e2_completion_report.md)
- [Build y packaging de release](docs/build/release_build_and_packaging.md)
- [Resultados de tamaño y limpieza E6](docs/audit/e6/size_and_cleanup_results.md)

## Licencia

Todavía no se seleccionó una licencia. Hasta agregarla, el repositorio no se ofrece bajo una licencia open source.
