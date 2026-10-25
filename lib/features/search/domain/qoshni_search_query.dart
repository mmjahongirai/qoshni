import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_validation.dart';

/// User-entered search input with preserved original text and derived normalization.
class QoshniSearchQuery {
  const QoshniSearchQuery({
    required this.originalText,
    required this.normalizedText,
    required this.validationIssue,
    this.categoryScope,
    this.searchReferenceId,
  });

  final String originalText;
  final String normalizedText;
  final QoshniSearchQueryValidationIssue validationIssue;
  final ServiceCategoryId? categoryScope;
  final String? searchReferenceId;

  bool get isSearchable =>
      validationIssue == QoshniSearchQueryValidationIssue.none &&
      normalizedText.isNotEmpty;
}
