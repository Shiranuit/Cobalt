import 'package:cobalt/backend.dart';
import 'package:cobalt/core/service/backend_service.dart';

class MyService with BackendServiceMixin {
  void printMessage() {
    print('HELLO');
  }
}
