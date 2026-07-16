# Auditoría del modelo de dominio

## Estado actual

Los tipos `Game`, `LibraryEntry`, `Playthrough`, etc. son data classes generadas por Drift y atraviesan data/application/presentation. No existe una frontera completa de modelos de dominio independiente. Sí hay value objects/modelos manuales para status, rating, filtros, filas de biblioteca, formularios, metadata y media.

## Separación conceptual

| Concepto | Campos/responsabilidad actuales | Pertenece a | Recomendación |
|---|---|---|---|
| `Game` | title, sortTitle, releaseDate, type | obra/catalogación | mantener; metadata externa actualiza la obra |
| `LibraryEntry` | gameId, status, personalRating, personalNotes | relación usuario–obra | mantener separado |
| `Playthrough` | entry, platform, status, fechas, horas, rating, notas | partida/intento histórico | mantener separado |
| Platform | nombre/shortName; relación primaria y partida | catálogo + contexto usuario | mantener entidad/catálogo |
| Genre | nombre y join con Game | obra | mantener |
| SavedView | filtros/sort/columnas JSON | preferencia local UI | mantener; versionar JSON si evoluciona |
| ExternalGameId | provider IDs/URLs/title | metadata aplicada a obra | mantener |
| MediaAsset | origen, provider, path, hash, selected, atribución | media de obra | mantener |

## Campos calculados

`LibraryGameRow` agrega título, plataformas, genres, selected cover, release date, completion date, horas sumadas, rating/notas del entry y type. `GameProgressSummary` calcula partida activa, total de horas y completions. Las estadísticas vuelven a agregar playthroughs.

Estos son read models/calculados; no deben persistirse sin una razón de performance medida. Effective Dart recomienda no almacenar lo que puede calcularse para evitar fuentes de verdad divergentes.

## Duplicaciones/ambigüedades

- `LibraryEntry.personalRating` y `Playthrough.rating`: pueden representar valoración global vs valoración de una partida, pero la UI/complete flow puede copiarlas. Debe documentarse un source of truth.
- `LibraryEntry.status` y `Playthrough.status`: uno representa backlog/progreso global, otro estado del intento. Ambos son válidos si la transición se coordina en un use case.
- Notas existen en entry y playthrough: preferencias generales vs diario de intento; mantener, con labels claros.
- Platform aparece como selección del entry y opcional en playthrough: correcto para biblioteca multiplataforma, pero validar que `isPrimary` sea único a nivel aplicación.
- Tipos Drift generados se usan como dominio; acopla UI a schema y hace más riesgosa una migración.

## Opciones para Playthrough

### A — Mantener entidad completa (recomendada)

Conserva múltiples intentos, horas, historial, estadísticas y plataforma por partida. Extraer `PlaythroughRepository` y un use case `CompletePlaythrough` que coordine status/rating global. Riesgo de migración mínimo.

### B — Mantener datos, simplificar UI

Oculta complejidad de múltiples intentos para usuarios que no la necesiten, pero preserva tabla/API. Es reversible y puede decidirse después de E2.

### C — Fusionar en LibraryEntry

Reduce conceptos visibles, pero pierde historial/múltiples plataformas, exige migración destructiva y complica stats. No recomendado sin evidencia de uso y decisión explícita.

## Frontera objetivo

- Definir modelos de dominio estables para aggregates que salen de repositorios: Game, LibraryEntry, Playthrough y LibraryGameDetails/Row.
- Renombrar eventualmente data classes Drift (`GameRow`, etc.) o mantenerlas encerradas en `data/`.
- No crear DTO + entity + mapper para cada join/tabla. Los joins y companions pueden permanecer internos a data.
- Requests de formulario/import y read models específicos pueden vivir en application/domain si expresan reglas, no por simetría.
- Interfaces de provider metadata/media tienen valor real porque ya existen varias implementaciones; conservarlas.
- `LibraryGameDetails`, hoy en `games/application` y basado en Drift, debe moverse a `games/domain` tras desacoplar tipos persistentes.

## Reglas y pruebas

1. Game no contiene estado/nota/rating personal.
2. LibraryEntry no contiene detalles externos/media del catálogo.
3. Playthrough no se elimina ni fusiona durante E2.
4. Un use case coordina completar/pausar/reanudar y mantiene invariantes entre entry/playthrough.
5. Tests de transición, múltiples partidas, suma de horas, rating y soft delete preceden el refactor.
6. Tests de import/backup aseguran que los campos históricos sobreviven.

Recomendación pendiente de aprobación: opción A, con posibilidad de simplificar presentación más adelante.
