import 'log_level.dart';
import 'logger.dart';

class PrettyLogger {
  static bool enabled = true;

  static const _reset = "\x1B[0m";
  static const _red = "\x1B[31m";
  static const _magenta = "\x1B[35m";
  static const _green = "\x1B[32m";
  static const _yellow = "\x1B[33m";
  static const _blue = "\x1B[34m";
  static const _cyan = "\x1B[36m";

  static const Map<LogLevel, String> _icons = {
    LogLevel.debug: "🐞",
    LogLevel.info: "ℹ️",
    LogLevel.warning: "⚠️",
    LogLevel.error: "❌",
    LogLevel.success: "✅",
    LogLevel.verbose: "",
  };

  static const Map<LogLevel, String> _colors = {
    LogLevel.debug: _blue,
    LogLevel.info: _cyan,
    LogLevel.warning: _yellow,
    LogLevel.error: _red,
    LogLevel.success: _green,
    LogLevel.verbose: _magenta,
  };

  static String _getIconColor(LogLevel level) {
    final icon = _icons[level] ?? "";
    final color = _colors[level] ?? _reset;
    return "$color$icon";
  }

  static void d(Object? message, {String? tag, bool? printAddress}) {
    Logger.d(
      '${_getIconColor(LogLevel.debug)} $message',
      tag: tag,
      printAddress: printAddress,
    );
  }

  static void i(Object? message, {String? tag, bool? printAddress}) {
    Logger.i(
      '${_getIconColor(LogLevel.info)} $message',
      tag: tag,
      printAddress: printAddress,
    );
  }

  static void w(Object? message, {String? tag, bool? printAddress}) {
    Logger.w(
      '${_getIconColor(LogLevel.warning)} $message',
      tag: tag,
      printAddress: printAddress,
    );
  }

  static void e(Object? message, {String? tag, bool? printAddress}) {
    Logger.e(
      '${_getIconColor(LogLevel.error)} $message',
      tag: tag,
      printAddress: printAddress,
    );
  }

  static void s(Object? message, {String? tag, bool? printAddress}) {
    Logger.s(
      '${_getIconColor(LogLevel.success)} $message',
      tag: tag,
      printAddress: printAddress,
    );
  }

  static void v(Object? message, String tag, {bool? printAddress}) {
    Logger.v(
      '${_getIconColor(LogLevel.verbose)} $message',
      tag,
      printAddress: printAddress,
    );
  }
}
