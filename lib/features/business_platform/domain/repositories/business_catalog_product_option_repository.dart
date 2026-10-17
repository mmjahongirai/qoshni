import 'package:qoshni/features/business_platform/domain/business_catalog_option.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_option_group.dart';

enum BusinessCatalogOptionGroupSaveResult {
  success,
  notFound,
  invalidProduct,
  invalidInput,
  failure,
}

enum BusinessCatalogOptionSaveResult {
  success,
  notFound,
  invalidGroup,
  invalidProduct,
  invalidInput,
  failure,
}

enum BusinessCatalogOptionGroupArchiveResult {
  success,
  notFound,
  failure,
}

abstract class BusinessCatalogProductOptionRepository {
  String get businessScopeId;

  List<BusinessCatalogOptionGroup> groupsForProduct(
    String productId, {
    bool includeArchived = false,
  });

  BusinessCatalogOptionGroup? findGroupById(String groupId);

  BusinessCatalogOption? findOptionById(String optionId);

  BusinessCatalogOptionGroupSaveResult createGroup({
    required String productId,
    required BusinessCatalogOptionGroupInput input,
  });

  BusinessCatalogOptionGroupSaveResult updateGroup({
    required String groupId,
    required BusinessCatalogOptionGroupInput input,
  });

  BusinessCatalogOptionGroupArchiveResult archiveGroup(String groupId);

  BusinessCatalogOptionSaveResult createOption({
    required String groupId,
    required BusinessCatalogOptionInput input,
  });

  BusinessCatalogOptionSaveResult updateOption({
    required String optionId,
    required BusinessCatalogOptionInput input,
  });

  BusinessCatalogOptionSaveResult setOptionActive({
    required String optionId,
    required bool isActive,
  });
}
