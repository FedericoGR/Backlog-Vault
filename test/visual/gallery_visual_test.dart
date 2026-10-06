import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'visual_fixture.dart';

void main() {
  for (final size in [const Size(1440, 960), const Size(900, 800)]) {
    testWidgets('annual gallery visual flow ${size.width.toInt()}', (
      tester,
    ) async {
      final fixture = VisualFixture();
      final width = size.width.toInt();
      await fixture.open(tester, size);
      await fixture.capture(tester, 'games_$width');
      await tester.enterText(
        find.byKey(const ValueKey('annual-search')),
        'Hades',
      );
      await fixture.capture(tester, 'games_search_$width');
      await tester.enterText(find.byKey(const ValueKey('annual-search')), '');
      await tester.tap(find.byKey(const ValueKey('selected-year')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sin año').last);
      await fixture.capture(tester, 'games_unknown_$width');
    });
  }

  testWidgets('annual gallery desktop filter states', (tester) async {
    final fixture = VisualFixture();
    await fixture.open(tester, const Size(1440, 960));
    await fixture.capture(tester, 'games_filters_visible_1440');

    await tester.tap(find.byKey(const ValueKey('hide-library-filters')));
    await tester.pumpAndSettle();
    await fixture.capture(tester, 'games_filters_hidden_1440');

    await tester.tap(find.byKey(const ValueKey('library-filters-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminados'));
    await tester.tap(find.byKey(const ValueKey('played-platform-filter-pc')));
    await tester.tap(find.text('4★ o más'));
    await fixture.capture(tester, 'games_filters_active_1440');
  });

  testWidgets('annual gallery filtered empty state', (tester) async {
    final desktop = VisualFixture();
    await desktop.open(tester, const Size(1440, 960));
    await tester.tap(find.text('Terminados'));
    await tester.tap(find.text('Sin puntaje'));
    await desktop.capture(tester, 'games_filters_empty_1440');
  });

  testWidgets('annual gallery compact filter states', (tester) async {
    final compact = VisualFixture();
    await compact.open(tester, const Size(900, 800));
    await compact.capture(tester, 'games_filters_compact_900');
    await tester.tap(find.byKey(const ValueKey('library-filters-toggle')));
    await tester.pumpAndSettle();
    await compact.capture(tester, 'games_filters_compact_open_900');
  });
}
