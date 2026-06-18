import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:utiler/src/logger/log_file_sink_stub.dart'
    if (dart.library.io) 'package:utiler/src/logger/log_file_sink_io.dart';
import 'package:utiler/src/logger/log_level.dart';

/// A flexible logging utility with support for console logs, file export,
/// and in-app log visualization.
///
/// [Logger] provides multiple log levels and optional features such as:
/// - writing logs to a file
/// - displaying logs in a Flutter widget via [ValueNotifier]
/// - capturing class/file/line information from stack traces
///
/// Example:
/// ```dart
/// await Logger.i('App started', tag: 'BOOT');
///
/// await Logger.e('Something failed', tag: 'API');
///
/// Logger.export = true;
/// Logger.showWidget = true;
///
/// Logger.logs.addListener(() {
///   print(Logger.logs.value);
/// });
/// ```
class Logger {
  /// Prevents instantiation. Use static methods such as [i], [e], and [d].
  Logger._();

  /// Enables or disables all logging output.
  static bool enabled = true;

  /// Enables writing logs to a file when [exportDirectory] is set.
  static bool export = false;

  /// Directory for log file export. Required when [export] is `true`.
  ///
  /// On mobile/desktop pass an absolute directory path from the host app.
  /// On web pass a logical storage prefix (file export is skipped on web).
  ///
  /// @example
  /// ```dart
  /// Logger.exportDirectory = '/path/from/your/app';
  /// Logger.export = true;
  /// ```
  static String? exportDirectory;

  /// Enables in-app log tracking via [logs].
  static bool showWidget = false;

  /// In-memory list of captured logs for UI display.
  static ValueNotifier<List<LogModel>> logs = ValueNotifier([]);

  /// Controller used for auto-scrolling log UI widgets.
  static final ScrollController scrollController = ScrollController();

  /// Logs a debug-level message.
  static Future<void> d(
    Object? message, {
    String? tag,
    bool? printAddress,
  }) async {
    await _log(LogLevel.debug, message, tag, printAddress);
  }

  /// Logs an info-level message.
  static Future<void> i(
    Object? message, {
    String? tag,
    bool? printAddress,
  }) async {
    await _log(LogLevel.info, message, tag, printAddress);
  }

  /// Logs a warning-level message.
  static Future<void> w(
    Object? message, {
    String? tag,
    bool? printAddress,
  }) async {
    await _log(LogLevel.warning, message, tag, printAddress);
  }

  /// Logs an error-level message.
  static Future<void> e(
    Object? message, {
    String? tag,
    bool? printAddress,
  }) async {
    await _log(LogLevel.error, message, tag, printAddress);
  }

  /// Logs a success-level message.
  static Future<void> s(
    Object? message, {
    String? tag,
    bool? printAddress,
  }) async {
    await _log(LogLevel.success, message, tag, printAddress);
  }

  /// Logs a verbose-level message with a required [tag].
  static Future<void> v(
    Object? message,
    String tag, {
    bool? printAddress,
  }) async {
    await _log(LogLevel.verbose, message, tag, printAddress);
  }

  /// Internal logging handler used by all public log methods.
  ///
  /// Formats message, prints to console, optionally exports to file,
  /// and optionally stores it for UI rendering.
  static Future<void> _log(
    LogLevel level,
    Object? message,
    String? tag,
    bool? printAddress,
  ) async {
    if (!enabled) return;

    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    final tagStr = tag != null ? '[$tag]' : '';
    final addStr = printAddress ?? false ? _getClassFileAndLine() : null;

    final msg =
        '${level != LogLevel.verbose ? tagStr : ''}'
        '[$time] '
        '${addStr != null ? [addStr] : ''} '
        '${message.toString()}';

    if (level == LogLevel.verbose) {
      developer.log(msg, name: tag!);
    } else {
      developer.log(msg, name: _getName(level));
    }

    if (export && exportDirectory != null) {
      await _logToFile(
        '[${level == LogLevel.verbose ? tag : _getName(level)}] $msg',
      );
    }

    if (showWidget) {
      final newList = List<LogModel>.from(logs.value);

      final widgetMsg =
          '[${level == LogLevel.verbose ? tag : _getName(level)}] '
          '[$time] '
          '${addStr != null ? [addStr] : ''} \n '
          '${message.toString()}';

      newList.add(LogModel(level: level, message: _removeColors(widgetMsg)));

      if (newList.length == 101) {
        newList.removeAt(0);
      }

      logs.value = newList;

      if (scrollController.positions.isNotEmpty &&
          scrollController.position.pixels >=
              scrollController.positions.last.maxScrollExtent) {
        Future.delayed(const Duration(milliseconds: 50)).then((_) {
          scrollController.jumpTo(
            scrollController.positions.last.maxScrollExtent,
          );
        });
      }
    }
  }

  /// Writes a log entry to `app.log` inside [exportDirectory].
  static Future<void> _logToFile(String message) async {
    try {
      await appendLogToFile(exportDirectory!, _removeColors(message));
    } catch (_) {}
  }

  /// Removes ANSI color codes from log strings.
  static String _removeColors(String message) {
    message = message.replaceAll('\x1B[0m', '');
    message = message.replaceAll('\x1B[31m', '');
    message = message.replaceAll('\x1B[35m', '');
    message = message.replaceAll('\x1B[32m', '');
    message = message.replaceAll('\x1B[33m', '');
    message = message.replaceAll('\x1B[34m', '');
    message = message.replaceAll('\x1B[36m', '');
    return message;
  }

  /// Extracts file name and line number from the current stack trace.
  static String? _getClassFileAndLine() {
    final stackTrace = StackTrace.current.toString();
    final lines = stackTrace.split('\n');

    var frameLine = lines[3];

    if (frameLine.toLowerCase().contains('pretty_logger')) {
      frameLine = lines[4];
    }
    if (frameLine.toLowerCase().contains('stopwatch_logger')) {
      frameLine = lines[5];
    }
    if (frameLine.toLowerCase().contains('future_impl')) {
      return null;
    }

    final fileNameAndLine = frameLine.split('(').last.split(')').first;

    return fileNameAndLine;
  }

  /// Maps [LogLevel] to a display string.
  static String _getName(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.success:
        return 'SUCCESS';
      case LogLevel.verbose:
        return '';
    }
  }
}

/// Represents a single log entry stored in memory.
class LogModel {
  /// Creates a log entry with a [level] and [message].
  LogModel({required this.level, required this.message});

  /// Severity level of the log.
  final LogLevel level;

  /// Log message content.
  final String message;
}
