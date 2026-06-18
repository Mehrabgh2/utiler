/// Extensions on [String] providing formatting, parsing, and utility helpers.
extension StringExtensions on String {
  /// Returns `true` if the string is empty or contains only whitespace.
  ///
  /// Example:
  /// ```dart
  /// ''.isBlank      // true
  /// '   '.isBlank   // true
  /// 'hi'.isBlank    // false
  /// ```
  bool get isBlank => trim().isEmpty;

  /// Alias for [isBlank]. Kept for backwards compatibility.
  bool get isNullOrEmpty => isBlank;

  /// Returns `true` if the string contains only whitespace characters.
  bool get isWhitespaceOnly => trim().isEmpty;

  /// Capitalizes the first letter of the string.
  ///
  /// Returns the string unchanged if it is empty.
  ///
  /// Example:
  /// ```dart
  /// 'hello'.capitalize // Hello
  /// ''.capitalize      // ''
  /// ```
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Converts the string to Title Case (each word capitalized).
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.toTitleCase // Hello World
  /// ```
  String get toTitleCase => split(' ').map((word) => word.capitalize).join(' ');

  /// Converts the string to snake_case.
  ///
  /// Handles space-separated words, camelCase, and PascalCase input.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.toSnakeCase // hello_world
  /// 'helloWorld'.toSnakeCase  // hello_world
  /// 'HTMLParser'.toSnakeCase  // html_parser
  /// ```
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'(?<=[a-z\d])([A-Z])|(?<=[A-Z])(?=[A-Z][a-z])'),
      (m) => '_${m.group(0)!}',
    ).replaceAll(RegExp(r'[\s-]+'), '_').toLowerCase();
  }

  /// Converts the string to camelCase (first word lowercase, rest capitalized).
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.toCamelCase // helloWorld
  /// 'Hello World'.toCamelCase // helloWorld
  /// ```
  String get toCamelCase {
    final words = split(' ').where((s) => s.isNotEmpty).toList();
    if (words.isEmpty) return this;
    return words.first.toLowerCase() +
        words.skip(1).map((s) => s.capitalize).join();
  }

  /// Converts the string to PascalCase (every word capitalized, no separator).
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.toPascalCase // HelloWorld
  /// ```
  String get toPascalCase =>
      split(' ').where((s) => s.isNotEmpty).map((s) => s.capitalize).join();

  /// Returns a lowercase version of the string.
  String get lowercase => toLowerCase();

  /// Returns an uppercase version of the string.
  String get uppercase => toUpperCase();

  /// Checks whether the string contains [substring], ignoring case.
  ///
  /// Example:
  /// ```dart
  /// 'Hello'.containsIgnoreCase('he') // true
  /// ```
  bool containsIgnoreCase(String substring) =>
      toLowerCase().contains(substring.toLowerCase());

  /// Safely parses the string into an [int].
  ///
  /// Returns `null` if parsing fails.
  int? toIntOrNull() {
    try {
      return int.parse(this);
    } catch (_) {
      return null;
    }
  }

  /// Safely parses the string into a [double].
  ///
  /// Returns `null` if parsing fails.
  double? toDoubleOrNull() {
    try {
      return double.parse(this);
    } catch (_) {
      return null;
    }
  }

  /// Truncates the string to [maxLength] and appends `'...'` if needed.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World'.truncate(maxLength: 5) // Hello...
  /// ```
  String truncate({int maxLength = 20}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Converts ASCII digits in the string to Persian numerals.
  ///
  /// Example:
  /// ```dart
  /// '123'.toPersianDigits() // ۱۲۳
  /// ```
  String toPersianDigits() {
    final buffer = StringBuffer();
    for (final char in split('')) {
      buffer.write(_persianDigits[char] ?? char);
    }
    return buffer.toString();
  }
}

/// Mapping of Latin digits to Persian numerals.
const Map<String, String> _persianDigits = {
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
