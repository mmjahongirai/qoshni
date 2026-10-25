import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/search/domain/qoshni_search_suggestion_kind.dart';

class QoshniSearchAutocompleteSuggestion {
  const QoshniSearchAutocompleteSuggestion({
    required this.suggestionId,
    required this.displayText,
    required this.normalizedText,
    required this.kind,
    this.categoryId,
    this.synonymGroupId,
  });

  final String suggestionId;
  final String displayText;
  final String normalizedText;
  final QoshniSearchSuggestionKind kind;
  final ServiceCategoryId? categoryId;
  final String? synonymGroupId;
}
