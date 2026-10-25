import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/localization/generated/app_localizations_en.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/search/application/qoshni_search_catalog_matcher.dart';
import 'package:qoshni/features/search/application/qoshni_search_cursor_codec.dart';
import 'package:qoshni/features/search/application/qoshni_search_execution_service.dart';
import 'package:qoshni/features/search/application/qoshni_search_query_processor.dart';
import 'package:qoshni/features/search/application/qoshni_search_ranking_engine.dart';
import 'package:qoshni/features/search/data/in_memory_qoshni_search_index_repository.dart';
import 'package:qoshni/features/search/data/in_memory_qoshni_search_vocabulary_repository.dart';
import 'package:qoshni/features/search/domain/qoshni_search_eligibility.dart';
import 'package:qoshni/features/search/domain/qoshni_search_filters.dart';
import 'package:qoshni/features/search/domain/qoshni_search_index_record.dart';
import 'package:qoshni/features/search/domain/qoshni_search_location.dart';
import 'package:qoshni/features/search/domain/qoshni_search_page_result.dart';
import 'package:qoshni/features/search/domain/qoshni_search_rank_reason.dart';
import 'package:qoshni/features/search/domain/qoshni_search_ranking_signals.dart';
import 'package:qoshni/features/search/domain/qoshni_search_request.dart';

void main() {
  late QoshniSearchQueryProcessor processor;
  late QoshniSearchExecutionService execution;
  late InMemoryQoshniSearchIndexRepository indexRepo;
  late List<SearchCatalogEntry> catalog;

  setUp(() {
    final vocabulary = InMemoryQoshniSearchVocabularyRepository();
    processor = QoshniSearchQueryProcessor(vocabulary);
    indexRepo = InMemoryQoshniSearchIndexRepository();
    execution = QoshniSearchExecutionService(
      queryProcessor: processor,
      indexRepository: indexRepo,
    );
    final l10n = AppLocalizationsEn();
    catalog = buildSearchCatalog(l10n, const ColorScheme.light());
  });

  test('suspended businesses are hard-filtered before ranking', () {
    final understanding = processor.understand(rawQuery: 'shifo');
    final page = execution.execute(
      request: const QoshniSearchRequest(rawQuery: 'shifo'),
      catalog: catalog,
      understanding: understanding,
    );
    expect(page.status, QoshniSearchExecutionStatus.success);
    expect(
      page.items.any(
        (i) => i.catalogEntry.businessId == MockBusinessId.shifoPlus,
      ),
      isFalse,
    );
  });

  test('pharmacy synonym matches category and ranks deterministically', () {
    final understanding = processor.understand(rawQuery: 'apteka');
    final page = execution.execute(
      request: const QoshniSearchRequest(rawQuery: 'apteka', pageSize: 20),
      catalog: catalog,
      understanding: understanding,
    );
    expect(page.items, isNotEmpty);
    final ids = page.items.map((e) => e.stableId).toList();
    final again = execution.execute(
      request: const QoshniSearchRequest(rawQuery: 'apteka', pageSize: 20),
      catalog: catalog,
      understanding: understanding,
    );
    expect(again.items.map((e) => e.stableId).toList(), ids);
  });

  test('cursor pagination returns no duplicates across pages', () {
    const pageSize = 3;
    final understanding = processor.understand(rawQuery: 'a');
    final seen = <String>{};
    String? cursor;
    for (var pageIndex = 0; pageIndex < 20; pageIndex++) {
      final page = execution.execute(
        request: QoshniSearchRequest(
          rawQuery: 'a',
          pageSize: pageSize,
          cursor: cursor,
        ),
        catalog: catalog,
        understanding: understanding,
      );
      expect(page.status, QoshniSearchExecutionStatus.success);
      for (final item in page.items) {
        expect(seen.add(item.stableId), isTrue);
      }
      if (page.nextCursor == null) {
        break;
      }
      cursor = page.nextCursor;
    }
    expect(seen, isNotEmpty);
  });

  test('exhausted results omit next cursor', () {
    final understanding = processor.understand(rawQuery: 'zzzznotfound');
    final page = execution.execute(
      request: const QoshniSearchRequest(rawQuery: 'zzzznotfound'),
      catalog: catalog,
      understanding: understanding,
    );
    expect(page.items, isEmpty);
    expect(page.nextCursor, isNull);
  });

  test('invalid page size rejected', () {
    final page = execution.execute(
      request: const QoshniSearchRequest(rawQuery: 'a', pageSize: 99),
      catalog: catalog,
    );
    expect(page.status, QoshniSearchExecutionStatus.invalidRequest);
  });

  test('malformed cursor rejected', () {
    final page = execution.execute(
      request: const QoshniSearchRequest(
        rawQuery: 'a',
        cursor: 'not-a-valid-cursor',
      ),
      catalog: catalog,
    );
    expect(page.status, QoshniSearchExecutionStatus.invalidCursor);
  });

  test('catalog generation mismatch invalidates cursor', () {
    final first = execution.execute(
      request: const QoshniSearchRequest(rawQuery: 'a', pageSize: 2),
      catalog: catalog,
    );
    expect(first.nextCursor, isNotNull);
    indexRepo.replaceIndex(indexRepo.listRecords());
    final second = execution.execute(
      request: QoshniSearchRequest(
        rawQuery: 'a',
        pageSize: 2,
        cursor: first.nextCursor,
      ),
      catalog: catalog,
    );
    expect(second.status, QoshniSearchExecutionStatus.invalidCursor);
  });

  test('sponsored label only when explicit demo flag is set', () {
    final understanding = processor.understand(rawQuery: 'cafe');
    final page = execution.execute(
      request: const QoshniSearchRequest(rawQuery: 'cafe', pageSize: 10),
      catalog: catalog,
      understanding: understanding,
    );
    final sponsored = page.items.where((i) => i.showSponsoredLabel).toList();
    expect(sponsored.length, lessThanOrEqualTo(1));
    if (sponsored.isNotEmpty) {
      expect(
        sponsored.first.catalogEntry.businessId,
        MockBusinessId.samarkandCafe,
      );
      expect(
        sponsored.first.rankReasons,
        contains(QoshniSearchRankReason.sponsoredBoostCapped),
      );
    }
  });

  test('significantly more relevant result outranks sponsored boost', () {
    final understanding = processor.understand(rawQuery: 'baraka');
    final page = execution.execute(
      request: const QoshniSearchRequest(rawQuery: 'baraka', pageSize: 5),
      catalog: catalog,
      understanding: understanding,
    );
    expect(page.items.first.catalogEntry.businessId, MockBusinessId.barakaMarket);
  });

  test('ranking engine treats missing metadata as unknown', () {
    const record = QoshniSearchIndexRecord(
      stableId: 'business:sample',
      kind: SearchEntryKind.business,
      title: 'Alpha Shop',
      subtitle: '',
      categoryLabel: 'Retail',
      eligibility: QoshniSearchEligibility.eligible(),
      signals: QoshniSearchRankingSignals(),
    );
    final understanding = processor.understand(rawQuery: 'alpha');
    final ranked = qoshniSearchRankRecord(
      record: record,
      understanding: understanding,
      filters: const QoshniSearchFilters(),
    );
    expect(
      ranked.reasons,
      anyElement(
        isIn([
          QoshniSearchRankReason.textMatch,
          QoshniSearchRankReason.titlePrefixMatch,
        ]),
      ),
    );
    expect(ranked.reasons, isNot(contains(QoshniSearchRankReason.ratingHigh)));
    expect(
      ranked.reasons,
      isNot(contains(QoshniSearchRankReason.trustScoreHigh)),
    );
  });

  test('distance boost applies only with search location and coordinates', () {
    const record = QoshniSearchIndexRecord(
      stableId: 'business:near',
      kind: SearchEntryKind.business,
      title: 'Near Place',
      subtitle: '',
      categoryLabel: 'Food',
      categoryId: ServiceCategoryId.restaurants,
      eligibility: QoshniSearchEligibility.eligible(),
      signals: QoshniSearchRankingSignals(
        distanceMeters: 400,
        latitude: 41.3,
        longitude: 69.2,
      ),
    );
    final understanding = processor.understand(rawQuery: 'near');
    final withoutLocation = qoshniSearchRankRecord(
      record: record,
      understanding: understanding,
      filters: const QoshniSearchFilters(),
    );
    expect(
      withoutLocation.reasons,
      isNot(contains(QoshniSearchRankReason.distanceNear)),
    );

    final withLocation = qoshniSearchRankRecord(
      record: record,
      understanding: understanding,
      filters: const QoshniSearchFilters(
        searchLocation: QoshniSearchLocation(latitude: 41.31, longitude: 69.27),
      ),
    );
    expect(withLocation.reasons, contains(QoshniSearchRankReason.distanceNear));
  });

  test('WP1 catalog matcher regression', () {
    final understanding = processor.understand(rawQuery: 'apteka');
    final legacy = filterSearchCatalogWithUnderstanding(catalog, understanding);
    final page = execution.execute(
      request: const QoshniSearchRequest(rawQuery: 'apteka', pageSize: 20),
      catalog: catalog,
      understanding: understanding,
    );
    expect(page.status, QoshniSearchExecutionStatus.success);
    final executionTitles =
        page.items.map((i) => i.catalogEntry.title).toSet();
    final legacyTitles = legacy.map((e) => e.title).toSet();
    expect(legacyTitles.containsAll(executionTitles), isTrue);
    expect(executionTitles, contains(AppLocalizationsEn().categoryPharmacy));
    expect(legacyTitles, contains(AppLocalizationsEn().nearbyMock3Name));
    expect(executionTitles, isNot(contains(AppLocalizationsEn().nearbyMock3Name)));
  });

  test('cursor codec round-trip', () {
    const payload = QoshniSearchCursorPayload(
      version: kQoshniSearchCursorVersion,
      queryFingerprint: 'apteka||',
      catalogGeneration: 2,
      afterTotalScore: 0.91,
      afterRelevanceScore: 0.85,
      afterStableId: 'business:baraka-market',
    );
    final encoded = qoshniSearchEncodeCursor(payload);
    final decoded = qoshniSearchDecodeCursor(encoded)!;
    expect(decoded.afterStableId, payload.afterStableId);
    expect(decoded.queryFingerprint, payload.queryFingerprint);
    expect(decoded.catalogGeneration, payload.catalogGeneration);
  });
}
