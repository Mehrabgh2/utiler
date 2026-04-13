import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'log_level.dart';
import 'logger.dart';

class LoggerConsole extends StatefulWidget {
  const LoggerConsole({required this.child, super.key});
  final Widget child;

  @override
  State<LoggerConsole> createState() => _LoggerConsoleState();
}

class _LoggerConsoleState extends State<LoggerConsole> {
  bool isShow = false;
  bool isShowFab = false;
  bool dEnabled = false;
  bool iEnabled = false;
  bool wEnabled = false;
  bool eEnabled = false;
  bool sEnabled = false;
  bool vEnabled = false;

  @override
  void initState() {
    Logger.scrollController.addListener(() {
      if (Logger.scrollController.positions.isNotEmpty &&
          Logger.scrollController.position.pixels >=
              Logger.scrollController.positions.last.maxScrollExtent) {
        isShowFab = false;
      } else {
        isShowFab = true;
      }
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        widget.child,
        AnimatedPositioned(
          bottom: isShow ? 0 : -size.height * .5,
          duration: const Duration(milliseconds: 400),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: size.width,
                height: size.height * .5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white.withValues(alpha: 0.07),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isShow = false;
                            });
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.black87,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        _chip('d', () {
                          setState(() {
                            dEnabled = !dEnabled;
                          });
                        }, dEnabled ? _getColor(LogLevel.debug) : null),
                        _chip('i', () {
                          setState(() {
                            iEnabled = !iEnabled;
                          });
                        }, iEnabled ? _getColor(LogLevel.info) : null),
                        _chip('w', () {
                          setState(() {
                            wEnabled = !wEnabled;
                          });
                        }, wEnabled ? _getColor(LogLevel.warning) : null),
                        _chip('e', () {
                          setState(() {
                            eEnabled = !eEnabled;
                          });
                        }, eEnabled ? _getColor(LogLevel.error) : null),
                        _chip('s', () {
                          setState(() {
                            sEnabled = !sEnabled;
                          });
                        }, sEnabled ? _getColor(LogLevel.success) : null),
                        _chip('v', () {
                          setState(() {
                            vEnabled = !vEnabled;
                          });
                        }, vEnabled ? _getColor(LogLevel.verbose) : null),
                        IconButton(
                          onPressed: () {
                            Logger.logs.value = [];
                          },
                          icon: Icon(Icons.delete, color: Colors.black87),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 15,
                          right: 15,
                          bottom: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .65),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ValueListenableBuilder<List<LogModel>>(
                          valueListenable: Logger.logs,
                          builder: (context, value, child) {
                            List<LogModel> list = _getList(value);
                            return ScrollbarTheme(
                              data: ScrollbarThemeData(
                                thumbColor: WidgetStateColor.resolveWith(
                                  (states) => Colors.grey,
                                ),
                                trackColor: WidgetStateColor.resolveWith(
                                  (states) => Colors.grey.withValues(alpha: .2),
                                ),
                                radius: Radius.circular(100),
                              ),
                              child: list.isEmpty
                                  ? Center(
                                      child: Text(
                                        "Nothing to show",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 20,
                                        ),
                                      ),
                                    )
                                  : Scrollbar(
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      controller: Logger.scrollController,
                                      interactive: true,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              controller:
                                                  Logger.scrollController,
                                              physics: const BouncingScrollPhysics(
                                                parent:
                                                    AlwaysScrollableScrollPhysics(),
                                              ),
                                              itemCount: list.length,
                                              itemBuilder: (context, index) {
                                                return _logRow(list[index]);
                                              },
                                            ),
                                          ),
                                          if (isShowFab)
                                            Positioned(
                                              bottom: 10,
                                              right: 10,
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        100,
                                                      ),
                                                  color: Colors.black,
                                                ),
                                                child: FittedBox(
                                                  child: IconButton(
                                                    onPressed: () {
                                                      Logger.scrollController
                                                          .animateTo(
                                                            Logger
                                                                .scrollController
                                                                .positions
                                                                .last
                                                                .maxScrollExtent,
                                                            duration:
                                                                const Duration(
                                                                  milliseconds:
                                                                      500,
                                                                ),
                                                            curve: Curves
                                                                .easeInOut,
                                                          );
                                                    },
                                                    icon: Icon(
                                                      Icons
                                                          .keyboard_arrow_down_rounded,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          bottom: isShow ? -100 : 20,
          left: 20,
          duration: const Duration(milliseconds: 500),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white.withValues(alpha: 0.07),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isShow = true;
                    });
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String text, VoidCallback onTap, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: color ?? Colors.black54,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            width: 30,
            height: 30,
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: color == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logRow(LogModel log) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: GestureDetector(
        onDoubleTap: () {
          Clipboard.setData(ClipboardData(text: log.message.split('\n')[1]));
        },
        child: Text.rich(
          TextSpan(
            text: log.message.split('\n')[0],
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            children: [
              TextSpan(
                text: log.message.split('\n')[1],
                style: TextStyle(color: _getColor(log.level), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<LogModel> _getList(List<LogModel> logs) {
    if (!dEnabled &&
        !iEnabled &&
        !wEnabled &&
        !eEnabled &&
        !sEnabled &&
        !vEnabled) {
      return logs;
    }
    List<LogModel> filtered = [];
    if (dEnabled) {
      filtered.addAll(logs.where((element) => element.level == LogLevel.debug));
    }
    if (iEnabled) {
      filtered.addAll(logs.where((element) => element.level == LogLevel.info));
    }
    if (wEnabled) {
      filtered.addAll(
        logs.where((element) => element.level == LogLevel.warning),
      );
    }
    if (eEnabled) {
      filtered.addAll(logs.where((element) => element.level == LogLevel.error));
    }
    if (sEnabled) {
      filtered.addAll(
        logs.where((element) => element.level == LogLevel.success),
      );
    }
    if (vEnabled) {
      filtered.addAll(
        logs.where((element) => element.level == LogLevel.verbose),
      );
    }
    return filtered;
  }

  static Color _getColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.blue;
      case LogLevel.info:
        return Colors.cyan;
      case LogLevel.warning:
        return Colors.amber;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.success:
        return Colors.green;
      case LogLevel.verbose:
        return Colors.deepPurpleAccent;
    }
  }
}
