import 'package:cobalt/errors/error_manager.dart';
import 'package:cobalt/errors/internal_error.dart';

import 'errors/api_error.dart';

void loadErrorCodes(ErrorManager errorManager) {
  errorManager.addError(
    errorCode: 'api:not_found',
    message: 'Route %s %s doest not exists',
    constructor: ApiError.new,
  );
}
