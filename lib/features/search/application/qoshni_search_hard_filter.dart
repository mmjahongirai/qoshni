import 'package:qoshni/features/search/application/qoshni_search_text_normalizer.dart';
import 'package:qoshni/features/search/domain/qoshni_search_filters.dart';
import 'package:qoshni/features/search/domain/qoshni_search_index_record.dart';
import 'package:qoshni/features/search/domain/qoshni_search_location.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_understanding.dart';

bool qoshniSearchRecordPassesHardFilters({
  required QoshniSearchIndexRecord record,
  required QoshniSearchQueryUnderstanding understanding,
  required QoshniSearchFilters filters,
}) {
  if (!record.eligibility.isEligible) {
    return false;
  }
  if (filters.categoryScope != null &&
      record.categoryId != null &&
      record.categoryId != filters.categoryScope) {
    return false;
  }
  if (understanding.query.categoryScope != null &&
      record.categoryId != null &&
      record.categoryId != understanding.query.categoryScope) {
    return false;
  }
  if (filters.onlyOpen && record.signals.isOpen != true) {
    return false;
  }
  final maxDistance = filters.maxDistanceMeters;
  if (maxDistance != null) {
    final distance = _effectiveDistanceMeters(record, filters.searchLocation);
    if (distance == null || distance > maxDistance) {
      return false;
    }
  }
  return _recordMatchesUnderstanding(record, understanding);
}

bool _recordMatchesUnderstanding(
  QoshniSearchIndexRecord record,
  QoshniSearchQueryUnderstanding understanding,
) {
  final haystack = qoshniSearchNormalizeQueryText(record.searchableHaystack);
  for (final term in understanding.matchTerms) {
    if (term.isNotEmpty && haystack.contains(term)) {
      return true;
    }
  }
  if (record.categoryId != null &&
      understanding.impliedCategoryIds.contains(record.categoryId)) {
    return true;
  }
  return false;
}

int? _effectiveDistanceMeters(
  QoshniSearchIndexRecord record,
  QoshniSearchLocation? searchLocation,
) {
  if (searchLocation == null) {
    return null;
  }
  final lat = record.signals.latitude;
  final lng = record.signals.longitude;
  if (lat == null || lng == null) {
    return null;
  }
  final demoDistance = record.signals.distanceMeters;
  if (demoDistance != null) {
    return demoDistance;
  }
  return null;
}
