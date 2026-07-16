# Política de archivos, código y comentarios

## Tamaño como señal

- Revisar archivos >300 líneas.
- Revisar widgets/screens >200–300 líneas.
- Revisar métodos >40–60 líneas.
- Revisar clases con muchas responsabilidades/métodos y archivos con varias clases públicas no relacionadas.

No dividir por número solamente. Un schema/ARB/generado puede ser largo; una clase corta puede mezclar responsabilidades.

## Cohesión

- Un archivo tiene una responsabilidad principal y su nombre la comunica.
- Widgets privados pequeños pueden convivir con su screen; moverlos cuando se reutilizan o el archivo pierde legibilidad.
- Modelos relacionados pueden convivir; evitar archivos “models.dart” gigantes sin aggregate claro.
- `manager`, `helper`, `service` o `utils` requieren una responsabilidad/fuente explícita.

## Comentarios

Usar:

- `///` para APIs públicas importantes;
- decisiones no obvias, invariantes y pre/postcondiciones;
- migraciones y compatibilidad de formatos/schema;
- workarounds de plataforma con link/condición de retiro;
- seguridad, redacción, paths confiables y por qué una decisión existe.

No usar:

- comentarios que repiten el código;
- comentarios en getters/setters triviales;
- bloques narrativos gigantes dentro de implementación;
- código comentado en lugar de Git;
- comentarios de Sync obsoletos después de E2;
- TODO sin owner/entregable/criterio.

Seguir [Effective Dart Documentation](https://dart.dev/effective-dart/documentation): resumen inicial breve, doc comments con `///`, referencias en corchetes y poca ornamentación.

## Interfaces

Crear cuando hay dos implementaciones, sustitución prevista real, boundary de infraestructura o fake que reduce costo. MetadataProvider/MediaProvider son buenos ejemplos. No crear `IGameRepository` sólo por convención si provider override/concrete boundary basta; reevaluar cuando domain necesite independencia real.

## Use cases

Crear para:

- completar una partida y coordinar entry/playthrough;
- importar un preview con varias reglas;
- aplicar metadata/media coordinada;
- restaurar datos transaccionalmente;
- cualquier regla reutilizada o multi-repository.

No crear `GetGameUseCase`/`DeleteGameUseCase` de una línea sin regla adicional.

## Async/errors

- Await de todas las operaciones dentro de transacciones Drift.
- Preservar stack traces; no ocultar excepciones genéricas.
- Mapear infra failures en la frontera; localizar mensaje en UI.
- State async consistente por screen (`AsyncValue`/state sellado), sin booleanos conflictivos dispersos.
- Cancelar/dispose controllers, clients y streams.

## Generados

No editar `.g.dart`, `app_localizations*.dart` ni registrants. Editar source y regenerar. Un diff generado debe revisarse y commitearse sólo si la política de tracking actual lo exige.

## Barrel files

- Evitar barrels globales que oculten dependencies/ciclos.
- Permitir un barrel pequeño y estable dentro de design system/domain si sus exports tienen ownership único.
- No exportar data internals desde un barrel de feature.

## Revisión mínima por PR

1. Una intención/feature clara.
2. Analyzer/tests relevantes y globales según riesgo.
3. Sin imports prohibidos/ciclos nuevos.
4. Migración con snapshot/data tests si toca schema.
5. Comentarios/docs actualizados sólo donde cambia una decisión pública.
6. Medición de APK/Windows sólo si cambia dependency/asset/packaging.
