import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/features/home/presentation/pages/home_page.dart';
import 'package:qoshni/routing/route_paths.dart';

/// Application router. Add feature routes here as modules are introduced.
class AppRouter {
  AppRouter({required AppLogger this._logger});

  final AppLogger _logger;

  late final GoRouter router = GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    observers: [_LoggingNavigatorObserver(_logger)],
    routes: [
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}

class _LoggingNavigatorObserver extends NavigatorObserver {
  _LoggingNavigatorObserver(this._logger);

  final AppLogger _logger;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logger.debug('Nav push: ${route.settings.name ?? route.settings}');
  }
}
