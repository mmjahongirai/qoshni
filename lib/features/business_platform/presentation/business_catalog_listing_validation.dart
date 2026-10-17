import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';

bool catalogListingHasName(BusinessCatalogLocalizedFields localized) {
  return localized.trimmed().hasAnyName;
}
