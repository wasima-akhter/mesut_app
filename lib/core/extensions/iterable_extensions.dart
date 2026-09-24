extension IterableExtensions<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;

  T? get lastOrNull => isEmpty ? null : last;

  List<T> separatedBy(T separator) {
    if (isEmpty) return [];

    final result = <T>[];

    for (var i = 0; i < length; i++) {
      result.add(elementAt(i));

      if (i != length - 1) {
        result.add(separator);
      }
    }

    return result;
  }
}
