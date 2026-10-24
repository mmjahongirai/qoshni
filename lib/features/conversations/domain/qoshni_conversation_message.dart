import 'package:qoshni/features/conversations/domain/qoshni_conversation_participant_role.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';

enum QoshniConversationMessageStatus {
  sent,
}

class QoshniConversationMessage {
  const QoshniConversationMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderReference,
    required this.senderRole,
    required this.body,
    required this.createdAt,
    this.replyToMessageId,
    this.status = QoshniConversationMessageStatus.sent,
  });

  final String messageId;
  final String conversationId;
  final String senderReference;
  final QoshniConversationParticipantRole senderRole;
  final String body;
  final DateTime createdAt;
  final String? replyToMessageId;
  final QoshniConversationMessageStatus status;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;
}
