import 'dart:core';

extension ListExtension<T> on List<T> {
  void addIfAbsent(T element) {
    if (!contains(element)) {
      add(element);
    }
  }
}
