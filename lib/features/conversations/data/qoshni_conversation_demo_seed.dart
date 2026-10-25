import 'package:qoshni/features/conversations/domain/qoshni_conversation.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_lifecycle_state.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_message.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_participant.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_participant_role.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_type.dart';
import 'package:qoshni/features/notifications/data/qoshni_notification_demo_seed.dart';

const String kDemoConversationCustomerParticipant =
    kDemoNotificationRecipientReference;

const String kDemoConversationBusinessAgent = 'demo-business-agent-001';
const String kDemoConversationSupportAgent = 'demo-support-agent-001';

final DateTime kDemoConversationEpoch = DateTime.utc(2025, 4, 11, 10, 0);

class QoshniConversationDemoSeed {
  const QoshniConversationDemoSeed({
    required this.conversations,
    required this.messagesByConversationId,
  });

  final List<QoshniConversation> conversations;
  final Map<String, List<QoshniConversationMessage>> messagesByConversationId;
}

QoshniConversationDemoSeed buildQoshniConversationDemoSeed() {
  final convAvailability = QoshniConversation(
    conversationId: 'conv-demo-availability',
    demoReference: 'demo.conv.availability',
    type: QoshniConversationType.customerBusiness,
    lifecycleState: QoshniConversationLifecycleState.open,
    participants: const [
      QoshniConversationParticipant(
        participantReference: kDemoConversationCustomerParticipant,
        role: QoshniConversationParticipantRole.customer,
        displayLabel: 'Demo guest',
      ),
      QoshniConversationParticipant(
        participantReference: kDemoConversationBusinessAgent,
        role: QoshniConversationParticipantRole.businessAgent,
        displayLabel: 'Demo Cafe desk',
      ),
    ],
    createdAt: DateTime.utc(2025, 4, 11, 8, 0),
    updatedAt: DateTime.utc(2025, 4, 11, 9, 30),
    businessScopeLabel: 'Demo Cafe',
    branchScopeLabel: 'Demo branch A',
    lastMessageId: 'msg-conv-demo-availability-002',
    lastMessagePreview: 'We have demo slots tomorrow afternoon.',
    lastMessageAt: DateTime.utc(2025, 4, 11, 9, 30),
  );

  final convService = QoshniConversation(
    conversationId: 'conv-demo-service-clarification',
    demoReference: 'demo.conv.service-clarification',
    type: QoshniConversationType.customerBusiness,
    lifecycleState: QoshniConversationLifecycleState.open,
    participants: const [
      QoshniConversationParticipant(
        participantReference: kDemoConversationCustomerParticipant,
        role: QoshniConversationParticipantRole.customer,
        displayLabel: 'Demo guest',
      ),
      QoshniConversationParticipant(
        participantReference: kDemoConversationBusinessAgent,
        role: QoshniConversationParticipantRole.businessAgent,
        displayLabel: 'Demo Cafe desk',
      ),
    ],
    createdAt: DateTime.utc(2025, 4, 10, 14, 0),
    updatedAt: DateTime.utc(2025, 4, 10, 14, 20),
    businessScopeLabel: 'Demo Cafe',
    lastMessageId: 'msg-conv-demo-service-002',
    lastMessagePreview: 'Pickup is demo-only; no real order is placed.',
    lastMessageAt: DateTime.utc(2025, 4, 10, 14, 20),
  );

  final convSupport = QoshniConversation(
    conversationId: 'conv-demo-support-fictional',
    demoReference: 'demo.conv.support-fictional',
    type: QoshniConversationType.supportDemo,
    lifecycleState: QoshniConversationLifecycleState.closed,
    participants: const [
      QoshniConversationParticipant(
        participantReference: kDemoConversationCustomerParticipant,
        role: QoshniConversationParticipantRole.customer,
        displayLabel: 'Demo guest',
      ),
      QoshniConversationParticipant(
        participantReference: kDemoConversationSupportAgent,
        role: QoshniConversationParticipantRole.supportAgent,
        displayLabel: 'Demo support',
      ),
    ],
    createdAt: DateTime.utc(2025, 4, 9, 16, 0),
    updatedAt: DateTime.utc(2025, 4, 9, 16, 45),
    lastMessageId: 'msg-conv-demo-support-002',
    lastMessagePreview: 'Ticket closed — fictional scenario only.',
    lastMessageAt: DateTime.utc(2025, 4, 9, 16, 45),
  );

  final messages = <String, List<QoshniConversationMessage>>{
    convAvailability.conversationId: [
      QoshniConversationMessage(
        messageId: 'msg-conv-demo-availability-001',
        conversationId: convAvailability.conversationId,
        senderReference: kDemoConversationCustomerParticipant,
        senderRole: QoshniConversationParticipantRole.customer,
        body: 'Hello, do you have demo availability this week?',
        createdAt: DateTime.utc(2025, 4, 11, 9, 0),
      ),
      QoshniConversationMessage(
        messageId: 'msg-conv-demo-availability-002',
        conversationId: convAvailability.conversationId,
        senderReference: kDemoConversationBusinessAgent,
        senderRole: QoshniConversationParticipantRole.businessAgent,
        body: 'We have demo slots tomorrow afternoon.',
        createdAt: DateTime.utc(2025, 4, 11, 9, 30),
      ),
    ],
    convService.conversationId: [
      QoshniConversationMessage(
        messageId: 'msg-conv-demo-service-001',
        conversationId: convService.conversationId,
        senderReference: kDemoConversationCustomerParticipant,
        senderRole: QoshniConversationParticipantRole.customer,
        body: 'Is pickup available for the demo menu item?',
        createdAt: DateTime.utc(2025, 4, 10, 14, 5),
      ),
      QoshniConversationMessage(
        messageId: 'msg-conv-demo-service-002',
        conversationId: convService.conversationId,
        senderReference: kDemoConversationBusinessAgent,
        senderRole: QoshniConversationParticipantRole.businessAgent,
        body: 'Pickup is demo-only; no real order is placed.',
        createdAt: DateTime.utc(2025, 4, 10, 14, 20),
      ),
    ],
    convSupport.conversationId: [
      QoshniConversationMessage(
        messageId: 'msg-conv-demo-support-001',
        conversationId: convSupport.conversationId,
        senderReference: kDemoConversationCustomerParticipant,
        senderRole: QoshniConversationParticipantRole.customer,
        body: 'Fictional question about demo app navigation.',
        createdAt: DateTime.utc(2025, 4, 9, 16, 10),
      ),
      QoshniConversationMessage(
        messageId: 'msg-conv-demo-support-002',
        conversationId: convSupport.conversationId,
        senderReference: kDemoConversationSupportAgent,
        senderRole: QoshniConversationParticipantRole.supportAgent,
        body: 'Ticket closed — fictional scenario only.',
        createdAt: DateTime.utc(2025, 4, 9, 16, 45),
      ),
    ],
  };

  return QoshniConversationDemoSeed(
    conversations: [
      convAvailability,
      convService,
      convSupport,
    ],
    messagesByConversationId: messages,
  );
}
