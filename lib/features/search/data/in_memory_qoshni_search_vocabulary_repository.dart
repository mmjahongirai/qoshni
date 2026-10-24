import 'package:qoshni/features/search/data/qoshni_search_demo_vocabulary.dart';
import 'package:qoshni/features/search/domain/repositories/qoshni_search_vocabulary_repository.dart';

class InMemoryQoshniSearchVocabularyRepository
    implements QoshniSearchVocabularyRepository {
  InMemoryQoshniSearchVocabularyRepository({
    List<QoshniSearchVocabularyTerm>? seed,
    Map<String, List<String>>? synonymGroups,
  })  : _terms = List.unmodifiable(seed ?? buildQoshniSearchDemoVocabulary()),
        _synonymGroups = Map.unmodifiable(
          synonymGroups ??
              buildQoshniSearchSynonymGroupIndex(
                seed ?? buildQoshniSearchDemoVocabulary(),
              ),
        );

  final List<QoshniSearchVocabularyTerm> _terms;
  final Map<String, List<String>> _synonymGroups;

  @override
  List<QoshniSearchVocabularyTerm> listTerms() => _terms;

  @override
  List<String> synonymGroupVariants(String synonymGroupId) {
    return List.unmodifiable(_synonymGroups[synonymGroupId] ?? const []);
  }
}
