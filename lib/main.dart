import 'package:qoshni/bootstrap/bootstrap.dart';
import 'package:qoshni/core/config/app_environment.dart';

/// Default entrypoint → production.
Future<void> main() => bootstrap(AppEnvironment.production);
