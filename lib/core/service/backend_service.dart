import 'package:cobalt/backend.dart';

mixin BackendServiceMixin {
  late Backend backend;

  /// Initialize the service
  /// Called by the backend when the service is added to the backend.
  void init({required Backend backend}) async {
    this.backend = backend;
  }
}

mixin ServiceManagerMixin {
  /// Register a new instance of a service
  void registerService<T extends BackendServiceMixin>(T service);

  /// Access an instance of a service
  T? getService<T extends BackendServiceMixin>();
}
