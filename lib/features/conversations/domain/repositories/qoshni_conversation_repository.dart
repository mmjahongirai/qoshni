import 'package:qoshni/features/conversations/domain/qoshni_conversation.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_message.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_operation_result.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_participant_role.dart';

abstract class QoshniConversationRepository {
  List<QoshniConversation> listForParticipant(String participantReference);

  QoshniConversation? getConversation(
    String conversationId, {
    required String participantReference,
  });

  List<QoshniConversationMessage> listMessages(
    String conversationId, {
    required String participantReference,
  });

  QoshniConversationSendMessageResult sendMessage({
    required String conversationId,
    required String senderReference,
    required QoshniConversationParticipantRole senderRole,
    required String rawBody,
    required DateTime createdAtUtc,
    required String messageId,
    String? replyToMessageId,
  });

  QoshniConversationMutationResult closeConversation({
    required String conversationId,
    required String actorReference,
    required DateTime updatedAtUtc,
  });

  QoshniConversationMutationResult reopenConversation({
    required String conversationId,
    required String actorReference,
    required DateTime updatedAtUtc,
  });

  QoshniConversationMutationResult archiveConversation({
    required String conversationId,
    required String actorReference,
    required DateTime updatedAtUtc,
  });

  void markConversationRead({
    required String conversationId,
    required String participantReference,
    required DateTime readAtUtc,
  });

  int unreadMessageCount({
    required String participantReference,
  });
}
