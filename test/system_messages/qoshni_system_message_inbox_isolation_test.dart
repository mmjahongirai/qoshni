import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_repository.dart';
import 'package:qoshni/features/system_messages/data/in_memory_qoshni_system_message_repository.dart';
import 'package:qoshni/features/system_messages/data/qoshni_system_message_demo_seed.dart';

void main() {
  test('marking system messages read does not change notification inbox', () {
    final inbox = InMemoryQoshniNotificationRepository();
    final systemMessages = InMemoryQoshniSystemMessageRepository();
    final before = inbox.list().length;

    systemMessages.markRead(
      demoRecipientReference: kDemoSystemMessageRecipientPrimary,
      messageId: 'sys-msg-001',
      readAtUtc: kDemoSystemMessageEpoch,
    );
    systemMessages.markAllVisibleRead(
      demoRecipientReference: kDemoSystemMessageRecipientPrimary,
      evaluationUtc: kDemoSystemMessageEpoch,
      readAtUtc: kDemoSystemMessageEpoch,
    );

    expect(inbox.list().length, before);
  });
}
