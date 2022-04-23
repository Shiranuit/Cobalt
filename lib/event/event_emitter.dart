import 'dart:async';

import 'package:cobalt/extensions/list.dart';

typedef EventListener<T> = FutureOr<void> Function(T event);
typedef PipeListener<T> = FutureOr<T> Function(T event);

/// Interface class
class IEvent {}

class IPipeEvent {}

mixin EventEmitterMixin {
  /// Register an event listener to a type of event
  void on<T extends IEvent>(EventListener<T> listener);

  /// Remove an event listener from a type of event
  void removeListener<T extends IEvent>(EventListener<T> listener);

  /// Emit an async event to all listeners
  Future<void> emit<T extends IEvent>(T event);

  /// Register a pipe listener to a type of event
  void onPipe<T extends IPipeEvent>(PipeListener<T> listener);

  /// Remove a pipe listener from a type of event
  void removePipeListener<T extends IPipeEvent>(PipeListener<T> listener);

  /// Emit a pipe event
  /// The result of each pipe listener will be passed to the next listener
  /// Causing a waterfall effect
  /// If one of the pipes throws an exception, the rest of the pipes will not be called
  FutureOr<T> pipe<T extends IPipeEvent>(T event);
}

class EventEmitter with EventEmitterMixin {
  final Map<Type, List<dynamic>> _eventListeners = {};
  final Map<Type, List<dynamic>> _pipeListeners = {};
  EventEmitter();

  /// Register an event listener to a type of event
  @override
  void on<T extends IEvent>(EventListener<T> listener) {
    _eventListeners.putIfAbsent(T, () => []).addIfAbsent(listener);
  }

  /// Remove an event listener from a type of event
  @override
  void removeListener<T extends IEvent>(EventListener<T> listener) {
    _eventListeners.putIfAbsent(T, () => []).remove(listener);
  }

  /// Emit an async event to all listeners
  @override
  Future<void> emit<T extends IEvent>(T event) async {
    if (!_eventListeners.containsKey(T)) {
      return;
    }

    List<EventListener<T>> events =
        _eventListeners[T]!.cast<EventListener<T>>();

    for (EventListener<T> listener in events) {
      await listener(event);
    }
  }

  /// Register a pipe listener to a type of event
  @override
  void onPipe<T extends IPipeEvent>(PipeListener<T> listener) {
    _pipeListeners.putIfAbsent(T, () => []).addIfAbsent(listener);
  }

  /// Remove a pipe listener from a type of event
  @override
  void removePipeListener<T extends IPipeEvent>(PipeListener<T> listener) {
    _pipeListeners.putIfAbsent(T, () => []).remove(listener);
  }

  /// Emit a pipe event
  /// The result of each pipe listener will be passed to the next listener
  /// Causing a waterfall effect
  /// If one of the pipes throws an exception, the rest of the pipes will not be called
  @override
  FutureOr<T> pipe<T extends IPipeEvent>(T event) async {
    if (!_pipeListeners.containsKey(T)) {
      return event;
    }

    List<PipeListener<T>> listeners =
        _pipeListeners[T]!.cast<PipeListener<T>>();

    if (listeners.isEmpty) {
      return event;
    }

    T result = await listeners[0](event);
    for (int i = 1; i < listeners.length; i++) {
      result = await listeners[i](result);
    }

    return result;
  }
}
