import 'package:meta/meta.dart';
import 'package:cobalt/backend.dart';

/// Internal class used to add a module to the backend.
abstract class BackendModule {
  @protected
  final Backend backend;
  BackendModule(this.backend);

  void init();
}
