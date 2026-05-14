/// Extensions on [String] providing formatting, parsing, and utility helpers.
///
/// These helpers make it easier to transform strings into common formats
/// such as camelCase, snake_case, title case, and also provide safe parsing
/// and comparison utilities.
extension StringExtensions on String {
  /// Returns `true` if the string is empty or contains only whitespace.
  ///
  /// Example:
  /// ```dart
  /// ''.isNullOrEmpty // true
  /// '   '.isNullOrEmpty // true
  /// ```
  bool get isNullOrEmpty => isEmpty || isWhitespaceOnly;

  /// Returns `true` if the string contains only whitespace characters.
  bool get isWhitespaceOnly => trim().isEmpty;

  /// Converts the string to Title Case (each word capitalized).
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.toTitleCase // Hello World
  /// ```
  String get toTitleCase => split(' ').map((word) => word.capitalize).join(' ');

  /// Converts the string to snake_case.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.toSnakeCase // hello_world
  /// ```
  String get toSnakeCase => toLowerCase().replaceAll(' ', '_');

  /// Converts the string to CamelCase.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.toCamelCase // HelloWorld
  /// ```
  String get toCamelCase => split(' ').map((s) => s.capitalize).join();

  /// Capitalizes the first letter of the string.
  ///
  /// Example:
  /// ```dart
  /// 'hello'.capitalize // Hello
  /// ```
  String get capitalize => replaceRange(0, 1, this[0].toUpperCase());

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

  /// Truncates the string to [maxLength] and appends ellipsis if needed.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World'.truncate(maxLength: 5) // Hello ...
  /// ```
  String truncate({int maxLength = 20}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)} ...';
  }

  /// Converts ASCII digits in the string to Persian numerals.
  ///
  /// Example:
  /// ```dart
  /// '123'.toPersianDigits // ۱۲۳
  /// ```
  String toPersianDigits() {
    return replaceAllMapped(
      RegExp(r'[0-9]'),
      (match) => _persianDigits[match.group(0)!]!,
    );
  }
}

/// Mapping of Latin digits to Persian numerals.
///
/// Used internally by [StringExtensions.toPersianDigits].
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
