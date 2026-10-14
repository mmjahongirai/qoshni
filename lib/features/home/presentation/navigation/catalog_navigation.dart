import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';
import 'package:qoshni/routing/route_paths.dart';

void openCatalogItemDetail(
  BuildContext context, {
  required MockBusinessId businessId,
  required MockCatalogItemId catalogItemId,
}) {
  context.pushNamed(
    RouteNames.catalogItemDetail,
    pathParameters: {
      'businessId': businessId.routeParam,
      'catalogItemId': catalogItemId.routeParam,
    },
  );
}
