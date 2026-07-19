# Remaining presentation hotspots after E5

Generated Drift/localization files are excluded. Size is a review signal, not
an automatic split rule.

| File | E4 lines | E5 lines | Decision and remaining debt |
|---|---:|---:|---|
| `games/presentation/game_form_page.dart` | 1,502 | 631 | Retain one form state and submit lifecycle; further division would require a tested form-state boundary. |
| `bulk_metadata_import/presentation/parts/bulk_preview.dart` | part of 1,763 | 576 | Cohesive preview editor with selection and cover chooser; profile before changing rebuild boundaries. |
| `games/presentation/parts/game_detail_sections.dart` | part of 1,324 | 544 | Cohesive read-only work/personal/progress sections; split only when a section changes independently. |
| `bulk_metadata_import/presentation/bulk_metadata_import_page.dart` | 1,763 | 499 | Four-stage state coordinator; ViewModel owns batching, but local selection editing remains substantial. |
| `games/presentation/parts/game_form_metadata.dart` | part of 1,502 | 457 | One optional metadata comparison workflow; no reuse outside the form. |
| `metadata/presentation/metadata_search_dialog.dart` | 639 | 411 | Dialog state and async orchestration remain together intentionally. |
| `library/presentation/widgets/library_filter_dialogs.dart` | part of 1,808 | 399 | Related filter/column/saved-view dialogs; no global component justified. |
| `games/presentation/parts/playthrough_dialogs.dart` | part of 1,324 | 380 | Related completion/playthrough forms; preserve a single validation vocabulary. |

The former library, game detail, CSV, statistics and Settings page shells are no
longer primary hotspots. E6 should not split the residual files by line count;
its exact recommendation is to profile build/package/dependency size first and
touch presentation only for measured rebuild or binary impact.
