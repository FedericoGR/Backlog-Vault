bool isValidStarRating(int? value) {
  if (value == null) return true;
  return value >= 1 && value <= 5;
}

String formatStarRating(int? value) {
  if (value == null) return '-';
  if (!isValidStarRating(value)) return '-';
  return List.filled(value, '⭐').join();
}
