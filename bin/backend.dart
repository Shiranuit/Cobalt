import 'package:cobalt/backend.dart';

import 'my_service.dart';
import 'test_controller.dart';

void main(List<String> arguments) {
  Backend backend = Backend();

  backend.addError(
    errorCode: "math:add_fail",
    message: "Addition failed %s + %s",
    constructor: ApiError.new,
  );

  backend.registerService(MyService());

  backend.registerController(MathController());

  backend.start();
}
