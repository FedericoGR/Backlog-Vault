# Backlog Vault

Backlog Vault es un gestor offline-first de backlog de videojuegos para Windows y Android. La biblioteca, notas personales, partidas, metadata y portadas quedan en tus dispositivos. No requiere cuenta, backend ni cloud.

> Documentación principal en inglés: [README.md](README.md)

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
- Paquetes de cambios `.vaultsync` cifrados con password, preview, deduplicación y manejo conservador de conflictos.
- Invitaciones `.vaultpair` cifradas con password para pairing manual y paquetes `.vaultsync` con clave de grupo reutilizable.
- Sync manual por red local para dispositivos emparejados con sesión temporal host/cliente.
- Restore conservador con backup previo automático.
- Home y estadísticas de biblioteca.
- Tema claro/oscuro con diseño OLED-friendly.
- Español e inglés con selector por dispositivo.

## Privacidad local-first

- No hay login ni backend de Backlog Vault.
- SQLite y la media quedan en cada dispositivo.
- La DB y la media local **todavía no están cifradas at rest**.
- Los backups cifrados están disponibles cuando el archivo sale del dispositivo.
- Las credenciales de providers se guardan en el secure storage del sistema.
- Claves RAWG, credenciales y tokens IGDB/Twitch, y claves SteamGridDB no se incluyen en backups ni exports.
- Ya existen paquetes manuales cifrados y sync por red local para dispositivos emparejados.
- El pairing manual habilita paquetes con clave de grupo y sesiones LAN manuales; no habilita sync automático, background, cloud, QR, discovery ni transferencia de media.
- La clave aleatoria de grupo de 256 bits vive únicamente en el secure storage del sistema de cada dispositivo emparejado y no entra en backups.

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
.\tool\package_windows.ps1 -SkipBuild
```

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
- `.vaultsync` es un paquete cifrado separado que transporta cambios; no es un backup completo ni incluye por sí mismo los bytes de la media.
- `.vaultpair` es una invitación temporal cifrada con password que transporta la clave de grupo para emparejar otro dispositivo; no contiene biblioteca, media ni credenciales de providers.
- Las passwords no se guardan; si se pierde una, su backup cifrado o paquete `.vaultsync` no se puede recuperar.
- El restore es completo y conservador: lo ausente se marca con borrado lógico, sin hard delete.
- Las credenciales externas y el secure storage no viajan en backups.

Usá `.vaultbackup.enc` para migración completa, recuperación o copia con media. Usá `.vaultpair` para establecer una clave de grupo compartida y después archivos `.vaultsync` o **Ajustes → Sync → Sync por red local** para intercambiar cambios sin escribir una password cada vez. El modo `.vaultsync` con password sigue disponible. Las invitaciones vencen después de 24 horas; compartí el archivo y la password temporal por canales confiables separados. El sync LAN requiere que ambos dispositivos estén en la misma red local y usar IP, puerto y código de sesión del host. Los conflictos se omiten de forma segura. El sync LAN también transfiere portadas gestionadas por la app usando SHA-256 cuando el emisor tiene el archivo y el receptor puede verificar sus bytes. Las credenciales se configuran por separado.

## Idioma

La app detecta el idioma del sistema por default. En **Ajustes → Idioma** podés elegir Sistema, Español o English. La preferencia se guarda por dispositivo y no entra en SQLite ni en backups.

## Roadmap de sync

Los paquetes manuales con password, los paquetes con clave de grupo emparejado, las sesiones LAN emparejadas y la transferencia LAN de portadas por hash están implementados. No requieren cuenta, backend ni cloud. El sync LAN manual requiere que ambos dispositivos estén en la misma red local:

- v0.1.x: estabilización, UI bilingüe y hardening de backup/restore.
- Foundation v0.2: change tracking determinista y paquetes manuales cifrados PC ↔ Android.
- Pairing manual `.vaultpair` con clave en secure storage; QR queda para una etapa posterior.
- Transporte LAN manual para dispositivos emparejados usando IP, puerto y código corto de sesión.
- Media por hash sobre LAN sin referencias rotas.
- QR, discovery automático, background sync y UI avanzada de resolución de conflictos quedan para etapas posteriores.
- Sin dependencia cloud al principio; cloud E2EE opcional mucho más adelante.

Ver [docs/sync_roadmap.md](docs/sync_roadmap.md).

## Screenshots

La sección queda preparada. Se agregarán capturas reales de Windows y Android usando una biblioteca descartable y sin credenciales.

## Documentación

- [Instalación y portabilidad](docs/install_and_portability.md)
- [Checklist QA v1](docs/qa_v1_checklist.md)
- [Notas de RC3](docs/release_notes_v1.md)
- [Roadmap técnico de sync](docs/sync_roadmap.md)

## Licencia

Todavía no se seleccionó una licencia. Hasta agregarla, el repositorio no se ofrece bajo una licencia open source.
