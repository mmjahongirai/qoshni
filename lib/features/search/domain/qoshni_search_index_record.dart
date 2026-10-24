import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/search/domain/qoshni_search_eligibility.dart';
import 'package:qoshni/features/search/domain/qoshni_search_ranking_signals.dart';

class QoshniSearchIndexRecord {
  const QoshniSearchIndexRecord({
    required this.stableId,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.categoryLabel,
    required this.eligibility,
    required this.signals,
    this.categoryId,
    this.businessId,
  });

  final String stableId;
  final SearchEntryKind kind;
  final String title;
  final String subtitle;
  final String categoryLabel;
  final ServiceCategoryId? categoryId;
  final MockBusinessId? businessId;
  final QoshniSearchEligibility eligibility;
  final QoshniSearchRankingSignals signals;

  String get searchableHaystack => '$title $categoryLabel $subtitle';
}
