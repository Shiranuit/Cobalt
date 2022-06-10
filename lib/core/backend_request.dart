import 'dart:convert';
import 'dart:io';

import 'package:cobalt/core/backend_response.dart';
import 'package:cobalt/network/multipart_parser.dart';

enum ParamsType { query, body, params }

class PrivateBackendRequest extends BackendRequest {
  PrivateBackendRequest(HttpRequest request) : super(request);

  void setBody(String body) {
    _body = body;
    if (body.isNotEmpty) {
      _bodyParams = jsonDecode(body) as Map<String, dynamic>;
    }
  }

  void setParams(Map<String, String> params) {
    _params = params;
  }

  void setAction(String action) {
    _action = action;
  }

  void setController(String controller) {
    _controller = controller;
  }

  void setMultipartParts(List<MultiPartPart> parts) {
    _multipartParts = parts;
  }
}

class BackendRequest {
  String? _body;
  String? _action;
  String? _controller;
  Map<String, dynamic>? _bodyParams;
  Map<String, String>? _params;
  final HttpRequest _request;
  late final BackendResponse _response;
  List<MultiPartPart>? _multipartParts;

  BackendRequest(this._request) {
    _response = BackendResponse(_request.response);
  }

  /// The corresponding [action] called by the request.
  String get action => _action!;

  /// The corresponding [controller] called by the request.
  String get controller => _controller!;

  /// The [response] of the current request.
  BackendResponse get response => _response;

  /// The original [HttpRequest] before being wrapped.
  HttpRequest get originalRequest => _request;

  /// The [body] of the current request as String.
  String? get bodyString => _body;

  /// The [body] of the current request as Map.
  Map<String, dynamic>? get body => _bodyParams;

  /// The [params] of the current request as Map.
  Map<String, String>? get params => _params;

  /// The verb used to call the controller's action.
  String get method => _request.method;

  /// Get the headers of the HTTP Request.
  HttpHeaders get headers => _request.headers;

  /// Query parameters of the request
  Map<String, String> get queryParams => originalRequest.uri.queryParameters;

  List<MultiPartPart>? get parts => _multipartParts;

  MultiPartPart? getPartByName(String name) {
    if (_multipartParts == null) {
      return null;
    }

    for (MultiPartPart part in _multipartParts!) {
      if (part.name == name) {
        return part;
      }
    }

    return null;
  }

  bool _shouldBeDefaulted(ParamsType type, String name) {
    switch (type) {
      case ParamsType.query:
        return queryParams[name] == null;
      case ParamsType.body:
        return body == null || body![name] == null;
      case ParamsType.params:
        return params == null || params![name] == null;
      default:
        return true;
    }
  }

  T? _parse<T>(String value) {
    switch (T) {
      case Map<String, dynamic>:
        return jsonDecode(value) as T?;
      case List<dynamic>:
        return jsonDecode(value) as T?;
      case bool:
        return (value == 'true') as T?;
      case String:
        return value as T?;
      case double:
        return double.tryParse(value) as T?;
      case int:
        return int.tryParse(value) as T?;
      default:
        return null;
    }
  }

  T _expected<T>(ParamsType paramType, String name, T? value) {
    if (value == null) {
      throw Exception(
        'Expected ${T.toString()} for parameter "$name" but got "${_stringifyValue(paramType, name)}"',
      );
    }
    return value;
  }

  String _stringifyValue(ParamsType paramType, String name) {
    switch (paramType) {
      case ParamsType.query:
        return queryParams[name] ?? '';
      case ParamsType.body:
        return body != null && body![name] != null
            ? body![name]!.toString()
            : '';
      case ParamsType.params:
        return params != null && params![name] != null
            ? params![name]!.toString()
            : '';
      default:
        return '';
    }
  }

  T? _value<T>(ParamsType paramType, String name) {
    switch (paramType) {
      case ParamsType.query:
        return queryParams[name] as T;
      case ParamsType.body:
        return body != null && body![name] != null ? body![name] as T : null;
      case ParamsType.params:
        return params != null && params![name] != null
            ? _parse<T>(params![name]!)
            : null;
      default:
        return null;
    }
  }

  /// Tries to get the value of the parameter [name] from the [ParamsType] category.
  /// If the value is not found, the default value [defaultValue] is returned.
  /// If the value is found but the type does not match, an exception is thrown.
  T? get<T>(ParamsType paramType, String name, {T? defaultValue}) {
    if (_shouldBeDefaulted(paramType, name)) {
      return defaultValue;
    }

    return _expected<T>(
      paramType,
      name,
      _value(paramType, name),
    );
  }
}
