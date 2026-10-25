import 'package:qoshni/features/search/domain/qoshni_search_result_item.dart';

enum QoshniSearchExecutionStatus {
  success,
  invalidRequest,
  invalidCursor,
  remoteUnauthorized,
  remoteUnavailable,
}

class QoshniSearchPageResult {
  const QoshniSearchPageResult({
    required this.status,
    required this.items,
    this.nextCursor,
    this.queryFingerprint,
    this.catalogGeneration,
  });

  final QoshniSearchExecutionStatus status;
  final List<QoshniSearchResultItem> items;
  final String? nextCursor;
  final String? queryFingerprint;
  final int? catalogGeneration;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}
