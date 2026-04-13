extension NumExtensions on num {
  String get toPersianNumber {
    return toString().replaceAllMapped(
      RegExp(r'[0-9]'),
      (match) => _persianDigits[match.group(0)!]!,
    );
  }

  bool isBetween(num min, num max) => this >= min && this <= max;

  double get toRadians => this * (3.141592653589793 / 180);

  double get toDegrees => this * (180 / 3.141592653589793);
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
