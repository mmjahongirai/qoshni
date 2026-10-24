import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/search/application/qoshni_search_stable_id.dart';

SearchCatalogEntry? qoshniSearchCatalogEntryForStableId(
  List<SearchCatalogEntry> catalog,
  String stableId,
) {
  for (final entry in catalog) {
    if (qoshniSearchStableIdForCatalogEntry(entry) == stableId) {
      return entry;
    }
  }
  return null;
}
