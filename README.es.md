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
- Backups normales `.vaultbackup` y cifrados `.vaultbackup.enc`.
- Restore conservador con backup previo automático.
- Home y estadísticas de biblioteca.
- Tema claro/oscuro con diseño OLED-friendly.
- Español e inglés con selector por dispositivo.

## Privacidad offline

- No hay login ni backend de Backlog Vault.
- SQLite y la media quedan en cada dispositivo.
- La DB y la media local **todavía no están cifradas at rest**.
- Los backups cifrados están disponibles cuando el archivo sale del dispositivo.
- Las credenciales de providers se guardan en el secure storage del sistema.
- Claves RAWG, credenciales y tokens IGDB/Twitch, y claves SteamGridDB no se incluyen en backups ni exports.
- La aplicación no abre sockets, empareja dispositivos, escanea QR ni intercambia datos con otra instalación de Backlog Vault.
- Metadata y covers externos sólo consultan Internet cuando el usuario invoca explícitamente esas capacidades opcionales.

## Instalación

### Windows ZIP

Extraé el ZIP completo y ejecutá `backlog_vault.exe`. La carpeta portable de la app no es la carpeta de datos. Antes de actualizar binarios o mover el uso a otra PC, creá un backup cifrado.

### Android APK

Instalá el APK local aceptando el permiso de origen cuando Android lo solicite. Los APK actuales usan firma local para uso personal y QA; no son paquetes de Play Store. Un APK firmado con otra clave puede obligar a desinstalar, lo que puede borrar datos locales: hacé un backup cifrado antes.

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

## Backups y portabilidad

- `.vaultbackup` incluye biblioteca lógica y media, pero no está cifrado.
- `.vaultbackup.enc` cifra el backup completo con una password elegida por el usuario.
- Las passwords de backup no se guardan; si se pierde una, el backup cifrado no se puede recuperar.
- El restore es completo y conservador: lo ausente se marca con borrado lógico, sin hard delete.
- Las credenciales externas y el secure storage no viajan en backups.

Usá `.vaultbackup.enc` para migración completa, recuperación o copia con media. Mové el backup mediante un canal bajo tu control y configurá por separado las credenciales opcionales en el dispositivo de destino.

## Idioma

La app detecta el idioma del sistema por default. En **Ajustes → Idioma** podés elegir Sistema, Español o English. La preferencia se guarda por dispositivo y no entra en SQLite ni en backups.

## Dirección Offline

Backlog Vault es intencionalmente offline y de un solo dispositivo. La portabilidad se resuelve mediante exportación/backup local explícito y restore conservador, no mediante protocolos de sincronización. La implementación histórica permanece preservada en Git y en el bundle externo previo al refactor.

## Screenshots

La sección queda preparada. Se agregarán capturas reales de Windows y Android usando una biblioteca descartable y sin credenciales.

## Documentación

- [Instalación y portabilidad](docs/install_and_portability.md)
- [Checklist QA v0.2](docs/qa_v0_2_checklist.md)
- [Notas v0.2](docs/release_notes_v0_2.md)
- [Checklist QA v0.3](docs/qa_v0_3_checklist.md)
- [Notas v0.3](docs/release_notes_v0_3.md)
- [Migración Offline schema 5→6](docs/migrations/offline_schema_5_to_6.md)
- [Reporte de finalización E2](docs/planning/e2_completion_report.md)

## Licencia

Todavía no se seleccionó una licencia. Hasta agregarla, el repositorio no se ofrece bajo una licencia open source.
