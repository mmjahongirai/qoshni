import 'package:qoshni/features/conversations/domain/qoshni_conversation_participant_role.dart';

class QoshniConversationParticipant {
  const QoshniConversationParticipant({
    required this.participantReference,
    required this.role,
    this.displayLabel,
  });

  final String participantReference;
  final QoshniConversationParticipantRole role;
  final String? displayLabel;
}
