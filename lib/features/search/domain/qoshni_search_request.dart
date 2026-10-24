import 'package:qoshni/features/search/domain/qoshni_search_filters.dart';

const int kQoshniSearchDefaultPageSize = 8;
const int kQoshniSearchMaxPageSize = 20;
const int kQoshniSearchMinPageSize = 1;

class QoshniSearchRequest {
  const QoshniSearchRequest({
    required this.rawQuery,
    this.filters = const QoshniSearchFilters(),
    this.pageSize = kQoshniSearchDefaultPageSize,
    this.cursor,
  });

  final String rawQuery;
  final QoshniSearchFilters filters;
  final int pageSize;
  final String? cursor;
}
