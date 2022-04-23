import 'package:cobalt/backend.dart';

/// Annotation for [BackendController] classes.
/// The annotation is used configure how the routes of the controller must
/// be generated.
class ControllerInfo {
  final String? path;
  const ControllerInfo({this.path});
}
