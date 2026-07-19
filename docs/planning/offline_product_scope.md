# Alcance funcional propuesto Offline

Principio: la aplicación debe poder instalarse, iniciar y ofrecer toda la biblioteca personal sin credenciales ni Internet. Metadata/covers remotos son mejoras explícitamente opcionales.

| Capacidad | Decisión propuesta | Notas/condición |
|---|---|---|
| Biblioteca local | mantener | núcleo del producto |
| Tabla | mantener | filtros/sort/columnas |
| Galería | mantener | covers locales/remotos cacheados |
| Filtros | mantener | offline |
| Vistas guardadas | mantener | preservar JSON/datos |
| Alta/edición | mantener | Game + LibraryEntry + playthroughs |
| Soft delete | mantener | protege recuperación/scope; revisar purga aparte |
| Importación CSV | mantener | Notion actual; naming puede generalizarse luego |
| Exportación local | mantener | único JSON completo, legible y versionado; CSV import sigue separado |
| Backup | retirado en E3 | no ZIP, cifrado, passwords ni packaging de media |
| Restore | retirado en E3 | no restore/import JSON, merge o recuperación automática |
| Metadata RAWG | mantener opcional | nunca requerida al arranque; funciona sin key mostrando indisponible |
| Metadata IGDB | mantener opcional | requiere client id/secret/token seguro |
| Covers SteamGridDB | mantener opcional | key segura; media queda local |
| Covers IGDB | mantener opcional | puede compartir auth core, no data internals metadata |
| Media local | mantener | filesystem + MediaAssets; exporta descripción, no bytes ni paths |
| Estadísticas | mantener | consume biblioteca/playthroughs |
| Playthroughs | mantener | entidad separada de Game y LibraryEntry |
| Sync | eliminado en E2 | preservado sólo en Git, bundle y auditoría histórica |
| Pairing | eliminado en E2 | `.vaultpair`, groups/devices/keys retirados |
| QR | eliminado en E2 | render/scanner, dependencias y CAMERA retirados |
| LAN | eliminado en E2 | sockets, challenge/proof y media transfer retirados |
| Background sync | eliminar/no implementar | no existe hoy; remover roadmap/promesas |
| `.vaultsync` | eliminar | preservar sólo por Git/bundle |
| Secure storage | mantener selectivo | sólo credenciales externas; E2 limpia allowlist heredada de Sync |
| Español/inglés | mantener | regenerar l10n sin 153 keys Sync |
| Tema claro/OLED | mantener | system theme actual |
| Windows | mantener | release portable y datos fuera del binario |
| Android | mantener | retirar CAMERA; INTERNET sólo metadata/media opcional |

## Definición de “completamente Offline”

- Ninguna cuenta, login, device identity ni group key.
- Ningún server/socket/discovery/protocolo de sincronización.
- Ninguna operación de red automática durante bootstrap o uso de biblioteca.
- Sin API keys: biblioteca/import/export/media local/stats/settings siguen completos.
- Sin Internet: metadata/covers muestran estado opcional y no degradan datos existentes.
- Exportación guarda un JSON local elegido por el usuario; no implica restore,
  packaging de imágenes ni transferencia entre dispositivos.

## Exportación e importación

No confundir:

- export JSON: snapshot de información legible/portable para el usuario;
- import CSV: alta de juegos mediante el flujo existente, no restore;
- backup/restore: retirado del producto activo;
- Sync: intercambio incremental/conflictos, eliminado en E2.

El JSON no incluye credenciales, paths locales, bytes de imágenes, DB, caches o
datos de Sync. No existe importación ni restore del formato durante este ciclo.

## Fuera de alcance inmediato

Cloud, cuentas, cross-device, QR, LAN, background jobs, collaboration y nuevos providers. Tampoco se rediseña UX completa en E2.
