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
}
