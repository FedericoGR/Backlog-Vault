# Investigación de arquitectura para Backlog Vault Offline

Fecha de consulta: 2026-07-16. Se priorizaron fuentes oficiales/primarias. La decisión no se basa en una moda ni en reducir binarios: arquitectura organiza responsabilidades; los plugins/assets/packaging gobiernan el peso.

## Contexto evaluado

- Flutter Windows + Android, Riverpod, Drift y go_router.
- 168 archivos fuente, 54k+ líneas Dart de `lib` incluyendo generados, 332 tests.
- Producto local sin cuentas/sync/cloud, pero con filesystem, import/export, media y HTTP opcional para metadata/covers.
- Equipo/proyecto que se beneficia de navegación simple y bajo boilerplate.
- Necesidad inmediata de retirar una feature transversal sin perder datos.

## Qué dicen las fuentes

Flutter recomienda separar UI y data; Views sólo presentan/encaminan eventos, ViewModels transforman datos y mantienen UI state, repositories son source of truth y services aíslan APIs/plataforma/filesystem. La capa domain/use cases es opcional y se justifica al combinar repositorios, encapsular lógica compleja o reutilizarla. También recomienda DI, go_router y fakes/tests de boundaries.

Riverpod permite providers top-level inmutables, composición, overrides y tests aislados con ProviderContainer. Esto sirve como DI/composición y como estado, pero no define por sí solo ownership de features.

Drift recomienda migraciones incrementales con snapshots/tests y transacciones; el schema generado debe permanecer detrás de data boundaries. Flutter Testing recomienda muchas pruebas unit/widget y suficientes integration tests para recorridos críticos.

## Comparación de enfoques

Escala 1 (malo) a 5 (excelente). “Boilerplate” 5 significa poco overhead.

| Enfoque | Fit proyecto | Offline/local | Testing | Retirar Sync | Boilerplate | Riesgo principal | Decisión |
|---|---:|---:|---:|---:|---:|---|---|
| Arquitectura oficial Flutter | 5 | 5 | 5 | 4 | 4 | aplicada literalmente puede imponer 1 VM por view aun trivial | adoptar principios |
| Feature-first | 5 | 5 | 4 | 5 | 4 | duplicación/feature boundaries difusos | adoptar organización |
| MVVM | 5 | 5 | 5 | 4 | 4 | ViewModels “god object” o uno por widget | adoptar a nivel screen/workflow |
| Repository + Services | 5 | 5 | 5 | 5 | 4 | repositories demasiado amplios o dependientes entre sí | adoptar con boundaries |
| Clean Architecture estricta | 3 | 5 | 5 | 4 | 1 | interfaces/DTO/mappers/use cases por CRUD; costo cognitivo | rechazar rigidez |
| Capas globales por tipo | 3 | 5 | 4 | 2 | 4 | cambios saltan por todo `lib/`; ownership débil | no como estructura raíz |
| Vertical slice/modular | 5 | 5 | 5 | 5 | 3 | repetir infraestructura/modelos y comunicación entre slices | adoptar límites, no aislamiento extremo |
| Híbrido pragmático | 5 | 5 | 5 | 5 | 5 | requiere disciplina/revisión porque no todo es una regla mecánica | recomendado |

## Evaluación detallada

### Flutter oficial + MVVM

Es la base más compatible: las páginas actuales contienen mutaciones y workflows que se pueden mover a Notifiers/ViewModels, manteniendo widgets testeables. Se adapta Riverpod en lugar de ChangeNotifier. Excepción pragmática: un screen read-only simple puede consumir un `StreamProvider` sin crear una clase ViewModel vacía.

### Feature-first/vertical slice

Agrupar domain/data/application/presentation por capacidad reduce saltos y facilita borrar Sync como módulo. `app` conserva composición/rutas; `core` sólo infraestructura genuinamente compartida. Las features no deben convertirse en paquetes aislados ni duplicar HTTP/filesystem.

### Repository + Services

Drift, filesystem, secure storage, HTTP y plugins son boundaries valiosos. Repositories entregan modelos/read models de aplicación y coordinan uno o varios data sources; services adaptan una fuente externa. Repositories no dependen de otros repositories: la coordinación va al ViewModel o use case.

### Clean estricta

La independencia de domain respecto de Flutter/Drift es útil. No lo es crear una interfaz, DTO, mapper y use case por cada operación. Se adopta la dirección de dependencias y se rechaza el ceremonial obligatorio.

### Capas globales

El estado actual ya demuestra ciclos entre games/library/media/metadata/l10n. Un árbol global `models/repositories/screens` los ocultaría más. Se usan capas dentro de cada feature, no como raíz única.

## Recomendación

**Feature-first + MVVM pragmático + Repository/Service**, con capa domain/use cases selectiva.

Se adopta:

- UI sin business/data/file logic;
- Notifier/ViewModel por pantalla o workflow mutable/complejo;
- repositories source of truth y services por data source;
- domain independiente de Flutter, Drift y plugins;
- DI/composición con providers Riverpod top-level;
- features como unidad de ownership y tests espejados;
- `app` puede importar features para rutas/composición;
- `core` nunca importa features;
- use cases para multi-repo, transacciones/reglas complejas o reutilización.

Se rechaza:

- interfaces para cada clase;
- use case por CRUD trivial;
- DTO/mappers 1:1 para cada tabla/join;
- repositories que se llaman entre sí;
- barrels globales;
- services/manager/helper genéricos sin una fuente/responsabilidad clara;
- refactor masivo de carpetas durante el retiro de Sync.

## Impacto en peso

El patrón no reducirá significativamente EXE/APK. El ahorro vendrá de `mobile_scanner`/Barhopper/modelos ML, QR/cámara, protocolos Sync, código muerto resultante, assets, builds ignorados y estrategia multi-ABI/packaging.

## Fuentes oficiales consultadas

- [Flutter — Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)
- [Flutter — Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)
- [Flutter — Architecture case study/package structure](https://docs.flutter.dev/app-architecture/case-study)
- [Flutter — Offline-first support](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)
- [Flutter — Testing overview](https://docs.flutter.dev/testing/overview)
- [Effective Dart](https://dart.dev/effective-dart)
- [Effective Dart — Documentation](https://dart.dev/effective-dart/documentation)
- [Riverpod — Providers](https://riverpod.dev/docs/concepts2/providers)
- [Riverpod — Testing providers](https://docs-v2.riverpod.dev/docs/essentials/testing)
- [Riverpod — DO/DON'T](https://riverpod.dev/docs/root/do_dont)
- [Drift — Migrations](https://drift.simonbinder.eu/migrations/)
- [Drift — Testing migrations](https://drift.simonbinder.eu/migrations/tests/)
- [Drift — Migrator API](https://drift.simonbinder.eu/migrations/api/)
- [Drift — Transactions](https://drift.simonbinder.eu/dart_api/transactions/)
- [Drift — Testing](https://drift.simonbinder.eu/testing/)
- [go_router — paquete oficial Flutter](https://pub.dev/packages/go_router)

## Límites de la investigación

Las fuentes describen principios, no una estructura única obligatoria. “Feature-first” es una decisión contextual derivada del tamaño/grafo del repo y de la necesidad de retirar Sync. No se investigó una migración de framework porque Flutter/Riverpod/Drift siguen siendo adecuados.
