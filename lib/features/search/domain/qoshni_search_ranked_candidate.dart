import 'package:qoshni/features/search/domain/qoshni_search_index_record.dart';
import 'package:qoshni/features/search/domain/qoshni_search_rank_reason.dart';

class QoshniSearchRankedCandidate {
  const QoshniSearchRankedCandidate({
    required this.record,
    required this.relevanceScore,
    required this.totalScore,
    required this.reasons,
  });

  final QoshniSearchIndexRecord record;
  final double relevanceScore;
  final double totalScore;
  final List<QoshniSearchRankReason> reasons;
}
