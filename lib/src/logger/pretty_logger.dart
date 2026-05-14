import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:utiler/src/core/guard.dart';
import 'package:utiler/src/logger/log_level.dart';
import 'package:utiler/src/logger/logger.dart';

/// A styled logging utility built on top of [Logger] that adds:
///
/// - colored output (ANSI escape codes)
/// - emoji icons per log level
/// - API response pretty printing
/// - JSON pretty formatting
///
/// [PrettyLogger] is designed for development/debug environments and
/// enhances readability of logs in the console.
///
/// Example:
/// ```dart
/// await PrettyLogger.i('App initialized', tag: 'BOOT');
///
/// await PrettyLogger.e('Something failed');
///
/// await PrettyLogger.api(response);
/// ```
class PrettyLogger {
  /// Enables or disables pretty logging output globally.
  static bool enabled = true;

  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _magenta = '\x1B[35m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';
  static const _cyan = '\x1B[36m';

  /// Emoji icons mapped to each log level.
  static const Map<LogLevel, String> _icons = {
    LogLevel.debug: '🐞',
    LogLevel.info: 'ℹ️',
    LogLevel.warning: '⚠️',
    LogLevel.error: '❌',
    LogLevel.success: '✅',
    LogLevel.verbose: '',
  };

  /// ANSI colors mapped to each log level.
  static const Map<LogLevel, String> _colors = {
    LogLevel.debug: _blue,
    LogLevel.info: _cyan,
    LogLevel.warning: _yellow,
    LogLevel.error: _red,
    LogLevel.success: _green,
    LogLevel.verbose: _magenta,
  };

  /// Returns a colored emoji icon for the given [LogLevel].
  static String _getIconColor(LogLevel level) {
    final icon = _icons[level] ?? '';
    final color = _colors[level] ?? _reset;
    return '$color$icon';
  }

  /// Returns a color based on HTTP status code.
  ///
  /// - 2xx → green
  /// - 3xx → yellow
  /// - 4xx/5xx → red
  static String _getStatusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return _green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return _yellow;
    } else {
      return _red;
    }
  }

  /// Logs a debug message with styling.
  static Future<void> d(
    Object? message, {
    String? tag,
    bool? printAddress,
  }) async {
    await Logger.d(
      '${_getIconColor(LogLevel.debug)} $message',
      tag: tag,
      printAddress: printAddress,
    );
  }

  /// Logs an info message with styling.
  static Future<void> i(
    Object? message, {
    String? tag,
    bool? printAddress,
  }) async {
    await Logger.i(
      '${_getIconColor(LogLevel.info)} $message',
      tag: tag,
      printAddress: printAddress,
    );
  }

  /// Logs a warning message with styling.
  static Future<void> w(
    Object? message, {
    String? tag,
    bool? printAddress,
  }) async {
    await Logger.w(
      '${_getIconColor(LogLevel.warning)} $message',
      tag: tag,
      printAddress: printAddress,
    );
  }

  /// Logs an error message with styling.
  static Future<void> e(
    Object? message, {
    String? tag,
    bool? printAddress,
  }) async {
    await Logger.e(
      '${_getIconColor(LogLevel.error)} $message',
      tag: tag,
      printAddress: printAddress,
    );
  }

  /// Logs a success message with styling.
  static Future<void> s(
    Object? message, {
    String? tag,
    bool? printAddress,
  }) async {
    await Logger.s(
      '${_getIconColor(LogLevel.success)} $message',
      tag: tag,
      printAddress: printAddress,
    );
  }

  /// Logs a verbose message with styling.
  static Future<void> v(
    Object? message,
    String tag, {
    bool? printAddress,
  }) async {
    await Logger.v(
      '${_getIconColor(LogLevel.verbose)} $message',
      tag,
      printAddress: printAddress,
    );
  }

  /// Logs an HTTP API response in a formatted and colorized way.
  ///
  /// The response body is automatically pretty-printed if it is valid JSON.
  static Future<void> api(http.Response response, {bool? printAddress}) async {
    String text =
        '${_getStatusColor(response.statusCode)} '
        '${_prettifyJson(response.body)}';

    text = text.replaceAll('\n', '\n${_getStatusColor(response.statusCode)}');

    text = '\n$text';

    await Logger.v(
      text,
      '${response.request?.method} '
      '${response.request?.url.path} '
      '${response.statusCode}',
      printAddress: printAddress,
    );
  }

  /// Attempts to pretty-print a JSON string.
  ///
  /// Supports both Map and List JSON structures. If parsing fails,
  /// returns the original string.
  static String _prettifyJson(String data) {
    try {
      final Map<dynamic, dynamic>? jsonMap = Guard<Map<dynamic, dynamic>?>()(
        () => jsonDecode(data) as Map,
      );

      if (jsonMap != null) {
        return const JsonEncoder.withIndent('  ').convert(jsonMap);
      }

      final List<dynamic>? list = Guard<List<dynamic>>()(
        () => List.from(jsonDecode(data) as List),
      );

      if (list != null) {
        return const JsonEncoder.withIndent('  ').convert(list);
      }

      return data;
    } catch (_) {
      return data.toString();
    }
  }
}
