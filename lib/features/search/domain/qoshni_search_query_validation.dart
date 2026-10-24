enum QoshniSearchQueryValidationIssue {
  none,
  empty,
  whitespaceOnly,
  tooLong,
}

const int kQoshniSearchQueryMaxLength = 120;

QoshniSearchQueryValidationIssue qoshniSearchQueryValidationIssue(String raw) {
  if (raw.isEmpty) {
    return QoshniSearchQueryValidationIssue.empty;
  }
  if (raw.trim().isEmpty) {
    return QoshniSearchQueryValidationIssue.whitespaceOnly;
  }
  if (raw.length > kQoshniSearchQueryMaxLength) {
    return QoshniSearchQueryValidationIssue.tooLong;
  }
  return QoshniSearchQueryValidationIssue.none;
}

bool qoshniSearchQueryIsSearchable(String raw) {
  return qoshniSearchQueryValidationIssue(raw) ==
      QoshniSearchQueryValidationIssue.none;
}
