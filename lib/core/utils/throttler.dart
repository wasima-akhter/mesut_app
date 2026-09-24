import 'dart:async';

class Throttler {
  Throttler({this.duration = const Duration(milliseconds: 500)});

  final Duration duration;

  Timer? _timer;

  void run(void Function() action) {
    if (_timer?.isActive ?? false) {
      return;
    }

    action();

    _timer = Timer(duration, () {});
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
