import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'visual_fixture.dart';

void main() {
  for (final size in [const Size(1440, 960), const Size(900, 800)]) {
    testWidgets('statistics and settings visual flow ${size.width.toInt()}', (
      tester,
    ) async {
      final fixture = VisualFixture();
      final width = size.width.toInt();
      await fixture.open(tester, size);
      await tester.tap(find.byKey(const ValueKey('nav-statistics')));
      await fixture.capture(tester, 'statistics_$width');
      if (width == 900) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -240));
        await fixture.capture(tester, 'statistics_platforms_$width');
      }
      await tester.tap(find.byKey(const ValueKey('statistics-next-year')));
      await fixture.capture(tester, 'statistics_empty_$width');
      await tester.tap(find.byKey(const ValueKey('nav-settings')));
      await fixture.capture(tester, 'settings_$width');
      if (width == 900) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -240));
        await fixture.capture(tester, 'settings_application_$width');
        await tester.drag(find.byType(ListView).first, const Offset(0, 1000));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('IGDB / Twitch'));
      await fixture.capture(tester, 'settings_credentials_$width');
    });
  }
}
