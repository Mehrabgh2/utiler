import 'dart:async';

class Debouncer {
  Debouncer(this.milliseconds);

  final int milliseconds;
  Timer? _timer;

  void call(void Function() action) {
    dispose();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
