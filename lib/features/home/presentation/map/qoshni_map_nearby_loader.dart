import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/service_category_id.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_branch_marker.dart';
import 'package:qoshni/features/location/domain/qoshni_current_location_snapshot.dart';
import 'package:qoshni/features/location/domain/qoshni_location_search_policy.dart';
import 'package:qoshni/features/search/application/qoshni_search_execution_coordinator.dart';
import 'package:qoshni/features/search/application/qoshni_search_query_processor.dart';
import 'package:qoshni/features/search/domain/qoshni_search_filters.dart';
import 'package:qoshni/features/search/domain/qoshni_search_location.dart';
import 'package:qoshni/features/search/domain/qoshni_search_page_result.dart';
import 'package:qoshni/features/search/domain/qoshni_search_request.dart';

/// Loads nearby search hits that include verified branch coordinates only.
Future<List<QoshniMapBranchMarker>> qoshniLoadVerifiedMapBranchMarkers({
  required QoshniSearchExecutionCoordinator execution,
  required QoshniSearchQueryProcessor queryProcessor,
  required List<SearchCatalogEntry> catalog,
  required QoshniCurrentLocationSnapshot deviceSnapshot,
  ServiceCategoryId? categoryScope,
}) async {
  final origin = QoshniSearchLocation(
    latitude: deviceSnapshot.coordinates.latitude,
    longitude: deviceSnapshot.coordinates.longitude,
  );
  final filters = QoshniSearchFilters(
    categoryScope: categoryScope,
    maxDistanceMeters: kQoshniSearchDefaultNearbyRadiusMeters,
    searchLocation: origin,
  );
  final understanding = queryProcessor.understand(rawQuery: '');
  final QoshniSearchPageResult page = await execution.execute(
    request: QoshniSearchRequest(rawQuery: '', filters: filters, pageSize: 20),
    catalog: catalog,
    understanding: understanding,
  );
  if (page.status != QoshniSearchExecutionStatus.success) {
    return const [];
  }
  return page.items
      .where((item) => item.hasVerifiedMapLocation)
      .map(
        (item) => QoshniMapBranchMarker(
          stableId: item.stableId,
          title: item.catalogEntry.title,
          location: item.verifiedBranchLocation!.searchLocation,
        ),
      )
      .toList(growable: false);
}
