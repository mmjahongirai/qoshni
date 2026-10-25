import 'package:qoshni/features/home/presentation/data/service_category_id.dart';

class QoshniSearchVocabularyTerm {
  const QoshniSearchVocabularyTerm({
    required this.termId,
    required this.displayForms,
    required this.normalizedForms,
    this.categoryId,
    this.synonymGroupId,
  });

  final String termId;
  final List<String> displayForms;
  final List<String> normalizedForms;
  final ServiceCategoryId? categoryId;
  final String? synonymGroupId;
}

abstract class QoshniSearchVocabularyRepository {
  List<QoshniSearchVocabularyTerm> listTerms();

  List<String> synonymGroupVariants(String synonymGroupId);
}
