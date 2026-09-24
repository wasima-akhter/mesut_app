import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionNotifier<T> extends Notifier<T?> {
  SelectionNotifier(this.initialValue);

  final T? initialValue;

  @override
  T? build() {
    return initialValue;
  }

  void select(T value) {
    state = value;
  }

  void clear() {
    state = null;
  }
}
