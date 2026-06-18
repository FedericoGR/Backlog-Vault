import '../../../core/design_system/bv_breakpoints.dart';
import '../domain/library_layout_mode.dart';

const double libraryFilterSidebarReservedWidth = 300;
const double libraryTablePreferredWidth = 1120;

bool shouldShowLibraryFilterSidebar({
  required double width,
  required LibraryLayoutMode layoutMode,
  required bool filtersVisible,
}) {
  if (!filtersVisible || width < BvBreakpoints.desktop) return false;
  if (layoutMode != LibraryLayoutMode.table) return true;
  return width >=
      libraryFilterSidebarReservedWidth + libraryTablePreferredWidth;
}
