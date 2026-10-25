import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/conversations/data/in_memory_qoshni_conversation_repository.dart';
import 'package:qoshni/features/conversations/data/qoshni_conversation_demo_seed.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_lifecycle_state.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_operation_result.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_participant_role.dart';

void main() {
  late InMemoryQoshniConversationRepository repo;

  setUp(() {
    repo = InMemoryQoshniConversationRepository();
  });

  test('lists conversations for demo customer deterministically', () {
    final list = repo.listForParticipant(kDemoConversationCustomerParticipant);
    expect(list.length, 3);
    expect(list.first.conversationId, 'conv-demo-availability');
  });

  test('orders messages chronologically', () {
    final messages = repo.listMessages(
      'conv-demo-availability',
      participantReference: kDemoConversationCustomerParticipant,
    );
    expect(messages.length, 2);
    expect(messages.first.createdAt.isBefore(messages.last.createdAt), isTrue);
  });

  test('rejects send into closed conversation', () {
    final result = repo.sendMessage(
      conversationId: 'conv-demo-support-fictional',
      senderReference: kDemoConversationCustomerParticipant,
      senderRole: QoshniConversationParticipantRole.customer,
      rawBody: 'Another question',
      createdAtUtc: kDemoConversationEpoch,
      messageId: 'msg-new-closed-test',
    );
    expect(result, QoshniConversationSendMessageResult.conversationNotOpen);
    expect(
      repo.listMessages(
        'conv-demo-support-fictional',
        participantReference: kDemoConversationCustomerParticipant,
      ).length,
      2,
    );
  });

  test('send appends message and updates preview', () {
    final result = repo.sendMessage(
      conversationId: 'conv-demo-availability',
      senderReference: kDemoConversationCustomerParticipant,
      senderRole: QoshniConversationParticipantRole.customer,
      rawBody: '  Thanks   for   the   demo  ',
      createdAtUtc: kDemoConversationEpoch,
      messageId: 'msg-new-open-test',
    );
    expect(result, QoshniConversationSendMessageResult.success);
    final messages = repo.listMessages(
      'conv-demo-availability',
      participantReference: kDemoConversationCustomerParticipant,
    );
    expect(messages.last.body, 'Thanks for the demo');
    final conv = repo.getConversation(
      'conv-demo-availability',
      participantReference: kDemoConversationCustomerParticipant,
    );
    expect(conv?.lastMessageId, 'msg-new-open-test');
  });

  test('invalid lifecycle transition does not mutate state', () {
    final before = repo.getConversation(
      'conv-demo-support-fictional',
      participantReference: kDemoConversationCustomerParticipant,
    );
    final result = repo.reopenConversation(
      conversationId: 'conv-demo-support-fictional',
      actorReference: kDemoConversationCustomerParticipant,
      updatedAtUtc: kDemoConversationEpoch,
    );
    expect(result, QoshniConversationMutationResult.success);
    final after = repo.getConversation(
      'conv-demo-support-fictional',
      participantReference: kDemoConversationCustomerParticipant,
    );
    expect(after?.lifecycleState, QoshniConversationLifecycleState.open);
    expect(before?.lifecycleState, QoshniConversationLifecycleState.closed);
  });

  test('non-member cannot access conversation messages', () {
    final messages = repo.listMessages(
      'conv-demo-availability',
      participantReference: 'demo-outsider-001',
    );
    expect(messages, isEmpty);
  });
}
