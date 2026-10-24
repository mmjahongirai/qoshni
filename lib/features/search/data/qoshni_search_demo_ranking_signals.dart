import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/search/domain/qoshni_search_eligibility.dart';
import 'package:qoshni/features/search/domain/qoshni_search_ranking_signals.dart';

/// Demo-only ranking/eligibility metadata — not authoritative production data.
class QoshniSearchDemoRecordMetadata {
  const QoshniSearchDemoRecordMetadata({
    required this.eligibility,
    required this.signals,
  });

  final QoshniSearchEligibility eligibility;
  final QoshniSearchRankingSignals signals;
}

QoshniSearchDemoRecordMetadata qoshniSearchDemoMetadataForCategory(
  ServiceCategoryId categoryId,
) {
  return const QoshniSearchDemoRecordMetadata(
    eligibility: QoshniSearchEligibility.eligible(),
    signals: QoshniSearchRankingSignals(isOpen: true),
  );
}

Map<MockBusinessId, QoshniSearchDemoRecordMetadata>
    buildQoshniSearchDemoBusinessMetadata() {
  return {
    MockBusinessId.barakaMarket: const QoshniSearchDemoRecordMetadata(
      eligibility: QoshniSearchEligibility.eligible(),
      signals: QoshniSearchRankingSignals(
        averageRating: 4.6,
        demoTrustScore: 82,
        distanceMeters: 450,
        isOpen: true,
        latitude: 41.311,
        longitude: 69.279,
      ),
    ),
    MockBusinessId.samarkandCafe: const QoshniSearchDemoRecordMetadata(
      eligibility: QoshniSearchEligibility.eligible(),
      signals: QoshniSearchRankingSignals(
        averageRating: 4.8,
        demoTrustScore: 88,
        distanceMeters: 900,
        isOpen: true,
        isSponsored: true,
        latitude: 41.315,
        longitude: 69.285,
      ),
    ),
    MockBusinessId.shifoPlus: const QoshniSearchDemoRecordMetadata(
      eligibility: QoshniSearchEligibility(
        status: QoshniSearchEligibilityStatus.suspended,
        reasonCode: 'demo_suspended',
      ),
      signals: QoshniSearchRankingSignals(
        averageRating: 4.2,
        demoTrustScore: 75,
        distanceMeters: 1200,
        isOpen: false,
      ),
    ),
    MockBusinessId.sampleTechCorner: const QoshniSearchDemoRecordMetadata(
      eligibility: QoshniSearchEligibility.eligible(),
      signals: QoshniSearchRankingSignals(
        averageRating: 4.1,
        demoTrustScore: 70,
        distanceMeters: 2100,
        isOpen: true,
      ),
    ),
    MockBusinessId.sampleStyleShop: const QoshniSearchDemoRecordMetadata(
      eligibility: QoshniSearchEligibility.eligible(),
      signals: QoshniSearchRankingSignals(
        averageRating: 3.9,
        demoTrustScore: 68,
        distanceMeters: 1800,
        isOpen: false,
      ),
    ),
  };
}
