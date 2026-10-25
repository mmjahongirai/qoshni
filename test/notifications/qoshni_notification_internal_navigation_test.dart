import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_internal_navigation.dart';
import 'package:qoshni/routing/route_paths.dart';

void main() {
  test('allows known internal routes only', () {
    expect(isAllowedQoshniNotificationInternalRoute(RoutePaths.home), isTrue);
    expect(isAllowedQoshniNotificationInternalRoute(RoutePaths.map), isTrue);
    expect(isAllowedQoshniNotificationInternalRoute(RoutePaths.notificationsInbox), isTrue);
    expect(
      isAllowedQoshniNotificationInternalRoute(RoutePaths.notificationPreferences),
      isTrue,
    );
    expect(
      isAllowedQoshniNotificationInternalRoute(
        RoutePaths.notificationDispatchDiagnostics,
      ),
      isTrue,
    );
    expect(
      isAllowedQoshniNotificationInternalRoute('${RoutePaths.demoOrders}/demo-order-042'),
      isTrue,
    );
  });

  test('rejects external and unsafe routes', () {
    expect(isAllowedQoshniNotificationInternalRoute('https://example.com'), isFalse);
    expect(isAllowedQoshniNotificationInternalRoute('/orders/not-demo-id'), isFalse);
    expect(isAllowedQoshniNotificationInternalRoute('javascript:alert(1)'), isFalse);
  });
}
