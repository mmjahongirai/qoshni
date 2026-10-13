import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/routing/route_paths.dart';

void openMockBusinessDetail(BuildContext context, MockBusinessId businessId) {
  context.pushNamed(
    RouteNames.businessDetail,
    pathParameters: {'businessId': businessId.routeParam},
  );
}

void openSearchCatalogEntry(BuildContext context, SearchCatalogEntry entry) {
  switch (entry.kind) {
    case SearchEntryKind.business:
      final businessId = entry.businessId;
      if (businessId != null) {
        openMockBusinessDetail(context, businessId);
      }
    case SearchEntryKind.category:
      final categoryId = entry.categoryId;
      if (categoryId != null) {
        context.pushNamed(
          RouteNames.categoryListing,
          pathParameters: {'categoryId': categoryId.name},
        );
      }
  }
}
