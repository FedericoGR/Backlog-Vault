import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'visual_fixture.dart';

void main() {
  for (final size in [const Size(1440, 960), const Size(900, 800)]) {
    testWidgets('personal record visual flow ${size.width.toInt()}', (
      tester,
    ) async {
      final fixture = VisualFixture();
      final width = size.width.toInt();
      await fixture.open(tester, size);
      await tester.tap(find.byKey(const ValueKey('add-game')));
      await fixture.capture(tester, 'add_$width');
      fixture.router.go('/');
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('annual-search')),
        'Hades',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hades II'));
      await fixture.capture(tester, 'detail_completed_$width');
      final poster = tester.getRect(
        find.byKey(const ValueKey('detail-poster')),
      );
      final identity = tester.getRect(
        find.byKey(const ValueKey('detail-personal-record')),
      );
      expect(poster.top, lessThanOrEqualTo(identity.top));
      expect(poster.width / poster.height, closeTo(2 / 3, .01));
      await tester.tap(find.text('Editar'));
      await fixture.capture(tester, 'edit_$width');
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('hours-field')))
            .controller!
            .text,
        '38.0',
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('game-information')),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('game-information')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Géneros'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await fixture.capture(tester, 'edit_catalog_$width');
      fixture.router.go('/games/1');
      await fixture.capture(tester, 'detail_unfinished_$width');
    });
  }
}
