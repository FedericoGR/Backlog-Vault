import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/bv_chip.dart';
import '../../../../core/design_system/bv_panel.dart';
import '../../../../core/design_system/bv_surface.dart';
import '../../../../core/design_system/bv_theme_extension.dart';
import '../../../../core/design_system/bv_tokens.dart';
import '../../../../core/formatting/date_formatters.dart';
import '../../../../l10n/domain_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/game_status.dart';
import '../../domain/library_filter_state.dart';
import '../../domain/library_game_row.dart';
import '../../domain/library_table_summary.dart';
import '../../domain/rating.dart';
import 'library_cover_thumbnail.dart';

part 'library_summary_widgets.dart';
part 'library_grid_widgets.dart';
part 'library_list_widgets.dart';
part 'library_filter_sidebar.dart';

/// Builds the actions shown for one catalog row at the requested density.
typedef LibraryRowActionsBuilder =
    Widget Function(LibraryGameRow row, bool compact);

/// Reports selection changes without duplicating selection state in a card.
typedef LibraryRowSelectionChanged =
    void Function(String entryId, bool selected);
