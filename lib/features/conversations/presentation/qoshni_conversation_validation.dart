import 'package:qoshni/features/conversations/domain/qoshni_conversation.dart';

const int kQoshniConversationIdMaxLength = 120;
const int kQoshniConversationDemoReferenceMaxLength = 120;
const int kQoshniConversationMessageBodyMinLength = 1;
const int kQoshniConversationMessageBodyMaxLength = 2000;
const int kQoshniConversationParticipantReferenceMaxLength = 80;

String? qoshniConversationParticipantReferenceValidationError(String reference) {
  final ref = reference.trim();
  if (ref.isEmpty || ref.length > kQoshniConversationParticipantReferenceMaxLength) {
    return 'invalid_participant';
  }
  if (ref.contains('@') || ref.contains(' ')) {
    return 'unsafe_participant';
  }
  final lower = ref.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return 'unsafe_participant';
  }
  return null;
}

String normalizeQoshniConversationMessageBody(String raw) {
  return raw.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String? qoshniConversationMessageBodyValidationError(String rawBody) {
  final body = normalizeQoshniConversationMessageBody(rawBody);
  if (body.length < kQoshniConversationMessageBodyMinLength) {
    return 'empty_message';
  }
  if (body.length > kQoshniConversationMessageBodyMaxLength) {
    return 'message_too_long';
  }
  if (body.contains('<') || body.contains('>')) {
    return 'markup_not_allowed';
  }
  final lower = body.toLowerCase();
  if (lower.contains('http://') ||
      lower.contains('https://') ||
      lower.contains('javascript:')) {
    return 'url_not_allowed';
  }
  if (lower.contains('password') ||
      lower.contains('iban') ||
      lower.contains('credit card')) {
    return 'sensitive_content';
  }
  return null;
}

String? qoshniConversationMessageIdValidationError(String messageId) {
  final id = messageId.trim();
  if (id.isEmpty || id.length > kQoshniConversationIdMaxLength) {
    return 'invalid_message_id';
  }
  if (id.contains(' ') || id.contains('/')) {
    return 'invalid_message_id';
  }
  return null;
}

bool qoshniConversationSenderAuthorized(
  QoshniConversation conversation,
  String senderReference,
) {
  return conversation.includesParticipant(senderReference);
}

String previewFromMessageBody(String body) {
  final normalized = normalizeQoshniConversationMessageBody(body);
  if (normalized.length <= 80) {
    return normalized;
  }
  return '${normalized.substring(0, 77)}...';
}
