import 'package:cobalt/errors/backend_error.dart';

class SecurityError extends BackendError {
  SecurityError(
    String errorCode,
    String message,
  ) : super(
          statusCode: 502,
          errorCode: errorCode,
          message: message,
          type: 'SecurityError',
          stackTrace: StackTrace.current,
        );
}
