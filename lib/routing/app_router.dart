import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/features/home/presentation/pages/home_page.dart';
import 'package:qoshni/features/home/presentation/pages/map_placeholder_page.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';
import 'package:qoshni/features/home/presentation/pages/business_detail_page.dart';
import 'package:qoshni/features/home/presentation/cart/demo_order_snapshot.dart';
import 'package:qoshni/features/home/presentation/pages/cart_page.dart';
import 'package:qoshni/features/home/presentation/pages/checkout_page.dart';
import 'package:qoshni/features/home/presentation/pages/demo_order_confirmation_page.dart';
import 'package:qoshni/features/home/presentation/pages/demo_order_detail_page.dart';
import 'package:qoshni/features/home/presentation/pages/demo_orders_page.dart';
import 'package:qoshni/features/home/presentation/pages/catalog_item_detail_page.dart';
import 'package:qoshni/features/home/presentation/pages/favorites_page.dart';
import 'package:qoshni/features/home/presentation/pages/profile_page.dart';
import 'package:qoshni/features/home/presentation/pages/category_listing_page.dart';
import 'package:qoshni/features/home/presentation/pages/search_page.dart';
import 'package:qoshni/features/business_platform/domain/business_profile_draft.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_center_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_profile_detail_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_inventory_edit_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_inventory_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_offering_form_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_profile_form_page.dart';
import 'package:qoshni/features/auth/presentation/pages/auth_sessions_page.dart';
import 'package:qoshni/features/auth/presentation/pages/auth_sign_in_page.dart';
import 'package:qoshni/features/business_onboarding/presentation/pages/onboarding_application_page.dart';
import 'package:qoshni/features/business_onboarding/presentation/pages/onboarding_hub_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_owner_profile_editor_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_owner_profile_overview_page.dart';
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
        routes: [
          GoRoute(
            path: 'catalog/:catalogItemId',
            name: RouteNames.catalogItemDetail,
            builder: (context, state) {
              final businessId = tryParseMockBusinessId(
                state.pathParameters['businessId'],
              );
              final catalogItemId = tryParseMockCatalogItemId(
                state.pathParameters['catalogItemId'],
              );
              return CatalogItemDetailPage(
                businessId: businessId,
                catalogItemId: catalogItemId,
              );
            },
          ),
        ],
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
        routes: [
          GoRoute(
            path: 'sign-in',
            name: RouteNames.authSignIn,
            builder: (context, state) => const AuthSignInPage(),
          ),
          GoRoute(
            path: 'sessions',
            name: RouteNames.authSessions,
            builder: (context, state) => const AuthSessionsPage(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.cart,
        name: RouteNames.cart,
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: RoutePaths.checkout,
        name: RouteNames.checkout,
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: RoutePaths.demoOrderConfirmation,
        name: RouteNames.demoOrderConfirmation,
        builder: (context, state) {
          final extra = state.extra;
          return DemoOrderConfirmationPage(
            snapshot: extra is DemoOrderSnapshot ? extra : null,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.demoOrders,
        name: RouteNames.demoOrders,
        builder: (context, state) => const DemoOrdersPage(),
        routes: [
          GoRoute(
            path: ':referenceId',
            name: RouteNames.demoOrderDetail,
            builder: (context, state) {
              return DemoOrderDetailPage(
                referenceId: state.pathParameters['referenceId'],
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.businessCenter,
        name: RouteNames.businessCenter,
        builder: (context, state) => const BusinessCenterPage(),
        routes: [
          GoRoute(
            path: 'onboarding',
            name: RouteNames.businessOnboardingHub,
            builder: (context, state) => const OnboardingHubPage(),
            routes: [
              GoRoute(
                path: ':applicationId',
                name: RouteNames.businessOnboardingApplication,
                builder: (context, state) {
                  return OnboardingApplicationPage(
                    applicationId: state.pathParameters['applicationId']!,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'business-profile',
            name: RouteNames.businessOwnerProfile,
            builder: (context, state) =>
                const BusinessOwnerProfileOverviewPage(),
            routes: [
              GoRoute(
                path: 'edit',
                name: RouteNames.businessOwnerProfileEdit,
                builder: (context, state) =>
                    const BusinessOwnerProfileEditorPage(),
              ),
            ],
          ),
          GoRoute(
            path: 'profile/new',
            name: RouteNames.businessProfileCreate,
            builder: (context, state) {
              final extra = state.extra;
              return BusinessProfileFormPage(
                seed: extra is BusinessProfileFormSeed ? extra : null,
              );
            },
          ),
          GoRoute(
            path: 'profile/:profileId',
            name: RouteNames.businessProfileDetail,
            builder: (context, state) {
              return BusinessProfileDetailPage(
                profileId: state.pathParameters['profileId'],
              );
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: RouteNames.businessProfileEdit,
                builder: (context, state) {
                  return BusinessProfileFormPage(
                    draftId: state.pathParameters['profileId'],
                  );
                },
              ),
              GoRoute(
                path: 'offerings/new',
                name: RouteNames.businessOfferingCreate,
                builder: (context, state) {
                  return BusinessOfferingFormPage(
                    profileId: state.pathParameters['profileId'],
                  );
                },
              ),
              GoRoute(
                path: 'offerings/:offeringId/edit',
                name: RouteNames.businessOfferingEdit,
                builder: (context, state) {
                  return BusinessOfferingFormPage(
                    profileId: state.pathParameters['profileId'],
                    offeringId: state.pathParameters['offeringId'],
                  );
                },
              ),
              GoRoute(
                path: 'inventory',
                name: RouteNames.businessInventory,
                builder: (context, state) {
                  return BusinessInventoryPage(
                    profileId: state.pathParameters['profileId'],
                  );
                },
                routes: [
                  GoRoute(
                    path: ':offeringId/edit',
                    name: RouteNames.businessInventoryEdit,
                    builder: (context, state) {
                      return BusinessInventoryEditPage(
                        profileId: state.pathParameters['profileId'],
                        offeringId: state.pathParameters['offeringId'],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
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
