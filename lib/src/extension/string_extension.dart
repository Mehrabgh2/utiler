extension StringExtensions on String {
  bool get isNullOrEmpty => isEmpty || isWhitespaceOnly;

  bool get isWhitespaceOnly => trim().isEmpty;

  String get toTitleCase => split(' ').map((word) => word.capitalize).join(' ');

  String get toSnakeCase => toLowerCase().replaceAll(' ', '_');

  String get toCamelCase => split(' ').map((s) => s.capitalize).join();

  String get capitalize => replaceRange(0, 1, this[0].toUpperCase());

  String get lowercase => toLowerCase();

  String get uppercase => toUpperCase();

  bool containsIgnoreCase(String substring) =>
      toLowerCase().contains(substring.toLowerCase());

  int? toIntOrNull() {
    try {
      return int.parse(this);
    } catch (e) {
      return null;
    }
  }

  double? toDoubleOrNull() {
    try {
      return double.parse(this);
    } catch (e) {
      return null;
    }
  }

  String truncate({int maxLength = 20}) {
    if (length <= maxLength) return this;
    return "${substring(0, maxLength)} ...";
  }

  String toPersianDigits() {
    return replaceAllMapped(
      RegExp(r'[0-9]'),
      (match) => _persianDigits[match.group(0)!]!,
    );
  }
}

Map<String, String> _persianDigits = {
  '0': '۰',
  '1': '۱',
  '2': '۲',
  '3': '۳',
  '4': '۴',
  '5': '۵',
  '6': '۶',
  '7': '۷',
  '8': '۸',
  '9': '۹',
};
