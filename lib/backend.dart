import 'package:cobalt/annotations/backend_annotations.dart';
import 'package:cobalt/core/service/backend_service.dart';

import 'network/router_part.dart';
import 'utils/reflect.dart';

import 'package:cobalt/core/controller/backend_controller.dart';
import 'package:cobalt/errors/backend_error.dart';
import 'package:cobalt/errors/error_manager.dart';
import 'package:cobalt/event/event_emitter.dart';
import 'package:cobalt/network/entrypoint.dart';
import 'package:cobalt/network/router.dart';
import 'backend_error_codes.dart';

export 'package:cobalt/annotations/backend_annotations.dart';
export 'package:cobalt/core/controller/backend_controller.dart';
export 'package:cobalt/core/backend_request.dart';
export 'package:cobalt/event/event.dart';
export 'package:cobalt/errors/errors.dart';

class Backend extends EventEmitter with ErrorManagerMixin, ServiceManagerMixin {
  late final Router _router;
  late final Entrypoint _entrypoint;
  final ErrorManager errorManager = ErrorManager();
  final Map<dynamic, BackendServiceMixin> _services = {};

  Backend() {
    _router = Router(this);
    _entrypoint = Entrypoint(this, _router);

    loadErrorCodes(errorManager);
  }

  /// Start the backend, on the specified [port].
  void start({int port = 8080}) async {
    await _entrypoint.listen(port: port);
  }

  /// Construct a new error from the given [errorCode] and [message].
  /// The error code is used to identify the error and must be unique.
  /// The [message] is used to describe the error, placeholder `%s` can be used
  /// to insert the arguments into the message once an error is thrown or generated.
  @override
  void addError<T extends BackendError>({
    required String errorCode,
    required String message,
    required T Function(String, String) constructor,
  }) {
    errorManager.addError<T>(
      errorCode: errorCode,
      message: message,
      constructor: constructor,
    );
  }

  /// Return a standardized error using the [errorCode] and [args] if given.
  /// [args] are used to replace placeholders `%s` in the error message.
  @override
  BackendError getError(String errorCode, {List<String?>? args}) {
    return errorManager.getError(errorCode, args: args);
  }

  /// Throw a standardized error using the [errorCode] and [args] if given.
  /// [args] are used to replace placeholders `%s` in the error message.
  @override
  void throwError(String errorCode, {List<String?>? args}) {
    errorManager.throwError(errorCode, args: args);
  }

  /// Register a new [controller] and its routes
  void registerController(BackendControllerMixin controller) {
    controller.init(backend: this);

    InstanceMirror mirror = reflect(controller);
    Map<Symbol, MethodMirror> members = mirror.type.instanceMembers;

    ControllerInfo? controllerInfo = Reflect.getControllerAnnotation(mirror);

    String controllerName = MirrorSystem.getName(mirror.type.simpleName);

    if (controllerName.endsWith('Controller')) {
      controllerName = controllerName.substring(
        0,
        controllerName.length - 'Controller'.length,
      );
    }

    for (MapEntry<Symbol, MethodMirror> entry in members.entries) {
      List<RouteMetadata> metadata = Reflect.listRouteMetadata(entry.value);

      List<RouteAnnotation> annotations =
          metadata.whereType<RouteAnnotation>().toList();

      if (annotations.isEmpty) {
        continue;
      }

      if (!Reflect.isValidRouteMethod(entry.value)) {
        throw Exception(
          'Route method "${entry.key}" of ${controller.runtimeType.toString()} instance should match Function(BackendRequest)',
        );
      }

      for (RouteAnnotation annotation in annotations) {
        List<String> path = [];

        path.add(controllerInfo?.path ?? controllerName.toLowerCase());
        path.add(annotation.path ?? MirrorSystem.getName(entry.key));

        final String buildedPath = path
            .map((e) {
              if (e.startsWith('/')) {
                return e.substring(1);
              }
              return e;
            })
            .where((element) => element.isNotEmpty)
            .join('/');

        print("Add route ${annotation.verb} /$buildedPath");

        RouterPart part = _router.add(
          verb: annotation.verb,
          path: "/$buildedPath",
          handler: mirror.getField(entry.key).reflectee as RouteHandler,
          controller: controllerName.toLowerCase(),
          action: MirrorSystem.getName(entry.value.simpleName).toLowerCase(),
        );

        entry.value.metadata
            .where((element) => element.type.isSubtypeOf(routeMetadataType))
            .forEach((element) {
          part.metadata[element.reflectee.runtimeType] = element.reflectee;
        });
      }
    }
  }

  /// Register a new instance of a service
  @override
  void registerService<T extends BackendServiceMixin>(T service) {
    if (_services.containsKey(T)) {
      throw Exception('Service already registered');
    }
    _services[T] = service;
    service.init(backend: this);
  }

  /// Access an instance of a service
  @override
  T? getService<T extends BackendServiceMixin>() {
    BackendServiceMixin? service = _services[T];
    if (service == null) {
      return null;
    }
    return service as T;
  }
}
