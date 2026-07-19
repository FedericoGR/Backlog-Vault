# Remaining hotspots after E4

E4 extracted state and coordination. Visual decomposition remains E5 work.

| File | Baseline lines | E4 lines | Remaining reason |
|---|---:|---:|---|
| `library/presentation/game_list_page.dart` | 1,809 | 1,808 | table/gallery/list widgets and dialogs |
| `bulk_metadata_import/presentation/bulk_metadata_import_page.dart` | 1,777 | 1,763 | preview/editor visual surface |
| `games/presentation/game_form_page.dart` | 1,522 | 1,502 | form sections and embedded metadata dialog |
| `games/presentation/game_detail_page.dart` | 1,324 | 1,324 | detail panels and playthrough dialogs |
| `statistics/presentation/statistics_page.dart` | 683 | 682 | chart/card composition |
| `metadata/presentation/metadata_search_dialog.dart` | 629 | 639 | diff preview widgets; coordination extracted |
| `settings/presentation/settings_page.dart` | 609 | 548 | credential panels and export card |
| `media/presentation/media_search_dialog.dart` | 515 | 499 | candidate/cover grids |
| `games/data/game_repository.dart` | 672 | 617 | game aggregate plus progress transitions |

Generated Drift/localization files remain larger and are not manual hotspots.
E5 should split the first eight files by cohesive visual sections without
changing providers, behavior, navigation or theme semantics.
