import 'package:backlog_vault/features/library/domain/rating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats ratings as stars', () {
    expect(formatStarRating(3), '⭐⭐⭐');
    expect(formatStarRating(5), '⭐⭐⭐⭐⭐');
    expect(formatStarRating(null), '-');
    expect(formatStarRating(6), '-');
  });
}
