# Plan revisado de entregables Offline

## E1 — Auditoría/preservación/arquitectura

Estado: completado documentalmente en `codex/offline-e1-audit`. Incluye bundle externo, baseline, builds, inventario, arquitectura/ADR, scope y planes. Gate: aprobación de Federico; no merge automático.

## E2 — Retiro controlado de Sync

Objetivo: desacoplar mutaciones, retirar UI/protocolos/QR/LAN, dependencias/permisos/l10n, migrar schema y limpiar secure storage selectivo. Sin gran reorganización. Gate: datos, tests y builds Windows/Android.

## E3 — Refactor arquitectónico incremental

1. Library ViewModel y división table/gallery/filters/views.
2. Games + Playthrough repository/use cases y screens.
3. Import/export/backup workflows.
4. Metadata/media boundaries y credentials core.
5. Statistics/settings.
6. Romper ciclos l10n/features y eliminar leaks Drift/filesystem.

Cada slice mantiene comportamiento y tests; movimientos y cambios conductuales separados cuando sea práctico.

## E4 — Dependencias, peso y repo hygiene

- updates pequeños de Drift/Riverpod/path/file_picker/uuid;
- resolver KGP;
- split ABI/packaging;
- limpiar outputs/dist con política externa;
- GC local aprobado, sin rewrite;
- medir APK/Windows/repo.

## E5 — QA y Offline Release

- pruebas integration Windows/Android;
- migración con datasets y backup/restore;
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

- Antes de E2: baseline, ADR, export/backup y Playthrough no destructivo.
- Antes de E3: naming/estructura y orden de slices.
- Antes de E4: canal Android/ABI y política de artefactos/GC.
- Antes de E5: providers finales, versión y checklist de release.

No iniciar E2 hasta recibir aprobación explícita de las decisiones abiertas de E1.
