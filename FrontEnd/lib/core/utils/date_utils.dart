/// Utilitaires pour la manipulation et le calcul de dates.
class AppDateUtils {
  const AppDateUtils._();

  /// Calcule le nombre de jours entre [now] (ou aujourd'hui) et la date ISO [isoDate].
  /// Retourne `null` si la date est invalide ou absente.
  static int? daysUntil(String? isoDate, {DateTime? now}) {
    if (isoDate == null || isoDate.isEmpty) return null;
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return null;
    final today = _dateOnly(now ?? DateTime.now());
    final target = _dateOnly(parsed);
    return target.difference(today).inDays;
  }

  /// Supprime la partie horaire d'un [DateTime] pour ne conserver que la date.
  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
