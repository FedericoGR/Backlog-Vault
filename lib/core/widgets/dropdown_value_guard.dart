T? safeDropdownValue<T>(T? value, Iterable<T?> values) {
  if (value == null) return null;
  var matches = 0;
  for (final candidate in values) {
    if (candidate == value) matches++;
  }
  return matches == 1 ? value : null;
}
