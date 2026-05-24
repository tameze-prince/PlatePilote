class AppDateUtils {
  const AppDateUtils._();

  static int? daysUntil(String? isoDate, {DateTime? now}) {
    if (isoDate == null || isoDate.isEmpty) return null;
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return null;
    final today = _dateOnly(now ?? DateTime.now());
    final target = _dateOnly(parsed);
    return target.difference(today).inDays;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
