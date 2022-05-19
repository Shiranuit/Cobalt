import 'dart:io';

import 'package:cobalt/errors/error_manager.dart';
import 'package:cobalt/errors/errors.dart';

class HttpStream {
  late Stream<List<int>> stream;
  int? size;
  String? contentType;

  bool busy = false;

  HttpStream(
    this.stream, {
    this.size,
    this.contentType,
  });
}
