import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/search/domain/qoshni_search_rank_reason.dart';
import 'package:qoshni/features/search/domain/qoshni_search_verified_branch_location.dart';

class QoshniSearchResultItem {
  const QoshniSearchResultItem({
    required this.stableId,
    required this.catalogEntry,
    required this.totalScore,
    required this.relevanceScore,
    required this.rankReasons,
    required this.showSponsoredLabel,
    this.verifiedBranchLocation,
  });

  final String stableId;
  final SearchCatalogEntry catalogEntry;
  final double totalScore;
  final double relevanceScore;
  final List<QoshniSearchRankReason> rankReasons;
  final bool showSponsoredLabel;
  final QoshniSearchVerifiedBranchLocation? verifiedBranchLocation;

  bool get hasVerifiedMapLocation => verifiedBranchLocation != null;
}
