import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import 'log_level.dart';

class Logger {
  static bool enabled = true;
  static bool export = false;
  static bool showWidget = false;
  static ValueNotifier<List<LogModel>> logs = ValueNotifier([]);
  static final ScrollController scrollController = ScrollController();

  static void d(Object? message, {String? tag, bool? printAddress}) {
    _log(LogLevel.debug, message, tag, printAddress);
  }

  static void i(Object? message, {String? tag, bool? printAddress}) {
    _log(LogLevel.info, message, tag, printAddress);
  }

  static void w(Object? message, {String? tag, bool? printAddress}) {
    _log(LogLevel.warning, message, tag, printAddress);
  }

  static void e(Object? message, {String? tag, bool? printAddress}) {
    _log(LogLevel.error, message, tag, printAddress);
  }

  static void s(Object? message, {String? tag, bool? printAddress}) {
    _log(LogLevel.success, message, tag, printAddress);
  }

  static void v(Object? message, String tag, {bool? printAddress}) {
    _log(LogLevel.verbose, message, tag, printAddress);
  }

  static void _log(
    LogLevel level,
    Object? message,
    String? tag,
    bool? printAddress,
  ) {
    if (!enabled) return;

    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final tagStr = tag != null ? '[$tag]' : '';
    final addStr = printAddress ?? false ? _getClassFileAndLine() : null;
    final msg =
        '${level != LogLevel.verbose ? tagStr : ''}[$time] ${addStr != null ? [addStr] : ''} ${message.toString()}';

    if (level == LogLevel.verbose) {
      developer.log(msg, name: tag!);
    } else {
      developer.log(msg, name: _getName(level));
    }
    if (showWidget) {
      final newList = List<LogModel>.from(logs.value);
      final widgetMsg =
          '[${level == LogLevel.verbose ? tag : _getName(level)}]  [$time] ${addStr != null ? [addStr] : ''} \n ${message.toString()}';
      newList.add(LogModel(level: level, message: _removeColors(widgetMsg)));
      if (newList.length == 101) {
        newList.removeAt(0);
      }
      logs.value = newList;
      if (scrollController.positions.isNotEmpty &&
          scrollController.position.pixels >=
              scrollController.positions.last.maxScrollExtent) {
        Future.delayed(Duration(milliseconds: 50)).then((_) {
          scrollController.jumpTo(
            scrollController.positions.last.maxScrollExtent,
          );
        });
      }
    }
  }

  static String _removeColors(String message) {
    message = message.replaceAll("\x1B[0m", '');
    message = message.replaceAll("\x1B[31m", '');
    message = message.replaceAll("\x1B[35m", '');
    message = message.replaceAll("\x1B[32m", '');
    message = message.replaceAll("\x1B[33m", '');
    message = message.replaceAll("\x1B[34m", '');
    message = message.replaceAll("\x1B[36m", '');
    return message;
  }

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

class LogModel {
  LogModel({required this.level, required this.message});

  final LogLevel level;
  final String message;
}
