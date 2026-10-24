import 'package:qoshni/features/search/application/qoshni_search_text_normalizer.dart';
import 'package:qoshni/features/search/domain/qoshni_search_filters.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_understanding.dart';

String qoshniSearchQueryFingerprint({
  required QoshniSearchQueryUnderstanding understanding,
  required QoshniSearchFilters filters,
}) {
  final normalized = qoshniSearchNormalizeQueryText(understanding.originalText);
  final categoryScope = understanding.query.categoryScope?.name ??
      filters.categoryScope?.name ??
      '';
  final location = filters.searchLocation;
  final locationPart = location == null
      ? ''
      : '${location.latitude}:${location.longitude}';
  return [
    normalized,
    categoryScope,
    filters.onlyOpen ? 'open' : '',
    filters.maxDistanceMeters?.toString() ?? '',
    locationPart,
  ].join('|');
}
