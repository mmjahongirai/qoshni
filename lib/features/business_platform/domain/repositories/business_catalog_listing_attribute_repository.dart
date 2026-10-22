import 'package:qoshni/features/business_platform/domain/business_catalog_listing_attribute.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_listing_kind.dart';

enum BusinessCatalogListingAttributeSaveResult {
  success,
  notFound,
  invalidListing,
  duplicateKey,
  invalidInput,
  failure,
}

enum BusinessCatalogListingAttributeDeleteResult {
  success,
  notFound,
  failure,
}

abstract class BusinessCatalogListingAttributeRepository {
  String get businessScopeId;

  List<BusinessCatalogListingAttribute> attributesForListing({
    required BusinessCatalogListingKind listingKind,
    required String listingId,
  });

  BusinessCatalogListingAttribute? findById(String attributeId);

  BusinessCatalogListingAttributeSaveResult createAttribute({
    required BusinessCatalogListingKind listingKind,
    required String listingId,
    required BusinessCatalogListingAttributeInput input,
  });

  BusinessCatalogListingAttributeSaveResult updateAttribute({
    required String attributeId,
    required BusinessCatalogListingAttributeInput input,
  });

  BusinessCatalogListingAttributeDeleteResult deleteAttribute(String attributeId);
}
