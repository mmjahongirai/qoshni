class QoshniSearchRemoteRequestDto {
  const QoshniSearchRemoteRequestDto({
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

  Map<String, dynamic> toJson() => {
        'query': query,
        if (cursor != null) 'cursor': cursor,
        'page_size': pageSize,
        'only_open': onlyOpen,
        if (maxDistanceMeters != null) 'max_distance_meters': maxDistanceMeters,
        if (categoryScope != null) 'category_scope': categoryScope,
        if (searchLatitude != null) 'search_latitude': searchLatitude,
        if (searchLongitude != null) 'search_longitude': searchLongitude,
      };
}

class QoshniSearchRemoteResultItemDto {
  QoshniSearchRemoteResultItemDto({
    required this.stableId,
    required this.kind,
    required this.title,
    required this.isSponsored,
    this.branchLatitude,
    this.branchLongitude,
  });

  factory QoshniSearchRemoteResultItemDto.fromJson(Map<String, dynamic> json) {
    return QoshniSearchRemoteResultItemDto(
      stableId: json['stable_id'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      isSponsored: json['is_sponsored'] as bool? ?? false,
      branchLatitude: (json['branch_latitude'] as num?)?.toDouble(),
      branchLongitude: (json['branch_longitude'] as num?)?.toDouble(),
    );
  }

  final String stableId;
  final String kind;
  final String title;
  final bool isSponsored;
  final double? branchLatitude;
  final double? branchLongitude;
}

class QoshniSearchRemoteResponseDto {
  QoshniSearchRemoteResponseDto({
    required this.items,
    this.nextCursor,
    this.queryFingerprint,
    this.catalogGeneration,
  });

  factory QoshniSearchRemoteResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return QoshniSearchRemoteResponseDto(
      items: rawItems
          .map(
            (item) => QoshniSearchRemoteResultItemDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
      nextCursor: json['next_cursor'] as String?,
      queryFingerprint: json['query_fingerprint'] as String?,
      catalogGeneration: json['catalog_generation'] as int?,
    );
  }

  final List<QoshniSearchRemoteResultItemDto> items;
  final String? nextCursor;
  final String? queryFingerprint;
  final int? catalogGeneration;
}
