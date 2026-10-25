enum QoshniSystemMessageMutationResult {
  success,
  notFound,
  validationFailed,
  invalidTransition,
  duplicateMessageKey,
}

enum QoshniSystemMessageReadResult {
  success,
  notFound,
  invalidRecipient,
  alreadyRead,
}
