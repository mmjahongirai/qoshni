import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';

String qoshniSearchStableIdForCatalogEntry(SearchCatalogEntry entry) {
  return switch (entry.kind) {
    SearchEntryKind.category => 'category:${entry.categoryId!.name}',
    SearchEntryKind.business => 'business:${entry.businessId!.routeParam}',
  };
}
