/// Mixin used to create new annotations for routes.
mixin RouteMetadata {}

class RouteAnnotation with RouteMetadata {
  final String? path;
  final String verb;

  const RouteAnnotation(
    this.verb, {
    this.path,
  });
}

/// Annotation used to generate a Get route.
/// If a [path] is given, the route will be generated with the given path
/// instead of the method name.
class Get extends RouteAnnotation {
  const Get({String? path}) : super('GET', path: path);
}

/// Annotation used to generate a Post route.
/// If a [path] is given, the route will be generated with the given path
/// instead of the method name.
class Post extends RouteAnnotation {
  const Post({String? path}) : super('POST', path: path);
}

/// Annotation used to generate a Delete route.
/// If a [path] is given, the route will be generated with the given path
/// instead of the method name.
class Delete extends RouteAnnotation {
  const Delete({String? path}) : super('DELETE', path: path);
}

/// Annotation used to generate a Put route.
/// If a [path] is given, the route will be generated with the given path
/// instead of the method name.
class Put extends RouteAnnotation {
  const Put({String? path}) : super('PUT', path: path);
}

/// Annotation used to generate a Patch route.
/// If a [path] is given, the route will be generated with the given path
/// instead of the method name.
class Patch extends RouteAnnotation {
  const Patch({String? path}) : super('PATCH', path: path);
}

/// Annotation used to generate to prevent the backend from parsing the request input.
/// This is useful when the request input is not a JSON object.
/// You can use this annotation to parse the request input manually.
class NoInputParse with RouteMetadata {
  const NoInputParse();
}
