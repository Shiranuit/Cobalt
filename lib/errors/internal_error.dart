import 'package:cobalt/errors/backend_error.dart';

class InternalError extends BackendError {
  InternalError(
    String? errorCode,
    String message,
  ) : super(
          statusCode: 500,
          errorCode: errorCode,
          message: message,
          stackTrace: StackTrace.current,
          type: 'InternalError',
        );
}
