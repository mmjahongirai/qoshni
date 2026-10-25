import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/system_messages/data/in_memory_qoshni_system_message_repository.dart';
import 'package:qoshni/features/system_messages/data/qoshni_system_message_demo_seed.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_lifecycle_status.dart';
import 'package:qoshni/features/system_messages/domain/qoshni_system_message_mutation_result.dart';

void main() {
  late InMemoryQoshniSystemMessageRepository repo;

  setUp(() {
    repo = InMemoryQoshniSystemMessageRepository();
  });

  test('seed is deterministic', () {
    final a = InMemoryQoshniSystemMessageRepository();
    final b = InMemoryQoshniSystemMessageRepository();
    expect(a.list().length, b.list().length);
  });

  test('visibility excludes draft withdrawn archived future and expired', () {
    final visible = repo.visibleMessages(
      evaluationUtc: kDemoSystemMessageEpoch,
      demoRecipientReference: kDemoSystemMessageRecipientPrimary,
    );
    final keys = visible.map((m) => m.messageKey).toSet();
    expect(keys, contains('demo.announcement.welcome'));
    expect(keys, isNot(contains('demo.announcement.draft')));
    expect(keys, isNot(contains('demo.announcement.withdrawn')));
    expect(keys, isNot(contains('demo.announcement.archived')));
    expect(keys, isNot(contains('demo.announcement.future')));
    expect(keys, isNot(contains('demo.announcement.expired')));
  });

  test('publish draft and withdraw published', () {
    final result = repo.publish(
      messageId: 'sys-msg-007',
      publishedAtUtc: kDemoSystemMessageEpoch,
    );
    expect(result, QoshniSystemMessageMutationResult.success);
    final published = repo.getById('sys-msg-007');
    expect(published?.lifecycleStatus,
        QoshniSystemMessageLifecycleStatus.published);

    final withdraw = repo.withdraw(
      messageId: 'sys-msg-001',
      updatedAtUtc: kDemoSystemMessageEpoch,
    );
    expect(withdraw, QoshniSystemMessageMutationResult.success);
    final visible = repo.visibleMessages(
      evaluationUtc: kDemoSystemMessageEpoch,
      demoRecipientReference: kDemoSystemMessageRecipientPrimary,
    );
    expect(
      visible.any((m) => m.messageId == 'sys-msg-001'),
      isFalse,
    );
  });

  test('invalid transition leaves message unchanged', () {
    final before = repo.getById('sys-msg-001');
    final result = repo.publish(
      messageId: 'sys-msg-001',
      publishedAtUtc: kDemoSystemMessageEpoch,
    );
    expect(result, QoshniSystemMessageMutationResult.invalidTransition);
    final after = repo.getById('sys-msg-001');
    expect(after?.lifecycleStatus, before?.lifecycleStatus);
  });

  test('read state is isolated per recipient', () {
    repo.markRead(
      demoRecipientReference: kDemoSystemMessageRecipientPrimary,
      messageId: 'sys-msg-001',
      readAtUtc: kDemoSystemMessageEpoch,
    );
    expect(
      repo.isRead(
        demoRecipientReference: kDemoSystemMessageRecipientPrimary,
        messageId: 'sys-msg-001',
      ),
      isTrue,
    );
    expect(
      repo.isRead(
        demoRecipientReference: kDemoSystemMessageRecipientAlternate,
        messageId: 'sys-msg-001',
      ),
      isFalse,
    );
    expect(
      repo.unreadCount(
        demoRecipientReference: kDemoSystemMessageRecipientAlternate,
        evaluationUtc: kDemoSystemMessageEpoch,
      ),
      greaterThan(0),
    );
  });

  test('mark all visible read is idempotent for already read', () {
    repo.markAllVisibleRead(
      demoRecipientReference: kDemoSystemMessageRecipientPrimary,
      evaluationUtc: kDemoSystemMessageEpoch,
      readAtUtc: kDemoSystemMessageEpoch,
    );
    final firstCount = repo.unreadCount(
      demoRecipientReference: kDemoSystemMessageRecipientPrimary,
      evaluationUtc: kDemoSystemMessageEpoch,
    );
    expect(firstCount, 0);
    final repeat = repo.markRead(
      demoRecipientReference: kDemoSystemMessageRecipientPrimary,
      messageId: 'sys-msg-001',
      readAtUtc: kDemoSystemMessageEpoch,
    );
    expect(repeat, QoshniSystemMessageReadResult.alreadyRead);
  });
}
