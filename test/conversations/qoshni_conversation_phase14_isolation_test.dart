import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/conversations/data/in_memory_qoshni_conversation_repository.dart';
import 'package:qoshni/features/conversations/data/qoshni_conversation_demo_seed.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_participant_role.dart';
import 'package:qoshni/features/notifications/data/in_memory_qoshni_notification_repository.dart';
import 'package:qoshni/features/system_messages/data/in_memory_qoshni_system_message_repository.dart';
import 'package:qoshni/features/system_messages/data/qoshni_system_message_demo_seed.dart';

void main() {
  test('sending demo chat message does not mutate inbox or system messages', () {
    final inbox = InMemoryQoshniNotificationRepository();
    final system = InMemoryQoshniSystemMessageRepository();
    final chat = InMemoryQoshniConversationRepository();

    final inboxBefore = inbox.list().length;
    final systemUnreadBefore = system.unreadCount(
      demoRecipientReference: kDemoSystemMessageRecipientPrimary,
      evaluationUtc: kDemoSystemMessageEpoch,
    );

    chat.sendMessage(
      conversationId: 'conv-demo-availability',
      senderReference: kDemoConversationCustomerParticipant,
      senderRole: QoshniConversationParticipantRole.customer,
      rawBody: 'Demo isolation check',
      createdAtUtc: kDemoConversationEpoch,
      messageId: 'msg-isolation-001',
    );

    expect(inbox.list().length, inboxBefore);
    expect(
      system.unreadCount(
        demoRecipientReference: kDemoSystemMessageRecipientPrimary,
        evaluationUtc: kDemoSystemMessageEpoch,
      ),
      systemUnreadBefore,
    );
  });
}
