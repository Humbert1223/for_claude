/// Extensions utiles pour List
extension ListExtensions<T> on List<T> {
  /// Trouve le premier élément correspondant au test, ou null
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Trouve le dernier élément correspondant au test, ou null
  T? lastWhereOrNull(bool Function(T element) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) return this[i];
    }
    return null;
  }

  /// Trouve l'index du premier élément correspondant au test, ou -1
  int indexWhereOrNull(bool Function(T element) test) {
    for (var i = 0; i < length; i++) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  /// Récupère un élément à l'index donné, ou null si hors limites
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Sépare la liste en deux selon un prédicat [left, right]
  List<List<T>> partition(bool Function(T element) test) {
    final left = <T>[];
    final right = <T>[];
    for (var element in this) {
      if (test(element)) {
        left.add(element);
      } else {
        right.add(element);
      }
    }
    return [left, right];
  }

  /// Groupe les éléments par clé
  Map<K, List<T>> groupBy<K>(K Function(T element) keySelector) {
    final map = <K, List<T>>{};
    for (var element in this) {
      final key = keySelector(element);
      (map[key] ??= []).add(element);
    }
    return map;
  }

  /// Retourne une liste distincte (sans doublons)
  List<T> distinct() {
    return toSet().toList();
  }

  /// Retourne une liste distincte selon une clé
  List<T> distinctBy<K>(K Function(T element) keySelector) {
    final seen = <K>{};
    final result = <T>[];
    for (var element in this) {
      final key = keySelector(element);
      if (seen.add(key)) {
        result.add(element);
      }
    }
    return result;
  }

  /// Divise la liste en chunks de taille n
  List<List<T>> chunked(int size) {
    if (size <= 0) throw ArgumentError('Size must be positive');
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(sublist(i, (i + size > length) ? length : i + size));
    }
    return result;
  }

  /// Retourne true si la liste contient tous les éléments
  bool containsAll(List<T> elements) {
    return elements.every((e) => contains(e));
  }

  /// Retourne true si la liste contient au moins un élément
  bool containsAny(List<T> elements) {
    return elements.any((e) => contains(e));
  }

  /// Compte le nombre d'éléments correspondant au prédicat
  int count([bool Function(T element)? test]) {
    if (test == null) return length;
    return where(test).length;
  }

  /// Retourne la somme des valeurs (pour List<num>)
  num sumOf(num Function(T element) selector) {
    return fold(0, (sum, element) => sum + selector(element));
  }

  /// Retourne la moyenne des valeurs
  double? averageOf(num Function(T element) selector) {
    if (isEmpty) return null;
    return sumOf(selector) / length;
  }

  /// Retourne le min selon un selector
  T? minBy<C extends Comparable>(C Function(T element) selector) {
    if (isEmpty) return null;
    return reduce((a, b) =>
    selector(a).compareTo(selector(b)) <= 0 ? a : b
    );
  }

  /// Retourne le max selon un selector
  T? maxBy<C extends Comparable>(C Function(T element) selector) {
    if (isEmpty) return null;
    return reduce((a, b) =>
    selector(a).compareTo(selector(b)) >= 0 ? a : b
    );
  }

  /// Retourne une copie triée selon un selector
  List<T> sortedBy<C extends Comparable>(C Function(T element) selector) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => selector(a).compareTo(selector(b)));
    return copy;
  }

  /// Retourne une copie triée en ordre décroissant
  List<T> sortedByDescending<C extends Comparable>(C Function(T element) selector) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => selector(b).compareTo(selector(a)));
    return copy;
  }

  /// Prend les n premiers éléments
  List<T> takeFirst(int n) {
    if (n <= 0) return [];
    if (n >= length) return List<T>.from(this);
    return sublist(0, n);
  }

  /// Prend les n derniers éléments
  List<T> takeLast(int n) {
    if (n <= 0) return [];
    if (n >= length) return List<T>.from(this);
    return sublist(length - n);
  }

  /// Saute les n premiers éléments
  List<T> skipFirst(int n) {
    if (n <= 0) return List<T>.from(this);
    if (n >= length) return [];
    return sublist(n);
  }

  /// Saute les n derniers éléments
  List<T> skipLast(int n) {
    if (n <= 0) return List<T>.from(this);
    if (n >= length) return [];
    return sublist(0, length - n);
  }

  /// Applique une fonction à chaque élément (side effect)
  void forEachIndexed(void Function(int index, T element) action) {
    for (var i = 0; i < length; i++) {
      action(i, this[i]);
    }
  }

  /// Map avec index
  List<R> mapIndexed<R>(R Function(int index, T element) transform) {
    final result = <R>[];
    for (var i = 0; i < length; i++) {
      result.add(transform(i, this[i]));
    }
    return result;
  }

  /// Retourne un random element ou null
  T? randomOrNull() {
    if (isEmpty) return null;
    return this[(length * (DateTime.now().microsecondsSinceEpoch % 1000) / 1000).floor()];
  }

  /// Mélange et retourne une nouvelle liste
  List<T> shuffled() {
    final copy = List<T>.from(this);
    copy.shuffle();
    return copy;
  }

  /// Vérifie si la liste est vide ou nulle (extension pour null safety)
  bool get isNullOrEmpty => isEmpty;

  /// Vérifie si la liste n'est ni vide ni nulle
  bool get isNotNullOrEmpty => isNotEmpty;
}

/// Extension pour List nullable
extension NullableListExtensions<T> on List<T>? {
  /// Vérifie si la liste est null ou vide
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Vérifie si la liste n'est ni null ni vide
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Retourne la liste ou une liste vide si null
  List<T> orEmpty() => this ?? [];
}

/// Extension spécifique pour List<String>
extension StringListExtensions on List<String> {
  /// Joint avec un séparateur et filtre les vides
  String joinNonEmpty([String separator = ', ']) {
    return where((s) => s.trim().isNotEmpty).join(separator);
  }

  /// Filtre et trim les éléments
  List<String> trimAll() {
    return map((s) => s.trim()).toList();
  }

  /// Filtre les chaînes vides après trim
  List<String> removeEmpty() {
    return where((s) => s.trim().isNotEmpty).toList();
  }
}

/// Extension pour List<num>
extension NumListExtensions on List<num> {
  /// Somme de tous les éléments
  num get sum => fold(0, (a, b) => a + b);

  /// Moyenne de tous les éléments
  double? get average => isEmpty ? null : sum / length;

  /// Valeur minimale
  num? get min => isEmpty ? null : reduce((a, b) => a < b ? a : b);

  /// Valeur maximale
  num? get max => isEmpty ? null : reduce((a, b) => a > b ? a : b);
}