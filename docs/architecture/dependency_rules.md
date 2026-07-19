# Reglas de dependencias

## Matriz permitida

| Desde | Puede depender de | No puede depender de |
|---|---|---|
| `app` | core + features para composición/rutas | data internals, reglas de negocio |
| `core` | Dart/Flutter/paquetes de infraestructura | cualquier feature |
| feature `presentation` | su application/domain, app l10n/design system | Drift, File/IO, HTTP, plugins, data de otra feature |
| feature `application` | su domain/repository contracts; contracts domain ajenos justificados | widgets, concrete DB/filesystem, presentation ajena |
| feature `domain` | Dart puro; value objects domain permitidos | Flutter, Riverpod, Drift, HTTP, plugins |
| feature `data` | su domain + core infrastructure | presentation; repositories ajenos |

## Cross-feature

1. Preferir un coordinator/use case en la feature dueña del workflow.
2. Importar un contract/model domain ajeno, no su data implementation.
3. Si dos features comparten infraestructura, subir sólo esa infraestructura a core; no mover conceptos de negocio.
4. Si dos features se importan mutuamente, detener el cambio y definir ownership/contrato.
5. `app` registra rutas pero no se usa como service locator desde features.

## Repositories y services

- Un repository no llama otro repository.
- Repository puede usar varios services/data sources.
- Service puede reutilizarse por repositories si representa una fuente concreta.
- Mutaciones multi-repo van en use case con una transacción explícita cuando comparten DB.
- No exponer `AppDatabase`, tables, companions o rows fuera de data.

## Riverpod

- Providers viven junto a la capa que componen.
- Dependencias se obtienen por `ref.watch/read`, no singletons/global mutable.
- No crear providers dinámicamente en widgets.
- View no inicializa manualmente un provider con `init()`; el provider se auto-inicializa o el bootstrap explícito lo hace.
- Tests crean ProviderContainer/ProviderScope por caso y overridean boundaries.

## Enforcement

E4 agregó `test/architecture/offline_architecture_test.dart`, sin dependencia
nueva. El test hace fallar la suite al:

- fallar si `lib/core` contiene `/features/`;
- fallar si presentation importa Drift, `dart:io`, http, secure storage o file_picker/mobile plugins;
- detectar ciclos no visuales feature↔feature;
- evitar barrels `features.dart`/`core.dart` globales.

No agregar una herramienta externa en E1. `flutter analyze`, tests y revisión del grafo son suficientes para comenzar.

## Excepciones

Toda excepción debe quedar cerca del import o en un ADR: motivo, alcance y condición de retiro. Ejemplo aceptable: widget platform-specific encapsulado en presentation que usa una API Flutter UI; no aceptable: page que abre archivos y actualiza DB directamente.
