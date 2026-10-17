import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_status.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_listing_filters.dart';

void main() {
  test('parseCatalogListingStatus reads enum name', () {
    expect(
      parseCatalogListingStatus('draft'),
      BusinessCatalogListingStatus.draft,
    );
    expect(parseCatalogListingStatus(''), isNull);
  });

  test('catalogListingFiltersActive detects any filter', () {
    expect(
      catalogListingFiltersActive(
        query: '',
        categoryFilter: null,
        statusFilter: null,
      ),
      isFalse,
    );
    expect(
      catalogListingFiltersActive(
        query: 'x',
        categoryFilter: null,
        statusFilter: null,
      ),
      isTrue,
    );
  });
}
