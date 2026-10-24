import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/search/application/qoshni_search_catalog_lookup.dart';
import 'package:qoshni/features/search/application/qoshni_search_cursor_codec.dart';
import 'package:qoshni/features/search/application/qoshni_search_hard_filter.dart';
import 'package:qoshni/features/search/application/qoshni_search_index_builder.dart';
import 'package:qoshni/features/search/application/qoshni_search_query_fingerprint.dart';
import 'package:qoshni/features/search/application/qoshni_search_query_processor.dart';
import 'package:qoshni/features/search/application/qoshni_search_ranking_engine.dart';
import 'package:qoshni/features/search/application/qoshni_search_request_validator.dart';
import 'package:qoshni/features/search/data/in_memory_qoshni_search_index_repository.dart';
import 'package:qoshni/features/search/domain/qoshni_search_index_record.dart';
import 'package:qoshni/features/search/domain/qoshni_search_page_result.dart';
import 'package:qoshni/features/search/domain/qoshni_search_ranked_candidate.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_understanding.dart';
import 'package:qoshni/features/search/domain/qoshni_search_request.dart';
import 'package:qoshni/features/search/domain/qoshni_search_result_item.dart';
import 'package:qoshni/features/search/domain/repositories/qoshni_search_index_repository.dart';

class QoshniSearchExecutionService {
  QoshniSearchExecutionService({
    required QoshniSearchQueryProcessor queryProcessor,
    required QoshniSearchIndexRepository indexRepository,
  })  : _queryProcessor = queryProcessor,
        _indexRepository = indexRepository;

  final QoshniSearchQueryProcessor _queryProcessor;
  final QoshniSearchIndexRepository _indexRepository;

  QoshniSearchPageResult execute({
    required QoshniSearchRequest request,
    required List<SearchCatalogEntry> catalog,
    QoshniSearchQueryUnderstanding? understanding,
  }) {
    final validation = qoshniSearchValidateRequest(request);
    if (!validation.isValid) {
      return const QoshniSearchPageResult(
        status: QoshniSearchExecutionStatus.invalidRequest,
        items: [],
      );
    }

    _syncIndexFromCatalog(catalog);

    final resolvedUnderstanding = understanding ??
        _queryProcessor.understand(rawQuery: request.rawQuery);

    final fingerprint = qoshniSearchQueryFingerprint(
      understanding: resolvedUnderstanding,
      filters: request.filters,
    );
    final generation = _indexRepository.catalogGeneration;

    if (!resolvedUnderstanding.isSearchable) {
      return QoshniSearchPageResult(
        status: QoshniSearchExecutionStatus.success,
        items: const [],
        queryFingerprint: fingerprint,
        catalogGeneration: generation,
      );
    }

    QoshniSearchCursorPayload? cursorPayload;
    if (request.cursor != null && request.cursor!.isNotEmpty) {
      cursorPayload = qoshniSearchDecodeCursor(request.cursor);
      if (cursorPayload == null ||
          cursorPayload.queryFingerprint != fingerprint ||
          cursorPayload.catalogGeneration != generation) {
        return const QoshniSearchPageResult(
          status: QoshniSearchExecutionStatus.invalidCursor,
          items: [],
        );
      }
    }

    final eligible = _indexRepository.listRecords().where((record) {
      return qoshniSearchRecordPassesHardFilters(
        record: record,
        understanding: resolvedUnderstanding,
        filters: request.filters,
      );
    }).toList(growable: false);

    final ranked = qoshniSearchRankAndSort(
      records: eligible,
      understanding: resolvedUnderstanding,
      filters: request.filters,
    );

    final Iterable<QoshniSearchRankedCandidate> rankedAfterCursor =
        cursorPayload == null
        ? ranked
        : ranked.where(
            (candidate) => qoshniSearchCursorIsAfterCandidate(
              cursor: cursorPayload!,
              candidate: candidate,
            ),
          );

    final window = rankedAfterCursor.toList(growable: false);
    final pageSize = validation.pageSize;
    final slice = window.take(pageSize).toList(growable: false);

    final items = <QoshniSearchResultItem>[];
    for (final candidate in slice) {
      final entry = qoshniSearchCatalogEntryForStableId(
        catalog,
        candidate.record.stableId,
      );
      if (entry == null) {
        continue;
      }
      items.add(
        QoshniSearchResultItem(
          stableId: candidate.record.stableId,
          catalogEntry: entry,
          totalScore: candidate.totalScore,
          relevanceScore: candidate.relevanceScore,
          rankReasons: candidate.reasons,
          showSponsoredLabel: candidate.record.signals.isSponsored,
        ),
      );
    }

    String? nextCursor;
    if (window.length > pageSize && slice.isNotEmpty) {
      final last = slice.last;
      nextCursor = qoshniSearchEncodeCursor(
        QoshniSearchCursorPayload(
          version: kQoshniSearchCursorVersion,
          queryFingerprint: fingerprint,
          catalogGeneration: generation,
          afterTotalScore: last.totalScore,
          afterRelevanceScore: last.relevanceScore,
          afterStableId: last.record.stableId,
        ),
      );
    }

    return QoshniSearchPageResult(
      status: QoshniSearchExecutionStatus.success,
      items: items,
      nextCursor: nextCursor,
      queryFingerprint: fingerprint,
      catalogGeneration: generation,
    );
  }

  void _syncIndexFromCatalog(List<SearchCatalogEntry> catalog) {
    final built = buildQoshniSearchIndexFromCatalog(catalog);
    final repo = _indexRepository;
    if (repo is InMemoryQoshniSearchIndexRepository) {
      final nextKey = _catalogStableKey(built);
      final currentKey = _catalogStableKey(repo.listRecords());
      if (nextKey != currentKey) {
        repo.replaceIndex(built);
      }
    }
  }

  String _catalogStableKey(List<QoshniSearchIndexRecord> records) {
    return records.map((r) => r.stableId).join(',');
  }
}
