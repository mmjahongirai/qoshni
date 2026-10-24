enum QoshniConversationMutationResult {
  success,
  notFound,
  validationFailed,
  invalidTransition,
  notParticipant,
  conversationNotOpen,
}

enum QoshniConversationSendMessageResult {
  success,
  notFound,
  validationFailed,
  notParticipant,
  conversationNotOpen,
  invalidReplyTarget,
}
