import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/features/home/presentation/pages/home_page.dart';
import 'package:qoshni/features/home/presentation/pages/map_placeholder_page.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/pages/business_detail_page.dart';
import 'package:qoshni/features/home/presentation/pages/favorites_page.dart';
import 'package:qoshni/features/home/presentation/pages/profile_page.dart';
import 'package:qoshni/features/home/presentation/pages/category_listing_page.dart';
import 'package:qoshni/features/home/presentation/pages/search_page.dart';
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
      GoRoute(
        path: RoutePaths.map,
        name: RouteNames.map,
        builder: (context, state) => const MapPlaceholderPage(),
      ),
      GoRoute(
        path: RoutePaths.search,
        name: RouteNames.search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: RoutePaths.categoryListing,
        name: RouteNames.categoryListing,
        builder: (context, state) {
          final categoryId = tryParseServiceCategoryId(
            state.pathParameters['categoryId'],
          );
          return CategoryListingPage(categoryId: categoryId);
        },
      ),
      GoRoute(
        path: RoutePaths.businessDetail,
        name: RouteNames.businessDetail,
        builder: (context, state) {
          final businessId = tryParseMockBusinessId(
            state.pathParameters['businessId'],
          );
          return BusinessDetailPage(businessId: businessId);
        },
      ),
      GoRoute(
        path: RoutePaths.favorites,
        name: RouteNames.favorites,
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfilePage(),
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
