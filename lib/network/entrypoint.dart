import 'dart:convert';
import 'dart:io';

import 'package:cobalt/backend.dart';
import 'package:cobalt/backend_module.dart';
import 'package:cobalt/core/backend_response.dart';
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
    response.addHeader('Content-Type', 'application/json');
    response.addHeader('Access-Control-Allow-Origin', '*');
    response.addHeader(
        'Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    response.addHeader('Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept, Authorization');
    response.addHeader('Access-Control-Allow-Credentials', 'true');
  }

  void sendResponse(BackendRequest request) {
    HttpResponse response = request.response.originalResponse;

    addDefaultHeaders(request, request.response);

    if (request.response.errored) {
      response.write(jsonEncode({'error': request.response.error!.toJson()}));
      response.close();
      return;
    }

    String json = jsonEncode({'result': request.response.result});
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
