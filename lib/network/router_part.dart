import 'dart:core';

import 'package:cobalt/annotations/route_annotations.dart';

enum PathType {
  /// A path that is a simple string.
  static,

  /// A path that is a string with a wildcard.
  templated,
}

class RouterTemplate {
  /// The name of the template
  final String name;

  /// The index of the template in the path when splitted on /
  final int idx;

  /// The type of the template, either static or templated
  final PathType type;

  final String? value;

  RouterTemplate({
    required this.name,
    required this.idx,
    required this.type,
    this.value,
  });

  @override
  String toString() {
    return 'RouterTemplate{name: $name, idx: $idx, type: $type, value: $value}';
  }
}

class RouterPart {
  PathType type;
  String path;
  List<RouterTemplate> templates;
  Function? handler;
  String controller = "";
  String action = "";
  Map<dynamic, RouteMetadata> metadata = {};

  void setMetadata<T extends RouteMetadata>(T annotation) {
    metadata[T] = annotation;
  }

  T? getMetadata<T extends RouteMetadata>() {
    RouteMetadata? meta = metadata[T];
    if (meta == null) {
      return null;
    }
    return meta as T;
  }

  RouterPart._({
    required this.type,
    required this.path,
    required this.templates,
    this.handler,
  });

  bool match(String path) {
    String _path = _sanitizePath(path);
    if (type == PathType.static) {
      return _path == this.path;
    } else {
      List<String> parts = _path.split('/');
      if (parts.length != templates.length) {
        return false;
      }

      for (RouterTemplate template in templates) {
        if (template.type == PathType.static) {
          if (parts[template.idx] != template.name) {
            return false;
          }
          continue;
        }
      }
    }
    return true;
  }

  Map<String, String>? getParams(String path) {
    if (type == PathType.static) {
      return null;
    }

    Map<String, String> params = {};
    List<String> parts = _sanitizePath(path).split('/');
    if (parts.length != templates.length) {
      return null;
    }

    for (RouterTemplate template in templates) {
      if (template.type == PathType.static &&
          template.name != parts[template.idx]) {
        return null;
      }

      if (template.type == PathType.templated) {
        params[template.name] = Uri.decodeComponent(parts[template.idx]);
      }
    }

    return params;
  }

  static RouterPart parse(String path, Function? handler,
      {Map<String, dynamic>? metadata}) {
    String sanitizedPath = _sanitizePath(path);

    PathType pathType = PathType.static;
    List<RouterTemplate> templates = [];
    List<String> parts = sanitizedPath.split('/');
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].startsWith(':')) {
        pathType = PathType.templated;
        templates.add(RouterTemplate(
          name: parts[i].substring(1),
          idx: i,
          type: PathType.templated,
        ));
      } else {
        templates.add(RouterTemplate(
          name: parts[i],
          idx: i,
          type: PathType.static,
        ));
      }
    }

    return RouterPart._(
      type: pathType,
      path: sanitizedPath,
      templates: templates,
      handler: handler,
    );
  }

  @override
  String toString() {
    return 'RouterPart{type: $type, path: $path, templates: $templates}';
  }

  static String _sanitizePath(String path) {
    return path.split('/').where((part) => part.isNotEmpty).join('/');
  }
}
