import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/notifications/presentation/qoshni_notification_validation.dart';
import 'package:qoshni/routing/route_paths.dart';

void main() {
  QoshniNotificationDeliverInput validInput() {
    return QoshniNotificationDeliverInput(
      demoRecipientReference: 'demo-inbox-recipient-001',
      category: QoshniNotificationCategory.security,
      channel: QoshniNotificationChannel.inApp,
      title: 'Demo security notice',
      body: 'Synthetic preview body.',
      createdAt: DateTime.utc(2025, 1, 1),
      priority: QoshniNotificationPriority.high,
      provenance: QoshniNotificationProvenance.syntheticDemo,
      internalNavigationRoute: RoutePaths.profile,
      deduplicationReference: 'dedupe-security-001',
    );
  }

  test('valid deliver input passes validation', () {
    expect(qoshniNotificationDeliverValidationError(validInput()), isNull);
  });

  test('rejects unsafe title and external navigation routes', () {
    final unsafeTitle = QoshniNotificationDeliverInput(
      demoRecipientReference: validInput().demoRecipientReference,
      category: validInput().category,
      channel: validInput().channel,
      title: 'Reach user@example.com',
      body: validInput().body,
      createdAt: validInput().createdAt,
      priority: validInput().priority,
      provenance: validInput().provenance,
      internalNavigationRoute: 'https://evil.example/phish',
    );
    expect(qoshniNotificationDeliverValidationError(unsafeTitle), isNotNull);
  });

  test('notification id validation rejects empty and unsafe tokens', () {
    expect(qoshniNotificationIdValidationError(''), isNotNull);
    expect(qoshniNotificationIdValidationError('id-with@token'), isNotNull);
    expect(qoshniNotificationIdValidationError('demo-notification-001'), isNull);
  });
}
