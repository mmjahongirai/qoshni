import 'package:qoshni/features/search/application/qoshni_search_text_normalizer.dart';
import 'package:qoshni/features/search/domain/qoshni_search_autocomplete_suggestion.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_validation.dart';
import 'package:qoshni/features/search/domain/qoshni_search_suggestion_kind.dart';
import 'package:qoshni/features/search/domain/repositories/qoshni_search_vocabulary_repository.dart';

const int kQoshniSearchAutocompleteDefaultLimit = 8;
const int kQoshniSearchAutocompleteMinPrefixLength = 1;

class QoshniSearchAutocompleteService {
  QoshniSearchAutocompleteService(this._vocabularyRepository);

  final QoshniSearchVocabularyRepository _vocabularyRepository;

  List<QoshniSearchAutocompleteSuggestion> suggest({
    required String rawQuery,
    int limit = kQoshniSearchAutocompleteDefaultLimit,
  }) {
    if (!qoshniSearchQueryIsSearchable(rawQuery)) {
      return const [];
    }
    final normalized = qoshniSearchNormalizeQueryText(rawQuery);
    if (normalized.length < kQoshniSearchAutocompleteMinPrefixLength) {
      return const [];
    }

    final matches = <QoshniSearchAutocompleteSuggestion>[];
    final seen = <String>{};

    for (final term in _vocabularyRepository.listTerms()) {
      for (final display in term.displayForms) {
        final normalizedForm = qoshniSearchNormalizeQueryText(display);
        if (!normalizedForm.startsWith(normalized)) {
          continue;
        }
        if (!seen.add(normalizedForm)) {
          continue;
        }
        matches.add(
          QoshniSearchAutocompleteSuggestion(
            suggestionId: '${term.termId}-$normalizedForm',
            displayText: display,
            normalizedText: normalizedForm,
            kind: term.synonymGroupId != null
                ? QoshniSearchSuggestionKind.synonymGroup
                : QoshniSearchSuggestionKind.curatedTerm,
            categoryId: term.categoryId,
            synonymGroupId: term.synonymGroupId,
          ),
        );
      }
    }

    matches.sort((a, b) => a.displayText.length.compareTo(b.displayText.length));
    if (matches.length <= limit) {
      return matches;
    }
    return matches.sublist(0, limit);
  }
}
