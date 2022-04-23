import 'package:cobalt/backend.dart';

/// A controller is a class that can be used to handle requests.
/// Each public method of a controller can be used to handle a request.
/// The method name is used as the path of the request.
/// The path of a request is a combination of the controller (name or path) and method (name or path).
/// The method must have a [BackendRequest] as the first parameter.
/// The method must return a [Future] or a [dynamic].
/// Routes can be added to a controller by using the [Get],[Post],[Delete],[Put],[Patch] annotation.
mixin BackendControllerMixin {
  late Backend backend;

  /// Initialize the controller
  /// Called by the backend when the controller is added to the backend.
  void init({required Backend backend}) async {
    this.backend = backend;
  }
}
