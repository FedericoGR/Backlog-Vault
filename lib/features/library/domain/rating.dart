bool isValidStarRating(int? value) {
  if (value == null) return true;
  return value >= 1 && value <= 5;
}

String formatStarRating(int? value) {
  if (value == null) return '-';
  return '$value/5';
}
