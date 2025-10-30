/// Extensions utiles pour String
extension StringExtensions on String {
  /// Capitalise la première lettre
  /// Exemple: "hello world" -> "Hello world"
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalise chaque mot
  /// Exemple: "hello world" -> "Hello World"
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty ? word : word.capitalize())
        .join(' ');
  }

  /// Tronque le texte avec ellipsis
  /// Exemple: "Hello World".truncate(8) -> "Hello..."
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  /// Vérifie si la chaîne est un email valide
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Vérifie si la chaîne est un numéro de téléphone valide (format flexible)
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{8,}$');
    return phoneRegex.hasMatch(this);
  }

  /// Supprime les espaces au début et à la fin
  String get trimmed => trim();

  /// Vérifie si la chaîne est vide ou ne contient que des espaces
  bool get isBlank => trim().isEmpty;

  /// Vérifie si la chaîne n'est pas vide et ne contient pas que des espaces
  bool get isNotBlank => !isBlank;

  /// Convertit en camelCase
  /// Exemple: "hello world" -> "helloWorld"
  String toCamelCase() {
    if (isEmpty) return this;
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;

    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.capitalize()).join();
  }

  /// Convertit en snake_case
  /// Exemple: "helloWorld" -> "hello_world"
  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  /// Masque une partie du texte (utile pour les données sensibles)
  /// Exemple: "1234567890".mask(start: 2, end: 8) -> "12******90"
  String mask({
    int start = 0,
    int? end,
    String maskChar = '*',
  }) {
    if (isEmpty) return this;
    final endIndex = end ?? length;
    if (start >= length || start >= endIndex) return this;

    return substring(0, start) +
        maskChar * (endIndex - start) +
        substring(endIndex);
  }

  /// Retire les accents
  /// Exemple: "éàçù" -> "eacu"
  String removeAccents() {
    const withAccents = 'àâäéèêëïîôùûüÿœæçÀÂÄÉÈÊËÏÎÔÙÛÜŸŒÆÇ';
    const withoutAccents = 'aaaeeeeiioouuyoeacAAAAEEEEIIOUUUYOEAC';

    String result = this;
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return result;
  }

  /// Inverse la chaîne
  String get reversed => split('').reversed.join();

  /// Compte le nombre de mots
  int get wordCount => trim().split(RegExp(r'\s+')).length;

  /// Parse en int de manière sécurisée
  int? toIntOrNull() => int.tryParse(this);

  /// Parse en double de manière sécurisée
  double? toDoubleOrNull() => double.tryParse(this);

  /// Extrait les chiffres uniquement
  String get digitsOnly => replaceAll(RegExp(r'[^\d]'), '');

  /// Extrait les lettres uniquement
  String get lettersOnly => replaceAll(RegExp(r'[^a-zA-Z]'), '');
}

/// Extensions pour String nullable
extension NullableStringExtensions on String? {
  /// Vérifie si la chaîne est null ou vide
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Vérifie si la chaîne n'est pas null et n'est pas vide
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Retourne la valeur ou une chaîne par défaut
  String orDefault(String defaultValue) => this ?? defaultValue;

  /// Retourne la valeur ou une chaîne vide
  String get orEmpty => this ?? '';
}