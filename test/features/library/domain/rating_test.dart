import 'package:backlog_vault/features/library/domain/rating.dart';
import 'package:backlog_vault/features/library/presentation/widgets/rating_stars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats ratings as stars', () {
    expect(formatStarRating(3), '⭐⭐⭐');
    expect(formatStarRating(5), '⭐⭐⭐⭐⭐');
    expect(formatStarRating(null), '-');
    expect(formatStarRating(6), '-');
  });

  testWidgets('RatingStars renders a readable empty label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RatingStars(rating: null, emptyLabel: 'Sin puntaje'),
      ),
    );

    expect(find.text('Sin puntaje'), findsOneWidget);
  });
}
