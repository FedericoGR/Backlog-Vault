# Plan revisado de entregables Offline

## E1 — Auditoría/preservación/arquitectura

Estado: completado documentalmente en `codex/offline-e1-audit`. Incluye bundle externo, baseline, builds, inventario, arquitectura/ADR, scope y planes. Gate: aprobación de Federico; no merge automático.

## E2 — Retiro controlado de Sync

Estado: implementado en `codex/offline-e2-remove-sync`. Los repositorios usan
transacciones Drift locales, se retiraron UI/protocolos/QR/LAN y sus
dependencias, el schema 5 migra a 6 y secure storage se limpia mediante una
allowlist estricta. No se realizó la reorganización arquitectónica de E3.

Gate: tests y builds reproducibles completos; el smoke/migración en un Android
real permanece como validación manual previa al merge cuando exista un
dispositivo con recuperación segura de datos.

## E3 — Simplificación funcional Offline

1. Reemplazar backup/restore por un único export JSON versionado.
2. Mantener importación CSV separada.
3. Retirar ZIP, cifrado, passwords, restore y packaging de media.
4. Documentar dominio y revisar providers sin eliminarlos.

No ejecutar todavía el refactor general hacia MVVM.

## E4 — Refactor arquitectónico incremental

- Library ViewModel y división table/gallery/filters/views.
- Games + Playthrough repository/use cases y screens.
- Import/export, metadata/media, statistics/settings por slices.
- Romper ciclos y eliminar leaks Drift/filesystem antes de optimización profunda.

## E5 — QA y Offline Release

- pruebas integration Windows/Android;
- migración con datasets y validación del export JSON;
- offline/no credentials/no Internet;
- accesibilidad/l10n/theme/layout;
- packaging/checksums/release notes;
- versión aprobada y PR final a main.

## Gates de producto

| Gate | Condición |
|---|---|
| Datos | ninguna pérdida en 10 tablas/media; rollback documentado |
| Offline | cold start y core completo sin red/keys |
| Arquitectura | reglas ADR verificadas sin sobrearquitectura |
| Calidad | analyzer limpio; tests unit/widget/integration críticos |
| Plataformas | build y smoke Windows/Android |
| Peso | medición comparable y causas documentadas |
| Release | scope/versión aprobados; no Sync activo |

## Decisiones antes de cada etapa

- Antes de E2: baseline, ADR y Playthrough no destructivo.
- Antes de E3: contrato JSON y retiro de backup/restore.
- Antes de E4: naming/estructura y orden de slices.
- Antes de E5: providers finales, versión y checklist de release.

E2 se inició después de la aprobación explícita de las decisiones de E1. No
iniciar E3 hasta revisar el reporte de cierre de E2 y acordar el primer slice.
