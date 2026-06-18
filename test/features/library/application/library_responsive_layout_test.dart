import 'package:backlog_vault/features/library/application/library_responsive_layout.dart';
import 'package:backlog_vault/features/library/domain/library_layout_mode.dart';
import 'package:test/test.dart';

void main() {
  test('collapses filter sidebar for table when content would be squeezed', () {
    expect(
      shouldShowLibraryFilterSidebar(
        width: 1240,
        layoutMode: LibraryLayoutMode.table,
        filtersVisible: true,
      ),
      isFalse,
    );
  });

  test(
    'keeps filter sidebar for table when enough desktop width is available',
    () {
      expect(
        shouldShowLibraryFilterSidebar(
          width: libraryFilterSidebarReservedWidth + libraryTablePreferredWidth,
          layoutMode: LibraryLayoutMode.table,
          filtersVisible: true,
        ),
        isTrue,
      );
    },
  );

  test('keeps filter sidebar for non-table layouts on desktop widths', () {
    expect(
      shouldShowLibraryFilterSidebar(
        width: 1240,
        layoutMode: LibraryLayoutMode.gallery,
        filtersVisible: true,
      ),
      isTrue,
    );
    expect(
      shouldShowLibraryFilterSidebar(
        width: 1240,
        layoutMode: LibraryLayoutMode.list,
        filtersVisible: true,
      ),
      isTrue,
    );
  });

  test('hides filter sidebar below desktop or when disabled', () {
    expect(
      shouldShowLibraryFilterSidebar(
        width: 1199,
        layoutMode: LibraryLayoutMode.gallery,
        filtersVisible: true,
      ),
      isFalse,
    );
    expect(
      shouldShowLibraryFilterSidebar(
        width: 1600,
        layoutMode: LibraryLayoutMode.table,
        filtersVisible: false,
      ),
      isFalse,
    );
  });
}
