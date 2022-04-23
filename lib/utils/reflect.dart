export 'dart:mirrors';
import 'dart:mirrors';
import 'package:cobalt/annotations/backend_annotations.dart';
import 'package:cobalt/core/backend_request.dart';

final TypeMirror routeMetadataType = reflectType(RouteMetadata);
final TypeMirror controllerAnnotationType = reflectType(ControllerInfo);
final TypeMirror backendrequestType = reflectType(BackendRequest);

class Reflect {
  static List<RouteMetadata> listRouteMetadata(MethodMirror method) {
    return method.metadata
        .where((element) => element.type.isSubtypeOf(routeMetadataType))
        .map((e) => e.reflectee as RouteMetadata)
        .toList();
  }

  static bool isValidRouteMethod(MethodMirror method) {
    if (method.parameters.isEmpty) {
      return false;
    }

    return method.parameters.first.type.isSubtypeOf(backendrequestType);
  }

  static ControllerInfo? getControllerAnnotation(InstanceMirror instance) {
    final List<InstanceMirror> metadata = instance.type.metadata;
    int index = metadata.indexWhere(
        (element) => element.type.isSubtypeOf(controllerAnnotationType));

    if (index == -1) {
      return null;
    }

    return metadata[index].reflectee as ControllerInfo;
  }
}
