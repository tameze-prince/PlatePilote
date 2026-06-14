/// Helpers de dédup fuzzy pour la liste de courses.
///
/// Utilise une normalisation simple (lowercase, pluriels en -s, accents)
/// et une distance Levenshtein réduite pour matcher des items similaires.
/// Pas de dépendance externe — Cost: O(n*m) sur longueur de chaînes.
library;

/// Normalise un nom d'aliment pour la comparaison fuzzy.
///
/// - lowercase
/// - retire accents/espaces multiples
/// - retire pluriels anglais basiques (-s, -es)
/// - retire la ponctuation
String normalizeGroceryName(String input) {
  var s = input.toLowerCase().trim();
  s = s.replaceAll(RegExp(r'[éèêë]'), 'e');
  s = s.replaceAll(RegExp(r'[àâä]'), 'a');
  s = s.replaceAll(RegExp(r'[ïî]'), 'i');
  s = s.replaceAll(RegExp(r'[ôö]'), 'o');
  s = s.replaceAll(RegExp(r'[ùûü]'), 'u');
  s = s.replaceAll(RegExp(r'[ç]'), 'c');
  // pluriels
  if (s.length > 3 && s.endsWith('es')) {
    s = s.substring(0, s.length - 2);
  } else if (s.length > 2 && s.endsWith('s')) {
    s = s.substring(0, s.length - 1);
  }
  s = s.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

/// Distance Levenshtein pure-Dart (pas de dépendance externe).
int levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  final m = a.length;
  final n = b.length;
  final dp = List<List<int>>.generate(
    m + 1,
    (_) => List<int>.filled(n + 1, 0),
  );
  for (var i = 0; i <= m; i++) {
    dp[i][0] = i;
  }
  for (var j = 0; j <= n; j++) {
    dp[0][j] = j;
  }
  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      dp[i][j] = [
        dp[i - 1][j] + 1,
        dp[i][j - 1] + 1,
        dp[i - 1][j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
    }
  }
  return dp[m][n];
}

/// Renvoie true si [a] et [b] matchent fuzzy.
/// Règles:
/// - Normalized equals → match.
/// - Levenshtein <= 2 sur chaînes <= 6 chars
/// - Levenshtein <= 2 sur chaînes <= 12 chars
bool isSameGroceryItem(String a, String b) {
  final na = normalizeGroceryName(a);
  final nb = normalizeGroceryName(b);
  if (na.isEmpty || nb.isEmpty) return false;
  if (na == nb) return true;
  final dist = levenshtein(na, nb);
  final threshold = na.length <= 6 || nb.length <= 6
      ? 1
      : (na.length <= 12 || nb.length <= 12 ? 2 : 3);
  return dist <= threshold;
}

/// Trouve l'index d'un item existant qui pourrait-être un doublon.
/// Retourne -1 si aucun match.
int findDuplicateIndex<T>(
  List<T> items,
  String candidateName,
  String Function(T) nameGetter,
) {
  for (var i = 0; i < items.length; i++) {
    if (isSameGroceryItem(nameGetter(items[i]), candidateName)) {
      return i;
    }
  }
  return -1;
}
