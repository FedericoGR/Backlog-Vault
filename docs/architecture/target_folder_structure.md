# Estructura objetivo de carpetas

Estructura conceptual, no instrucción de mover todo en un solo commit:

```text
lib/
  main.dart
  app/
    bootstrap/
      app_bootstrap.dart
      app_providers.dart
    routing/
      app_router.dart
      app_shell.dart
    theme/
    localization/

  core/
    database/
      app_database.dart
      tables/
      migrations/
    filesystem/
      local_file_store.dart
      file_picker_gateway.dart
    network/
      http_client_provider.dart
      network_failure.dart
    credentials/
      secure_key_value_store.dart
    errors/
    logging/
    ids/
    time/
    formatting/
    design_system/

  features/
    library/
      domain/
      data/
      application/
        library_view_model.dart
        library_state.dart
      presentation/
        library_page.dart
        widgets/

    games/
      domain/
      data/
      application/
      presentation/
        detail/
        form/

    playthroughs/
      domain/
      data/
      application/
      presentation/

    catalogs/
    metadata/
    media/
    import_export/
      csv_import/
      local_export/
      backup_restore/
    statistics/
    settings/

test/
  app/
  core/
  features/              # espejo de lib/features
  fixtures/
integration_test/
  offline_startup_test.dart
  import_export_test.dart
  migration_smoke_test.dart
```

## Mapeos prioritarios

| Actual | Objetivo |
|---|---|
| `app/router.dart` + shell | `app/routing/` |
| `app/theme.dart` | `app/theme/` con builders cohesivos |
| `core/design_system/*` | `core/design_system/` (mantener) |
| `games/application/library_game_details.dart` | `games/domain/library_game_details.dart` sin Drift |
| `game_list_page.dart` | page + ViewModel + widgets filter/table/gallery/saved views |
| `game_form_page.dart` | form screen/sections + ViewModel |
| `game_detail_page.dart` | detail screen/panels + ViewModel |
| `GameRepository` playthrough methods | `playthroughs/data/playthrough_repository.dart` + coordinator |
| backup/export actuales | subfeatures bajo import_export o mantener feature separada si ownership queda más claro |
| metadata key storage reutilizado por media | `core/credentials` adapter + contracts específicos |
| `l10n/domain_localizations.dart` | label mappers dentro de presentation de cada feature |
| `features/sync/*` | eliminado en E2; no tiene target activo |

## Estrategia incremental

1. E2 no aplica movimientos masivos; sólo seams indispensables para retirar Sync.
2. E3 mueve una vertical slice con tests verdes y sin alias/barrels globales.
3. Mantener imports explícitos; actualizar tests en el mismo slice.
4. No crear todas las carpetas anticipadamente.
5. Un movimiento puro y una reescritura conductual deben ser commits separados cuando sea práctico.

## Naming

`*_page.dart` o `*_screen.dart` debe elegirse una vez y usarse consistentemente; se recomienda `*_page.dart` para compatibilidad actual. `*_view_model.dart`, `*_repository.dart`, `*_service.dart`/`*_client.dart` expresan rol. Evitar `manager`, `helper` y `utils` salvo responsabilidad precisa.
