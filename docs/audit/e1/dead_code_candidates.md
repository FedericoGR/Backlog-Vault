# Candidatos a código muerto u obsoleto

## Evidencia

`flutter analyze` reporta 0 issues y no detecta miembros privados sin uso. El grafo de imports muestra que todo archivo Dart productivo no generado tiene al menos un dependiente local, salvo `lib/main.dart`, que es el entrypoint. Por lo tanto, E1 no declara código “muerto” sólo por baja referencia.

## Obsoleto por definición de producto

| Grupo | Archivos | Estado actual | Decisión |
|---|---:|---|---|
| `lib/features/sync/` | 24 | activo y alcanzable | eliminar en E2 en orden controlado |
| `test/features/sync/` | 8 | cobertura activa | eliminar sólo junto al componente correspondiente |
| keys `sync*` en ARB | 153 por idioma | usadas por UI Sync | eliminar de fuentes ARB y regenerar l10n |
| `qr_flutter`, `mobile_scanner` | 2 deps | usadas | eliminar tras retirar UI/imports |
| permiso CAMERA | 1 manifest | usado por scanner | eliminar tras retirar scanner |
| bootstrap Sync | `main.dart` | ejecutado en cada inicio | simplificar |
| sección Sync settings | `settings_page.dart` | visible | retirar |
| seis tablas/ocho índices | schema 5 | persistencia real posible | migrar sólo con backup/tests |
| docs activas QR/Sync | 2 principales + release/QA | historia y guía activa mezcladas | conservar historia; actualizar superficie activa al cerrar E2 |

## Candidatos de revisión, no eliminación automática

- `third_party/flutter_secure_storage_windows`: vendorizado, pero metadata aún lo necesita.
- backup cifrado: comparte cryptography con Sync, pero cumple una necesidad independiente.
- `canonical_json.dart`: exclusivo de Sync hoy; no reutilizar por nombre en export sin demostrar una necesidad.
- `privacy_redactor.dart`: parece relacionado con seguridad/Sync, pero protege logs/paths generales y debe conservarse.
- media hashing/storage: usados por covers y backup; no confundir con LAN media transfer.
- file pickers: dos son Sync; los de CSV, backup y media continúan.
- `ExternalGameIds` y `MediaAssets`: metadata/covers, no Sync.

## Validación requerida antes de borrar

1. `rg` sin imports Sync fuera de docs/migration fixture.
2. Analyzer sin símbolos faltantes.
3. Tests funcionales iguales o superiores a 332 como piso, reemplazando tests Sync por tests de migración/ausencia.
4. APK sin CAMERA, scanner/Barhopper/modelos ML.
5. Windows sin cambios en DB/media/credentials externas.
6. Conteos y hashes de todas las tablas funcionales iguales antes/después de migración.

No se borró ningún candidato en E1.
