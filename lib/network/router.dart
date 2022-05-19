import 'dart:async';
import 'dart:convert';

import 'package:cobalt/backend.dart';
import 'package:cobalt/backend_module.dart';
import 'package:cobalt/errors/error_manager.dart';
import 'package:cobalt/network/multipart_parser.dart';
import 'package:cobalt/network/router_part.dart';

class Routes {
  final List<RouterPart> _staticParts = [];
  final List<RouterPart> _templatedParts = [];
}

typedef RouteHandler = dynamic Function(BackendRequest);

class Router extends BackendModule {
  final Map<String, Routes> _routes = {};

  Router(Backend backend) : super(backend);

  @override
  void init() {}

  RouterPart add({
    required String verb,
    required String path,
    required RouteHandler handler,
    required String controller,
    required String action,
  }) {
    RouterPart part = RouterPart.parse(path, handler);
    part.action = action;
    part.controller = controller;

    Routes? routes = _routes[verb.toLowerCase()];
    if (routes == null) {
      _routes[verb.toLowerCase()] = (routes = Routes());
    }

    if (part.type == PathType.static) {
      int index = routes._staticParts.indexWhere(
        (element) => element.path == part.path,
      );

      if (index > -1) {
        throw Exception(
          'Duplicate static route: ${verb.toUpperCase()} $path',
        );
      }

      routes._staticParts.add(part);
    } else {
      int index = routes._templatedParts.indexWhere(
        (element) => element.path == part.path,
      );

      if (index > -1) {
        throw Exception(
          'Duplicate templated route: ${verb.toUpperCase()} $path',
        );
      }

      routes._templatedParts.add(part);
    }
    return part;
  }

  RouterPart? match(String verb, String path) {
    Routes? routes = _routes[verb.toLowerCase()];
    if (routes == null) {
      return null;
    }

    for (RouterPart part in routes._staticParts) {
      if (part.match(path)) {
        return part;
      }
    }

    for (RouterPart part in routes._templatedParts) {
      if (part.match(path)) {
        return part;
      }
    }

    return null;
  }

  Future<void> execute(PrivateBackendRequest request) async {
    RouterPart? part = match(request.method, request.originalRequest.uri.path);

    if (part == null) {
      request.response.error = backend.getError('api:not_found', args: [
        request.method.toUpperCase(),
        request.originalRequest.uri.path
      ]);
      return;
    }

    request.setController(part.controller);
    request.setAction(part.action);

    Map<String, String>? params = part.getParams(
      request.originalRequest.uri.path,
    );

    if (params != null) {
      request.setParams(params);
    }

    try {
      if (request.headers.contentType?.primaryType == 'multipart' &&
          request.headers.contentType?.subType == 'form-data') {
        String? boundary = request.headers.contentType?.parameters['boundary'];
        if (boundary == null) {
          throw Exception('Missing boundary in multipart/form-data');
        }

        List<int> data = [];
        Completer<void> completer = Completer();
        request.originalRequest.listen(data.addAll, onDone: () {
          request.setMultipartParts(MultiPartParser.parse('--$boundary', data));
          completer.complete();
        });
        await completer.future;
      } else if (part.getMetadata<NoInputParse>() == null) {
        String body = await utf8.decodeStream(request.originalRequest);
        request.setBody(body);
      }
      BeforeRequestProcessingEvent beforeProcessing =
          await backend.pipe(BeforeRequestProcessingEvent(request));

      dynamic result = await part.handler!(beforeProcessing.request);
      request.response.result = result;

      await backend.pipe(AfterRequestProcessingEvent(request));
    } catch (error) {
      request.response.error = ErrorManager.wrapError(error);
    }
  }
}
