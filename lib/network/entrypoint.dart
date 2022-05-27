import 'dart:convert';
import 'dart:io';

import 'package:cobalt/backend.dart';
import 'package:cobalt/backend_module.dart';
import 'package:cobalt/core/backend_response.dart';
import 'package:cobalt/errors/error_manager.dart';
import 'package:cobalt/network/http_stream.dart';
import 'package:cobalt/network/router.dart';

class Entrypoint extends BackendModule {
  HttpServer? server;
  Router router;

  Entrypoint(Backend backend, this.router) : super(backend);

  @override
  void init() {}

  Future<void> listen({int port = 8080}) async {
    server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    print('Listening on port: $port');

    server!.listen(_onHTTPRequest);
    backend.emit(AfterStartListingEvent());
  }

  void addDefaultHeaders(BackendRequest request, BackendResponse response) {
    response.addHeader('Access-Control-Allow-Origin', '*');
    response.addHeader(
        'Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    response.addHeader('Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept, Authorization');
    response.addHeader('Access-Control-Allow-Credentials', 'true');
  }

  void sendHttpStream(BackendRequest request, HttpStream stream) {
    HttpResponse response = request.response.originalResponse;

    if (stream.busy) {
      response.headers.add('Content-Type', 'application/json');
      response.write(backend.encode({
        'error': InternalError(null, 'Stream busy, cannot use it while busy')
            .toJson()
      }));
      response.close();
      return;
    }

    if (stream.contentType != null) {
      response.headers.add('Content-Type', stream.contentType!);
    }
    if (stream.size != null) {
      response.headers.add('Content-Length', stream.size!);
    }
    response.headers.add('Transfer-Encoding', 'Chunked');

    stream.busy = true;
    bool writeStarted = false;
    stream.stream.listen((List<int> data) {
      response.add(data);
      writeStarted = true;
    }, onDone: () {
      response.close();
    }, onError: (error) {
      if (!writeStarted) {
        response.headers.clear();
        addDefaultHeaders(request, request.response);
        response.headers.add('Content-Type', 'application/json');
      } else {
        print(error);
      }

      response.write(backend.encode(
        {'error': ErrorManager.wrapError(error).toJson()},
      ));
      response.close();
    }, cancelOnError: true);
  }

  void sendResponse(BackendRequest request) {
    HttpResponse response = request.response.originalResponse;

    addDefaultHeaders(request, request.response);

    if (request.response.errored) {
      response.headers.add('Content-Type', 'application/json');
      response
          .write(backend.encode({'error': request.response.error!.toJson()}));
      response.close();
      return;
    }

    if (request.response.result is HttpStream) {
      sendHttpStream(request, request.response.result as HttpStream);
      return;
    }
    String? json;
    try {
      response.headers.add('Content-Type', 'application/json');
      json = backend.encode({'result': request.response.result});
    } catch (error) {
      response.headers.add('Content-Type', 'application/json');
      response.write(backend.encode(
        {'error': ErrorManager.wrapError(error).toJson()},
      ));
      response.close();
      return;
    }
    response.write(json);
    response.close();
  }

  void _onHTTPRequest(HttpRequest request) {
    PrivateBackendRequest _request = PrivateBackendRequest(request);

    Future(() async {
      await router.execute(_request);
      sendResponse(_request);
    });
  }

  void stop() {
    server?.close();
  }
}
