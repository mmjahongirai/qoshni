import 'package:qoshni/features/conversations/domain/qoshni_conversation_lifecycle_state.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_participant.dart';
import 'package:qoshni/features/conversations/domain/qoshni_conversation_type.dart';
import 'package:qoshni/features/notifications/domain/qoshni_notification_provenance.dart';

class QoshniConversation {
  const QoshniConversation({
    required this.conversationId,
    required this.demoReference,
    required this.type,
    required this.lifecycleState,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
    this.businessScopeLabel,
    this.branchScopeLabel,
    this.lastMessageId,
    this.lastMessagePreview,
    this.lastMessageAt,
  });

  final String conversationId;
  final String demoReference;
  final QoshniConversationType type;
  final QoshniConversationLifecycleState lifecycleState;
  final List<QoshniConversationParticipant> participants;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? businessScopeLabel;
  final String? branchScopeLabel;
  final String? lastMessageId;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;

  QoshniNotificationProvenance get provenance =>
      QoshniNotificationProvenance.syntheticDemo;

  QoshniConversation copyWith({
    QoshniConversationLifecycleState? lifecycleState,
    DateTime? updatedAt,
    String? lastMessageId,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
  }) {
    return QoshniConversation(
      conversationId: conversationId,
      demoReference: demoReference,
      type: type,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      participants: participants,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      businessScopeLabel: businessScopeLabel,
      branchScopeLabel: branchScopeLabel,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  bool includesParticipant(String participantReference) {
    final ref = participantReference.trim();
    return participants.any((p) => p.participantReference == ref);
  }
}
