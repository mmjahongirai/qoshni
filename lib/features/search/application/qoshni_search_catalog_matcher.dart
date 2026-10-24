import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/search/application/qoshni_search_text_normalizer.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_understanding.dart';

bool qoshniSearchCatalogEntryMatches(
  SearchCatalogEntry entry,
  QoshniSearchQueryUnderstanding understanding,
) {
  if (!understanding.isSearchable) {
    return false;
  }
  if (understanding.query.categoryScope != null &&
      entry.categoryId != null &&
      entry.categoryId != understanding.query.categoryScope) {
    return false;
  }

  final haystack = qoshniSearchNormalizeQueryText(
    [entry.title, entry.categoryLabel, entry.subtitle].join(' '),
  );

  for (final term in understanding.matchTerms) {
    if (term.isEmpty) {
      continue;
    }
    if (haystack.contains(term)) {
      return true;
    }
  }
  if (entry.categoryId != null &&
      understanding.impliedCategoryIds.contains(entry.categoryId)) {
    return true;
  }
  return false;
}

List<SearchCatalogEntry> filterSearchCatalogWithUnderstanding(
  List<SearchCatalogEntry> catalog,
  QoshniSearchQueryUnderstanding understanding,
) {
  if (!understanding.isSearchable) {
    return const [];
  }
  return catalog
      .where((entry) => qoshniSearchCatalogEntryMatches(entry, understanding))
      .toList(growable: false);
}
