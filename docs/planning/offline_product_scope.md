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
| Exportación local | simplificar | decisión: JSON o JSON + CSV |
| Backup | decisión pendiente | recomendado mantener cifrado completo mientras madura export simple |
| Restore | decisión pendiente | recomendado mantener con preview/confirmación y migraciones |
| Metadata RAWG | mantener opcional | nunca requerida al arranque; funciona sin key mostrando indisponible |
| Metadata IGDB | mantener opcional | requiere client id/secret/token seguro |
| Covers SteamGridDB | mantener opcional | key segura; media queda local |
| Covers IGDB | mantener opcional | puede compartir auth core, no data internals metadata |
| Media local | mantener | filesystem + MediaAssets + backup |
| Estadísticas | mantener | consume biblioteca/playthroughs |
| Playthroughs | decisión pendiente | recomendación mantener entidad; posible UI simplificada |
| Sync | eliminar | código, datos auxiliares, docs activas |
| Pairing | eliminar | `.vaultpair`, groups/devices/keys |
| QR | eliminar | render/scanner, dependency y CAMERA |
| LAN | eliminar | sockets, challenge/proof, media transfer |
| Background sync | eliminar/no implementar | no existe hoy; remover roadmap/promesas |
| `.vaultsync` | eliminar | preservar sólo por Git/bundle |
| Secure storage | simplificar | sólo credenciales externas; borrar keys Sync selectivamente |
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
- Exportación guarda un archivo local elegido por el usuario; no implica transferencia entre dispositivos.

## Exportación vs backup

No confundir:

- export simple: datos legibles/portables para uso del usuario;
- backup/restore: snapshot completo, media, compatibilidad e integridad;
- Sync: intercambio incremental/conflictos, eliminado.

Opciones abiertas:

1. JSON: fiel a estructura completa y más fácil de restaurar.
2. JSON + CSV: JSON completo y CSV humano/tabular de entradas activas.
3. Backup cifrado: mantener como herramienta avanzada separada o simplificar después de estabilizar Offline.

## Fuera de alcance inmediato

Cloud, cuentas, cross-device, QR, LAN, background jobs, collaboration y nuevos providers. Tampoco se rediseña UX completa en E2.
