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
import 'package:qoshni/features/business_platform/presentation/pages/business_branch_list_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_branch_detail_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_branch_editor_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_staff_list_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_staff_detail_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_staff_editor_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_branch_permissions_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_home_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_category_list_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_category_detail_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_category_editor_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_product_list_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_product_detail_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_product_editor_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_product_variants_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_product_variant_editor_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_service_list_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_inventory_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_inventory_reservations_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_resource_list_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_pricing_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_discount_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_promo_code_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_commercial_fee_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_reviews_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_delivery_task_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_fulfillment_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_service_detail_page.dart';
import 'package:qoshni/features/business_platform/presentation/pages/business_catalog_service_editor_page.dart';
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
            path: 'branches',
            name: RouteNames.businessBranches,
            builder: (context, state) => const BusinessBranchListPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.businessBranchCreate,
                builder: (context, state) =>
                    const BusinessBranchEditorPage(),
              ),
              GoRoute(
                path: ':branchId',
                name: RouteNames.businessBranchDetail,
                builder: (context, state) {
                  return BusinessBranchDetailPage(
                    branchId: state.pathParameters['branchId'],
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.businessBranchEdit,
                    builder: (context, state) {
                      return BusinessBranchEditorPage(
                        branchId: state.pathParameters['branchId'],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'branch-permissions',
            name: RouteNames.businessBranchPermissions,
            builder: (context, state) {
              return BusinessBranchPermissionsPage(
                initialStaffId: state.uri.queryParameters['staffId'],
                initialBranchId: state.uri.queryParameters['branchId'],
              );
            },
          ),
          GoRoute(
            path: 'catalog',
            name: RouteNames.businessCatalog,
            builder: (context, state) => const BusinessCatalogHomePage(),
            routes: [
              GoRoute(
                path: 'categories',
                name: RouteNames.businessCatalogCategories,
                builder: (context, state) =>
                    const BusinessCatalogCategoryListPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: RouteNames.businessCatalogCategoryCreate,
                    builder: (context, state) =>
                        const BusinessCatalogCategoryEditorPage(),
                  ),
                  GoRoute(
                    path: ':categoryId',
                    name: RouteNames.businessCatalogCategoryDetail,
                    builder: (context, state) {
                      return BusinessCatalogCategoryDetailPage(
                        categoryId: state.pathParameters['categoryId'],
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: RouteNames.businessCatalogCategoryEdit,
                        builder: (context, state) {
                          return BusinessCatalogCategoryEditorPage(
                            categoryId: state.pathParameters['categoryId'],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'products',
                name: RouteNames.businessCatalogProducts,
                builder: (context, state) {
                  return BusinessCatalogProductListPage(
                    initialCategoryId: state.uri.queryParameters['categoryId'],
                    initialStatus: state.uri.queryParameters['status'],
                  );
                },
                routes: [
                  GoRoute(
                    path: 'new',
                    name: RouteNames.businessCatalogProductCreate,
                    builder: (context, state) =>
                        const BusinessCatalogProductEditorPage(),
                  ),
                  GoRoute(
                    path: ':productId',
                    name: RouteNames.businessCatalogProductDetail,
                    builder: (context, state) {
                      return BusinessCatalogProductDetailPage(
                        productId: state.pathParameters['productId'],
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: RouteNames.businessCatalogProductEdit,
                        builder: (context, state) {
                          return BusinessCatalogProductEditorPage(
                            productId: state.pathParameters['productId'],
                          );
                        },
                      ),
                      GoRoute(
                        path: 'variants',
                        name: RouteNames.businessCatalogProductVariants,
                        builder: (context, state) {
                          return BusinessCatalogProductVariantsPage(
                            productId: state.pathParameters['productId'],
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'new',
                            name: RouteNames.businessCatalogProductVariantCreate,
                            builder: (context, state) {
                              return BusinessCatalogProductVariantEditorPage(
                                productId: state.pathParameters['productId'],
                              );
                            },
                          ),
                          GoRoute(
                            path: ':variantId/edit',
                            name: RouteNames.businessCatalogProductVariantEdit,
                            builder: (context, state) {
                              return BusinessCatalogProductVariantEditorPage(
                                productId: state.pathParameters['productId'],
                                variantId: state.pathParameters['variantId'],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'services',
                name: RouteNames.businessCatalogServices,
                builder: (context, state) {
                  return BusinessCatalogServiceListPage(
                    initialCategoryId: state.uri.queryParameters['categoryId'],
                    initialStatus: state.uri.queryParameters['status'],
                  );
                },
                routes: [
                  GoRoute(
                    path: 'new',
                    name: RouteNames.businessCatalogServiceCreate,
                    builder: (context, state) =>
                        const BusinessCatalogServiceEditorPage(),
                  ),
                  GoRoute(
                    path: ':serviceId',
                    name: RouteNames.businessCatalogServiceDetail,
                    builder: (context, state) {
                      return BusinessCatalogServiceDetailPage(
                        serviceId: state.pathParameters['serviceId'],
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: RouteNames.businessCatalogServiceEdit,
                        builder: (context, state) {
                          return BusinessCatalogServiceEditorPage(
                            serviceId: state.pathParameters['serviceId'],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'inventory',
                name: RouteNames.businessCatalogInventory,
                builder: (context, state) =>
                    const BusinessCatalogInventoryPage(),
                routes: [
                  GoRoute(
                    path: 'reservations',
                    name: RouteNames.businessCatalogInventoryReservations,
                    builder: (context, state) =>
                        const BusinessCatalogInventoryReservationsPage(),
                  ),
                ],
              ),
              GoRoute(
                path: 'resources',
                name: RouteNames.businessCatalogResources,
                builder: (context, state) =>
                    const BusinessCatalogResourceListPage(),
              ),
              GoRoute(
                path: 'pricing',
                name: RouteNames.businessCatalogPricing,
                builder: (context, state) =>
                    const BusinessCatalogPricingPage(),
              ),
              GoRoute(
                path: 'discounts',
                name: RouteNames.businessCatalogDiscounts,
                builder: (context, state) =>
                    const BusinessCatalogDiscountPage(),
              ),
              GoRoute(
                path: 'promo-codes',
                name: RouteNames.businessCatalogPromoCodes,
                builder: (context, state) =>
                    const BusinessCatalogPromoCodePage(),
              ),
              GoRoute(
                path: 'commercial-fees',
                name: RouteNames.businessCatalogCommercialFees,
                builder: (context, state) =>
                    const BusinessCatalogCommercialFeePage(),
              ),
            ],
          ),
          GoRoute(
            path: 'fulfillment',
            name: RouteNames.businessFulfillment,
            builder: (context, state) => const BusinessFulfillmentPage(),
            routes: [
              GoRoute(
                path: 'delivery-tasks',
                name: RouteNames.businessDeliveryTasks,
                builder: (context, state) =>
                    const BusinessDeliveryTaskPage(),
              ),
            ],
          ),
          GoRoute(
            path: 'reviews',
            name: RouteNames.businessReviews,
            builder: (context, state) => const BusinessReviewsPage(),
          ),
          GoRoute(
            path: 'staff',
            name: RouteNames.businessStaff,
            builder: (context, state) => const BusinessStaffListPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.businessStaffCreate,
                builder: (context, state) => const BusinessStaffEditorPage(),
              ),
              GoRoute(
                path: ':staffId',
                name: RouteNames.businessStaffDetail,
                builder: (context, state) {
                  return BusinessStaffDetailPage(
                    staffId: state.pathParameters['staffId'],
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.businessStaffEdit,
                    builder: (context, state) {
                      return BusinessStaffEditorPage(
                        staffId: state.pathParameters['staffId'],
                      );
                    },
                  ),
                ],
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
