import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/search/application/qoshni_search_edit_distance.dart';
import 'package:qoshni/features/search/application/qoshni_search_text_normalizer.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_understanding.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_validation.dart';
import 'package:qoshni/features/search/domain/qoshni_search_spelling_correction_candidate.dart';
import 'package:qoshni/features/search/domain/repositories/qoshni_search_vocabulary_repository.dart';

const int kQoshniSearchTypoMaxDistance = 2;
const int kQoshniSearchTypoMinQueryLength = 3;

class QoshniSearchQueryProcessor {
  QoshniSearchQueryProcessor(this._vocabularyRepository);

  final QoshniSearchVocabularyRepository _vocabularyRepository;
  int _referenceCounter = 0;

  QoshniSearchQuery parse({
    required String rawQuery,
    ServiceCategoryId? categoryScope,
  }) {
    final validation = qoshniSearchQueryValidationIssue(rawQuery);
    final normalized = validation == QoshniSearchQueryValidationIssue.none
        ? qoshniSearchNormalizeQueryText(rawQuery)
        : '';
    _referenceCounter++;
    return QoshniSearchQuery(
      originalText: rawQuery,
      normalizedText: normalized,
      validationIssue: validation,
      categoryScope: categoryScope,
      searchReferenceId:
          'search-q-${_referenceCounter.toString().padLeft(6, '0')}',
    );
  }

  QoshniSearchQueryUnderstanding understand({
    required String rawQuery,
    ServiceCategoryId? categoryScope,
  }) {
    final query = parse(rawQuery: rawQuery, categoryScope: categoryScope);
    if (!query.isSearchable) {
      return QoshniSearchQueryUnderstanding(
        query: query,
        matchTerms: const [],
      );
    }

    final matchTerms = <String>{query.normalizedText};
    final impliedCategories = <ServiceCategoryId>{};
    _expandSynonyms(query.normalizedText, matchTerms, impliedCategories);

    final spelling = _suggestSpellingCorrection(query.normalizedText, matchTerms);

    return QoshniSearchQueryUnderstanding(
      query: query,
      matchTerms: matchTerms.toList()..sort(),
      impliedCategoryIds: impliedCategories,
      spellingCorrection: spelling,
    );
  }

  void _expandSynonyms(
    String normalizedQuery,
    Set<String> matchTerms,
    Set<ServiceCategoryId> impliedCategories,
  ) {
    for (final term in _vocabularyRepository.listTerms()) {
      if (term.normalizedForms.contains(normalizedQuery)) {
        matchTerms.addAll(term.normalizedForms);
        if (term.categoryId != null) {
          impliedCategories.add(term.categoryId!);
        }
        final groupId = term.synonymGroupId;
        if (groupId != null) {
          matchTerms.addAll(_vocabularyRepository.synonymGroupVariants(groupId));
        }
      }
    }
    for (final term in _vocabularyRepository.listTerms()) {
      final groupId = term.synonymGroupId;
      if (groupId == null) {
        continue;
      }
      final variants = _vocabularyRepository.synonymGroupVariants(groupId);
      for (final variant in variants) {
        if (normalizedQuery.contains(variant) || variant.contains(normalizedQuery)) {
          matchTerms.addAll(variants);
          if (term.categoryId != null) {
            impliedCategories.add(term.categoryId!);
          }
        }
      }
    }
  }

  QoshniSearchSpellingCorrectionCandidate? _suggestSpellingCorrection(
    String normalizedQuery,
    Set<String> matchTerms,
  ) {
    if (normalizedQuery.length < kQoshniSearchTypoMinQueryLength) {
      return null;
    }
    final hasExact = _vocabularyRepository.listTerms().any(
      (term) => term.normalizedForms.any((form) => form == normalizedQuery),
    );
    if (hasExact || matchTerms.length > 1) {
      return null;
    }

    QoshniSearchSpellingCorrectionCandidate? best;
    for (final term in _vocabularyRepository.listTerms()) {
      for (final form in term.normalizedForms) {
        if (form.length < kQoshniSearchTypoMinQueryLength) {
          continue;
        }
        final distance =
            qoshniSearchLevenshteinDistance(normalizedQuery, form);
        if (distance == 0 || distance > kQoshniSearchTypoMaxDistance) {
          continue;
        }
        final display = term.displayForms.firstWhere(
          (d) => qoshniSearchNormalizeQueryText(d) == form,
          orElse: () => term.displayForms.first,
        );
        final candidate = QoshniSearchSpellingCorrectionCandidate(
          suggestedText: display,
          normalizedSuggestedText: form,
          distance: distance,
          vocabularyTermId: term.termId,
        );
        if (best == null || distance < best.distance) {
          best = candidate;
        }
      }
    }
    return best;
  }
}
