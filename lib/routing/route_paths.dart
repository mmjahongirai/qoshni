/// Central route path constants.
abstract final class RoutePaths {
  static const String home = '/';
  static const String map = '/map';
  static const String search = '/search';
  static const String categoryListing = '/category/:categoryId';
  static const String businessDetail = '/business/:businessId';
  static const String catalogItemDetail =
      '/business/:businessId/catalog/:catalogItemId';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String authSignIn = '/profile/sign-in';
  static const String authSessions = '/profile/sessions';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String demoOrderConfirmation = '/order/demo-confirmation';
  static const String demoOrders = '/orders';
  static const String demoOrderDetail = '/orders/:referenceId';
  static const String businessCenter = '/business-center';
  static const String businessProfileCreate = '/business-center/profile/new';
  static const String businessProfileDetail =
      '/business-center/profile/:profileId';
  static const String businessProfileEdit =
      '/business-center/profile/:profileId/edit';
  static const String businessOfferingCreate =
      '/business-center/profile/:profileId/offerings/new';
  static const String businessOfferingEdit =
      '/business-center/profile/:profileId/offerings/:offeringId/edit';
  static const String businessInventory =
      '/business-center/profile/:profileId/inventory';
  static const String businessInventoryEdit =
      '/business-center/profile/:profileId/inventory/:offeringId/edit';
  static const String businessOnboardingHub = '/business-center/onboarding';
  static const String businessOnboardingApplication =
      '/business-center/onboarding/:applicationId';
  static const String businessOwnerProfile =
      '/business-center/business-profile';
  static const String businessOwnerProfileEdit =
      '/business-center/business-profile/edit';
  static const String businessBranches = '/business-center/branches';
  static const String businessBranchCreate = '/business-center/branches/new';
  static const String businessBranchDetail =
      '/business-center/branches/:branchId';
  static const String businessBranchEdit =
      '/business-center/branches/:branchId/edit';

  static String businessBranchDetailPath(String branchId) =>
      '/business-center/branches/$branchId';

  static String businessBranchEditPath(String branchId) =>
      '/business-center/branches/$branchId/edit';
  static const String businessStaff = '/business-center/staff';
  static const String businessStaffCreate = '/business-center/staff/new';
  static const String businessStaffDetail = '/business-center/staff/:staffId';
  static const String businessStaffEdit =
      '/business-center/staff/:staffId/edit';

  static String businessStaffDetailPath(String staffId) =>
      '/business-center/staff/$staffId';

  static String businessStaffEditPath(String staffId) =>
      '/business-center/staff/$staffId/edit';
  static const String businessBranchPermissions =
      '/business-center/branch-permissions';
  static const String businessCatalog = '/business-center/catalog';
  static const String businessCatalogCategories =
      '/business-center/catalog/categories';
  static const String businessCatalogCategoryCreate =
      '/business-center/catalog/categories/new';
  static const String businessCatalogCategoryDetail =
      '/business-center/catalog/categories/:categoryId';
  static const String businessCatalogCategoryEdit =
      '/business-center/catalog/categories/:categoryId/edit';

  static String businessCatalogCategoryDetailPath(String categoryId) =>
      '/business-center/catalog/categories/$categoryId';

  static String businessCatalogCategoryEditPath(String categoryId) =>
      '/business-center/catalog/categories/$categoryId/edit';

  static const String businessCatalogProducts =
      '/business-center/catalog/products';
  static const String businessCatalogProductCreate =
      '/business-center/catalog/products/new';
  static const String businessCatalogProductDetail =
      '/business-center/catalog/products/:productId';
  static const String businessCatalogProductEdit =
      '/business-center/catalog/products/:productId/edit';
  static const String businessCatalogProductVariants =
      '/business-center/catalog/products/:productId/variants';
  static const String businessCatalogProductVariantCreate =
      '/business-center/catalog/products/:productId/variants/new';
  static const String businessCatalogProductVariantEdit =
      '/business-center/catalog/products/:productId/variants/:variantId/edit';

  static String businessCatalogProductDetailPath(String productId) =>
      '/business-center/catalog/products/$productId';

  static String businessCatalogProductEditPath(String productId) =>
      '/business-center/catalog/products/$productId/edit';

  static String businessCatalogProductVariantsPath(String productId) =>
      '/business-center/catalog/products/$productId/variants';

  static String businessCatalogProductVariantCreatePath(String productId) =>
      '/business-center/catalog/products/$productId/variants/new';

  static String businessCatalogProductVariantEditPath(
    String productId,
    String variantId,
  ) =>
      '/business-center/catalog/products/$productId/variants/$variantId/edit';

  static const String businessCatalogServices =
      '/business-center/catalog/services';
  static const String businessCatalogServiceCreate =
      '/business-center/catalog/services/new';
  static const String businessCatalogServiceDetail =
      '/business-center/catalog/services/:serviceId';
  static const String businessCatalogServiceEdit =
      '/business-center/catalog/services/:serviceId/edit';

  static String businessCatalogServiceDetailPath(String serviceId) =>
      '/business-center/catalog/services/$serviceId';

  static String businessCatalogServiceEditPath(String serviceId) =>
      '/business-center/catalog/services/$serviceId/edit';

  static const String businessCatalogInventory =
      '/business-center/catalog/inventory';

  static const String businessCatalogInventoryReservations =
      '/business-center/catalog/inventory/reservations';

  static const String businessCatalogResources =
      '/business-center/catalog/resources';

  static const String businessCatalogPricing =
      '/business-center/catalog/pricing';

  static const String businessCatalogDiscounts =
      '/business-center/catalog/discounts';
}

abstract final class RouteNames {
  static const String home = 'home';
  static const String map = 'map';
  static const String search = 'search';
  static const String categoryListing = 'categoryListing';
  static const String businessDetail = 'businessDetail';
  static const String catalogItemDetail = 'catalogItemDetail';
  static const String favorites = 'favorites';
  static const String profile = 'profile';
  static const String authSignIn = 'authSignIn';
  static const String authSessions = 'authSessions';
  static const String cart = 'cart';
  static const String checkout = 'checkout';
  static const String demoOrderConfirmation = 'demoOrderConfirmation';
  static const String demoOrders = 'demoOrders';
  static const String demoOrderDetail = 'demoOrderDetail';
  static const String businessCenter = 'businessCenter';
  static const String businessProfileCreate = 'businessProfileCreate';
  static const String businessProfileDetail = 'businessProfileDetail';
  static const String businessProfileEdit = 'businessProfileEdit';
  static const String businessOfferingCreate = 'businessOfferingCreate';
  static const String businessOfferingEdit = 'businessOfferingEdit';
  static const String businessInventory = 'businessInventory';
  static const String businessInventoryEdit = 'businessInventoryEdit';
  static const String businessOnboardingHub = 'businessOnboardingHub';
  static const String businessOnboardingApplication =
      'businessOnboardingApplication';
  static const String businessOwnerProfile = 'businessOwnerProfile';
  static const String businessOwnerProfileEdit = 'businessOwnerProfileEdit';
  static const String businessBranches = 'businessBranches';
  static const String businessBranchCreate = 'businessBranchCreate';
  static const String businessBranchDetail = 'businessBranchDetail';
  static const String businessBranchEdit = 'businessBranchEdit';
  static const String businessStaff = 'businessStaff';
  static const String businessStaffCreate = 'businessStaffCreate';
  static const String businessStaffDetail = 'businessStaffDetail';
  static const String businessStaffEdit = 'businessStaffEdit';
  static const String businessBranchPermissions = 'businessBranchPermissions';
  static const String businessCatalog = 'businessCatalog';
  static const String businessCatalogCategories = 'businessCatalogCategories';
  static const String businessCatalogCategoryCreate =
      'businessCatalogCategoryCreate';
  static const String businessCatalogCategoryDetail =
      'businessCatalogCategoryDetail';
  static const String businessCatalogCategoryEdit =
      'businessCatalogCategoryEdit';
  static const String businessCatalogProducts = 'businessCatalogProducts';
  static const String businessCatalogProductCreate =
      'businessCatalogProductCreate';
  static const String businessCatalogProductDetail =
      'businessCatalogProductDetail';
  static const String businessCatalogProductEdit =
      'businessCatalogProductEdit';
  static const String businessCatalogProductVariants =
      'businessCatalogProductVariants';
  static const String businessCatalogProductVariantCreate =
      'businessCatalogProductVariantCreate';
  static const String businessCatalogProductVariantEdit =
      'businessCatalogProductVariantEdit';
  static const String businessCatalogServices = 'businessCatalogServices';
  static const String businessCatalogServiceCreate =
      'businessCatalogServiceCreate';
  static const String businessCatalogServiceDetail =
      'businessCatalogServiceDetail';
  static const String businessCatalogServiceEdit =
      'businessCatalogServiceEdit';
  static const String businessCatalogInventory = 'businessCatalogInventory';
  static const String businessCatalogInventoryReservations =
      'businessCatalogInventoryReservations';
  static const String businessCatalogResources = 'businessCatalogResources';
  static const String businessCatalogPricing = 'businessCatalogPricing';
  static const String businessCatalogDiscounts = 'businessCatalogDiscounts';
}
