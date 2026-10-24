import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/search/application/qoshni_search_stable_id.dart';
import 'package:qoshni/features/search/data/qoshni_search_demo_ranking_signals.dart';
import 'package:qoshni/features/search/domain/qoshni_search_eligibility.dart';
import 'package:qoshni/features/search/domain/qoshni_search_index_record.dart';
import 'package:qoshni/features/search/domain/qoshni_search_ranking_signals.dart';

List<QoshniSearchIndexRecord> buildQoshniSearchIndexFromCatalog(
  List<SearchCatalogEntry> catalog,
) {
  final businessMeta = buildQoshniSearchDemoBusinessMetadata();
  return catalog.map((entry) {
    final stableId = qoshniSearchStableIdForCatalogEntry(entry);
    final meta = switch (entry.kind) {
      SearchEntryKind.category => qoshniSearchDemoMetadataForCategory(
          entry.categoryId!,
        ),
      SearchEntryKind.business => businessMeta[entry.businessId!] ??
          const QoshniSearchDemoRecordMetadata(
            eligibility: QoshniSearchEligibility.eligible(),
            signals: QoshniSearchRankingSignals(),
          ),
    };
    return QoshniSearchIndexRecord(
      stableId: stableId,
      kind: entry.kind,
      title: entry.title,
      subtitle: entry.subtitle,
      categoryLabel: entry.categoryLabel,
      categoryId: entry.categoryId,
      businessId: entry.businessId,
      eligibility: meta.eligibility,
      signals: meta.signals,
    );
  }).toList(growable: false);
}
