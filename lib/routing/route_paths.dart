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
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String demoOrderConfirmation = '/order/demo-confirmation';
  static const String demoOrders = '/orders';
  static const String demoOrderDetail = '/orders/:referenceId';
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
  static const String cart = 'cart';
  static const String checkout = 'checkout';
  static const String demoOrderConfirmation = 'demoOrderConfirmation';
  static const String demoOrders = 'demoOrders';
  static const String demoOrderDetail = 'demoOrderDetail';
}
