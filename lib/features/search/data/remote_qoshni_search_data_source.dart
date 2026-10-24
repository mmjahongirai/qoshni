import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/search/data/qoshni_search_remote_dtos.dart';
import 'package:qoshni/features/search/domain/qoshni_search_page_result.dart';
import 'package:qoshni/features/search/domain/qoshni_search_request.dart';
import 'package:qoshni/features/search/domain/qoshni_search_location.dart';
import 'package:qoshni/features/search/domain/qoshni_search_result_item.dart';
import 'package:qoshni/features/search/domain/qoshni_search_verified_branch_location.dart';

class RemoteQoshniSearchDataSource {
  RemoteQoshniSearchDataSource({
    required ApiClient apiClient,
  }) : _dio = apiClient.dio;

  final Dio _dio;

  Future<QoshniSearchPageResult> search({
    required QoshniSearchRequest request,
    required String accessToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/search/discovery',
        data: QoshniSearchRemoteRequestDto(
          query: request.rawQuery,
          cursor: request.cursor,
          pageSize: request.pageSize,
          onlyOpen: request.filters.onlyOpen,
          maxDistanceMeters: request.filters.maxDistanceMeters,
          categoryScope: request.filters.categoryScope?.name,
          searchLatitude: request.filters.searchLocation?.latitude,
          searchLongitude: request.filters.searchLocation?.longitude,
        ).toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      final dto = QoshniSearchRemoteResponseDto.fromJson(response.data ?? {});
      final items = dto.items.map(_mapItem).toList(growable: false);
      return QoshniSearchPageResult(
        status: QoshniSearchExecutionStatus.success,
        items: items,
        nextCursor: dto.nextCursor,
        queryFingerprint: dto.queryFingerprint,
        catalogGeneration: dto.catalogGeneration,
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 400) {
        final code = _errorCode(error.response?.data);
        if (code == 'invalid_cursor') {
          return const QoshniSearchPageResult(
            status: QoshniSearchExecutionStatus.invalidCursor,
            items: [],
          );
        }
        return const QoshniSearchPageResult(
          status: QoshniSearchExecutionStatus.invalidRequest,
          items: [],
        );
      }
      if (status == 401 || status == 403) {
        return const QoshniSearchPageResult(
          status: QoshniSearchExecutionStatus.remoteUnauthorized,
          items: [],
        );
      }
      return const QoshniSearchPageResult(
        status: QoshniSearchExecutionStatus.remoteUnavailable,
        items: [],
      );
    }
  }

  String? _errorCode(Object? data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }
    final error = data['error'];
    if (error is Map<String, dynamic>) {
      return error['code'] as String?;
    }
    return null;
  }

  QoshniSearchResultItem _mapItem(QoshniSearchRemoteResultItemDto dto) {
    final kind = dto.kind == 'category'
        ? SearchEntryKind.category
        : SearchEntryKind.business;
    QoshniSearchVerifiedBranchLocation? verifiedLocation;
    final lat = dto.branchLatitude;
    final lng = dto.branchLongitude;
    if (lat != null && lng != null) {
      verifiedLocation = QoshniSearchVerifiedBranchLocation(
        searchLocation: QoshniSearchLocation(latitude: lat, longitude: lng),
      );
    }
    return QoshniSearchResultItem(
      stableId: dto.stableId,
      catalogEntry: SearchCatalogEntry(
        kind: kind,
        title: dto.title,
        subtitle: '',
        categoryLabel: '',
        icon: Icons.manage_search_outlined,
        accent: Colors.blueGrey,
      ),
      totalScore: 0,
      relevanceScore: 0,
      rankReasons: const [],
      showSponsoredLabel: dto.isSponsored,
      verifiedBranchLocation: verifiedLocation,
    );
  }
}
