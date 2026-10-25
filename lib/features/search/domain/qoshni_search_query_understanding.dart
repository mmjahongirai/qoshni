import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/search/domain/qoshni_search_autocomplete_suggestion.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query.dart';
import 'package:qoshni/features/search/domain/qoshni_search_spelling_correction_candidate.dart';

/// Deterministic query understanding output (rule-based — not ML intent detection).
class QoshniSearchQueryUnderstanding {
  const QoshniSearchQueryUnderstanding({
    required this.query,
    required this.matchTerms,
    this.impliedCategoryIds = const {},
    this.spellingCorrection,
    this.autocompleteSuggestions = const [],
  });

  final QoshniSearchQuery query;
  final List<String> matchTerms;
  final Set<ServiceCategoryId> impliedCategoryIds;
  final QoshniSearchSpellingCorrectionCandidate? spellingCorrection;
  final List<QoshniSearchAutocompleteSuggestion> autocompleteSuggestions;

  String get originalText => query.originalText;
  String get normalizedText => query.normalizedText;
  bool get isSearchable => query.isSearchable;
}
