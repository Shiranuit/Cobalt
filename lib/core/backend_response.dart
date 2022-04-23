import 'dart:io';

import 'package:cobalt/errors/backend_error.dart';

class BackendResponse {
  late final HttpResponse _response;
  dynamic _result;
  BackendError? _error;
  bool errored = false;

  BackendResponse(HttpResponse response) {
    _response = response;
  }

  /// Original [HttpResponse] of the request.
  HttpResponse get originalResponse => _response;

  /// Set the status code of the request.
  set status(int code) {
    _response.statusCode = code;
  }

  /// Set the result of the request.
  set result(dynamic _result) {
    this._result = _result;
    status = 200;
  }

  /// Get te result of the request
  dynamic get result => _result;

  /// Set the error of the request.
  /// [BackendError] is the only accepted type.
  /// The status of the response will use the status code of the [BackendError].
  set error(BackendError? exception) {
    if (exception == null) {
      return;
    }

    errored = true;
    _error = exception;
    _response.statusCode = exception.statusCode;
  }

  /// Add a header to the response.
  void addHeader(String header, String value) {
    _response.headers.add(header, value);
  }

  /// Add multiples headers to the response
  void addHeaders(Map<String, String> headers) {
    headers.forEach((key, value) {
      _response.headers.add(key, value);
    });
  }

  /// Retrieve the response error.
  BackendError? get error => _error;
}
