import 'package:qoshni/features/search/application/qoshni_search_text_normalizer.dart';
import 'package:qoshni/features/search/domain/qoshni_search_filters.dart';
import 'package:qoshni/features/search/domain/qoshni_search_index_record.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_understanding.dart';
import 'package:qoshni/features/search/domain/qoshni_search_rank_reason.dart';
import 'package:qoshni/features/search/domain/qoshni_search_ranked_candidate.dart';

const double kQoshniSearchSponsoredBoost = 0.05;
const double kQoshniSearchMinRelevanceForSponsoredBoost = 0.45;

QoshniSearchRankedCandidate qoshniSearchRankRecord({
  required QoshniSearchIndexRecord record,
  required QoshniSearchQueryUnderstanding understanding,
  required QoshniSearchFilters filters,
}) {
  final normalizedQuery = understanding.normalizedText;
  final normalizedTitle = qoshniSearchNormalizeQueryText(record.title);
  final haystack = qoshniSearchNormalizeQueryText(record.searchableHaystack);

  final reasons = <QoshniSearchRankReason>[];
  var relevance = 0.0;

  if (normalizedQuery.isNotEmpty && normalizedTitle == normalizedQuery) {
    relevance = 1.0;
    reasons.add(QoshniSearchRankReason.textMatch);
  } else if (normalizedQuery.isNotEmpty &&
      qoshniSearchNormalizedPrefixMatch(normalizedTitle, normalizedQuery)) {
    relevance = 0.78;
    reasons.add(QoshniSearchRankReason.titlePrefixMatch);
  } else {
    for (final term in understanding.matchTerms) {
      if (term.isEmpty) {
        continue;
      }
      if (normalizedTitle.contains(term)) {
        relevance = relevance > 0.85 ? relevance : 0.85;
        if (!reasons.contains(QoshniSearchRankReason.textMatch)) {
          reasons.add(QoshniSearchRankReason.textMatch);
        }
      } else if (haystack.contains(term)) {
        relevance = relevance > 0.62 ? relevance : 0.62;
        if (!reasons.contains(QoshniSearchRankReason.textMatch)) {
          reasons.add(QoshniSearchRankReason.textMatch);
        }
      }
    }
  }

  if (record.categoryId != null &&
      understanding.impliedCategoryIds.contains(record.categoryId)) {
    relevance = relevance > 0.55 ? relevance : 0.55;
    reasons.add(QoshniSearchRankReason.categoryImpliedMatch);
  }

  var qualityBoost = 0.0;
  if (record.signals.isOpen == true) {
    qualityBoost += 0.02;
    reasons.add(QoshniSearchRankReason.availabilityOpen);
  }

  final distance = _distanceMeters(record, filters);
  if (distance != null) {
    if (distance <= 500) {
      qualityBoost += 0.03;
      reasons.add(QoshniSearchRankReason.distanceNear);
    } else if (distance <= 1500) {
      qualityBoost += 0.01;
      reasons.add(QoshniSearchRankReason.distanceNear);
    }
  }

  final rating = record.signals.averageRating;
  if (rating != null && rating >= 4.5) {
    qualityBoost += 0.02;
    reasons.add(QoshniSearchRankReason.ratingHigh);
  }

  final trust = record.signals.demoTrustScore;
  if (trust != null && trust >= 85) {
    qualityBoost += 0.02;
    reasons.add(QoshniSearchRankReason.trustScoreHigh);
  }

  var sponsoredBoost = 0.0;
  if (record.signals.isSponsored &&
      relevance >= kQoshniSearchMinRelevanceForSponsoredBoost) {
    sponsoredBoost = kQoshniSearchSponsoredBoost;
    reasons.add(QoshniSearchRankReason.sponsoredBoostCapped);
  }

  final totalScore = relevance + qualityBoost + sponsoredBoost;

  return QoshniSearchRankedCandidate(
    record: record,
    relevanceScore: relevance,
    totalScore: totalScore,
    reasons: reasons,
  );
}

List<QoshniSearchRankedCandidate> qoshniSearchRankAndSort({
  required List<QoshniSearchIndexRecord> records,
  required QoshniSearchQueryUnderstanding understanding,
  required QoshniSearchFilters filters,
}) {
  final ranked = records
      .map(
        (record) => qoshniSearchRankRecord(
          record: record,
          understanding: understanding,
          filters: filters,
        ),
      )
      .toList(growable: false);
  ranked.sort(_compareRankedCandidates);
  return ranked;
}

int _compareRankedCandidates(
  QoshniSearchRankedCandidate a,
  QoshniSearchRankedCandidate b,
) {
  final relevanceDiff = b.relevanceScore.compareTo(a.relevanceScore);
  if ((a.relevanceScore - b.relevanceScore).abs() > 0.08) {
    return relevanceDiff;
  }
  final totalDiff = b.totalScore.compareTo(a.totalScore);
  if (totalDiff != 0) {
    return totalDiff;
  }
  final secondaryRelevance = b.relevanceScore.compareTo(a.relevanceScore);
  if (secondaryRelevance != 0) {
    return secondaryRelevance;
  }
  return a.record.stableId.compareTo(b.record.stableId);
}

int? _distanceMeters(
  QoshniSearchIndexRecord record,
  QoshniSearchFilters filters,
) {
  if (filters.searchLocation == null) {
    return null;
  }
  final lat = record.signals.latitude;
  final lng = record.signals.longitude;
  if (lat == null || lng == null) {
    return null;
  }
  return record.signals.distanceMeters;
}
