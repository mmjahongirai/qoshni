/// Suggested correction — does not replace [QoshniSearchQuery.originalText].
class QoshniSearchSpellingCorrectionCandidate {
  const QoshniSearchSpellingCorrectionCandidate({
    required this.suggestedText,
    required this.normalizedSuggestedText,
    required this.distance,
    required this.vocabularyTermId,
  });

  final String suggestedText;
  final String normalizedSuggestedText;
  final int distance;
  final String vocabularyTermId;
}
