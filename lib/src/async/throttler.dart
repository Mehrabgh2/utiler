import 'dart:async';

class Throttler {
  Throttler(this.intervalMilliseconds);

  final int intervalMilliseconds;
  bool _ready = true;

  void call(void Function() action) {
    if (!_ready) return;
    _ready = false;
    action();
    Timer(Duration(milliseconds: intervalMilliseconds), () => _ready = true);
  }
}
