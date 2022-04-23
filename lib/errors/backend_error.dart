class BackendError implements Exception {
  int statusCode;
  String? errorCode;
  String message;
  StackTrace? stackTrace;
  String type;

  BackendError({
    required this.statusCode,
    required this.message,
    this.errorCode,
    this.type = 'BackendError',
    StackTrace? stackTrace,
  }) {
    this.stackTrace = stackTrace ?? StackTrace.current;
  }

  @override
  String toString() {
    return '$message\n${stackTrace.toString()}';
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'errorCode': errorCode,
      'message': message,
      'stackTrace': stackTrace.toString(),
      'type': type,
    };
  }
}
