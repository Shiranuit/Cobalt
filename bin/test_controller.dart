import 'dart:io';

import 'package:cobalt/backend.dart';
import 'package:cobalt/network/http_stream.dart';
import 'package:cobalt/network/multipart_parser.dart';

import 'my_service.dart';

@ControllerInfo(path: '')
class MathController with BackendControllerMixin {
  @Get(path: '/:first/:second')
  int add(BackendRequest request) {
    return request.get<int>(ParamsType.params, 'first')! +
        request.get<int>(ParamsType.params, 'second')!;
  }

  @Post()
  void failParse(BackendRequest request) {}

  @Post()
  void upload(BackendRequest request) {
    if (request.parts != null) {
      for (MultiPartPart part in request.parts!) {
        print(part.name);
        print(part.isFile);
        print(part.filename);
        print(part.contentType);
        print(part.contentDisposition);
        print(part.contentAsString());
        print('-------');
      }
    }
  }

  @Get()
  HttpStream download(BackendRequest request) {
    return HttpStream(
      File('./bin/heatap.png').openRead(),
      contentType: 'image/png',
    );
  }

  @Get()
  void date(BackendRequest request) {
    print(backend.decode(backend.encode({'date': DateTime.now()})));
  }
}
