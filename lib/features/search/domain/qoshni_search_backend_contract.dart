/// Backend search API contract (implemented server-side in Phase 16 WP3 — see docs/search_discovery_wp3.md).
///
/// When a FastAPI search route and derived index exist, align request/response JSON
/// with these shapes and enforce authorization at the route boundary.
class QoshniSearchBackendSearchRequestDto {
  const QoshniSearchBackendSearchRequestDto({
    required this.query,
    this.cursor,
    this.pageSize = 8,
    this.onlyOpen = false,
    this.maxDistanceMeters,
    this.categoryScope,
    this.searchLatitude,
    this.searchLongitude,
  });

  final String query;
  final String? cursor;
  final int pageSize;
  final bool onlyOpen;
  final int? maxDistanceMeters;
  final String? categoryScope;
  final double? searchLatitude;
  final double? searchLongitude;
}

class QoshniSearchBackendResultItemDto {
  const QoshniSearchBackendResultItemDto({
    required this.stableId,
    required this.kind,
    required this.title,
    required this.isSponsored,
  });

  final String stableId;
  final String kind;
  final String title;
  final bool isSponsored;
}

class QoshniSearchBackendSearchResponseDto {
  const QoshniSearchBackendSearchResponseDto({
    required this.items,
    this.nextCursor,
    this.queryFingerprint,
    this.catalogGeneration,
  });

  final List<QoshniSearchBackendResultItemDto> items;
  final String? nextCursor;
  final String? queryFingerprint;
  final int? catalogGeneration;
}

/// Expected index maintenance (future): idempotent consumers on validated domain
/// events (`business.updated`, `business.suspended`, `business.removed`, …) with
/// monotonic revision checks — mirrors other backend reconciliation patterns.
