import 'package:intl/intl.dart';

final _visibleDateFormatter = DateFormat('dd-MM-yyyy');

String formatVisibleDate(DateTime? value) {
  if (value == null) return '-';
  return _visibleDateFormatter.format(value);
}
