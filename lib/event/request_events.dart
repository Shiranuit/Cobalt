import 'package:cobalt/core/backend_request.dart';
import 'package:cobalt/event/event_emitter.dart';

/// Before the request is processed, this event is emitted.
class BeforeRequestProcessingEvent with IPipeEvent {
  final BackendRequest request;

  BeforeRequestProcessingEvent(this.request);
}

/// After the request has been processed, this event is emitted.
/// Modification to the request will be executed before sending the result to the client.
class AfterRequestProcessingEvent with IPipeEvent {
  final BackendRequest request;

  AfterRequestProcessingEvent(this.request);
}
