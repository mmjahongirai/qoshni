import 'package:qoshni/features/notifications/domain/qoshni_notification.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_read_status.dart';
import 'package:qoshni/routing/route_paths.dart';

/// Fixed epoch for deterministic demo notification timestamps.
final DateTime kDemoNotificationEpoch = DateTime.utc(2025, 4, 10, 9, 0, 0);

const String kDemoNotificationRecipientReference = 'demo-inbox-recipient-001';

List<QoshniNotification> buildDemoQoshniNotifications({
  required String demoRecipientReference,
}) {
  var seq = 0;

  QoshniNotification seed({
    required QoshniNotificationCategory category,
    required QoshniNotificationChannel channel,
    required String title,
    required String body,
    required DateTime createdAt,
    required QoshniNotificationReadStatus readStatus,
    DateTime? readAt,
    required QoshniNotificationPriority priority,
    String? internalNavigationRoute,
    String? deduplicationReference,
  }) {
    seq++;
    return QoshniNotification(
      notificationId: 'demo-notification-${seq.toString().padLeft(3, '0')}',
      demoRecipientReference: demoRecipientReference,
      category: category,
      channel: channel,
      title: title,
      body: body,
      createdAt: createdAt,
      readStatus: readStatus,
      readAt: readAt,
      priority: priority,
      internalNavigationRoute: internalNavigationRoute,
      provenance: QoshniNotificationProvenance.syntheticDemo,
      deduplicationReference: deduplicationReference,
    );
  }

  final readAtOlder = kDemoNotificationEpoch.subtract(const Duration(hours: 2));

  return [
    seed(
      category: QoshniNotificationCategory.orders,
      channel: QoshniNotificationChannel.inApp,
      title: 'Demo order update',
      body: 'Synthetic status change for demo order reference demo-order-042.',
      createdAt: kDemoNotificationEpoch.add(const Duration(minutes: 30)),
      readStatus: QoshniNotificationReadStatus.unread,
      priority: QoshniNotificationPriority.high,
      internalNavigationRoute: '${RoutePaths.demoOrders}/demo-order-042',
      deduplicationReference: 'dedupe-order-status-demo-order-042',
    ),
    seed(
      category: QoshniNotificationCategory.delivery,
      channel: QoshniNotificationChannel.inApp,
      title: 'Demo delivery window',
      body: 'Courier ETA preview for a synthetic route segment (no GPS tracking).',
      createdAt: kDemoNotificationEpoch.add(const Duration(minutes: 20)),
      readStatus: QoshniNotificationReadStatus.unread,
      priority: QoshniNotificationPriority.normal,
      internalNavigationRoute: RoutePaths.map,
      deduplicationReference: 'dedupe-delivery-window-001',
    ),
    seed(
      category: QoshniNotificationCategory.walletPayments,
      channel: QoshniNotificationChannel.inApp,
      title: 'Demo wallet receipt',
      body: 'Synthetic wallet ledger entry recorded for preview only.',
      createdAt: kDemoNotificationEpoch.add(const Duration(minutes: 10)),
      readStatus: QoshniNotificationReadStatus.unread,
      priority: QoshniNotificationPriority.normal,
      deduplicationReference: 'dedupe-wallet-receipt-001',
    ),
    seed(
      category: QoshniNotificationCategory.bookings,
      channel: QoshniNotificationChannel.inApp,
      title: 'Demo booking reminder',
      body: 'Placeholder reminder for a synthetic service booking slot.',
      createdAt: kDemoNotificationEpoch,
      readStatus: QoshniNotificationReadStatus.read,
      readAt: readAtOlder,
      priority: QoshniNotificationPriority.low,
      deduplicationReference: 'dedupe-booking-reminder-001',
    ),
    seed(
      category: QoshniNotificationCategory.aiAlerts,
      channel: QoshniNotificationChannel.inApp,
      title: 'Demo AI insight',
      body: 'Synthetic assistant summary — not generated from live user data.',
      createdAt: kDemoNotificationEpoch.subtract(const Duration(minutes: 15)),
      readStatus: QoshniNotificationReadStatus.read,
      readAt: readAtOlder,
      priority: QoshniNotificationPriority.normal,
    ),
    seed(
      category: QoshniNotificationCategory.location,
      channel: QoshniNotificationChannel.inApp,
      title: 'Demo map preview',
      body: 'Open the map preview to explore the default Uzbekistan viewport.',
      createdAt: kDemoNotificationEpoch.subtract(const Duration(minutes: 25)),
      readStatus: QoshniNotificationReadStatus.unread,
      priority: QoshniNotificationPriority.low,
      internalNavigationRoute: RoutePaths.map,
    ),
    seed(
      category: QoshniNotificationCategory.business,
      channel: QoshniNotificationChannel.inApp,
      title: 'Demo business center',
      body: 'Synthetic alert pointing to Business Center demo modules.',
      createdAt: kDemoNotificationEpoch.subtract(const Duration(minutes: 35)),
      readStatus: QoshniNotificationReadStatus.read,
      readAt: readAtOlder,
      priority: QoshniNotificationPriority.normal,
      internalNavigationRoute: RoutePaths.businessCenter,
    ),
    seed(
      category: QoshniNotificationCategory.trustReviews,
      channel: QoshniNotificationChannel.inApp,
      title: 'Demo trust signal',
      body: 'Informational preview tied to synthetic review activity.',
      createdAt: kDemoNotificationEpoch.subtract(const Duration(minutes: 45)),
      readStatus: QoshniNotificationReadStatus.unread,
      priority: QoshniNotificationPriority.normal,
    ),
    seed(
      category: QoshniNotificationCategory.security,
      channel: QoshniNotificationChannel.inApp,
      title: 'Demo security notice',
      body: 'Synthetic sign-in activity summary for the inbox preview.',
      createdAt: kDemoNotificationEpoch.subtract(const Duration(hours: 1)),
      readStatus: QoshniNotificationReadStatus.read,
      readAt: readAtOlder,
      priority: QoshniNotificationPriority.urgent,
      internalNavigationRoute: RoutePaths.profile,
    ),
    seed(
      category: QoshniNotificationCategory.promotions,
      channel: QoshniNotificationChannel.pushPreview,
      title: 'Demo promotion preview',
      body: 'Marketing copy sample — no campaign is sent in this build.',
      createdAt: kDemoNotificationEpoch.subtract(const Duration(hours: 1, minutes: 20)),
      readStatus: QoshniNotificationReadStatus.unread,
      priority: QoshniNotificationPriority.low,
      deduplicationReference: 'dedupe-promo-preview-001',
    ),
  ];
}
