import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';

void main() {
  test('localized fields trim and detect any name', () {
    const raw = BusinessCatalogLocalizedFields(
      nameUz: '  ',
      nameRu: '  Non ',
      nameEn: '',
    );
    expect(raw.hasAnyName, isTrue);
    expect(raw.trimmed().nameRu, 'Non');
    expect(raw.nonEmptyNormalizedNames, ['non']);
  });
}
