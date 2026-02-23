DateTime? parseDateTime(String dateTimeString) {
  try {
    if (dateTimeString.isEmpty) return null;

    if (dateTimeString.contains('1900-01-01 00:00:00')) {
      return null;
    }

    return DateTime.tryParse(dateTimeString);
  } catch (e) {
    return null;
  }
}

String formatDateDMY(DateTime date) {
  final dd = date.day.toString().padLeft(2, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final yyyy = date.year.toString();
  return '$dd/$mm/$yyyy';
}

String formatDateString(String value) {
  final dt = DateTime.parse(value);
  final dd = dt.day.toString().padLeft(2, '0');
  final mm = dt.month.toString().padLeft(2, '0');
  final yyyy = dt.year.toString();
  return '$dd-$mm-$yyyy';
}
