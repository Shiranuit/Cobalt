import 'dart:convert';

import 'package:cobalt/backend.dart';
import 'package:cobalt/storage/backend_storage.dart';
import 'package:cobalt/storage/models/fields.dart';
import 'package:cobalt/storage/models/mapping.dart';
import 'my_service.dart';
import 'test_controller.dart';

void main(List<String> arguments) async {
  Backend backend = Backend();

  Mapping mapping = Mapping([
    Fields('name', [
      Field<String>('first'),
      Field<String>('last'),
    ]),
    Fields('age', [
      Field<int>('years'),
      Field<int>('months'),
      Field<int>('days'),
    ]),
  ]);

  backend.addError(
    errorCode: "math:add_fail",
    message: "Addition failed %s + %s",
    constructor: ApiError.new,
  );

  backend.registerService(MyService());

  backend.registerController(MathController());

  backend.start(
    beforeListeningCallback: () async {
      await backend.storageService.createIndex(
        StorageScope.public,
        'test',
        mapping,
      );
    },
  );
}
