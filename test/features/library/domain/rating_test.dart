import 'package:backlog_vault/features/library/domain/rating.dart';
import 'package:test/test.dart';

void main() {
  group('rating', () {
    test('accepts null and values from 1 to 5', () {
      expect(isValidStarRating(null), isTrue);
      expect(isValidStarRating(1), isTrue);
      expect(isValidStarRating(5), isTrue);
    });

    test('rejects values outside 1 to 5', () {
      expect(isValidStarRating(0), isFalse);
      expect(isValidStarRating(6), isFalse);
    });
  });
}
