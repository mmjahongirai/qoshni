import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_repository.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_category.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_channel.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_priority.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_read_status.dart';
import 'package:qoshni/features/notifications/domain/repositories/qoshni_notification_repository.dart';
import 'package:qoshni/routing/route_paths.dart';

void main() {
  late InMemoryQoshniNotificationRepository repo;

  setUp(() {
    repo = InMemoryQoshniNotificationRepository();
  });

  QoshniNotificationDeliverInput deliverInput({
    required String dedupe,
    String title = 'Demo title',
  }) {
    return QoshniNotificationDeliverInput(
      demoRecipientReference: repo.demoRecipientReference,
      category: QoshniNotificationCategory.orders,
      channel: QoshniNotificationChannel.inApp,
      title: title,
      body: 'Synthetic demo body for repository tests.',
      createdAt: DateTime.utc(2025, 5, 1),
      priority: QoshniNotificationPriority.normal,
      provenance: QoshniNotificationProvenance.syntheticDemo,
      deduplicationReference: dedupe,
      internalNavigationRoute: RoutePaths.home,
    );
  }

  test('demo seed sorts deterministically by createdAt desc then id', () {
    final list = repo.list();
    expect(list.length, 10);
    for (var i = 1; i < list.length; i++) {
      final prev = list[i - 1];
      final next = list[i];
      final byTime = prev.createdAt.compareTo(next.createdAt);
      expect(byTime >= 0, isTrue);
      if (byTime == 0) {
        expect(prev.notificationId.compareTo(next.notificationId), lessThanOrEqualTo(0));
      }
    }
  });

  test('unread count and unread filter stay consistent', () {
    final unreadListed = repo.list(
      readFilter: QoshniNotificationReadFilter.unreadOnly,
    );
    expect(unreadListed.length, repo.unreadCount());
    expect(unreadListed.every((n) => n.isUnread), isTrue);
  });

  test('category filter narrows results', () {
    final promos = repo.list(
      category: QoshniNotificationCategory.promotions,
    );
    expect(promos, isNotEmpty);
    expect(promos.every((n) => n.category == QoshniNotificationCategory.promotions), isTrue);
  });

  test('markRead updates status and repeated mark is idempotent', () {
    final unread = repo.list(
      readFilter: QoshniNotificationReadFilter.unreadOnly,
    ).first;
    expect(repo.markRead(unread.notificationId), QoshniNotificationMarkReadResult.success);
    final updated = repo.findById(unread.notificationId);
    expect(updated?.readStatus, QoshniNotificationReadStatus.read);
    expect(updated?.readAt, isNotNull);

    expect(
      repo.markRead(unread.notificationId),
      QoshniNotificationMarkReadResult.alreadyRead,
    );
  });

  test('markRead invalid and not found do not mutate unread count', () {
    final before = repo.unreadCount();
    expect(repo.markRead(''), QoshniNotificationMarkReadResult.invalidId);
    expect(repo.markRead('missing-id-001'), QoshniNotificationMarkReadResult.notFound);
    expect(repo.unreadCount(), before);
  });

  test('markAllRead clears unread count', () {
    expect(repo.unreadCount(), greaterThan(0));
    expect(repo.markAllRead(), QoshniNotificationMarkAllReadResult.success);
    expect(repo.unreadCount(), 0);
  });

  test('deliver deduplicates by deduplication reference', () {
    const dedupe = 'test-dedupe-unique-001';
    expect(repo.deliver(deliverInput(dedupe: dedupe)), QoshniNotificationDeliverResult.success);
    expect(
      repo.deliver(deliverInput(dedupe: dedupe, title: 'Duplicate attempt')),
      QoshniNotificationDeliverResult.duplicateDeduplicationReference,
    );
  });

  test('invalid deliver does not change list length', () {
    final before = repo.list().length;
    expect(
      repo.deliver(
        deliverInput(dedupe: 'bad-dedupe').copyWithUnsafeEmailTitle(),
      ),
      QoshniNotificationDeliverResult.invalidInput,
    );
    expect(repo.list().length, before);
  });

  test('failNextMarkRead leaves unread state unchanged', () {
    repo.failNextMarkRead = true;
    final target = repo.list(
      readFilter: QoshniNotificationReadFilter.unreadOnly,
    ).first;
    expect(repo.markRead(target.notificationId), QoshniNotificationMarkReadResult.failure);
    expect(repo.findById(target.notificationId)?.isUnread, isTrue);
  });
}

extension on QoshniNotificationDeliverInput {
  QoshniNotificationDeliverInput copyWithUnsafeEmailTitle() {
    return QoshniNotificationDeliverInput(
      demoRecipientReference: demoRecipientReference,
      category: category,
      channel: channel,
      title: 'Contact user@example.com',
      body: body,
      createdAt: createdAt,
      priority: priority,
      provenance: provenance,
      deduplicationReference: deduplicationReference,
      internalNavigationRoute: internalNavigationRoute,
    );
  }
}
