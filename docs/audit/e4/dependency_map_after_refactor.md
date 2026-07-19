# Dependency map after E4

## Enforced flow

```mermaid
flowchart LR
  App["app/bootstrap · routing · theme"] --> Presentation["feature/presentation"]
  Presentation --> Application["feature/application · ViewModels"]
  Presentation --> Domain["feature/domain · read models"]
  Application --> Data["feature/data · repositories/services"]
  Application --> Domain
  Data --> Core["core/database · ids · time"]
  Data --> Domain
  Core --> Platform["Drift · filesystem · HTTP · secure storage"]
```

The automated checker proves:

1. `core` has no dependency on features;
2. presentation has no dependency on data, Drift, database, filesystem, HTTP,
   secure storage or FilePicker;
3. data has no dependency on presentation;
4. non-visual feature dependencies form an acyclic graph;
5. removed Sync and legacy backup module paths cannot be reintroduced.

## Cross-feature ownership edges

```mermaid
flowchart TD
  Games --> Catalogs
  Games --> Library
  Games --> Playthroughs
  Games --> Media
  Media --> Metadata
  Metadata --> Catalogs
  Bulk["bulk_metadata_import"] --> Library
  Bulk --> Metadata
  Bulk --> Media
  Statistics --> Library
  Statistics --> Playthroughs
  Settings --> Metadata
  Settings --> ImportExport["import_export"]
```

Presentation composition may open a dialog owned by another feature, but this
edge is visual only and is excluded from the non-visual dependency graph.
Repositories do not call repositories from other features.

## Infrastructure boundaries

- Drift is referenced by concrete repositories only.
- HTTP clients and provider authentication stay in metadata/media data.
- secure storage stays behind `MetadataApiKeyStorage`; Settings observes only
  `ExternalCredentialsState` booleans.
- FilePicker stays behind CSV/export/media services.
- filesystem cover reads return bytes through an application provider.
