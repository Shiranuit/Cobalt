import 'package:cobalt/backend.dart';
import 'package:cobalt/utils/json_encoder.dart';

import 'my_service.dart';
import 'test_controller.dart';

class DateTimeSerialize extends JsonSerializer<DateTime> {
  @override
  DateTime fromJson(Object? key, Object? value) {
    return DateTime.parse(value as String);
  }

  @override
  bool test(Object? key, Object? value) {
    return value != null && value is String && DateTime.tryParse(value) != null;
  }

  @override
  Object? toJson(DateTime value) {
    return value.toIso8601String();
  }
}

void main(List<String> arguments) {
  Backend backend = Backend();

  backend.addError(
    errorCode: "math:add_fail",
    message: "Addition failed %s + %s",
    constructor: ApiError.new,
  );

  backend.registerService(MyService());

  backend.registerController(MathController());

  backend.addSerializer(DateTimeSerialize());

  backend.start();
}
