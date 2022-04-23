import 'package:cobalt/errors/backend_error.dart';

class ApiError extends BackendError {
  ApiError(
    String errorCode,
    String message,
  ) : super(
          statusCode: 504,
          errorCode: errorCode,
          message: message,
          type: 'ApiError',
          stackTrace: StackTrace.current,
        );
}
