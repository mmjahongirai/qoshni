import 'package:qoshni/routing/route_paths.dart';

/// Allowlisted in-app routes that demo notifications may deep-link to.
bool isAllowedQoshniNotificationInternalRoute(String route) {
  final normalized = route.trim();
  if (normalized.isEmpty) {
    return false;
  }
  if (normalized.contains('://') || normalized.contains('..')) {
    return false;
  }

  const exactAllowed = {
    RoutePaths.home,
    RoutePaths.map,
    RoutePaths.search,
    RoutePaths.favorites,
    RoutePaths.profile,
    RoutePaths.cart,
    RoutePaths.checkout,
    RoutePaths.demoOrders,
    RoutePaths.demoOrderConfirmation,
    RoutePaths.businessCenter,
    RoutePaths.notificationsInbox,
    RoutePaths.notificationPreferences,
  };

  if (exactAllowed.contains(normalized)) {
    return true;
  }

  if (normalized.startsWith('${RoutePaths.demoOrders}/')) {
    final suffix = normalized.substring(RoutePaths.demoOrders.length + 1);
    return _isSafeDemoOrderReferenceSegment(suffix);
  }

  return false;
}

bool _isSafeDemoOrderReferenceSegment(String segment) {
  if (segment.isEmpty || segment.contains('/')) {
    return false;
  }
  if (segment.contains('@') || segment.contains(' ')) {
    return false;
  }
  return segment.startsWith('demo-');
}
