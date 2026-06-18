/// Extensions on [DateTime] for common comparisons, formatting, and display.
extension DateTimeExtensions on DateTime {
  /// Whether this date falls on today's calendar date (local time).
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Whether this date falls on yesterday's calendar date (local time).
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Whether this date falls on tomorrow's calendar date (local time).
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Whether this moment is strictly before [DateTime.now].
  bool get isPast => isBefore(DateTime.now());

  /// Whether this moment is strictly after [DateTime.now].
  bool get isFuture => isAfter(DateTime.now());

  /// A human-readable relative time string such as `'3h ago'` or `'2d ago'`.
  ///
  /// Intended for past dates. For future dates the difference is still
  /// expressed as a positive duration (e.g. `'-5s ago'` will not appear;
  /// use [isFuture] to distinguish).
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().subtract(Duration(hours: 3)).timeAgo // '3h ago'
  /// DateTime.now().subtract(Duration(days: 8)).timeAgo  // '1w ago'
  /// ```
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  /// Formats this [DateTime] using a simple pattern string.
  ///
  /// Supported tokens:
  /// - `yyyy` — 4-digit year
  /// - `MM` — 2-digit month (01–12)
  /// - `dd` — 2-digit day (01–31)
  /// - `HH` — 2-digit hour in 24-hour format (00–23)
  /// - `mm` — 2-digit minute (00–59)
  /// - `ss` — 2-digit second (00–59)
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 3, 5, 14, 7).format('yyyy-MM-dd HH:mm') // '2024-03-05 14:07'
  /// DateTime(2024, 3, 5).format('dd/MM/yyyy')               // '05/03/2024'
  /// ```
  String format(String pattern) {
    return pattern
        .replaceAll('yyyy', year.toString().padLeft(4, '0'))
        .replaceAll('MM', month.toString().padLeft(2, '0'))
        .replaceAll('dd', day.toString().padLeft(2, '0'))
        .replaceAll('HH', hour.toString().padLeft(2, '0'))
        .replaceAll('mm', minute.toString().padLeft(2, '0'))
        .replaceAll('ss', second.toString().padLeft(2, '0'));
  }

  /// Midnight at the start of this date (`yyyy-MM-dd 00:00:00.000`).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Last millisecond of this date (`yyyy-MM-dd 23:59:59.999`).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Whether this date and [other] fall on the same calendar day.
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
