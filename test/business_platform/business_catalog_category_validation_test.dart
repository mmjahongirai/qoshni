import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_category_status.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_localized_fields.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_category_validation.dart';

final _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

void main() {
  final parent = BusinessCatalogCategory(
    categoryId: 'parent',
    businessScopeId: 'scope',
    dataSource: BusinessCatalogCategoryDataSource.userSession,
    status: BusinessCatalogCategoryStatus.active,
    localized: const BusinessCatalogLocalizedFields(nameEn: 'Parent'),
    createdAt: _epoch,
    updatedAt: _epoch,
  );

  final child = BusinessCatalogCategory(
    categoryId: 'child',
    businessScopeId: 'scope',
    dataSource: BusinessCatalogCategoryDataSource.userSession,
    status: BusinessCatalogCategoryStatus.active,
    localized: const BusinessCatalogLocalizedFields(nameEn: 'Child'),
    parentCategoryId: 'parent',
    createdAt: _epoch,
    updatedAt: _epoch,
  );

  test('requires at least one language name', () {
    final issue = validateCategoryInput(
      input: const BusinessCatalogCategoryInput(
        localized: BusinessCatalogLocalizedFields(),
        status: BusinessCatalogCategoryStatus.draft,
      ),
      existing: const [],
    );
    expect(issue, BusinessCatalogCategoryValidationIssue.missingName);
  });

  test('detects duplicate names case-insensitively', () {
    final issue = validateCategoryInput(
      input: const BusinessCatalogCategoryInput(
        localized: BusinessCatalogLocalizedFields(nameEn: '  Fresh GOODS '),
        status: BusinessCatalogCategoryStatus.active,
      ),
      existing: [
        BusinessCatalogCategory(
          categoryId: 'existing',
          businessScopeId: 'scope',
          dataSource: BusinessCatalogCategoryDataSource.demoSeed,
          status: BusinessCatalogCategoryStatus.active,
          localized: const BusinessCatalogLocalizedFields(nameUz: 'fresh goods'),
          createdAt: _epoch,
          updatedAt: _epoch,
        ),
      ],
    );
    expect(issue, BusinessCatalogCategoryValidationIssue.duplicateName);
  });

  test('rejects self parent and circular hierarchy', () {
    expect(
      validateCategoryInput(
        input: const BusinessCatalogCategoryInput(
          localized: BusinessCatalogLocalizedFields(nameEn: 'X'),
          status: BusinessCatalogCategoryStatus.active,
          parentCategoryId: 'child',
        ),
        existing: [parent, child],
        editingCategoryId: 'child',
      ),
      BusinessCatalogCategoryValidationIssue.selfParent,
    );

    expect(
      validateCategoryInput(
        input: const BusinessCatalogCategoryInput(
          localized: BusinessCatalogLocalizedFields(nameEn: 'Parent updated'),
          status: BusinessCatalogCategoryStatus.active,
          parentCategoryId: 'child',
        ),
        existing: [parent, child],
        editingCategoryId: 'parent',
      ),
      BusinessCatalogCategoryValidationIssue.invalidParent,
    );
  });
}
